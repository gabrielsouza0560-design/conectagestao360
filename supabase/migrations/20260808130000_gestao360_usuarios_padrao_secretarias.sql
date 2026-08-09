-- Cria um login padrão por secretaria (perfil secretario, senha conecta1234)
-- Pula silenciosamente qualquer e-mail que já exista.
do $$
declare
  v_tenant_id uuid;
  v_perfil_id uuid;
  v_auth_id uuid;
  v_registro record;
  v_pares text[][] := array[
    ['administracao@conectagestao.com.br', 'Administração'],
    ['agricultura@conectagestao.com.br', 'Agricultura'],
    ['assistencia.social@conectagestao.com.br', 'Assistência Social'],
    ['cultura@conectagestao.com.br', 'Cultura'],
    ['defesa.civil@conectagestao.com.br', 'Defesa Civil'],
    ['educacao@conectagestao.com.br', 'Educação'],
    ['esporte@conectagestao.com.br', 'Esporte'],
    ['financas@conectagestao.com.br', 'Finanças'],
    ['gabinete@conectagestao.com.br', 'Gabinete'],
    ['industria.comercio@conectagestao.com.br', 'Indústria e Comércio'],
    ['inovacao.tecnologia@conectagestao.com.br', 'Inovação e Tecnologia'],
    ['meio.ambiente@conectagestao.com.br', 'Meio Ambiente'],
    ['obras.servicos@conectagestao.com.br', 'Obras e Serviços Públicos'],
    ['planejamento@conectagestao.com.br', 'Planejamento'],
    ['saude@conectagestao.com.br', 'Saúde'],
    ['trabalho@conectagestao.com.br', 'TARBALHO'],
    ['turismo@conectagestao.com.br', 'Turismo']
  ];
  v_email text;
  v_secretaria_nome text;
  v_secretaria_id uuid;
begin
  select id into v_tenant_id from gestao360.tenants order by criado_em asc limit 1;
  select id into v_perfil_id from gestao360.perfis where nome = 'secretario';

  for i in 1..array_length(v_pares, 1) loop
    v_email := v_pares[i][1];
    v_secretaria_nome := v_pares[i][2];

    begin
      select id into v_secretaria_id from gestao360.secretarias where nome = v_secretaria_nome limit 1;
      if v_secretaria_id is null then
        raise notice 'Secretaria não encontrada: %, pulando %', v_secretaria_nome, v_email;
        continue;
      end if;

      if exists (select 1 from auth.users where email = v_email) then
        raise notice 'Já existe conta para %, pulando', v_email;
        continue;
      end if;

      v_auth_id := gen_random_uuid();

      insert into auth.users (
        id, instance_id, aud, role, email, encrypted_password,
        email_confirmed_at, created_at, updated_at,
        raw_app_meta_data, raw_user_meta_data,
        is_super_admin, confirmation_token, recovery_token,
        email_change_token_new, email_change, is_sso_user, is_anonymous
      ) values (
        v_auth_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
        v_email, crypt('conecta1234', gen_salt('bf')),
        now(), now(), now(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        jsonb_build_object('nome', v_secretaria_nome),
        false, '', '', '', '', false, false
      );

      insert into gestao360.usuarios (auth_user_id, tenant_id, nome, email, perfil_id, secretaria_id, status)
      values (v_auth_id, v_tenant_id, v_secretaria_nome, v_email, v_perfil_id, v_secretaria_id, 'ativo');

      raise notice 'Criado: %', v_email;
    exception when others then
      raise notice 'Falhou para % (%): %', v_email, v_secretaria_nome, SQLERRM;
    end;
  end loop;
end $$;
