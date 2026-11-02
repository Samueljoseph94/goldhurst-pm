-- An owner_viewer on one company sees only that company and cannot write.
\set ON_ERROR_STOP 1
begin;
create role app_user nologin; grant usage on schema public, auth to app_user;
grant select, insert, update, delete on all tables in schema public to app_user;
grant execute on all functions in schema public, auth to app_user;
insert into companies (id, name) values ('20000000-0000-0000-0000-000000000002', 'Hyjan (test)');
insert into properties (company_id, name) values ('20000000-0000-0000-0000-000000000002', '8 Victoria Mews');
insert into memberships values ('30000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000002', 'owner_viewer');
set local role app_user;
set local request.jwt.claim.sub = '30000000-0000-0000-0000-000000000003';
select 'visible properties' as check, string_agg(name, ', ') as result from properties;
select 'visible tenancies', count(*)::text from tenancies;
\set ON_ERROR_STOP 0
update properties set name = 'changed' where name = '8 Victoria Mews';
select 'write blocked', case when exists (select 1 from properties where name = 'changed') then 'FAIL' else 'PASS' end;
rollback;
