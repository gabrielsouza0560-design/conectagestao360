-- Obras: reaproveita a tabela de ações, igual foi feito com Festas
alter table gestao360.acoes
  add column if not exists eh_obra boolean not null default false,
  add column if not exists contratada text,
  add column if not exists numero_contrato text,
  add column if not exists valor_executado numeric(14,2),
  add column if not exists percentual_execucao integer,
  add column if not exists prazo_conclusao date;

-- Convênios: campos de vigência em cima de Captação de Recursos
alter table gestao360.oportunidades_recursos
  add column if not exists numero_convenio text,
  add column if not exists vigencia_inicio date,
  add column if not exists vigencia_fim date,
  add column if not exists contrapartida numeric(14,2);

-- Alertas automáticos de prazo (submissão e vigência de convênio) — 15/7/1 dias antes
create extension if not exists pg_cron;

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
end;
$$;

do $$
begin
  if exists (select 1 from cron.job where jobname = 'gestao360-alertas-prazo') then
    perform cron.unschedule('gestao360-alertas-prazo');
  end if;
end $$;

select cron.schedule('gestao360-alertas-prazo', '0 8 * * *', $$select gestao360.checar_alertas_prazo();$$);
