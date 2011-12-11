begin;
        create sequence users_id_seq start 1 increment 1 no cycle;
        create table users(
               id               integer not null default nextval('users_id_seq'),
               email            text not null,
               password_digest  text not null,
               admin            boolean not null default false,
               primary key(id)
        );
        create unique index users_lower_email_idx on users(lower(email));

        create sequence promo_codes_id_seq start 1 increment 1 no cycle;
        create table promo_codes(
               id               integer not null default nextval('promo_codes_id_seq'),
               code             varchar(8) not null,
               description      text not null,
               primary key(id)
        );
        create unique index promo_codes_code_idx on promo_codes(code);
commit;
