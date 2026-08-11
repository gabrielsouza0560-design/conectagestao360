-- Galeria: categoria + legenda nas mídias (evento_midias já é usado para fotos/vídeos
-- de qualquer ação, não só festas — a RLS não restringe por eh_evento)
alter table gestao360.evento_midias
  add column if not exists categoria text,
  add column if not exists legenda text;

notify pgrst, 'reload schema';
