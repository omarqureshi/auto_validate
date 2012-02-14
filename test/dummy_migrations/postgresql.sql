begin;
        create sequence users_id_seq start 1 increment 1 no cycle;
        create table users(
               id               integer not null default nextval('users_id_seq'),
               email            text not null,
               password_digest  text not null,
               admin            boolean not null default false,
               created_at       timestamp with time zone not null default now(),
               updated_at       timestamp with time zone not null default now(),
               primary key(id)
        );
        create unique index users_lower_email_idx on users(lower(email));

        create sequence promo_codes_id_seq start 1 increment 1 no cycle;
        create table promo_codes(
               id               integer not null default nextval('promo_codes_id_seq'),
               code             varchar(8) not null,
               description      text not null,
               created_at       timestamp with time zone not null default now(),
               updated_at       timestamp with time zone not null default now(),
               primary key(id)
        );
        create unique index promo_codes_code_idx on promo_codes(code);

        create sequence widget_requests_id_seq start 1 increment 1 no cycle;
        create table widget_requests(
               id               integer not null default nextval('widget_requests_id_seq'),
               user_id          integer not null references users(id),
               quantity         integer not null,
               created_at       timestamp with time zone not null default now(),
               updated_at       timestamp with time zone not null default now(),
               primary key(id)
        );

        create sequence tags_id_seq start 1 increment 1 no cycle;
        create table tags(
               id               integer not null default nextval('tags_id_seq'),
               name             varchar(60) not null,
               created_at       timestamp with time zone not null default now(),
               updated_at       timestamp with time zone not null default now(),
               primary key(id)
        );
        create unique index tags_name_idx on tags(name);

        create sequence taggings_id_seq start 1 increment 1 no cycle;
        create table taggings(
               id               integer not null default nextval('taggings_id_seq'),
               user_id          integer not null references users(id),
               tag_id           integer not null references tags(id),
               created_at       timestamp with time zone not null default now(),
               updated_at       timestamp with time zone not null default now(),
               primary key(id)
        );

        create unique index taggings_user_id_tag_id_idx on taggings(user_id, tag_id);
commit;
