-- Cria um login padrão por cargo restante (sem secretaria vinculada), senha conecta1234
-- Pula silenciosamente qualquer e-mail que já exista.
do $$
declare
  v_tenant_id uuid;
  v_perfil_id uuid;
  v_auth_id uuid;
  v_pares text[][] := array[
    ['prefeito@conectagestao.com.br', 'prefeito', 'Prefeito'],
    ['vice.prefeito@conectagestao.com.br', 'vice_prefeito', 'Vice-Prefeito'],
    ['comunicacao@conectagestao.com.br', 'comunicacao', 'Comunicação'],
    ['controladoria@conectagestao.com.br', 'controladoria', 'Controladoria'],
    ['diretor@conectagestao.com.br', 'diretor', 'Diretor'],
    ['coordenador@conectagestao.com.br', 'coordenador', 'Coordenador'],
    ['servidor@conectagestao.com.br', 'servidor', 'Servidor']
  ];
  v_email text;
  v_perfil_nome text;
  v_nome text;
begin
  select id into v_tenant_id from gestao360.tenants order by criado_em asc limit 1;

  for i in 1..array_length(v_pares, 1) loop
    v_email := v_pares[i][1];
    v_perfil_nome := v_pares[i][2];
    v_nome := v_pares[i][3];

    begin
      if exists (select 1 from auth.users where email = v_email) then
        raise notice 'Já existe conta para %, pulando', v_email;
        continue;
      end if;

      select id into v_perfil_id from gestao360.perfis where nome = v_perfil_nome;
      if v_perfil_id is null then
        raise notice 'Perfil não encontrado: %, pulando %', v_perfil_nome, v_email;
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
        jsonb_build_object('nome', v_nome),
        false, '', '', '', '', false, false
      );

      insert into gestao360.usuarios (auth_user_id, tenant_id, nome, email, perfil_id, secretaria_id, status)
      values (v_auth_id, v_tenant_id, v_nome, v_email, v_perfil_id, null, 'ativo');

      raise notice 'Criado: %', v_email;
    exception when others then
      raise notice 'Falhou para % (%): %', v_email, v_perfil_nome, SQLERRM;
    end;
  end loop;
end $$;
