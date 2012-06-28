begin;
        create table users(
               id               integer not null auto_increment,
               email            varchar(256) not null,
               password_digest  text not null,
               admin            boolean not null default false,
               created_at       datetime not null,
               updated_at       datetime not null,
               primary key(id)
        );
        create unique index users_email_idx on users(email);

        create table promo_codes(
               id               integer not null auto_increment,
               code             varchar(8) not null,
               description      text not null,
               created_at       datetime not null,
               updated_at       datetime not null,
               primary key(id)
        );
        create unique index promo_codes_code_idx on promo_codes(code);

        create table widget_requests(
               id               integer not null auto_increment,
               user_id          integer not null references users(id),
               quantity         integer not null,
               created_at       datetime not null,
               updated_at       datetime not null,
               primary key(id)
        );

        create table tags(
               id               integer not null auto_increment,
               name             varchar(60) not null,
               created_at       datetime not null,
               updated_at       datetime not null,
               primary key(id)
        );
        create unique index tags_name_idx on tags(name);

        create table taggings(
               id               integer not null auto_increment,
               user_id          integer not null references users(id),
               tag_id           integer not null references tags(id),
               created_at       datetime not null,
               updated_at       datetime not null,
               primary key(id)
        );

        create unique index taggings_user_id_tag_id_idx on taggings(user_id, tag_id);
commit;
