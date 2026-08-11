-- Captação de Recursos passa a ser visível no Portal Público (transparência de convênios/editais buscados)
drop policy if exists recursos_select_public on gestao360.oportunidades_recursos;
create policy recursos_select_public on gestao360.oportunidades_recursos for select to anon
  using (true);

grant select on gestao360.oportunidades_recursos to anon;

notify pgrst, 'reload schema';
