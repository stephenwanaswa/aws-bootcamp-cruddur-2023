-- this file was manually created
INSERT INTO public.users (display_name, email, handle, cognito_user_id)
VALUES
  ('Steve Wekesa','steveiwans@gmail.com' , 'steveiwans' ,'MOCK'),
  ('Papo Hapo','papohapo69@gmail.com' , 'papohapo' ,'MOCK'),
  ('Londo Mollari','lmollari@centari.com' ,'londo' ,'MOCK');

INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'steveiwans' LIMIT 1),
    'This was imported as seed data!',
    current_timestamp + interval '10 day'
  ),
  (
    (SELECT uuid from public.users WHERE users.handle = 'londo' LIMIT 1),
    'Another seed data!',
    current_timestamp + interval '10 day'
  );