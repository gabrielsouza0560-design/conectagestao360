-- Central de notificações deixa de avisar só sobre prazo de convênio.

-- 1) Novo usuário pendente avisa todo Admin Master
create or replace function gestao360.autocadastrar_usuario(p_nome text, p_perfil_nome text, p_secretaria_id uuid)
returns void
language plpgsql security definer set search_path = gestao360, public
as $$
declare
  v_perfil_id uuid;
  v_tenant_id uuid;
  u record;
begin
  select id into v_tenant_id from gestao360.tenants order by criado_em asc limit 1;
  select id into v_perfil_id from gestao360.perfis where nome = p_perfil_nome;
  if v_perfil_id is null then raise exception 'Cargo inválido'; end if;

  insert into gestao360.usuarios (auth_user_id, tenant_id, nome, email, perfil_id, secretaria_id, status)
  values (auth.uid(), v_tenant_id, p_nome, (select email from auth.users where id = auth.uid()), v_perfil_id, p_secretaria_id, 'pendente');

  for u in
    select us.id from gestao360.usuarios us
    join gestao360.perfis p on p.id = us.perfil_id
    where us.tenant_id = v_tenant_id and us.status = 'ativo' and p.nome = 'admin_master'
  loop
    insert into gestao360.notificacoes (usuario_id, titulo, corpo)
    values (u.id, 'Novo usuário aguardando aprovação', p_nome || ' se cadastrou e está pendente de aprovação.');
  end loop;
end;
$$;

-- 2) Nova manifestação (Sua Voz) avisa a secretaria destinatária (ou Admin Master, se for geral)
create or replace function gestao360.notificar_nova_manifestacao()
returns trigger
language plpgsql security definer set search_path = gestao360, public
as $$
declare
  u record;
  tipo_label text;
begin
  tipo_label := case new.tipo
    when 'sugestao' then 'Sugestão' when 'elogio' then 'Elogio' when 'critica' then 'Crítica'
    when 'reclamacao' then 'Reclamação' when 'pedido_melhoria' then 'Pedido de melhoria'
    when 'denuncia' then 'Denúncia' when 'solicitacao' then 'Solicitação' else new.tipo end;
  for u in
    select distinct us.id
    from gestao360.usuarios us
    join gestao360.perfis p on p.id = us.perfil_id
    where us.tenant_id = new.tenant_id and us.status = 'ativo'
      and (p.nome = 'admin_master' or (new.secretaria_id is not null and us.secretaria_id = new.secretaria_id))
  loop
    insert into gestao360.notificacoes (usuario_id, titulo, corpo)
    values (u.id, 'Nova manifestação recebida: ' || tipo_label, left(coalesce(new.descricao,''), 140));
  end loop;
  return new;
end;
$$;

drop trigger if exists trg_notificar_manifestacao on gestao360.manifestacoes;
create trigger trg_notificar_manifestacao
  after insert on gestao360.manifestacoes
  for each row execute function gestao360.notificar_nova_manifestacao();

-- 3) Alertas diários também para prazo de obra e festa com checklist incompleto
create or replace function gestao360.checar_alertas_prazo()
returns void
language plpgsql security definer set search_path = gestao360, public
as $$
declare
  r record;
  u record;
  dias int;
begin
  for r in
    select id, programa, secretaria_id, tenant_id, prazo_submissao as data_ref, 'submissao' as tipo_prazo
    from gestao360.oportunidades_recursos
    where prazo_submissao is not null
      and status not in ('aprovado','reprovado','concluido')
      and prazo_submissao - current_date in (15,7,1)
    union all
    select id, programa, secretaria_id, tenant_id, vigencia_fim as data_ref, 'vigencia'
    from gestao360.oportunidades_recursos
    where vigencia_fim is not null
      and vigencia_fim - current_date in (15,7,1)
  loop
    dias := r.data_ref - current_date;
    for u in
      select distinct us.id
      from gestao360.usuarios us
      join gestao360.perfis p on p.id = us.perfil_id
      where us.tenant_id = r.tenant_id and us.status = 'ativo'
        and (p.nome = 'admin_master' or (r.secretaria_id is not null and us.secretaria_id = r.secretaria_id))
    loop
      insert into gestao360.notificacoes (usuario_id, titulo, corpo)
      values (
        u.id,
        case when r.tipo_prazo = 'submissao' then 'Prazo de submissão se aproxima' else 'Convênio perto de vencer' end,
        r.programa || ' — faltam ' || dias || ' dia(s).'
      );
    end loop;
  end loop;

  for r in
    select id, titulo as programa, secretaria_id, tenant_id, prazo_conclusao as data_ref
    from gestao360.acoes
    where eh_obra = true and prazo_conclusao is not null
      and status not in ('concluido','cancelado')
      and prazo_conclusao - current_date in (15,7,1)
  loop
    dias := r.data_ref - current_date;
    for u in
      select distinct us.id
      from gestao360.usuarios us
      join gestao360.perfis p on p.id = us.perfil_id
      where us.tenant_id = r.tenant_id and us.status = 'ativo'
        and (p.nome = 'admin_master' or (r.secretaria_id is not null and us.secretaria_id = r.secretaria_id))
    loop
      insert into gestao360.notificacoes (usuario_id, titulo, corpo)
      values (u.id, 'Prazo de conclusão de obra se aproxima', r.programa || ' — faltam ' || dias || ' dia(s).');
    end loop;
  end loop;

  for r in
    select a.id, a.titulo as programa, a.secretaria_id, a.tenant_id, a.data as data_ref,
      coalesce(round(100.0 * count(*) filter (where ec.concluido) / nullif(count(ec.id),0)), 0) as pct
    from gestao360.acoes a
    left join gestao360.evento_checklist ec on ec.acao_id = a.id
    where a.eh_evento = true and a.data is not null and a.data - current_date in (7,1)
    group by a.id, a.titulo, a.secretaria_id, a.tenant_id, a.data
    having coalesce(round(100.0 * count(*) filter (where ec.concluido) / nullif(count(ec.id),0)), 0) < 100
  loop
    dias := r.data_ref - current_date;
    for u in
      select distinct us.id
      from gestao360.usuarios us
      join gestao360.perfis p on p.id = us.perfil_id
      where us.tenant_id = r.tenant_id and us.status = 'ativo'
        and (p.nome = 'admin_master' or (r.secretaria_id is not null and us.secretaria_id = r.secretaria_id))
    loop
      insert into gestao360.notificacoes (usuario_id, titulo, corpo)
      values (u.id, 'Festa com checklist incompleto', r.programa || ' — faltam ' || dias || ' dia(s), checklist ' || r.pct || '% pronto.');
    end loop;
  end loop;
end;
$$;
