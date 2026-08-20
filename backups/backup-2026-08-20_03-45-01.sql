--
-- PostgreSQL database dump
--

\restrict CrUbwIllYU471bJ3DuriosWA1cCOptgCZ2FzfpbePg6vuDnvfZeDc7dzRkBAZL7

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.11 (Ubuntu 17.11-1.pgdg24.04+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA extensions;


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql;


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql_public;


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgbouncer;


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA realtime;


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA storage;


--
-- Name: supabase_migrations; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA supabase_migrations;


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA vault;


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


--
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


--
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


--
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in',
    'like',
    'ilike',
    'is',
    'match',
    'imatch',
    'isdistinct'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text,
	negate boolean
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: -
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
begin
    if not exists (
        select 1
        from pg_event_trigger_ddl_commands() ev
        join pg_catalog.pg_extension e on ev.objid = e.oid
        where e.extname = 'pg_graphql'
    ) then
        return;
    end if;

    drop function if exists graphql_public.graphql;
    create or replace function graphql_public.graphql(
        "operationName" text default null,
        query text default null,
        variables jsonb default null,
        extensions jsonb default null
    )
        returns jsonb
        language sql
    as $$
        select graphql.resolve(
            query := query,
            variables := coalesce(variables, '{}'),
            "operationName" := "operationName",
            extensions := extensions
        );
    $$;

    -- Attach the wrapper to the extension so DROP EXTENSION cascades to it,
    -- which in turn triggers set_graphql_placeholder to reinstall the "not enabled" stub.
    alter extension pg_graphql add function graphql_public.graphql(text, text, jsonb, jsonb);

    grant usage on schema graphql to postgres, anon, authenticated, service_role;
    grant execute on function graphql.resolve to postgres, anon, authenticated, service_role;
    grant usage on schema graphql to postgres with grant option;
    grant usage on schema graphql_public to postgres with grant option;
end;
$_$;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: graphql(text, text, jsonb, jsonb); Type: FUNCTION; Schema: graphql_public; Owner: -
--

CREATE FUNCTION graphql_public.graphql("operationName" text DEFAULT NULL::text, query text DEFAULT NULL::text, variables jsonb DEFAULT NULL::jsonb, extensions jsonb DEFAULT NULL::jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $_$
  BEGIN
      RAISE DEBUG 'PgBouncer auth request: %', p_usename;

      RETURN QUERY
      SELECT
          rolname::text,
          CASE WHEN rolvaliduntil < now()
              THEN null
              ELSE rolpassword::text
          END
      FROM pg_authid
      WHERE rolname=$1 and rolcanlogin;
  END;
  $_$;


--
-- Name: check_comment_rate(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_comment_rate() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  recent int;
begin
  if new.author_user_id is null then
    return new;
  end if;

  select count(*) into recent
  from public.comments
  where author_user_id = new.author_user_id
    and created_at > now() - interval '1 hour';

  if recent >= 40 then
    raise exception 'Slow down — you can post up to 40 comments per hour.'
      using errcode = 'P0001';
  end if;

  return new;
end;
$$;


--
-- Name: check_diary_rate(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_diary_rate() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  recent int;
begin
  select count(*) into recent
  from public.diary_entries
  where author_user_id = new.author_user_id
    and created_at > now() - interval '1 hour';

  if recent >= 50 then
    raise exception 'Slow down — up to 50 diary entries per hour.'
      using errcode = 'P0001';
  end if;

  return new;
end;
$$;


--
-- Name: check_entry_rate(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_entry_rate() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  recent int;
begin
  -- Anonymous/guest signers can't be rate-limited by user id; skip them here.
  -- (They're already limited by the pending-approval requirement.)
  if new.signer_user_id is null then
    return new;
  end if;

  select count(*) into recent
  from public.entries
  where signer_user_id = new.signer_user_id
    and created_at > now() - interval '1 hour';

  if recent >= 20 then
    raise exception 'Slow down — you can write up to 20 entries per hour. Try again shortly.'
      using errcode = 'P0001';
  end if;

  return new;
end;
$$;


--
-- Name: check_event_entry_rate(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_event_entry_rate() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  recent int;
begin
  if new.author_user_id is null then
    return new;
  end if;

  select count(*) into recent
  from public.event_entries
  where author_user_id = new.author_user_id
    and created_at > now() - interval '1 hour';

  if recent >= 30 then
    raise exception 'Slow down — you can post up to 30 times per hour.'
      using errcode = 'P0001';
  end if;

  return new;
end;
$$;


--
-- Name: check_event_rate(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_event_rate() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  recent int;
begin
  select count(*) into recent
  from public.events
  where owner_user_id = new.owner_user_id
    and created_at > now() - interval '24 hours';

  if recent >= 10 then
    raise exception 'You can create up to 10 events per day.'
      using errcode = 'P0001';
  end if;

  return new;
end;
$$;


--
-- Name: check_guest_rate(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_guest_rate() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  recent int;
begin
  if new.user_id is null then
    return new;
  end if;

  select count(*) into recent
  from public.event_guests
  where user_id = new.user_id
    and created_at > now() - interval '1 hour';

  if recent >= 30 then
    raise exception 'Slow down — too many event requests. Try again later.'
      using errcode = 'P0001';
  end if;

  return new;
end;
$$;


--
-- Name: is_circle_member(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_circle_member(cid uuid) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$ select exists (select 1 from circle_members
                  where circle_id = cid and user_id = auth.uid()); $$;


--
-- Name: is_event_member(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_event_member(eid uuid) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  select exists(
    select 1 from public.events e
    where e.id = eid and e.owner_user_id = auth.uid()
  ) or exists(
    select 1 from public.event_guests g
    where g.event_id = eid and g.user_id = auth.uid() and g.status = 'joined'
  );
$$;


--
-- Name: mark_conversation_read(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mark_conversation_read(conv uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  update public.conversations
     set requester_last_read_at = now()
   where id = conv and owns_profile(requester_profile_id);

  update public.conversations
     set recipient_last_read_at = now()
   where id = conv and owns_profile(recipient_profile_id);
end;
$$;


--
-- Name: owns_profile(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.owns_profile(pid uuid) RETURNS boolean
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  select exists (select 1 from public.profiles where id = pid and user_id = auth.uid());
$$;


--
-- Name: recent_count(text, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.recent_count(tbl text, user_col text, minutes integer) RETURNS integer
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $_$
declare
  n int;
begin
  execute format(
    'select count(*) from public.%I where %I = $1 and created_at > now() - ($2 || '' minutes'')::interval',
    tbl, user_col
  ) into n using auth.uid(), minutes;
  return coalesce(n, 0);
end;
$_$;


--
-- Name: username_available(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.username_available(candidate text) RETURNS boolean
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  select not exists (select 1 from public.profiles where username = lower(candidate));
$$;


--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
    -- Regclass of the table e.g. public.notes
    entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

    -- I, U, D, T: insert, update ...
    action realtime.action = (
        case wal ->> 'action'
            when 'I' then 'INSERT'
            when 'U' then 'UPDATE'
            when 'D' then 'DELETE'
            else 'ERROR'
        end
    );

    -- Is row level security enabled for the table
    is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

    subscriptions realtime.subscription[] = array_agg(subs)
        from
            realtime.subscription subs
        where
            subs.entity = entity_
            -- Filter by action early - only get subscriptions interested in this action
            -- action_filter column can be: '*' (all), 'INSERT', 'UPDATE', or 'DELETE'
            and (subs.action_filter = '*' or subs.action_filter = action::text);

    -- Subscription vars
    working_role regrole;
    working_selected_columns text[];
    claimed_role regrole;
    claims jsonb;

    subscription_id uuid;
    subscription_has_access bool;
    visible_to_subscription_ids uuid[] = '{}';

    -- structured info for wal's columns
    columns realtime.wal_column[];
    -- previous identity values for update/delete
    old_columns realtime.wal_column[];

    error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

    -- Primary jsonb output for record
    output jsonb;

    -- Loop record for iterating unique roles (outer loop)
    role_record record;
    -- Loop record for iterating unique selected_columns within a role (inner loop)
    cols_record record;
    -- Subscription ids visible at the role level (before fanning out by selected_columns)
    visible_role_sub_ids uuid[] = '{}';

begin
    perform set_config('role', null, true);

    columns =
        array_agg(
            (
                x->>'name',
                x->>'type',
                x->>'typeoid',
                realtime.cast(
                    (x->'value') #>> '{}',
                    coalesce(
                        (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                        (x->>'type')::regtype
                    )
                ),
                (pks ->> 'name') is not null,
                true
            )::realtime.wal_column
        )
        from
            jsonb_array_elements(wal -> 'columns') x
            left join jsonb_array_elements(wal -> 'pk') pks
                on (x ->> 'name') = (pks ->> 'name');

    old_columns =
        array_agg(
            (
                x->>'name',
                x->>'type',
                x->>'typeoid',
                realtime.cast(
                    (x->'value') #>> '{}',
                    coalesce(
                        (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                        (x->>'type')::regtype
                    )
                ),
                (pks ->> 'name') is not null,
                true
            )::realtime.wal_column
        )
        from
            jsonb_array_elements(wal -> 'identity') x
            left join jsonb_array_elements(wal -> 'pk') pks
                on (x ->> 'name') = (pks ->> 'name');

    for role_record in
        select claims_role
        from (select distinct claims_role from unnest(subscriptions)) t
        order by claims_role::text
    loop
        working_role := role_record.claims_role;

        -- Update `is_selectable` for columns and old_columns (once per role)
        columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(columns) c;

        old_columns =
                array_agg(
                    (
                        c.name,
                        c.type_name,
                        c.type_oid,
                        c.value,
                        c.is_pkey,
                        pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                    )::realtime.wal_column
                )
                from
                    unnest(old_columns) c;

        if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
            -- Fan out 400 error per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;
                return next (
                    jsonb_build_object(
                        'schema', wal ->> 'schema',
                        'table', wal ->> 'table',
                        'type', action
                    ),
                    is_rls_enabled,
                    (select array_agg(s.subscription_id) from unnest(subscriptions) as s where s.claims_role = working_role and (s.selected_columns is not distinct from working_selected_columns)),
                    array['Error 400: Bad Request, no primary key']
                )::realtime.wal_rls;
            end loop;

        -- The claims role does not have SELECT permission to the primary key of entity
        elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
            -- Fan out 401 error per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;
                return next (
                    jsonb_build_object(
                        'schema', wal ->> 'schema',
                        'table', wal ->> 'table',
                        'type', action
                    ),
                    is_rls_enabled,
                    (select array_agg(s.subscription_id) from unnest(subscriptions) as s where s.claims_role = working_role and (s.selected_columns is not distinct from working_selected_columns)),
                    array['Error 401: Unauthorized']
                )::realtime.wal_rls;
            end loop;

        else
            -- Create the prepared statement (once per role)
            if is_rls_enabled and action <> 'DELETE' then
                if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                    deallocate walrus_rls_stmt;
                end if;
                execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
            end if;

            -- Collect all visible subscription IDs for this role (filter check + RLS check)
            visible_role_sub_ids = '{}';

            for subscription_id, claims in (
                    select
                        subs.subscription_id,
                        subs.claims
                    from
                        unnest(subscriptions) subs
                    where
                        subs.entity = entity_
                        and subs.claims_role = working_role
                        and (
                            realtime.is_visible_through_filters(columns, subs.filters)
                            or (
                              action = 'DELETE'
                              and realtime.is_visible_through_filters(old_columns, subs.filters)
                            )
                        )
            ) loop

                if not is_rls_enabled or action = 'DELETE' then
                    visible_role_sub_ids = visible_role_sub_ids || subscription_id;
                else
                    -- Check if RLS allows the role to see the record
                    perform
                        -- Trim leading and trailing quotes from working_role because set_config
                        -- doesn't recognize the role as valid if they are included
                        set_config('role', trim(both '"' from working_role::text), true),
                        set_config('request.jwt.claims', claims::text, true);

                    execute 'execute walrus_rls_stmt' into subscription_has_access;

                    -- Reset the role on every FOR..LOOP batch execution.
                    -- The first batch of 10 rows is pre-fetched using the current connection role (PG internal behaviour)
                    -- then we have to reset it again otherwise it would use the role defined in the `set_config` above
                    -- to fetch the remaining rows when rows>10, which could be a user-defined role that lacks execution grants.
                    -- The flow is:
                    --   1. run batch with conn role
                    --   2. set_config working_role
                    --   3. execute walrus
                    --   4. reset role (revert)
                    --   5. repeat
                    perform set_config('role', null, true);

                    if subscription_has_access then
                        visible_role_sub_ids = visible_role_sub_ids || subscription_id;
                    end if;
                end if;
            end loop;

            perform set_config('role', null, true);

            -- Inner loop: per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;

                output = jsonb_build_object(
                    'schema', wal ->> 'schema',
                    'table', wal ->> 'table',
                    'type', action,
                    'commit_timestamp', to_char(
                        ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                        'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
                    ),
                    'columns', (
                        select
                            jsonb_agg(
                                jsonb_build_object(
                                    'name', pa.attname,
                                    'type', pt.typname
                                )
                                order by pa.attnum asc
                            )
                        from
                            pg_attribute pa
                            join pg_type pt
                                on pa.atttypid = pt.oid
                            left join (
                                select unnest(conkey) as pkey_attnum
                                from pg_constraint
                                where conrelid = entity_ and contype = 'p'
                            ) pk on pk.pkey_attnum = pa.attnum
                        where
                            attrelid = entity_
                            and attnum > 0
                            and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
                            and (working_selected_columns is null or pa.attname = any(working_selected_columns) or pk.pkey_attnum is not null)
                    )
                )
                -- Add "record" key for insert and update
                || case
                    when action in ('INSERT', 'UPDATE') then
                        jsonb_build_object(
                            'record',
                            (
                                select
                                    jsonb_object_agg(
                                        -- if unchanged toast, get column name and value from old record
                                        coalesce((c).name, (oc).name),
                                        case
                                            when (c).name is null then (oc).value
                                            else (c).value
                                        end
                                    )
                                from
                                    unnest(columns) c
                                    full outer join unnest(old_columns) oc
                                        on (c).name = (oc).name
                                where
                                    coalesce((c).is_selectable, (oc).is_selectable)
                                    and (working_selected_columns is null or coalesce((c).name, (oc).name) = any(working_selected_columns) or coalesce((c).is_pkey, (oc).is_pkey))
                                    and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            )
                        )
                    else '{}'::jsonb
                end
                -- Add "old_record" key for update and delete
                || case
                    when action = 'UPDATE' then
                        jsonb_build_object(
                                'old_record',
                                (
                                    select jsonb_object_agg((c).name, (c).value)
                                    from unnest(old_columns) c
                                    where
                                        (c).is_selectable
                                        and (working_selected_columns is null or (c).name = any(working_selected_columns) or (c).is_pkey)
                                        and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                                )
                            )
                    when action = 'DELETE' then
                        jsonb_build_object(
                            'old_record',
                            (
                                select jsonb_object_agg((c).name, (c).value)
                                from unnest(old_columns) c
                                where
                                    (c).is_selectable
                                    and (working_selected_columns is null or (c).name = any(working_selected_columns) or (c).is_pkey)
                                    and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                                    and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                            )
                        )
                    else '{}'::jsonb
                end;

                -- Filter visible_role_sub_ids to those matching the current selected_columns group
                visible_to_subscription_ids = coalesce(
                    (
                        select array_agg(s.subscription_id)
                        from unnest(subscriptions) s
                        where s.claims_role = working_role
                          and (s.selected_columns is not distinct from working_selected_columns)
                          and s.subscription_id = any(visible_role_sub_ids)
                    ),
                    '{}'::uuid[]
                );

                return next (
                    output,
                    is_rls_enabled,
                    visible_to_subscription_ids,
                    case
                        when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                        else '{}'
                    end
                )::realtime.wal_rls;
            end loop;

        end if;
    end loop;

    perform set_config('role', null, true);
end;
$$;


--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  res jsonb;
begin
  if type_::text = 'bytea' then
    return to_jsonb(val);
  end if;
  execute format('select to_jsonb(%L::'|| type_::text || ')', val) into res;
  return res;
end
$$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
/*
Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
*/
declare
    op_symbol text = (
        case
            when op = 'eq' then '='
            when op = 'neq' then '!='
            when op = 'lt' then '<'
            when op = 'lte' then '<='
            when op = 'gt' then '>'
            when op = 'gte' then '>='
            when op = 'in' then '= any'
            else 'UNKNOWN OP'
        end
    );
    res boolean;
begin
    execute format(
        'select %L::'|| type_::text || ' ' || op_symbol
        || ' ( %L::'
        || (
            case
                when op = 'in' then type_::text || '[]'
                else type_::text end
        )
        || ')', val_1, val_2) into res;
    return res;
end;
$$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text, negate boolean) RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $$
declare
    op_symbol text;
    res boolean;
begin
    -- IS DISTINCT FROM / IS NOT DISTINCT FROM: infix, both sides typed literals
    if op = 'isdistinct' then
        execute format(
            'select %L::%s %s %L::%s',
            val_1,
            type_::text,
            case when negate then 'IS NOT DISTINCT FROM' else 'IS DISTINCT FROM' end,
            val_2,
            type_::text
        ) into res;
        return res;
    end if;

    -- IS requires a keyword RHS (NULL, TRUE, FALSE, UNKNOWN), not a typed literal
    if op = 'is' then
        if val_2 not in ('null', 'true', 'false', 'unknown') then
            raise exception 'invalid value for is filter: must be null, true, false, or unknown';
        end if;
        execute format(
            'select %L::%s %s %s',
            val_1,
            type_::text,
            case when negate then 'IS NOT' else 'IS' end,
            upper(val_2)
        ) into res;
        return res;
    end if;

    op_symbol = case
        when op = 'eq'    then '='
        when op = 'neq'   then '!='
        when op = 'lt'    then '<'
        when op = 'lte'   then '<='
        when op = 'gt'    then '>'
        when op = 'gte'   then '>='
        when op = 'in'    then '= any'
        when op = 'like'   then 'LIKE'
        when op = 'ilike'  then 'ILIKE'
        when op = 'match'  then '~'
        when op = 'imatch' then '~*'
        else null
    end;

    if op_symbol is null then
        raise exception 'unsupported equality operator: %', op::text;
    end if;

    execute format(
        'select %L::%s %s (%L::%s)',
        val_1,
        type_::text,
        op_symbol,
        val_2,
        case when op = 'in' then type_::text || '[]' else type_::text end
    ) into res;

    return case when negate then not res else res end;
end;
$$;


--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
    select
        filters is null
        or array_length(filters, 1) is null
        or coalesce(
            count(col.name) = count(1)
            and sum(
                realtime.check_equality_op(
                    op:=f.op,
                    type_:=coalesce(col.type_oid::regtype, col.type_name::regtype),
                    val_1:=col.value #>> '{}',
                    val_2:=f.value,
                    negate:=coalesce(f.negate, false)
                )::int
            ) filter (where col.name is not null) = count(col.name),
            false
        )
    from
        unnest(filters) f
        left join unnest(columns) col
            on f.column_name = col.name;
$$;


--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS TABLE(wal jsonb, is_rls_enabled boolean, subscription_ids uuid[], errors text[], slot_changes_count bigint)
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
  WITH pub AS (
    SELECT
      concat_ws(
        ',',
        CASE WHEN bool_or(pubinsert) THEN 'insert' ELSE NULL END,
        CASE WHEN bool_or(pubupdate) THEN 'update' ELSE NULL END,
        CASE WHEN bool_or(pubdelete) THEN 'delete' ELSE NULL END
      ) AS w2j_actions,
      coalesce(
        string_agg(
          realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
          ','
        ) filter (WHERE ppt.tablename IS NOT NULL),
        ''
      ) AS w2j_add_tables
    FROM pg_publication pp
    LEFT JOIN pg_publication_tables ppt ON pp.pubname = ppt.pubname
    WHERE pp.pubname = publication
    GROUP BY pp.pubname
    LIMIT 1
  ),
  -- MATERIALIZED ensures pg_logical_slot_get_changes is called exactly once
  w2j AS MATERIALIZED (
    SELECT x.*, pub.w2j_add_tables
    FROM pub,
         pg_logical_slot_get_changes(
           slot_name, null, max_changes,
           'include-pk', 'true',
           'include-transaction', 'false',
           'include-timestamp', 'true',
           'include-type-oids', 'true',
           'format-version', '2',
           'actions', pub.w2j_actions,
           'add-tables', pub.w2j_add_tables
         ) x
  ),
  slot_count AS (
    SELECT count(*)::bigint AS cnt
    FROM w2j
    WHERE w2j.w2j_add_tables <> ''
  ),
  rls_filtered AS (
    SELECT xyz.wal, xyz.is_rls_enabled, xyz.subscription_ids, xyz.errors
    FROM w2j,
         realtime.apply_rls(
           wal := w2j.data::jsonb,
           max_record_bytes := max_record_bytes
         ) xyz(wal, is_rls_enabled, subscription_ids, errors)
    WHERE w2j.w2j_add_tables <> ''
      AND xyz.subscription_ids[1] IS NOT NULL
  )
  SELECT rf.wal, rf.is_rls_enabled, rf.subscription_ids, rf.errors, sc.cnt
  FROM rls_filtered rf, slot_count sc

  UNION ALL

  SELECT null, null, null, null, sc.cnt
  FROM slot_count sc
  WHERE NOT EXISTS (SELECT 1 FROM rls_filtered)
$$;


--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
  SELECT
    realtime.wal2json_escape_identifier(nsp.nspname::text)
    || '.'
    || realtime.wal2json_escape_identifier(pc.relname::text)
  FROM pg_class pc
  JOIN pg_namespace nsp ON pc.relnamespace = nsp.oid
  WHERE pc.oid = entity
$$;


--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING 'WarnSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: send_binary(bytea, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send_binary(payload bytea, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
BEGIN
  BEGIN
    generated_id := gen_random_uuid();

    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    INSERT INTO realtime.messages (id, binary_payload, event, topic, private, extension)
    VALUES (generated_id, payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING 'WarnSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    col_names text[] = coalesce(
            array_agg(a.attname order by a.attnum),
            '{}'::text[]
        )
        from
            pg_catalog.pg_attribute a
        where
            a.attrelid = new.entity
            and a.attnum > 0
            and not a.attisdropped
            and pg_catalog.has_column_privilege(
                (new.claims ->> 'role'),
                a.attrelid,
                a.attnum,
                'SELECT'
            );
    filter realtime.user_defined_filter;
    col_type regtype;
    in_val jsonb;
    selected_col text;
begin
    for filter in select * from unnest(new.filters) loop
        if not filter.column_name = any(col_names) then
            raise exception 'invalid column for filter %', filter.column_name;
        end if;

        col_type = (
            select atttypid::regtype
            from pg_catalog.pg_attribute
            where attrelid = new.entity
                  and attname = filter.column_name
        );
        if col_type is null then
            raise exception 'failed to lookup type for column %', filter.column_name;
        end if;

        if filter.op = 'in'::realtime.equality_op then
            in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
            if coalesce(jsonb_array_length(in_val), 0) > 100 then
                raise exception 'too many values for `in` filter. Maximum 100';
            end if;
        elsif filter.op = 'is'::realtime.equality_op then
            -- `is` requires a keyword RHS rather than a typed literal
            if filter.value not in ('null', 'true', 'false', 'unknown') then
                raise exception 'invalid value for is filter: must be null, true, false, or unknown';
            end if;
            -- IS NULL works for any type, but IS TRUE/FALSE/UNKNOWN require a boolean
            -- operand. Reject the non-null keywords on non-boolean columns here so they
            -- don't abort apply_rls at WAL time.
            if filter.value <> 'null' and col_type <> 'boolean'::regtype then
                raise exception 'is % filter requires a boolean column, got %', filter.value, col_type::text;
            end if;
        elsif filter.op in ('like'::realtime.equality_op, 'ilike'::realtime.equality_op) then
            -- like/ilike apply the text pattern operator (~~); reject column types that
            -- have no such operator instead of failing at WAL time
            if not exists (
                select 1 from pg_catalog.pg_operator
                where oprname = '~~' and oprleft = col_type
            ) then
                raise exception 'operator % requires a text-compatible column type, got %', filter.op::text, col_type::text;
            end if;
        elsif filter.op in ('match'::realtime.equality_op, 'imatch'::realtime.equality_op) then
            -- match/imatch apply the regex operators ~ / ~*; reject column types that have
            -- no such operator (e.g. integer) instead of failing at WAL time, mirroring the
            -- like/ilike guard above.
            if not exists (
                select 1 from pg_catalog.pg_operator
                where oprname = case when filter.op = 'imatch'::realtime.equality_op then '~*' else '~' end
                  and oprleft = col_type
                  and oprright = col_type
                  and oprresult = 'boolean'::regtype
            ) then
                raise exception 'operator % requires a text-compatible column type, got %', filter.op::text, col_type::text;
            end if;
            -- validate the regex eagerly so a bad pattern is rejected here, not inside
            -- apply_rls where it would abort the WAL stream for the entity
            begin
                perform '' ~ filter.value;
            exception when others then
                raise exception 'invalid regular expression for % filter: %', filter.op::text, sqlerrm;
            end;
        else
            -- eq/neq/lt/lte/gt/gte: value must be coercable to the type
            perform realtime.cast(filter.value, col_type);
        end if;
    end loop;

    if new.selected_columns is not null then
        for selected_col in select * from unnest(new.selected_columns) loop
            if not selected_col = any(col_names) then
                raise exception 'invalid column for select %', selected_col;
            end if;
        end loop;
    end if;

    -- Apply consistent order to filters so the unique constraint can't be tricked by a
    -- different filter order. negate is part of the sort key.
    new.filters = coalesce(
        array_agg(f order by f.column_name, f.op, f.value, f.negate),
        '{}'
    ) from unnest(new.filters) f;

    new.selected_columns = (
        select array_agg(c order by c)
        from unnest(new.selected_columns) c
    );

    return new;
end;
$$;


--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: wal2json_escape_identifier(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.wal2json_escape_identifier(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
  -- Prefix `\`, `,`, `.`, and any whitespace with `\`
  SELECT regexp_replace(name, '([\\,.[:space:]])', '\\\1', 'g')
$$;


--
-- Name: allow_any_operation(text[]); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.allow_any_operation(expected_operations text[]) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT CASE
      WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
      ELSE raw_operation
    END AS current_operation
    FROM current_operation
  )
  SELECT EXISTS (
    SELECT 1
    FROM normalized n
    CROSS JOIN LATERAL unnest(expected_operations) AS expected_operation
    WHERE expected_operation IS NOT NULL
      AND expected_operation <> ''
      AND n.current_operation = CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END
  );
$$;


--
-- Name: allow_only_operation(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.allow_only_operation(expected_operation text) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT
      CASE
        WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
        ELSE raw_operation
      END AS current_operation,
      CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END AS requested_operation
    FROM current_operation
  )
  SELECT CASE
    WHEN requested_operation IS NULL OR requested_operation = '' THEN FALSE
    ELSE COALESCE(current_operation = requested_operation, FALSE)
  END
  FROM normalized;
$$;


--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Get the last path segment (the actual filename)
    SELECT _parts[array_length(_parts, 1)] INTO _filename;
    -- Extract extension: reverse, split on '.', then reverse again
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    RETURN _parts[array_length(_parts, 1)];
END
$$;


--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


--
-- Name: get_common_prefix(text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_common_prefix(p_key text, p_prefix text, p_delimiter text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
SELECT CASE
    WHEN position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)) > 0
    THEN left(p_key, length(p_prefix) + position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)))
    ELSE NULL
END;
$$;


--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint)::bigint as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_objects_with_delimiter(_bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;

    -- Configuration
    v_is_asc BOOLEAN;
    v_prefix TEXT;
    v_start TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_is_asc := lower(coalesce(sort_order, 'asc')) = 'asc';
    v_prefix := coalesce(prefix_param, '');
    v_start := CASE WHEN coalesce(next_token, '') <> '' THEN next_token ELSE coalesce(start_after, '') END;
    v_file_batch_size := LEAST(GREATEST(max_keys * 2, 100), 1000);

    -- Calculate upper bound for prefix filtering (bytewise, using COLLATE "C")
    IF v_prefix = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix, 1) = delimiter_param THEN
        v_upper_bound := left(v_prefix, -1) || chr(ascii(delimiter_param) + 1);
    ELSE
        v_upper_bound := left(v_prefix, -1) || chr(ascii(right(v_prefix, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'AND o.name COLLATE "C" < $3 ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'AND o.name COLLATE "C" >= $3 ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- ========================================================================
    -- SEEK INITIALIZATION: Determine starting position
    -- ========================================================================
    IF v_start = '' THEN
        IF v_is_asc THEN
            v_next_seek := v_prefix;
        ELSE
            -- DESC without cursor: find the last item in range
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;

            IF v_next_seek IS NOT NULL THEN
                v_next_seek := v_next_seek || delimiter_param;
            ELSE
                RETURN;
            END IF;
        END IF;
    ELSE
        -- Cursor provided: determine if it refers to a folder or leaf
        IF EXISTS (
            SELECT 1 FROM storage.objects o
            WHERE o.bucket_id = _bucket_id
              AND o.name COLLATE "C" LIKE v_start || delimiter_param || '%'
            LIMIT 1
        ) THEN
            -- Cursor refers to a folder
            IF v_is_asc THEN
                v_next_seek := v_start || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_start || delimiter_param;
            END IF;
        ELSE
            -- Cursor refers to a leaf object
            IF v_is_asc THEN
                v_next_seek := v_start || delimiter_param;
            ELSE
                v_next_seek := v_start;
            END IF;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= max_keys;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(v_peek_name, v_prefix, delimiter_param);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Emit and skip to next folder (no heap access needed)
            name := rtrim(v_common_prefix, delimiter_param);
            id := NULL;
            updated_at := NULL;
            created_at := NULL;
            last_accessed_at := NULL;
            metadata := NULL;
            RETURN NEXT;
            v_count := v_count + 1;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := left(v_common_prefix, -1) || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_common_prefix;
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query USING _bucket_id, v_next_seek,
                CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix) ELSE v_prefix END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(v_current.name, v_prefix, delimiter_param);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := v_current.name;
                    EXIT;
                END IF;

                -- Emit file
                name := v_current.name;
                id := v_current.id;
                updated_at := v_current.updated_at;
                created_at := v_current.created_at;
                last_accessed_at := v_current.last_accessed_at;
                metadata := v_current.metadata;
                RETURN NEXT;
                v_count := v_count + 1;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := v_current.name || delimiter_param;
                ELSE
                    v_next_seek := v_current.name;
                END IF;

                EXIT WHEN v_count >= max_keys;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: protect_delete(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.protect_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if storage.allow_delete_query is set to 'true'
    IF COALESCE(current_setting('storage.allow_delete_query', true), 'false') != 'true' THEN
        RAISE EXCEPTION 'Direct deletion from storage tables is not allowed. Use the Storage API instead.'
            USING HINT = 'This prevents accidental data loss from orphaned objects.',
                  ERRCODE = '42501';
    END IF;
    RETURN NULL;
END;
$$;


--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;
    v_delimiter CONSTANT TEXT := '/';

    -- Configuration
    v_limit INT;
    v_prefix TEXT;
    v_prefix_lower TEXT;
    v_is_asc BOOLEAN;
    v_order_by TEXT;
    v_sort_order TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;
    v_skipped INT := 0;
BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_limit := LEAST(coalesce(limits, 100), 1500);
    v_prefix := coalesce(prefix, '') || coalesce(search, '');
    v_prefix_lower := lower(v_prefix);
    v_is_asc := lower(coalesce(sortorder, 'asc')) = 'asc';
    v_file_batch_size := LEAST(GREATEST(v_limit * 2, 100), 1000);

    -- Validate sort column
    CASE lower(coalesce(sortcolumn, 'name'))
        WHEN 'name' THEN v_order_by := 'name';
        WHEN 'updated_at' THEN v_order_by := 'updated_at';
        WHEN 'created_at' THEN v_order_by := 'created_at';
        WHEN 'last_accessed_at' THEN v_order_by := 'last_accessed_at';
        ELSE v_order_by := 'name';
    END CASE;

    v_sort_order := CASE WHEN v_is_asc THEN 'asc' ELSE 'desc' END;

    -- ========================================================================
    -- NON-NAME SORTING: Use path_tokens approach (unchanged)
    -- ========================================================================
    IF v_order_by != 'name' THEN
        RETURN QUERY EXECUTE format(
            $sql$
            WITH folders AS (
                SELECT path_tokens[$1] AS folder
                FROM storage.objects
                WHERE objects.name ILIKE $2 || '%%'
                  AND bucket_id = $3
                  AND array_length(objects.path_tokens, 1) <> $1
                GROUP BY folder
                ORDER BY folder %s
            )
            (SELECT folder AS "name",
                   NULL::uuid AS id,
                   NULL::timestamptz AS updated_at,
                   NULL::timestamptz AS created_at,
                   NULL::timestamptz AS last_accessed_at,
                   NULL::jsonb AS metadata FROM folders)
            UNION ALL
            (SELECT path_tokens[$1] AS "name",
                   id, updated_at, created_at, last_accessed_at, metadata
             FROM storage.objects
             WHERE objects.name ILIKE $2 || '%%'
               AND bucket_id = $3
               AND array_length(objects.path_tokens, 1) = $1
             ORDER BY %I %s)
            LIMIT $4 OFFSET $5
            $sql$, v_sort_order, v_order_by, v_sort_order
        ) USING levels, v_prefix, bucketname, v_limit, offsets;
        RETURN;
    END IF;

    -- ========================================================================
    -- NAME SORTING: Hybrid skip-scan with batch optimization
    -- ========================================================================

    -- Calculate upper bound for prefix filtering
    IF v_prefix_lower = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix_lower, 1) = v_delimiter THEN
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(v_delimiter) + 1);
    ELSE
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(right(v_prefix_lower, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'AND lower(o.name) COLLATE "C" < $3 ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'AND lower(o.name) COLLATE "C" >= $3 ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- Initialize seek position
    IF v_is_asc THEN
        v_next_seek := v_prefix_lower;
    ELSE
        -- DESC: find the last item in range first (static SQL)
        IF v_upper_bound IS NOT NULL THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower AND lower(o.name) COLLATE "C" < v_upper_bound
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSIF v_prefix_lower <> '' THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSE
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        END IF;

        IF v_peek_name IS NOT NULL THEN
            v_next_seek := lower(v_peek_name) || v_delimiter;
        ELSE
            RETURN;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= v_limit;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix_lower <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(lower(v_peek_name), v_prefix_lower, v_delimiter);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Handle offset, emit if needed, skip to next folder
            IF v_skipped < offsets THEN
                v_skipped := v_skipped + 1;
            ELSE
                name := split_part(rtrim(storage.get_common_prefix(v_peek_name, v_prefix, v_delimiter), v_delimiter), v_delimiter, levels);
                id := NULL;
                updated_at := NULL;
                created_at := NULL;
                last_accessed_at := NULL;
                metadata := NULL;
                RETURN NEXT;
                v_count := v_count + 1;
            END IF;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := lower(left(v_common_prefix, -1)) || chr(ascii(v_delimiter) + 1);
            ELSE
                v_next_seek := lower(v_common_prefix);
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix_lower is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query
                USING bucketname, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix_lower) ELSE v_prefix_lower END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(lower(v_current.name), v_prefix_lower, v_delimiter);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := lower(v_current.name);
                    EXIT;
                END IF;

                -- Handle offset skipping
                IF v_skipped < offsets THEN
                    v_skipped := v_skipped + 1;
                ELSE
                    -- Emit file
                    name := split_part(v_current.name, v_delimiter, levels);
                    id := v_current.id;
                    updated_at := v_current.updated_at;
                    created_at := v_current.created_at;
                    last_accessed_at := v_current.last_accessed_at;
                    metadata := v_current.metadata;
                    RETURN NEXT;
                    v_count := v_count + 1;
                END IF;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := lower(v_current.name) || v_delimiter;
                ELSE
                    v_next_seek := lower(v_current.name);
                END IF;

                EXIT WHEN v_count >= v_limit;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: search_by_timestamp(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_by_timestamp(p_prefix text, p_bucket_id text, p_limit integer, p_level integer, p_start_after text, p_sort_order text, p_sort_column text, p_sort_column_after text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_cursor_op text;
    v_query text;
    v_prefix text;
BEGIN
    v_prefix := coalesce(p_prefix, '');

    IF p_sort_order = 'asc' THEN
        v_cursor_op := '>';
    ELSE
        v_cursor_op := '<';
    END IF;

    v_query := format($sql$
        WITH raw_objects AS (
            SELECT
                o.name AS obj_name,
                o.id AS obj_id,
                o.updated_at AS obj_updated_at,
                o.created_at AS obj_created_at,
                o.last_accessed_at AS obj_last_accessed_at,
                o.metadata AS obj_metadata,
                storage.get_common_prefix(o.name, $1, '/') AS common_prefix
            FROM storage.objects o
            WHERE o.bucket_id = $2
              AND o.name COLLATE "C" LIKE $1 || '%%'
        ),
        -- Aggregate common prefixes (folders)
        -- Both created_at and updated_at use MIN(obj_created_at) to match the old prefixes table behavior
        aggregated_prefixes AS (
            SELECT
                rtrim(common_prefix, '/') AS name,
                NULL::uuid AS id,
                MIN(obj_created_at) AS updated_at,
                MIN(obj_created_at) AS created_at,
                NULL::timestamptz AS last_accessed_at,
                NULL::jsonb AS metadata,
                TRUE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NOT NULL
            GROUP BY common_prefix
        ),
        leaf_objects AS (
            SELECT
                obj_name AS name,
                obj_id AS id,
                obj_updated_at AS updated_at,
                obj_created_at AS created_at,
                obj_last_accessed_at AS last_accessed_at,
                obj_metadata AS metadata,
                FALSE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NULL
        ),
        combined AS (
            SELECT * FROM aggregated_prefixes
            UNION ALL
            SELECT * FROM leaf_objects
        ),
        filtered AS (
            SELECT *
            FROM combined
            WHERE (
                $5 = ''
                OR ROW(
                    date_trunc('milliseconds', %I),
                    name COLLATE "C"
                ) %s ROW(
                    COALESCE(NULLIF($6, '')::timestamptz, 'epoch'::timestamptz),
                    $5
                )
            )
        )
        SELECT
            split_part(name, '/', $3) AS key,
            name,
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
        FROM filtered
        ORDER BY
            COALESCE(date_trunc('milliseconds', %I), 'epoch'::timestamptz) %s,
            name COLLATE "C" %s
        LIMIT $4
    $sql$,
        p_sort_column,
        v_cursor_op,
        p_sort_column,
        p_sort_order,
        p_sort_order
    );

    RETURN QUERY EXECUTE v_query
    USING v_prefix, p_bucket_id, p_level, p_limit, p_start_after, p_sort_column_after;
END;
$_$;


--
-- Name: search_v2(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_sort_col text;
    v_sort_ord text;
    v_limit int;
BEGIN
    -- Cap limit to maximum of 1500 records
    v_limit := LEAST(coalesce(limits, 100), 1500);

    -- Validate and normalize sort_order
    v_sort_ord := lower(coalesce(sort_order, 'asc'));
    IF v_sort_ord NOT IN ('asc', 'desc') THEN
        v_sort_ord := 'asc';
    END IF;

    -- Validate and normalize sort_column
    v_sort_col := lower(coalesce(sort_column, 'name'));
    IF v_sort_col NOT IN ('name', 'updated_at', 'created_at') THEN
        v_sort_col := 'name';
    END IF;

    -- Route to appropriate implementation
    IF v_sort_col = 'name' THEN
        -- Use list_objects_with_delimiter for name sorting (most efficient: O(k * log n))
        RETURN QUERY
        SELECT
            split_part(l.name, '/', levels) AS key,
            l.name AS name,
            l.id,
            l.updated_at,
            l.created_at,
            l.last_accessed_at,
            l.metadata
        FROM storage.list_objects_with_delimiter(
            bucket_name,
            coalesce(prefix, ''),
            '/',
            v_limit,
            start_after,
            '',
            v_sort_ord
        ) l;
    ELSE
        -- Use aggregation approach for timestamp sorting
        -- Not efficient for large datasets but supports correct pagination
        RETURN QUERY SELECT * FROM storage.search_by_timestamp(
            prefix, bucket_name, v_limit, levels, start_after,
            v_sort_ord, v_sort_col, sort_column_after
        );
    END IF;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: custom_oauth_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.custom_oauth_providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider_type text NOT NULL,
    identifier text NOT NULL,
    name text NOT NULL,
    client_id text NOT NULL,
    client_secret text NOT NULL,
    acceptable_client_ids text[] DEFAULT '{}'::text[] NOT NULL,
    scopes text[] DEFAULT '{}'::text[] NOT NULL,
    pkce_enabled boolean DEFAULT true NOT NULL,
    attribute_mapping jsonb DEFAULT '{}'::jsonb NOT NULL,
    authorization_params jsonb DEFAULT '{}'::jsonb NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    email_optional boolean DEFAULT false NOT NULL,
    issuer text,
    discovery_url text,
    skip_nonce_check boolean DEFAULT false NOT NULL,
    cached_discovery jsonb,
    discovery_cached_at timestamp with time zone,
    authorization_url text,
    token_url text,
    userinfo_url text,
    jwks_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    custom_claims_allowlist text[] DEFAULT '{}'::text[] NOT NULL,
    CONSTRAINT custom_oauth_providers_authorization_url_https CHECK (((authorization_url IS NULL) OR (authorization_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_authorization_url_length CHECK (((authorization_url IS NULL) OR (char_length(authorization_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_client_id_length CHECK (((char_length(client_id) >= 1) AND (char_length(client_id) <= 512))),
    CONSTRAINT custom_oauth_providers_discovery_url_length CHECK (((discovery_url IS NULL) OR (char_length(discovery_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_identifier_format CHECK ((identifier ~ '^[a-z0-9][a-z0-9:-]{0,48}[a-z0-9]$'::text)),
    CONSTRAINT custom_oauth_providers_issuer_length CHECK (((issuer IS NULL) OR ((char_length(issuer) >= 1) AND (char_length(issuer) <= 2048)))),
    CONSTRAINT custom_oauth_providers_jwks_uri_https CHECK (((jwks_uri IS NULL) OR (jwks_uri ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_jwks_uri_length CHECK (((jwks_uri IS NULL) OR (char_length(jwks_uri) <= 2048))),
    CONSTRAINT custom_oauth_providers_name_length CHECK (((char_length(name) >= 1) AND (char_length(name) <= 100))),
    CONSTRAINT custom_oauth_providers_oauth2_requires_endpoints CHECK (((provider_type <> 'oauth2'::text) OR ((authorization_url IS NOT NULL) AND (token_url IS NOT NULL) AND (userinfo_url IS NOT NULL)))),
    CONSTRAINT custom_oauth_providers_oidc_discovery_url_https CHECK (((provider_type <> 'oidc'::text) OR (discovery_url IS NULL) OR (discovery_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_issuer_https CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NULL) OR (issuer ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_requires_issuer CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NOT NULL))),
    CONSTRAINT custom_oauth_providers_provider_type_check CHECK ((provider_type = ANY (ARRAY['oauth2'::text, 'oidc'::text]))),
    CONSTRAINT custom_oauth_providers_token_url_https CHECK (((token_url IS NULL) OR (token_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_token_url_length CHECK (((token_url IS NULL) OR (char_length(token_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_userinfo_url_https CHECK (((userinfo_url IS NULL) OR (userinfo_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_userinfo_url_length CHECK (((userinfo_url IS NULL) OR (char_length(userinfo_url) <= 2048)))
);


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text,
    code_challenge_method auth.code_challenge_method,
    code_challenge text,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone,
    invite_token text,
    referrer text,
    oauth_client_state_id uuid,
    linking_target_id uuid,
    email_optional boolean DEFAULT false NOT NULL
);


--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.flow_state IS 'Stores metadata for all OAuth/SSO login flows';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);


--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    nonce text,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


--
-- Name: oauth_client_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_client_states (
    id uuid NOT NULL,
    provider_type text NOT NULL,
    code_verifier text,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: TABLE oauth_client_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    token_endpoint_auth_method text NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048)),
    CONSTRAINT oauth_clients_token_endpoint_auth_method_check CHECK ((token_endpoint_auth_method = ANY (ARRAY['client_secret_basic'::text, 'client_secret_post'::text, 'none'::text])))
);


--
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text,
    CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096))
);


--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: webauthn_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.webauthn_challenges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    challenge_type text NOT NULL,
    session_data jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    CONSTRAINT webauthn_challenges_challenge_type_check CHECK ((challenge_type = ANY (ARRAY['signup'::text, 'registration'::text, 'authentication'::text])))
);


--
-- Name: webauthn_credentials; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.webauthn_credentials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    credential_id bytea NOT NULL,
    public_key bytea NOT NULL,
    attestation_type text DEFAULT ''::text NOT NULL,
    aaguid uuid,
    sign_count bigint DEFAULT 0 NOT NULL,
    transports jsonb DEFAULT '[]'::jsonb NOT NULL,
    backup_eligible boolean DEFAULT false NOT NULL,
    backed_up boolean DEFAULT false NOT NULL,
    friendly_name text DEFAULT ''::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_used_at timestamp with time zone
);


--
-- Name: album_photos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.album_photos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_id uuid NOT NULL,
    signer_user_id uuid NOT NULL,
    url text NOT NULL,
    lat double precision,
    lng double precision,
    place_name text,
    taken_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    album_id uuid
);


--
-- Name: albums; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.albums (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_id uuid NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: blocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blocks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    blocker_user_id uuid NOT NULL,
    blocked_profile_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: circle_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.circle_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    circle_id uuid NOT NULL,
    user_id uuid NOT NULL,
    profile_id uuid,
    name text DEFAULT ''::text NOT NULL,
    username text DEFAULT ''::text NOT NULL,
    ink text DEFAULT '#726A59'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: circle_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.circle_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    circle_id uuid NOT NULL,
    sender_user_id uuid NOT NULL,
    sender_name text DEFAULT ''::text NOT NULL,
    body text,
    image_url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    key_wraps jsonb
);


--
-- Name: circles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.circles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entry_id uuid NOT NULL,
    author_user_id uuid,
    name text NOT NULL,
    body text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    parent_id uuid,
    CONSTRAINT comments_body_check CHECK ((char_length(body) <= 500))
);


--
-- Name: conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conversations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    requester_profile_id uuid NOT NULL,
    recipient_profile_id uuid NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    requester_last_read_at timestamp with time zone DEFAULT now() NOT NULL,
    recipient_last_read_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT conversations_check CHECK ((requester_profile_id <> recipient_profile_id)),
    CONSTRAINT conversations_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'accepted'::text, 'declined'::text])))
);


--
-- Name: diary_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.diary_entries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    author_user_id uuid,
    title text,
    body text DEFAULT ''::text NOT NULL,
    visibility text DEFAULT 'private'::text,
    shared_with_user_id uuid,
    shared_with_name text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    photos jsonb DEFAULT '[]'::jsonb,
    notes jsonb DEFAULT '[]'::jsonb,
    CONSTRAINT diary_entries_visibility_check CHECK ((visibility = ANY (ARRAY['private'::text, 'shared_person'::text, 'on_book'::text])))
);


--
-- Name: diary_moods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.diary_moods (
    user_id uuid NOT NULL,
    mood_date date NOT NULL,
    mood text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_id uuid NOT NULL,
    signer_user_id uuid,
    name text NOT NULL,
    nickname text,
    relation text,
    word text NOT NULL,
    answers jsonb DEFAULT '[]'::jsonb NOT NULL,
    message text NOT NULL,
    city jsonb,
    photos text[] DEFAULT '{}'::text[] NOT NULL,
    color text DEFAULT '#3C4A5E'::text,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    unlock_at timestamp with time zone,
    diary_entry_id uuid,
    guest_email text,
    voice_url text,
    voice_seconds integer,
    kind text,
    CONSTRAINT entries_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'approved'::text])))
);


--
-- Name: event_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_comments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entry_id uuid,
    event_id uuid,
    author_user_id uuid,
    author_name text NOT NULL,
    message text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    parent_id uuid
);


--
-- Name: event_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_entries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid,
    author_name text NOT NULL,
    message text NOT NULL,
    photos jsonb DEFAULT '[]'::jsonb,
    approved boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    author_user_id uuid,
    entry_type text DEFAULT 'post'::text,
    subject_member text,
    one_word text,
    tagged jsonb DEFAULT '[]'::jsonb,
    city text,
    lat double precision,
    lng double precision,
    color text,
    edited boolean DEFAULT false,
    CONSTRAINT event_entries_entry_type_check CHECK ((entry_type = ANY (ARRAY['post'::text, 'about'::text])))
);


--
-- Name: event_guests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_guests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid,
    guest_name text,
    guest_email text,
    status text DEFAULT 'invited'::text,
    created_at timestamp with time zone DEFAULT now(),
    user_id uuid,
    CONSTRAINT event_guests_status_check CHECK ((status = ANY (ARRAY['invited'::text, 'requested'::text, 'joined'::text, 'declined'::text])))
);


--
-- Name: event_likes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_likes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entry_id uuid,
    event_id uuid,
    liker_key text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    owner_user_id uuid,
    name text NOT NULL,
    event_date date,
    location text,
    description text,
    slug text,
    visibility text DEFAULT 'public'::text,
    created_at timestamp with time zone DEFAULT now(),
    cover_url text,
    event_time text,
    event_type text,
    organisation text,
    honoree text,
    features jsonb DEFAULT '[]'::jsonb,
    CONSTRAINT events_visibility_check CHECK ((visibility = ANY (ARRAY['public'::text, 'private'::text])))
);


--
-- Name: follows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.follows (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    follower_user_id uuid NOT NULL,
    followed_profile_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: growth_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.growth_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_name text NOT NULL,
    user_id uuid,
    properties jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: likes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.likes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entry_id uuid NOT NULL,
    liker_key text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    kind text DEFAULT 'heart'::text NOT NULL
);


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    conversation_id uuid NOT NULL,
    sender_profile_id uuid NOT NULL,
    body text DEFAULT ''::text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    voice_url text,
    voice_seconds integer,
    image_url text,
    CONSTRAINT messages_body_check CHECK ((char_length(body) <= 2000))
);


--
-- Name: poll_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.poll_votes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_id uuid NOT NULL,
    voter_user_id uuid NOT NULL,
    question_key text NOT NULL,
    option_index integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT poll_votes_option_index_check CHECK (((option_index >= 0) AND (option_index <= 4))),
    CONSTRAINT poll_votes_question_key_check CHECK ((question_key = ANY (ARRAY['spark'::text, 'element'::text, 'word'::text, 'value'::text, 'mark'::text])))
);


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    username text NOT NULL,
    name text NOT NULL,
    bio text DEFAULT 'Just here to collect some words.'::text,
    ink text DEFAULT '#57614A'::text,
    avatar_url text,
    cover_url text,
    visibility text DEFAULT 'public'::text NOT NULL,
    template_id text DEFAULT 'classic'::text,
    questions jsonb DEFAULT '[]'::jsonb NOT NULL,
    links jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    extras jsonb DEFAULT '{}'::jsonb NOT NULL,
    deactivated boolean DEFAULT false,
    album_public boolean DEFAULT false NOT NULL,
    CONSTRAINT profiles_username_check CHECK ((username ~ '^[a-z0-9_]{3,20}$'::text)),
    CONSTRAINT profiles_visibility_check CHECK ((visibility = ANY (ARRAY['public'::text, 'private'::text])))
);


--
-- Name: reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    target_type text NOT NULL,
    target_id uuid NOT NULL,
    reason text,
    reporter_key text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT reports_target_type_check CHECK ((target_type = ANY (ARRAY['entry'::text, 'comment'::text, 'profile'::text])))
);


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea
)
PARTITION BY RANGE (inserted_at);


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    action_filter text DEFAULT '*'::text,
    selected_columns text[],
    CONSTRAINT subscription_action_filter_check CHECK ((action_filter = ANY (ARRAY['*'::text, 'INSERT'::text, 'UPDATE'::text, 'DELETE'::text])))
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);


--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_analytics (
    name text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: buckets_vectors; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_vectors (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb
);


--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb,
    metadata jsonb
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: vector_indexes; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.vector_indexes (
    id text DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    bucket_id text NOT NULL,
    data_type text NOT NULL,
    dimension integer NOT NULL,
    distance_metric text NOT NULL,
    metadata_configuration jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: supabase_migrations; Owner: -
--

CREATE TABLE supabase_migrations.schema_migrations (
    version text NOT NULL,
    statements text[],
    name text,
    created_by text,
    idempotency_key text,
    rollback text[]
);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
\.


--
-- Data for Name: custom_oauth_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.custom_oauth_providers (id, provider_type, identifier, name, client_id, client_secret, acceptable_client_ids, scopes, pkce_enabled, attribute_mapping, authorization_params, enabled, email_optional, issuer, discovery_url, skip_nonce_check, cached_discovery, discovery_cached_at, authorization_url, token_url, userinfo_url, jwks_uri, created_at, updated_at, custom_claims_allowlist) FROM stdin;
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at, invite_token, referrer, oauth_client_state_id, linking_target_id, email_optional) FROM stdin;
1b725d8d-59fb-449d-8231-3b385173c0d7	\N	\N	\N	\N	google			2026-07-15 10:48:46.599365+00	2026-07-15 10:48:46.599365+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
07b86084-68ff-45cd-8ed2-0e682057936d	\N	\N	\N	\N	google			2026-07-06 07:16:17.606938+00	2026-07-06 07:16:17.606938+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
000bf631-be67-4d55-bfde-34fdc3a9b2c2	\N	\N	\N	\N	google			2026-07-21 14:06:57.845626+00	2026-07-21 14:06:57.845626+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
0d3abdc8-ea34-475b-9072-1c47137fde17	\N	\N	\N	\N	google			2026-07-15 13:24:37.036171+00	2026-07-15 13:24:37.036171+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
fac6bd61-881e-4187-9f87-95a577f65ec8	\N	\N	\N	\N	google			2026-07-31 11:29:14.527714+00	2026-07-31 11:29:14.527714+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
92f41bab-fdb5-4e02-a86b-e5624b1109f0	\N	\N	\N	\N	google			2026-07-31 12:42:11.92584+00	2026-07-31 12:42:11.92584+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
206e2c2a-e6b8-48fa-b7c2-27bf8dc10af5	\N	\N	\N	\N	google			2026-07-22 11:05:54.271344+00	2026-07-22 11:05:54.271344+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
afeeed56-bd8a-42d6-9af4-ad2567f85c19	\N	\N	\N	\N	google			2026-07-05 06:54:57.34325+00	2026-07-05 06:54:57.34325+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
d270fe7e-3941-4dff-bc19-ce364bf244fa	\N	\N	\N	\N	google			2026-07-11 17:30:05.587348+00	2026-07-11 17:30:05.587348+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
c9f9f6d3-55d2-43a7-a689-3bcbe4f7261d	\N	\N	\N	\N	google			2026-07-05 07:36:10.46969+00	2026-07-05 07:36:10.46969+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
2f2c928f-e11b-495c-b3bb-2a10d57807d2	\N	\N	\N	\N	google			2026-07-05 07:41:51.644102+00	2026-07-05 07:41:51.644102+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
e7034a7e-bfef-4244-88e6-04dc1130cfbd	\N	\N	\N	\N	google			2026-07-05 07:44:04.116844+00	2026-07-05 07:44:04.116844+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
ead31652-6e2b-402b-b136-4a2acb991ef2	\N	\N	\N	\N	google			2026-07-05 07:45:32.211067+00	2026-07-05 07:45:32.211067+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
31955aff-dd8d-4527-8cd9-9ffd75a555af	\N	\N	\N	\N	google			2026-07-05 07:48:49.399134+00	2026-07-05 07:48:49.399134+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
b9777c44-4027-471b-b587-da1ab5996d30	\N	\N	\N	\N	google			2026-07-05 07:52:25.346909+00	2026-07-05 07:52:25.346909+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
872deca1-12a5-4e46-b12b-d7164c5c5677	\N	\N	\N	\N	google			2026-07-05 07:58:48.913047+00	2026-07-05 07:58:48.913047+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
b64ec7a2-78af-449b-9918-98b87c08ebeb	\N	\N	\N	\N	google			2026-07-17 06:06:21.703375+00	2026-07-17 06:06:21.703375+00	oauth	\N	\N	https://earthlive.in/?u=aseshsarkar	\N	\N	f
ce750153-efc6-4d0e-b441-cb3fbcaa67a4	\N	\N	\N	\N	google			2026-07-23 08:36:37.398526+00	2026-07-23 08:36:37.398526+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
ddc38857-e4f0-493b-b137-1daedbdf41de	\N	\N	\N	\N	google			2026-07-23 12:22:24.974325+00	2026-07-23 12:22:24.974325+00	oauth	\N	\N	https://earthlive.in	\N	\N	f
f16f933a-7b6a-40c8-a8b6-ce47f7b2d762	\N	\N	\N	\N	google			2026-07-24 05:20:58.070784+00	2026-07-24 05:20:58.070784+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
a2203d19-1775-4278-b160-c8cbd48a4b06	\N	\N	\N	\N	google			2026-07-24 05:21:09.752944+00	2026-07-24 05:21:09.752944+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
23d9c177-1de1-412b-a164-c180a32780f0	\N	\N	\N	\N	google			2026-07-24 05:30:33.923645+00	2026-07-24 05:30:33.923645+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
b857d4da-38ca-49df-b421-4e9ef55d165b	\N	\N	\N	\N	google			2026-07-24 05:30:52.664837+00	2026-07-24 05:30:52.664837+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
dcb4bba6-d301-4c0c-baeb-dd895c275ae5	\N	\N	\N	\N	google			2026-08-01 09:51:54.291512+00	2026-08-01 09:51:54.291512+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
079dcfc7-e55d-47d9-8d45-eaa4258fd250	\N	\N	\N	\N	google			2026-07-24 05:31:43.405251+00	2026-07-24 05:31:43.405251+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
1b9a5697-e01e-4858-bd2c-08ccd067c64c	\N	\N	\N	\N	google			2026-07-07 04:54:23.370618+00	2026-07-07 04:54:23.370618+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
4df1a836-9eee-4439-9a20-1a4a24373444	\N	\N	\N	\N	google			2026-07-24 05:43:02.837365+00	2026-07-24 05:43:02.837365+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
8d775da9-ff75-4aa5-827b-84820d795c1b	\N	\N	\N	\N	google			2026-07-24 05:45:02.782983+00	2026-07-24 05:45:02.782983+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
c8138be2-0db9-4387-a9aa-eb6f0611f6f6	\N	\N	\N	\N	google			2026-07-07 06:03:17.98627+00	2026-07-07 06:03:17.98627+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
c55b7b94-fdbe-4bb4-8050-fcb5fde80495	\N	\N	\N	\N	google			2026-07-24 05:45:58.207218+00	2026-07-24 05:45:58.207218+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
0d0c0ac1-10bd-48f9-ad4c-f270d4c89c67	\N	\N	\N	\N	google			2026-07-07 06:58:40.078578+00	2026-07-07 06:58:40.078578+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
8e22a1ab-994c-4583-a4be-9459f41ec843	\N	\N	\N	\N	google			2026-07-07 07:32:32.101478+00	2026-07-07 07:32:32.101478+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
61dab5db-2335-48a6-8049-850d81f63735	\N	\N	\N	\N	google			2026-07-05 16:30:47.046658+00	2026-07-05 16:30:47.046658+00	oauth	\N	\N	https://earthlive.in/?u=aseshsarkar	\N	\N	f
2ceab135-00e0-45f4-80a1-2b9dad354fff	\N	\N	\N	\N	google			2026-07-24 05:48:29.779542+00	2026-07-24 05:48:29.779542+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
d2e53088-b6a2-4866-808b-5b4546fec853	\N	\N	\N	\N	google			2026-07-24 05:52:45.255193+00	2026-07-24 05:52:45.255193+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
2f51ae2a-e56d-4c43-b062-11b5a4f764dc	\N	\N	\N	\N	google			2026-07-05 16:35:22.339726+00	2026-07-05 16:35:22.339726+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
6d416733-95f1-45ac-a11e-3eb8c022c6e3	\N	\N	\N	\N	google			2026-07-24 06:38:50.041318+00	2026-07-24 06:38:50.041318+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
ed505a63-45bf-487f-8dc0-0121f7cce45a	\N	\N	\N	\N	google			2026-07-13 07:29:45.520627+00	2026-07-13 07:29:45.520627+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
4d6f72eb-96e1-4959-b5de-970677017034	\N	\N	\N	\N	google			2026-07-13 07:53:19.692095+00	2026-07-13 07:53:19.692095+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
5d4528ee-9e84-4a63-be85-4ba778346a69	\N	\N	\N	\N	google			2026-07-20 10:19:45.203302+00	2026-07-20 10:19:45.203302+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
6695df61-4c0b-4567-b409-3bcb01c54c07	\N	\N	\N	\N	google			2026-07-08 11:30:44.228896+00	2026-07-08 11:30:44.228896+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
2fb172de-d29c-4acf-96e8-d1bd9aeaf3e0	\N	\N	\N	\N	google			2026-07-24 11:07:17.91768+00	2026-07-24 11:07:17.91768+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
47f0a8cc-8cc7-4598-85b2-2647cc25fd31	\N	\N	\N	\N	google			2026-07-06 06:18:34.933688+00	2026-07-06 06:18:34.933688+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
4c291daf-f430-4599-a629-9bbd9e1494fb	\N	\N	\N	\N	google			2026-07-20 17:33:42.536175+00	2026-07-20 17:33:42.536175+00	oauth	\N	\N	https://earthlive.in	\N	\N	f
077c0df3-6711-4e20-aa96-fe65547e8a9c	\N	\N	\N	\N	google			2026-07-14 17:27:19.432268+00	2026-07-14 17:27:19.432268+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
17c33da8-9476-4973-b820-e905728c7424	\N	\N	\N	\N	google			2026-07-14 17:27:40.072893+00	2026-07-14 17:27:40.072893+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
478b0b0a-01b7-467b-b12b-49c9169cbf9f	\N	\N	\N	\N	google			2026-07-14 17:30:22.675072+00	2026-07-14 17:30:22.675072+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
983849ba-c742-4bcd-aa8d-24874b551f85	\N	\N	\N	\N	google			2026-07-26 08:26:16.813215+00	2026-07-26 08:26:16.813215+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
86660434-06ee-4cee-a4d7-9870074d3307	\N	\N	\N	\N	google			2026-07-27 05:04:59.157952+00	2026-07-27 05:04:59.157952+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
6faef1bf-4fb8-4926-9ec4-840c04bb11ab	\N	\N	\N	\N	google			2026-07-21 09:41:47.022087+00	2026-07-21 09:41:47.022087+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
9d7cc098-c011-4788-8bf2-3c2e2bfd9aec	\N	\N	\N	\N	google			2026-07-14 21:41:54.982306+00	2026-07-14 21:41:54.982306+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
efe241cd-de32-4f07-96c3-08a8f3ea6412	\N	\N	\N	\N	google			2026-07-15 04:28:17.860432+00	2026-07-15 04:28:17.860432+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
877df018-4bc0-4bef-a5b8-047ea9c16db6	\N	\N	\N	\N	google			2026-07-21 09:43:35.730363+00	2026-07-21 09:43:35.730363+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
99705d5d-826a-4f5e-99b7-b481389768b6	\N	\N	\N	\N	google			2026-07-21 09:53:43.598186+00	2026-07-21 09:53:43.598186+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
78ee427a-5a76-4cd6-a739-a128d4ffeabc	\N	\N	\N	\N	google			2026-07-29 13:10:44.617058+00	2026-07-29 13:10:44.617058+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
a86ca25d-889a-4b29-9f89-40e67aad38e5	\N	\N	\N	\N	google			2026-07-29 13:29:16.016709+00	2026-07-29 13:29:16.016709+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
b3802863-34fd-4992-91c7-b91ab25847b5	\N	\N	\N	\N	google			2026-07-29 16:42:24.308036+00	2026-07-29 16:42:24.308036+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
4f5e0ceb-988b-4f82-bd82-ae3ff5b107c0	\N	\N	\N	\N	google			2026-07-30 06:15:06.037864+00	2026-07-30 06:15:06.037864+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
3a3e3aa0-1780-401e-ab10-768c3fb5feb5	\N	\N	\N	\N	google			2026-08-12 05:58:46.094717+00	2026-08-12 05:58:46.094717+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
10e7fe8c-9571-46df-bb31-24ceb76618ec	\N	\N	\N	\N	google			2026-07-30 09:48:13.779255+00	2026-07-30 09:48:13.779255+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
2dc0825a-d066-4356-8d1f-3b5be807b9e2	\N	\N	\N	\N	google			2026-08-16 15:22:08.04245+00	2026-08-16 15:22:08.04245+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
cf0c2e5f-4d79-488d-b02f-5bc95071edde	\N	\N	\N	\N	google			2026-07-31 04:51:53.14979+00	2026-07-31 04:51:53.14979+00	oauth	\N	\N	https://earthlive.in/	\N	\N	f
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
113608888260705650384	0b3bf0ee-58ef-4f17-8567-ed5c07964c96	{"iss": "https://accounts.google.com", "sub": "113608888260705650384", "name": "Nitendra Thakur", "email": "thakur.nitendra24@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocIcn16KVyQJRiozhuz6dasbeYOMyDpznIdLiViI8doSS71iS2t9mw=s96-c", "full_name": "Nitendra Thakur", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocIcn16KVyQJRiozhuz6dasbeYOMyDpznIdLiViI8doSS71iS2t9mw=s96-c", "provider_id": "113608888260705650384", "email_verified": true, "phone_verified": false}	google	2026-07-06 16:30:43.680183+00	2026-07-06 16:30:43.680257+00	2026-07-06 16:42:53.230221+00	c4f9c4c8-887c-4eee-bd03-fdb44ff61dad
116171895639809519056	73cad07a-ae07-4ad6-be61-1e59d3943953	{"iss": "https://accounts.google.com", "sub": "116171895639809519056", "name": "Kalyan Sarkar", "email": "sarkaronline10@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJxwt9p7svbd5geRJ871rDP7KPxBxTE02r1GeqbR113B6swMA=s96-c", "full_name": "Kalyan Sarkar", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJxwt9p7svbd5geRJ871rDP7KPxBxTE02r1GeqbR113B6swMA=s96-c", "provider_id": "116171895639809519056", "email_verified": true, "phone_verified": false}	google	2026-07-05 20:25:43.126842+00	2026-07-05 20:25:43.126895+00	2026-07-05 20:25:43.126895+00	88978642-853b-489e-af41-eaacbfb359af
105765673274737054194	02989991-856d-4edb-bee7-26569343d07c	{"iss": "https://accounts.google.com", "sub": "105765673274737054194", "name": "Rohit R Prabhu", "email": "rohit.rp@bmsca.org", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJ9iGGLzpV-DRpgwFQkYPRz5h83Mj6dtOCJgO5jr40FJg0EZA=s96-c", "full_name": "Rohit R Prabhu", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJ9iGGLzpV-DRpgwFQkYPRz5h83Mj6dtOCJgO5jr40FJg0EZA=s96-c", "provider_id": "105765673274737054194", "custom_claims": {"hd": "bmsca.org"}, "email_verified": true, "phone_verified": false}	google	2026-07-06 07:56:09.932688+00	2026-07-06 07:56:09.932744+00	2026-07-06 07:59:13.793358+00	2e8fd64c-2507-4e6f-b26c-afa30f00df8d
109176001650248922868	fae6b5e3-7b7b-4195-910c-e1a0ec3159a5	{"iss": "https://accounts.google.com", "sub": "109176001650248922868", "name": "Dr. Naveen Kishore Khambadkone", "email": "naveen.k@bmsca.org", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKOoeiDG62OVbFtHlpXhuzTdwEQzo8WxspWBfl5Bp2Ra8gNgQ=s96-c", "full_name": "Dr. Naveen Kishore Khambadkone", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKOoeiDG62OVbFtHlpXhuzTdwEQzo8WxspWBfl5Bp2Ra8gNgQ=s96-c", "provider_id": "109176001650248922868", "custom_claims": {"hd": "bmsca.org"}, "email_verified": true, "phone_verified": false}	google	2026-07-06 10:00:47.368948+00	2026-07-06 10:00:47.369034+00	2026-07-06 10:00:47.369034+00	d4d413b7-d1bb-4c51-bb05-bdd652468b2c
13826d95-961c-494e-a2c2-018298bbda09	13826d95-961c-494e-a2c2-018298bbda09	{"sub": "13826d95-961c-494e-a2c2-018298bbda09", "email": "kaushikdas00@gmail.com", "email_verified": true, "phone_verified": false}	email	2026-07-06 14:25:32.768466+00	2026-07-06 14:25:32.76852+00	2026-07-06 14:25:32.76852+00	10470ed5-230e-4e45-9cac-a1d9976bfb56
102040178697397597560	596b2102-4ae0-430f-93c5-c9847886cf12	{"iss": "https://accounts.google.com", "sub": "102040178697397597560", "name": "Ms. Pooja Mailsamy", "email": "pooja.m@bmsca.org", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKPA--8xvOsz6Vr3UWlOm-gHSM7hhG-9Sj3MZrbx2Q180aaNQ=s96-c", "full_name": "Ms. Pooja Mailsamy", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKPA--8xvOsz6Vr3UWlOm-gHSM7hhG-9Sj3MZrbx2Q180aaNQ=s96-c", "provider_id": "102040178697397597560", "custom_claims": {"hd": "bmsca.org"}, "email_verified": true, "phone_verified": false}	google	2026-07-05 17:11:03.683953+00	2026-07-05 17:11:03.684006+00	2026-07-05 17:11:03.684006+00	5c48b7a3-a6d9-418c-958e-87f0f684aa03
108310024042724957882	caecce43-57a3-40aa-8a18-b22a318b3364	{"iss": "https://accounts.google.com", "sub": "108310024042724957882", "name": "Souvik Bagchi", "email": "rishi7souvik@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJ-wi6MV1ojgy9n8yIdB0wnHDYprgup--nZdTKf6eSIvXr1SDfh=s96-c", "full_name": "Souvik Bagchi", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJ-wi6MV1ojgy9n8yIdB0wnHDYprgup--nZdTKf6eSIvXr1SDfh=s96-c", "provider_id": "108310024042724957882", "email_verified": true, "phone_verified": false}	google	2026-07-08 07:45:49.199364+00	2026-07-08 07:45:49.199415+00	2026-07-08 07:45:49.199415+00	b852138f-c6e9-43ae-9405-8c3350d166fd
114431921419462930201	70d6dcbc-b05a-408e-b0a6-519a1e2e3cef	{"iss": "https://accounts.google.com", "sub": "114431921419462930201", "name": "Niravra", "email": "niravrakar2@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKohQnXk3K76q5p4xWQEwkRmpeGPWzh9eEyXGFYjVijz6aTrW_4=s96-c", "full_name": "Niravra", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKohQnXk3K76q5p4xWQEwkRmpeGPWzh9eEyXGFYjVijz6aTrW_4=s96-c", "provider_id": "114431921419462930201", "email_verified": true, "phone_verified": false}	google	2026-07-10 02:36:39.403512+00	2026-07-10 02:36:39.403571+00	2026-07-10 02:36:39.403571+00	8760fe9a-9537-4723-bbd0-28dec2226120
118249479869549119197	794c5058-c511-4509-ad40-938ce0d45eae	{"iss": "https://accounts.google.com", "sub": "118249479869549119197", "name": "asesh sarkar", "email": "aseshsarkar51@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocK_sH3eBI83fr2NCnWC6OYuNcYiTzLbfnI5dkk8NDvDIcrbD0_s=s96-c", "full_name": "asesh sarkar", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocK_sH3eBI83fr2NCnWC6OYuNcYiTzLbfnI5dkk8NDvDIcrbD0_s=s96-c", "provider_id": "118249479869549119197", "email_verified": true, "phone_verified": false}	google	2026-07-05 06:22:53.905694+00	2026-07-05 06:22:53.90575+00	2026-08-19 17:04:34.59026+00	5bf5fd45-13ad-4891-965e-003bc2794fc5
112434780019931353114	57022196-7fc3-4bb8-88f9-578c4c3832c6	{"iss": "https://accounts.google.com", "sub": "112434780019931353114", "name": "Yogita Choudhari", "email": "yogitaright@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKWPIbcbCxgE_lhOzayWSMsi-UZNgwj6jltWHX0sSgwqx7oyFhM=s96-c", "full_name": "Yogita Choudhari", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKWPIbcbCxgE_lhOzayWSMsi-UZNgwj6jltWHX0sSgwqx7oyFhM=s96-c", "provider_id": "112434780019931353114", "email_verified": true, "phone_verified": false}	google	2026-07-11 06:55:44.736727+00	2026-07-11 06:55:44.736821+00	2026-07-11 06:55:44.736821+00	713943a6-cc5f-4355-9209-f44d4c1fa11f
106699219073814621582	13554111-b50c-44ad-af7b-4988c8209afb	{"iss": "https://accounts.google.com", "sub": "106699219073814621582", "name": "ASESH SARKAR", "email": "asarkar@ar.iitr.ac.in", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKXVAHj_DqjoizbTLbp6xpLfLXYrHpvSYwYagKZchrsSWNWC8U=s96-c", "full_name": "ASESH SARKAR", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKXVAHj_DqjoizbTLbp6xpLfLXYrHpvSYwYagKZchrsSWNWC8U=s96-c", "provider_id": "106699219073814621582", "custom_claims": {"hd": "ar.iitr.ac.in"}, "email_verified": true, "phone_verified": false}	google	2026-07-05 06:25:33.396688+00	2026-07-05 06:25:33.396741+00	2026-08-12 14:03:05.206344+00	a43ebf25-147f-44ba-85f1-ada65a94849c
117911998377255858055	f3224654-1357-4933-a356-d10bf55f7354	{"iss": "https://accounts.google.com", "sub": "117911998377255858055", "name": "Dr. Asesh Sarkar", "email": "asesh.s@bmsca.org", "picture": "https://lh3.googleusercontent.com/a/ACg8ocK90aYxW_t_bb-RgCRq70xkMXqWwZR0xvJ-TXFsHO9Q3VU2vg=s96-c", "full_name": "Dr. Asesh Sarkar", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocK90aYxW_t_bb-RgCRq70xkMXqWwZR0xvJ-TXFsHO9Q3VU2vg=s96-c", "provider_id": "117911998377255858055", "custom_claims": {"hd": "bmsca.org"}, "email_verified": true, "phone_verified": false}	google	2026-07-05 17:57:51.76212+00	2026-07-05 17:57:51.762211+00	2026-08-02 14:34:21.130499+00	c110aedf-400e-4ab1-bc72-878ae381b572
110898796349013929292	81ade54b-a78a-497b-9181-dc06376c7d9f	{"iss": "https://accounts.google.com", "sub": "110898796349013929292", "name": "Queen Bee", "email": "queenbee.contact1@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKK8tUA110Y7zc0MMf_UlaZyE4Yxd3AuV4w17M1Cippv-2GKTs=s96-c", "full_name": "Queen Bee", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKK8tUA110Y7zc0MMf_UlaZyE4Yxd3AuV4w17M1Cippv-2GKTs=s96-c", "provider_id": "110898796349013929292", "email_verified": true, "phone_verified": false}	google	2026-07-14 18:29:15.073314+00	2026-07-14 18:29:15.07337+00	2026-07-14 18:29:15.07337+00	2d953d50-e1d9-4885-b69f-badeb9334b5f
115868545157363939361	3d1eb4e1-b2da-465b-b9b6-48d13e167d7a	{"iss": "https://accounts.google.com", "sub": "115868545157363939361", "name": "Sandhya Sharma", "email": "diya6665@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocLZgixdAIDDlu4GHDwcRB-OQmtbH5iMPKQ-wBy8wifUsh0STSIK=s96-c", "full_name": "Sandhya Sharma", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocLZgixdAIDDlu4GHDwcRB-OQmtbH5iMPKQ-wBy8wifUsh0STSIK=s96-c", "provider_id": "115868545157363939361", "email_verified": true, "phone_verified": false}	google	2026-07-14 17:57:38.21382+00	2026-07-14 17:57:38.214559+00	2026-07-14 21:34:32.21555+00	2871c0c3-1ef8-4a16-9608-ff16758bbc60
116600578525987489830	16ffc989-0287-4969-b279-bb957c906c51	{"iss": "https://accounts.google.com", "sub": "116600578525987489830", "name": "Rahul Das", "email": "rahuldas066@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJZ4ZyJzv0f9yhikN21cEvLejRl0w_y5jGVK6KvMBd1mAUQLpow=s96-c", "full_name": "Rahul Das", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJZ4ZyJzv0f9yhikN21cEvLejRl0w_y5jGVK6KvMBd1mAUQLpow=s96-c", "provider_id": "116600578525987489830", "email_verified": true, "phone_verified": false}	google	2026-07-15 07:04:00.33907+00	2026-07-15 07:04:00.339146+00	2026-07-15 07:04:00.339146+00	6ac550d9-d328-401c-a65b-4f7073590ff0
100960832167854243343	b9e20678-6e1b-4a4a-9cde-e30e6cfc80eb	{"iss": "https://accounts.google.com", "sub": "100960832167854243343", "name": "Parakh Katre", "email": "parakhkatre@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocLSHzWB3qdgGKSB4A-BdjRYMmJbc9w2Plc9hg1hHWQ_l4FXYw=s96-c", "full_name": "Parakh Katre", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocLSHzWB3qdgGKSB4A-BdjRYMmJbc9w2Plc9hg1hHWQ_l4FXYw=s96-c", "provider_id": "100960832167854243343", "email_verified": true, "phone_verified": false}	google	2026-07-16 17:16:06.36576+00	2026-07-16 17:16:06.365812+00	2026-07-16 17:16:06.365812+00	14a2ac07-e49c-47c5-9073-762a2c343b5e
100965135966347500128	9751051b-d866-4336-a7ce-a2b3f4605835	{"iss": "https://accounts.google.com", "sub": "100965135966347500128", "name": "Debjit Sardar", "email": "debjitsardar743426@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocL8cfBVEWSF4QaVxGqLBQnQ8TMa22RBHCkLSCsen7On6-2MDFZb=s96-c", "full_name": "Debjit Sardar", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocL8cfBVEWSF4QaVxGqLBQnQ8TMa22RBHCkLSCsen7On6-2MDFZb=s96-c", "provider_id": "100965135966347500128", "email_verified": true, "phone_verified": false}	google	2026-07-16 19:18:57.900562+00	2026-07-16 19:18:57.900623+00	2026-07-16 19:18:57.900623+00	d7686b14-9c1c-40de-b4ad-6e5caa00d858
103588304559153768719	65fae4b9-0c10-4dc8-b57c-b4d1d1cecb1f	{"iss": "https://accounts.google.com", "sub": "103588304559153768719", "name": "Prof. Surya P.S", "email": "suryaps@tkmce.ac.in", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKobCDYmqKiu1F7X7Cr5692lN3kTHM83jkU2YT0gFKKVcf35CM=s96-c", "full_name": "Prof. Surya P.S", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKobCDYmqKiu1F7X7Cr5692lN3kTHM83jkU2YT0gFKKVcf35CM=s96-c", "provider_id": "103588304559153768719", "custom_claims": {"hd": "tkmce.ac.in"}, "email_verified": true, "phone_verified": false}	google	2026-07-17 04:03:54.576607+00	2026-07-17 04:03:54.576669+00	2026-07-17 04:03:54.576669+00	d29cbf88-ef0a-40a7-8014-5a66cf3f8f98
101458068404335430271	93b861a6-d5bd-4248-a0b1-63d6bb067b66	{"iss": "https://accounts.google.com", "sub": "101458068404335430271", "name": "Monithakumar", "email": "monithakumar147k@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocL86WqrYnOwsKel0Xg3VtvnfyKHU9gDpJiDNIRvthQzIbGKP3Y=s96-c", "full_name": "Monithakumar", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocL86WqrYnOwsKel0Xg3VtvnfyKHU9gDpJiDNIRvthQzIbGKP3Y=s96-c", "provider_id": "101458068404335430271", "email_verified": true, "phone_verified": false}	google	2026-07-17 09:38:44.455455+00	2026-07-17 09:38:44.455509+00	2026-07-17 09:38:44.455509+00	9dde488d-60b8-4315-94fb-705983271c95
102003226648820322119	674599f7-e03b-4c53-8d8f-4d3bbc50bf64	{"iss": "https://accounts.google.com", "sub": "102003226648820322119", "name": "Samarth Gogineni", "email": "goginenisamarth@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocLFBJOnD3Srrp2D2j1C7681P49GikIs8c6Aq9Nu1FTlG_jW8Q=s96-c", "full_name": "Samarth Gogineni", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocLFBJOnD3Srrp2D2j1C7681P49GikIs8c6Aq9Nu1FTlG_jW8Q=s96-c", "provider_id": "102003226648820322119", "email_verified": true, "phone_verified": false}	google	2026-07-18 06:58:05.95717+00	2026-07-18 06:58:05.957232+00	2026-07-18 06:58:05.957232+00	5ab04594-5dce-468b-823d-ca114bbad4ac
112788440370978048702	d9da27bf-94eb-4751-a96c-af37f3c601e7	{"iss": "https://accounts.google.com", "sub": "112788440370978048702", "name": "import brain", "email": "xepi314@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJOWSjLX9LpRTx_7Gbvfc9Lfh57h1nbSh3eipjzJ9OLm7fJ4dM=s96-c", "full_name": "import brain", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJOWSjLX9LpRTx_7Gbvfc9Lfh57h1nbSh3eipjzJ9OLm7fJ4dM=s96-c", "provider_id": "112788440370978048702", "email_verified": true, "phone_verified": false}	google	2026-07-20 16:29:47.607621+00	2026-07-20 16:29:47.607669+00	2026-07-20 16:35:34.205+00	1db8b011-7d5e-4a85-b7b0-24eb88f65301
118004784576018256175	88f68f9f-5af9-4a19-9252-842e5e0a1776	{"iss": "https://accounts.google.com", "sub": "118004784576018256175", "name": "Varshini", "email": "varsha292627@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKHictThU49X61qQDXmEULl1uSdWQv4gYJvTrX3WTb4y_Wx5Tw=s96-c", "full_name": "Varshini", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKHictThU49X61qQDXmEULl1uSdWQv4gYJvTrX3WTb4y_Wx5Tw=s96-c", "provider_id": "118004784576018256175", "email_verified": true, "phone_verified": false}	google	2026-07-22 13:51:57.603907+00	2026-07-22 13:51:57.603961+00	2026-07-22 13:51:57.603961+00	096cf068-7dea-4481-a031-7d85d68d0237
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
df56247e-4e42-4aab-ac31-42cfc9d55567	2026-07-06 07:59:13.806407+00	2026-07-06 07:59:13.806407+00	oauth	4a723586-010f-4386-953c-c70934bf1060
66894c28-78a4-46b6-93b9-dcaf3efe6438	2026-07-06 10:00:47.432159+00	2026-07-06 10:00:47.432159+00	oauth	f579430b-6d91-43a3-92c9-6ce648f5cce3
4ae3e6d4-2a0a-40e6-a388-f67b81b22435	2026-07-18 06:58:06.024855+00	2026-07-18 06:58:06.024855+00	oauth	59e7818e-4b22-4f7e-b857-40b5e8089af3
00c871ae-c7d5-4193-aa29-704e583d3908	2026-07-06 14:25:58.198233+00	2026-07-06 14:25:58.198233+00	otp	fd8e6d05-e307-4057-88cb-2b51192f10c0
338e365b-4629-4df2-8a9a-24700e972d3e	2026-07-06 16:30:43.709307+00	2026-07-06 16:30:43.709307+00	oauth	fb988b0b-1501-4708-ba20-db7b3cd907d5
71fa4394-a791-4cfe-8e21-af138c027e93	2026-07-06 16:42:53.362008+00	2026-07-06 16:42:53.362008+00	oauth	d5cdd11e-a8c6-463a-b915-cc1def3319c9
dec1d1ba-1cf1-42c2-b095-0a838fc0e86f	2026-08-02 14:34:21.179729+00	2026-08-02 14:34:21.179729+00	oauth	68d25582-68df-41aa-a6eb-179892755d49
5e0bf425-ac14-4f37-b49a-dd1d530568d6	2026-07-08 07:45:49.231157+00	2026-07-08 07:45:49.231157+00	oauth	739e92a3-0c60-4ae2-8391-97594190f7ba
c9d9f062-7a2d-4556-9a10-f0d79c5bf5b4	2026-07-10 02:36:39.463459+00	2026-07-10 02:36:39.463459+00	oauth	c66098a0-4a56-42dc-af40-b4981dbffa6d
c0534111-bc6c-4047-9755-e62af5173bbe	2026-08-19 17:04:34.595872+00	2026-08-19 17:04:34.595872+00	oauth	cf88a424-08a5-4b6f-8200-6ae66e3aa3f5
d07bf3be-ca51-43fa-ad8b-3929c2362d12	2026-07-05 20:25:43.176882+00	2026-07-05 20:25:43.176882+00	oauth	4fca4023-f127-48c6-a181-7d8e48bd0433
7c620a01-4ea9-421e-a416-72fbb5b0a197	2026-07-11 06:55:44.769026+00	2026-07-11 06:55:44.769026+00	oauth	a89db923-40fa-4842-b289-843aedc2ab09
457eb078-bb2f-4d55-afa5-2ad106bebd83	2026-07-14 17:57:38.257436+00	2026-07-14 17:57:38.257436+00	oauth	e113b3dd-04b6-4831-a553-88633d7044de
8a9d8fd0-acc6-4135-b5bb-5dce10f7d432	2026-07-14 18:29:15.131132+00	2026-07-14 18:29:15.131132+00	oauth	907768c7-6ab5-4061-8fc2-485b6fdcea41
5f833739-d60b-433d-bea6-7a97f682e713	2026-07-14 21:32:34.753233+00	2026-07-14 21:32:34.753233+00	oauth	e7675db0-8d10-40f2-8310-528affe677df
e74f89d6-a0ee-4b84-87cd-e3080d3beeed	2026-07-14 21:34:32.244323+00	2026-07-14 21:34:32.244323+00	oauth	69ee4183-b647-499d-ad80-701882e9921b
f959cca9-4288-4080-ab18-922ba600f677	2026-07-15 07:04:00.413362+00	2026-07-15 07:04:00.413362+00	oauth	51dd53b5-acb6-4642-9da6-ab32e675010a
7ffbe1a4-14b0-4426-be50-32c8e9271a65	2026-07-22 13:51:57.666645+00	2026-07-22 13:51:57.666645+00	oauth	0e22b520-995f-417c-b407-40c91c5741ba
f5e8fbcb-7f83-4b37-aabf-a9bb7e721d28	2026-07-16 17:16:06.429167+00	2026-07-16 17:16:06.429167+00	oauth	84014005-9995-43d7-a620-7de87638d3dd
fe598a0d-5be3-487f-8747-3dc9cbfc3884	2026-07-16 19:18:57.959572+00	2026-07-16 19:18:57.959572+00	oauth	f5d98ef1-781b-4cfc-893c-714608457a9d
164f7c29-89f1-499c-b7e0-5928e5be225b	2026-07-17 04:03:54.635845+00	2026-07-17 04:03:54.635845+00	oauth	004bac63-795d-4983-9500-81f39cdc9e1c
80584205-4294-45d1-81ef-d42116862f43	2026-07-17 09:38:44.500854+00	2026-07-17 09:38:44.500854+00	oauth	f9f9143a-c674-4f11-b808-ab4a43fa2ae2
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid, last_webauthn_challenge_data) FROM stdin;
\.


--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_authorizations (id, authorization_id, client_id, user_id, redirect_uri, scope, state, resource, code_challenge, code_challenge_method, response_type, status, authorization_code, created_at, expires_at, approved_at, nonce) FROM stdin;
\.


--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_client_states (id, provider_type, code_verifier, created_at) FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_clients (id, client_secret_hash, registration_type, redirect_uris, grant_types, client_name, client_uri, logo_uri, created_at, updated_at, deleted_at, client_type, token_endpoint_auth_method) FROM stdin;
\.


--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_consents (id, user_id, client_id, scopes, granted_at, revoked_at) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
a6897a6e-cbab-4d7e-af64-45df7beebf4e	13554111-b50c-44ad-af7b-4988c8209afb	recovery_token	6be92d11f3eff66bd66a9e261ba5f928c9216c6fdb50c2ac988e4ce5	asarkar@ar.iitr.ac.in	2026-07-05 16:41:30.641884	2026-07-05 16:41:30.641884
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
00000000-0000-0000-0000-000000000000	510	6uzsfihhibvn	73cad07a-ae07-4ad6-be61-1e59d3943953	t	2026-07-25 14:05:40.338464+00	2026-07-27 15:19:46.558933+00	eks5l3ydix63	d07bf3be-ca51-43fa-ad8b-3929c2362d12
00000000-0000-0000-0000-000000000000	524	jw6a5pmvupwl	73cad07a-ae07-4ad6-be61-1e59d3943953	f	2026-07-27 15:19:46.576376+00	2026-07-27 15:19:46.576376+00	6uzsfihhibvn	d07bf3be-ca51-43fa-ad8b-3929c2362d12
00000000-0000-0000-0000-000000000000	486	wrbidgioph4f	674599f7-e03b-4c53-8d8f-4d3bbc50bf64	f	2026-07-22 16:16:06.268246+00	2026-07-22 16:16:06.268246+00	dyzpua3wliie	4ae3e6d4-2a0a-40e6-a388-f67b81b22435
00000000-0000-0000-0000-000000000000	99	pzb5ycbatvdx	0b3bf0ee-58ef-4f17-8567-ed5c07964c96	t	2026-07-06 16:42:53.311899+00	2026-07-06 19:36:47.808497+00	\N	71fa4394-a791-4cfe-8e21-af138c027e93
00000000-0000-0000-0000-000000000000	681	4viyzoieqlbk	f3224654-1357-4933-a356-d10bf55f7354	t	2026-08-02 14:34:21.154207+00	2026-08-02 16:23:00.042385+00	\N	dec1d1ba-1cf1-42c2-b095-0a838fc0e86f
00000000-0000-0000-0000-000000000000	295	6ggh6njca4qp	16ffc989-0287-4969-b279-bb957c906c51	t	2026-07-15 07:04:00.390731+00	2026-07-16 00:40:50.284069+00	\N	f959cca9-4288-4080-ab18-922ba600f677
00000000-0000-0000-0000-000000000000	305	fb4rx3b4xw66	16ffc989-0287-4969-b279-bb957c906c51	f	2026-07-16 00:40:50.295346+00	2026-07-16 00:40:50.295346+00	6ggh6njca4qp	f959cca9-4288-4080-ab18-922ba600f677
00000000-0000-0000-0000-000000000000	103	lvsdinalnlau	0b3bf0ee-58ef-4f17-8567-ed5c07964c96	t	2026-07-06 19:36:47.821083+00	2026-07-06 20:42:17.544726+00	pzb5ycbatvdx	71fa4394-a791-4cfe-8e21-af138c027e93
00000000-0000-0000-0000-000000000000	107	dqnwgaleiiwy	0b3bf0ee-58ef-4f17-8567-ed5c07964c96	f	2026-07-06 20:42:17.546227+00	2026-07-06 20:42:17.546227+00	lvsdinalnlau	71fa4394-a791-4cfe-8e21-af138c027e93
00000000-0000-0000-0000-000000000000	685	ejluavrz3iyw	f3224654-1357-4933-a356-d10bf55f7354	t	2026-08-02 17:41:24.97996+00	2026-08-02 19:09:28.466699+00	em3cwpq3n7aw	dec1d1ba-1cf1-42c2-b095-0a838fc0e86f
00000000-0000-0000-0000-000000000000	687	uv2s4d663gsb	f3224654-1357-4933-a356-d10bf55f7354	t	2026-08-02 19:09:28.484502+00	2026-08-02 20:08:06.669711+00	ejluavrz3iyw	dec1d1ba-1cf1-42c2-b095-0a838fc0e86f
00000000-0000-0000-0000-000000000000	145	z7jo6njnbwkk	caecce43-57a3-40aa-8a18-b22a318b3364	f	2026-07-08 07:45:49.2274+00	2026-07-08 07:45:49.2274+00	\N	5e0bf425-ac14-4f37-b49a-dd1d530568d6
00000000-0000-0000-0000-000000000000	689	6qrgs2ty5ob5	f3224654-1357-4933-a356-d10bf55f7354	t	2026-08-02 20:08:06.679002+00	2026-08-03 17:34:44.518482+00	uv2s4d663gsb	dec1d1ba-1cf1-42c2-b095-0a838fc0e86f
00000000-0000-0000-0000-000000000000	319	7t5noq4hf5km	73cad07a-ae07-4ad6-be61-1e59d3943953	t	2026-07-16 19:07:38.703916+00	2026-07-18 16:44:44.519216+00	fseplsa6v7hx	d07bf3be-ca51-43fa-ad8b-3929c2362d12
00000000-0000-0000-0000-000000000000	93	zgxxihyp73i3	0b3bf0ee-58ef-4f17-8567-ed5c07964c96	t	2026-07-06 16:30:43.704378+00	2026-07-07 01:40:00.623966+00	\N	338e365b-4629-4df2-8a9a-24700e972d3e
00000000-0000-0000-0000-000000000000	114	bhfso4r6vgxr	0b3bf0ee-58ef-4f17-8567-ed5c07964c96	f	2026-07-07 01:40:00.632845+00	2026-07-07 01:40:00.632845+00	zgxxihyp73i3	338e365b-4629-4df2-8a9a-24700e972d3e
00000000-0000-0000-0000-000000000000	293	sud7j264rf5j	73cad07a-ae07-4ad6-be61-1e59d3943953	t	2026-07-15 02:22:14.126564+00	2026-07-16 18:06:32.08497+00	dsbiwjgou4xu	d07bf3be-ca51-43fa-ad8b-3929c2362d12
00000000-0000-0000-0000-000000000000	981	ryv3misn5wav	794c5058-c511-4509-ad40-938ce0d45eae	f	2026-08-20 03:15:01.126057+00	2026-08-20 03:15:01.126057+00	34rs6iambero	c0534111-bc6c-4047-9755-e62af5173bbe
00000000-0000-0000-0000-000000000000	285	obwzw7i4uxtr	3d1eb4e1-b2da-465b-b9b6-48d13e167d7a	f	2026-07-14 17:57:38.243289+00	2026-07-14 17:57:38.243289+00	\N	457eb078-bb2f-4d55-afa5-2ad106bebd83
00000000-0000-0000-0000-000000000000	289	37wd4wxilyxb	81ade54b-a78a-497b-9181-dc06376c7d9f	f	2026-07-14 20:08:22.95618+00	2026-07-14 20:08:22.95618+00	vi457kumef3f	8a9d8fd0-acc6-4135-b5bb-5dce10f7d432
00000000-0000-0000-0000-000000000000	291	orhrwxoci263	3d1eb4e1-b2da-465b-b9b6-48d13e167d7a	f	2026-07-14 21:34:32.234057+00	2026-07-14 21:34:32.234057+00	\N	e74f89d6-a0ee-4b84-87cd-e3080d3beeed
00000000-0000-0000-0000-000000000000	56	dsbiwjgou4xu	73cad07a-ae07-4ad6-be61-1e59d3943953	t	2026-07-05 20:25:43.159674+00	2026-07-15 02:22:14.102752+00	\N	d07bf3be-ca51-43fa-ad8b-3929c2362d12
00000000-0000-0000-0000-000000000000	75	qyiekljrc62y	02989991-856d-4edb-bee7-26569343d07c	f	2026-07-06 07:59:13.802079+00	2026-07-06 07:59:13.802079+00	\N	df56247e-4e42-4aab-ac31-42cfc9d55567
00000000-0000-0000-0000-000000000000	323	nwrvhcy3lzwb	65fae4b9-0c10-4dc8-b57c-b4d1d1cecb1f	t	2026-07-17 04:03:54.622945+00	2026-07-17 07:28:55.360039+00	\N	164f7c29-89f1-499c-b7e0-5928e5be225b
00000000-0000-0000-0000-000000000000	77	jowathh345us	fae6b5e3-7b7b-4195-910c-e1a0ec3159a5	t	2026-07-06 10:00:47.419798+00	2026-07-06 10:59:23.993462+00	\N	66894c28-78a4-46b6-93b9-dcaf3efe6438
00000000-0000-0000-0000-000000000000	79	klolzytoluyl	fae6b5e3-7b7b-4195-910c-e1a0ec3159a5	f	2026-07-06 10:59:24.010401+00	2026-07-06 10:59:24.010401+00	jowathh345us	66894c28-78a4-46b6-93b9-dcaf3efe6438
00000000-0000-0000-0000-000000000000	327	hxuyuxy5innp	65fae4b9-0c10-4dc8-b57c-b4d1d1cecb1f	f	2026-07-17 07:28:55.377096+00	2026-07-17 07:28:55.377096+00	nwrvhcy3lzwb	164f7c29-89f1-499c-b7e0-5928e5be225b
00000000-0000-0000-0000-000000000000	86	6lftzew3kovd	13826d95-961c-494e-a2c2-018298bbda09	f	2026-07-06 14:25:58.181555+00	2026-07-06 14:25:58.181555+00	\N	00c871ae-c7d5-4193-aa29-704e583d3908
00000000-0000-0000-0000-000000000000	166	h3dviuqpbci4	70d6dcbc-b05a-408e-b0a6-519a1e2e3cef	t	2026-07-10 02:36:39.443499+00	2026-07-10 17:52:32.668719+00	\N	c9d9f062-7a2d-4556-9a10-f0d79c5bf5b4
00000000-0000-0000-0000-000000000000	184	awgeb4qgiu35	70d6dcbc-b05a-408e-b0a6-519a1e2e3cef	f	2026-07-10 17:52:32.677886+00	2026-07-10 17:52:32.677886+00	h3dviuqpbci4	c9d9f062-7a2d-4556-9a10-f0d79c5bf5b4
00000000-0000-0000-0000-000000000000	347	vthvu25cwwg4	674599f7-e03b-4c53-8d8f-4d3bbc50bf64	t	2026-07-18 06:58:06.007716+00	2026-07-22 12:57:40.666004+00	\N	4ae3e6d4-2a0a-40e6-a388-f67b81b22435
00000000-0000-0000-0000-000000000000	192	hfcovk5vyvmb	57022196-7fc3-4bb8-88f9-578c4c3832c6	f	2026-07-11 06:55:44.762639+00	2026-07-11 06:55:44.762639+00	\N	7c620a01-4ea9-421e-a416-72fbb5b0a197
00000000-0000-0000-0000-000000000000	483	ocyjdnospspv	88f68f9f-5af9-4a19-9252-842e5e0a1776	f	2026-07-22 13:51:57.645488+00	2026-07-22 13:51:57.645488+00	\N	7ffbe1a4-14b0-4426-be50-32c8e9271a65
00000000-0000-0000-0000-000000000000	481	dyzpua3wliie	674599f7-e03b-4c53-8d8f-4d3bbc50bf64	t	2026-07-22 12:57:40.677554+00	2026-07-22 16:16:06.257136+00	vthvu25cwwg4	4ae3e6d4-2a0a-40e6-a388-f67b81b22435
00000000-0000-0000-0000-000000000000	314	43c7nbohsmr3	b9e20678-6e1b-4a4a-9cde-e30e6cfc80eb	f	2026-07-16 17:16:06.411773+00	2026-07-16 17:16:06.411773+00	\N	f5e8fbcb-7f83-4b37-aabf-a9bb7e721d28
00000000-0000-0000-0000-000000000000	684	em3cwpq3n7aw	f3224654-1357-4933-a356-d10bf55f7354	t	2026-08-02 16:23:00.077596+00	2026-08-02 17:41:24.97186+00	4viyzoieqlbk	dec1d1ba-1cf1-42c2-b095-0a838fc0e86f
00000000-0000-0000-0000-000000000000	316	fseplsa6v7hx	73cad07a-ae07-4ad6-be61-1e59d3943953	t	2026-07-16 18:06:32.104125+00	2026-07-16 19:07:38.694322+00	sud7j264rf5j	d07bf3be-ca51-43fa-ad8b-3929c2362d12
00000000-0000-0000-0000-000000000000	320	tg3glvt52zvu	9751051b-d866-4336-a7ce-a2b3f4605835	f	2026-07-16 19:18:57.947253+00	2026-07-16 19:18:57.947253+00	\N	fe598a0d-5be3-487f-8747-3dc9cbfc3884
00000000-0000-0000-0000-000000000000	330	pbalned7wofl	93b861a6-d5bd-4248-a0b1-63d6bb067b66	f	2026-07-17 09:38:44.486954+00	2026-07-17 09:38:44.486954+00	\N	80584205-4294-45d1-81ef-d42116862f43
00000000-0000-0000-0000-000000000000	692	vznh4qlh4fcf	f3224654-1357-4933-a356-d10bf55f7354	t	2026-08-03 17:34:44.536339+00	2026-08-03 18:58:17.135211+00	6qrgs2ty5ob5	dec1d1ba-1cf1-42c2-b095-0a838fc0e86f
00000000-0000-0000-0000-000000000000	361	eks5l3ydix63	73cad07a-ae07-4ad6-be61-1e59d3943953	t	2026-07-18 16:44:44.539335+00	2026-07-25 14:05:40.321723+00	7t5noq4hf5km	d07bf3be-ca51-43fa-ad8b-3929c2362d12
00000000-0000-0000-0000-000000000000	286	vi457kumef3f	81ade54b-a78a-497b-9181-dc06376c7d9f	t	2026-07-14 18:29:15.115603+00	2026-07-14 20:08:22.944745+00	\N	8a9d8fd0-acc6-4135-b5bb-5dce10f7d432
00000000-0000-0000-0000-000000000000	290	6penqikr7y6v	3d1eb4e1-b2da-465b-b9b6-48d13e167d7a	f	2026-07-14 21:32:34.735555+00	2026-07-14 21:32:34.735555+00	\N	5f833739-d60b-433d-bea6-7a97f682e713
00000000-0000-0000-0000-000000000000	695	qcvdxtcfkk7q	f3224654-1357-4933-a356-d10bf55f7354	t	2026-08-03 18:58:17.142186+00	2026-08-04 13:36:46.190447+00	vznh4qlh4fcf	dec1d1ba-1cf1-42c2-b095-0a838fc0e86f
00000000-0000-0000-0000-000000000000	722	e6dlhuyqron7	f3224654-1357-4933-a356-d10bf55f7354	t	2026-08-04 13:36:46.210975+00	2026-08-04 14:52:09.820957+00	qcvdxtcfkk7q	dec1d1ba-1cf1-42c2-b095-0a838fc0e86f
00000000-0000-0000-0000-000000000000	726	4lunte6luivq	f3224654-1357-4933-a356-d10bf55f7354	f	2026-08-04 14:52:09.833409+00	2026-08-04 14:52:09.833409+00	e6dlhuyqron7	dec1d1ba-1cf1-42c2-b095-0a838fc0e86f
00000000-0000-0000-0000-000000000000	979	vhsmd2dzbjns	794c5058-c511-4509-ad40-938ce0d45eae	t	2026-08-19 17:04:34.593398+00	2026-08-19 18:11:33.073515+00	\N	c0534111-bc6c-4047-9755-e62af5173bbe
00000000-0000-0000-0000-000000000000	980	34rs6iambero	794c5058-c511-4509-ad40-938ce0d45eae	t	2026-08-19 18:11:33.094486+00	2026-08-20 03:15:01.104163+00	vhsmd2dzbjns	c0534111-bc6c-4047-9755-e62af5173bbe
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
20250731150234
20250804100000
20250901200500
20250903112500
20250904133000
20250925093508
20251007112900
20251104100000
20251111201300
20251201000000
20260115000000
20260121000000
20260219120000
20260302000000
20260625000000
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag, oauth_client_id, refresh_token_hmac_key, refresh_token_counter, scopes) FROM stdin;
00c871ae-c7d5-4193-aa29-704e583d3908	13826d95-961c-494e-a2c2-018298bbda09	2026-07-06 14:25:58.169042+00	2026-07-06 14:25:58.169042+00	\N	aal1	\N	\N	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.5 Mobile/15E148 Safari/604.1	157.50.187.132	\N	\N	\N	\N	\N
338e365b-4629-4df2-8a9a-24700e972d3e	0b3bf0ee-58ef-4f17-8567-ed5c07964c96	2026-07-06 16:30:43.695923+00	2026-07-07 01:40:00.652815+00	\N	aal1	\N	2026-07-07 01:40:00.6527	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.5.2 Mobile/15E148 Safari/604.1	42.108.27.135	\N	\N	\N	\N	\N
dec1d1ba-1cf1-42c2-b095-0a838fc0e86f	f3224654-1357-4933-a356-d10bf55f7354	2026-08-02 14:34:21.139799+00	2026-08-04 14:52:09.860953+00	\N	aal1	\N	2026-08-04 14:52:09.860841	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.5 Safari/605.1.15	49.205.203.56	\N	\N	\N	\N	\N
457eb078-bb2f-4d55-afa5-2ad106bebd83	3d1eb4e1-b2da-465b-b9b6-48d13e167d7a	2026-07-14 17:57:38.233683+00	2026-07-14 17:57:38.233683+00	\N	aal1	\N	\N	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.5 Mobile/15E148 Safari/604.1	49.43.217.59	\N	\N	\N	\N	\N
df56247e-4e42-4aab-ac31-42cfc9d55567	02989991-856d-4edb-bee7-26569343d07c	2026-07-06 07:59:13.800472+00	2026-07-06 07:59:13.800472+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	119.226.236.9	\N	\N	\N	\N	\N
66894c28-78a4-46b6-93b9-dcaf3efe6438	fae6b5e3-7b7b-4195-910c-e1a0ec3159a5	2026-07-06 10:00:47.396711+00	2026-07-06 10:59:24.03117+00	\N	aal1	\N	2026-07-06 10:59:24.031056	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:152.0) Gecko/20100101 Firefox/152.0	103.88.182.2	\N	\N	\N	\N	\N
f5e8fbcb-7f83-4b37-aabf-a9bb7e721d28	b9e20678-6e1b-4a4a-9cde-e30e6cfc80eb	2026-07-16 17:16:06.389971+00	2026-07-16 17:16:06.389971+00	\N	aal1	\N	\N	Mozilla/5.0 (iPhone; CPU iPhone OS 26_2_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/150.0.7871.51 Mobile/15E148 Safari/604.1	106.192.212.195	\N	\N	\N	\N	\N
7c620a01-4ea9-421e-a416-72fbb5b0a197	57022196-7fc3-4bb8-88f9-578c4c3832c6	2026-07-11 06:55:44.755888+00	2026-07-11 06:55:44.755888+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	119.226.236.9	\N	\N	\N	\N	\N
4ae3e6d4-2a0a-40e6-a388-f67b81b22435	674599f7-e03b-4c53-8d8f-4d3bbc50bf64	2026-07-18 06:58:05.987332+00	2026-07-22 16:16:06.30435+00	\N	aal1	\N	2026-07-22 16:16:06.304251	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.4 Mobile/15E148 Safari/604.1	106.51.204.65	\N	\N	\N	\N	\N
164f7c29-89f1-499c-b7e0-5928e5be225b	65fae4b9-0c10-4dc8-b57c-b4d1d1cecb1f	2026-07-17 04:03:54.607044+00	2026-07-17 07:28:55.398875+00	\N	aal1	\N	2026-07-17 07:28:55.398757	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	42.104.154.26	\N	\N	\N	\N	\N
8a9d8fd0-acc6-4135-b5bb-5dce10f7d432	81ade54b-a78a-497b-9181-dc06376c7d9f	2026-07-14 18:29:15.096044+00	2026-07-14 20:08:22.974764+00	\N	aal1	\N	2026-07-14 20:08:22.974649	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	49.42.184.235	\N	\N	\N	\N	\N
5f833739-d60b-433d-bea6-7a97f682e713	3d1eb4e1-b2da-465b-b9b6-48d13e167d7a	2026-07-14 21:32:34.722581+00	2026-07-14 21:32:34.722581+00	\N	aal1	\N	\N	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.5 Mobile/15E148 Safari/604.1	49.43.217.59	\N	\N	\N	\N	\N
71fa4394-a791-4cfe-8e21-af138c027e93	0b3bf0ee-58ef-4f17-8567-ed5c07964c96	2026-07-06 16:42:53.286529+00	2026-07-06 20:42:17.549043+00	\N	aal1	\N	2026-07-06 20:42:17.54895	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	49.36.107.193	\N	\N	\N	\N	\N
e74f89d6-a0ee-4b84-87cd-e3080d3beeed	3d1eb4e1-b2da-465b-b9b6-48d13e167d7a	2026-07-14 21:34:32.231303+00	2026-07-14 21:34:32.231303+00	\N	aal1	\N	\N	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.5 Mobile/15E148 Safari/604.1	49.43.217.59	\N	\N	\N	\N	\N
c9d9f062-7a2d-4556-9a10-f0d79c5bf5b4	70d6dcbc-b05a-408e-b0a6-519a1e2e3cef	2026-07-10 02:36:39.427117+00	2026-07-10 17:52:32.695519+00	\N	aal1	\N	2026-07-10 17:52:32.695409	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	98.221.43.228	\N	\N	\N	\N	\N
f959cca9-4288-4080-ab18-922ba600f677	16ffc989-0287-4969-b279-bb957c906c51	2026-07-15 07:04:00.366649+00	2026-07-16 00:40:50.314135+00	\N	aal1	\N	2026-07-16 00:40:50.314014	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Mobile Safari/537.36	157.40.162.237	\N	\N	\N	\N	\N
80584205-4294-45d1-81ef-d42116862f43	93b861a6-d5bd-4248-a0b1-63d6bb067b66	2026-07-17 09:38:44.474387+00	2026-07-17 09:38:44.474387+00	\N	aal1	\N	\N	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.5 Mobile/15E148 Safari/604.1	124.155.205.24	\N	\N	\N	\N	\N
7ffbe1a4-14b0-4426-be50-32c8e9271a65	88f68f9f-5af9-4a19-9252-842e5e0a1776	2026-07-22 13:51:57.628431+00	2026-07-22 13:51:57.628431+00	\N	aal1	\N	\N	Mozilla/5.0 (Linux; Android 15; V2432) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/123.0.6312.118 Mobile Safari/537.36 VivoBrowser/15.1.0.3	152.57.13.9	\N	\N	\N	\N	\N
fe598a0d-5be3-487f-8747-3dc9cbfc3884	9751051b-d866-4336-a7ce-a2b3f4605835	2026-07-16 19:18:57.923076+00	2026-07-16 19:18:57.923076+00	\N	aal1	\N	\N	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Mobile Safari/537.36	223.184.141.112	\N	\N	\N	\N	\N
5e0bf425-ac14-4f37-b49a-dd1d530568d6	caecce43-57a3-40aa-8a18-b22a318b3364	2026-07-08 07:45:49.218427+00	2026-07-08 07:45:49.218427+00	\N	aal1	\N	\N	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Mobile Safari/537.36	152.59.158.38	\N	\N	\N	\N	\N
c0534111-bc6c-4047-9755-e62af5173bbe	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-19 17:04:34.592289+00	2026-08-20 03:15:01.160731+00	\N	aal1	\N	2026-08-20 03:15:01.160591	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.5 Safari/605.1.15	103.88.182.2	\N	\N	\N	\N	\N
d07bf3be-ca51-43fa-ad8b-3929c2362d12	73cad07a-ae07-4ad6-be61-1e59d3943953	2026-07-05 20:25:43.149372+00	2026-07-27 15:19:46.605752+00	\N	aal1	\N	2026-07-27 15:19:46.605636	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.5.2 Mobile/15E148 Safari/604.1	110.224.2.83	\N	\N	\N	\N	\N
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
00000000-0000-0000-0000-000000000000	13826d95-961c-494e-a2c2-018298bbda09	authenticated	authenticated	kaushikdas00@gmail.com	$2a$10$QsZ2FsreRFuUmKrF3aCBKu1PFr3NvKdUDQyNArfR9n.d/UADmIPbW	2026-07-06 14:25:58.161348+00	\N		2026-07-06 14:25:32.781242+00		\N			\N	2026-07-06 14:25:58.167148+00	{"provider": "email", "providers": ["email"]}	{"sub": "13826d95-961c-494e-a2c2-018298bbda09", "email": "kaushikdas00@gmail.com", "email_verified": true, "phone_verified": false}	\N	2026-07-06 14:25:32.723829+00	2026-07-06 14:25:58.197469+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	3d1eb4e1-b2da-465b-b9b6-48d13e167d7a	authenticated	authenticated	diya6665@gmail.com	\N	2026-07-14 17:57:38.22439+00	\N		\N		\N			\N	2026-07-14 21:34:32.229163+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "115868545157363939361", "name": "Sandhya Sharma", "email": "diya6665@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocLZgixdAIDDlu4GHDwcRB-OQmtbH5iMPKQ-wBy8wifUsh0STSIK=s96-c", "full_name": "Sandhya Sharma", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocLZgixdAIDDlu4GHDwcRB-OQmtbH5iMPKQ-wBy8wifUsh0STSIK=s96-c", "provider_id": "115868545157363939361", "email_verified": true, "phone_verified": false}	\N	2026-07-14 17:57:38.192083+00	2026-07-14 21:34:32.241789+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	794c5058-c511-4509-ad40-938ce0d45eae	authenticated	authenticated	aseshsarkar51@gmail.com	\N	2026-07-05 06:22:53.91087+00	\N		\N		\N			\N	2026-08-19 17:04:34.592209+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "118249479869549119197", "name": "asesh sarkar", "email": "aseshsarkar51@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocK_sH3eBI83fr2NCnWC6OYuNcYiTzLbfnI5dkk8NDvDIcrbD0_s=s96-c", "full_name": "asesh sarkar", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocK_sH3eBI83fr2NCnWC6OYuNcYiTzLbfnI5dkk8NDvDIcrbD0_s=s96-c", "provider_id": "118249479869549119197", "email_verified": true, "phone_verified": false}	\N	2026-07-05 06:22:53.895865+00	2026-08-20 03:15:01.143681+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	596b2102-4ae0-430f-93c5-c9847886cf12	authenticated	authenticated	pooja.m@bmsca.org	\N	2026-07-05 17:11:03.699623+00	\N		\N		\N			\N	2026-07-05 17:11:03.706451+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "102040178697397597560", "name": "Ms. Pooja Mailsamy", "email": "pooja.m@bmsca.org", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKPA--8xvOsz6Vr3UWlOm-gHSM7hhG-9Sj3MZrbx2Q180aaNQ=s96-c", "full_name": "Ms. Pooja Mailsamy", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKPA--8xvOsz6Vr3UWlOm-gHSM7hhG-9Sj3MZrbx2Q180aaNQ=s96-c", "provider_id": "102040178697397597560", "custom_claims": {"hd": "bmsca.org"}, "email_verified": true, "phone_verified": false}	\N	2026-07-05 17:11:03.665903+00	2026-07-05 17:11:03.713499+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	73cad07a-ae07-4ad6-be61-1e59d3943953	authenticated	authenticated	sarkaronline10@gmail.com	\N	2026-07-05 20:25:43.135326+00	\N		\N		\N			\N	2026-07-05 20:25:43.1471+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "116171895639809519056", "name": "Kalyan Sarkar", "email": "sarkaronline10@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJxwt9p7svbd5geRJ871rDP7KPxBxTE02r1GeqbR113B6swMA=s96-c", "full_name": "Kalyan Sarkar", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJxwt9p7svbd5geRJ871rDP7KPxBxTE02r1GeqbR113B6swMA=s96-c", "provider_id": "116171895639809519056", "email_verified": true, "phone_verified": false}	\N	2026-07-05 20:25:43.096073+00	2026-07-27 15:19:46.586981+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	b9e20678-6e1b-4a4a-9cde-e30e6cfc80eb	authenticated	authenticated	parakhkatre@gmail.com	\N	2026-07-16 17:16:06.38122+00	\N		\N		\N			\N	2026-07-16 17:16:06.388756+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "100960832167854243343", "name": "Parakh Katre", "email": "parakhkatre@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocLSHzWB3qdgGKSB4A-BdjRYMmJbc9w2Plc9hg1hHWQ_l4FXYw=s96-c", "full_name": "Parakh Katre", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocLSHzWB3qdgGKSB4A-BdjRYMmJbc9w2Plc9hg1hHWQ_l4FXYw=s96-c", "provider_id": "100960832167854243343", "email_verified": true, "phone_verified": false}	\N	2026-07-16 17:16:06.344187+00	2026-07-16 17:16:06.428238+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	caecce43-57a3-40aa-8a18-b22a318b3364	authenticated	authenticated	rishi7souvik@gmail.com	\N	2026-07-08 07:45:49.209996+00	\N		\N		\N			\N	2026-07-08 07:45:49.217303+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "108310024042724957882", "name": "Souvik Bagchi", "email": "rishi7souvik@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJ-wi6MV1ojgy9n8yIdB0wnHDYprgup--nZdTKf6eSIvXr1SDfh=s96-c", "full_name": "Souvik Bagchi", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJ-wi6MV1ojgy9n8yIdB0wnHDYprgup--nZdTKf6eSIvXr1SDfh=s96-c", "provider_id": "108310024042724957882", "email_verified": true, "phone_verified": false}	\N	2026-07-08 07:45:49.184663+00	2026-07-08 07:45:49.229614+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	02989991-856d-4edb-bee7-26569343d07c	authenticated	authenticated	rohit.rp@bmsca.org	\N	2026-07-06 07:56:09.940243+00	\N		\N		\N			\N	2026-07-06 07:59:13.798294+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "105765673274737054194", "name": "Rohit R Prabhu", "email": "rohit.rp@bmsca.org", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJ9iGGLzpV-DRpgwFQkYPRz5h83Mj6dtOCJgO5jr40FJg0EZA=s96-c", "full_name": "Rohit R Prabhu", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJ9iGGLzpV-DRpgwFQkYPRz5h83Mj6dtOCJgO5jr40FJg0EZA=s96-c", "provider_id": "105765673274737054194", "custom_claims": {"hd": "bmsca.org"}, "email_verified": true, "phone_verified": false}	\N	2026-07-06 07:56:09.913965+00	2026-07-06 07:59:13.804727+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	d9da27bf-94eb-4751-a96c-af37f3c601e7	authenticated	authenticated	xepi314@gmail.com	\N	2026-07-20 16:29:47.621302+00	\N		\N		\N			\N	2026-07-20 16:35:34.212365+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "112788440370978048702", "name": "import brain", "email": "xepi314@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJOWSjLX9LpRTx_7Gbvfc9Lfh57h1nbSh3eipjzJ9OLm7fJ4dM=s96-c", "full_name": "import brain", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJOWSjLX9LpRTx_7Gbvfc9Lfh57h1nbSh3eipjzJ9OLm7fJ4dM=s96-c", "provider_id": "112788440370978048702", "email_verified": true, "phone_verified": false}	\N	2026-07-20 16:29:47.58524+00	2026-07-20 16:35:34.232898+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	f3224654-1357-4933-a356-d10bf55f7354	authenticated	authenticated	asesh.s@bmsca.org	\N	2026-07-05 17:57:51.770815+00	\N		\N		\N			\N	2026-08-02 14:34:21.137603+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "117911998377255858055", "name": "Dr. Asesh Sarkar", "email": "asesh.s@bmsca.org", "picture": "https://lh3.googleusercontent.com/a/ACg8ocK90aYxW_t_bb-RgCRq70xkMXqWwZR0xvJ-TXFsHO9Q3VU2vg=s96-c", "full_name": "Dr. Asesh Sarkar", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocK90aYxW_t_bb-RgCRq70xkMXqWwZR0xvJ-TXFsHO9Q3VU2vg=s96-c", "provider_id": "117911998377255858055", "custom_claims": {"hd": "bmsca.org"}, "email_verified": true, "phone_verified": false}	\N	2026-07-05 17:57:51.738581+00	2026-08-04 14:52:09.848255+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	fae6b5e3-7b7b-4195-910c-e1a0ec3159a5	authenticated	authenticated	naveen.k@bmsca.org	\N	2026-07-06 10:00:47.384664+00	\N		\N		\N			\N	2026-07-06 10:00:47.394584+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "109176001650248922868", "name": "Dr. Naveen Kishore Khambadkone", "email": "naveen.k@bmsca.org", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKOoeiDG62OVbFtHlpXhuzTdwEQzo8WxspWBfl5Bp2Ra8gNgQ=s96-c", "full_name": "Dr. Naveen Kishore Khambadkone", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKOoeiDG62OVbFtHlpXhuzTdwEQzo8WxspWBfl5Bp2Ra8gNgQ=s96-c", "provider_id": "109176001650248922868", "custom_claims": {"hd": "bmsca.org"}, "email_verified": true, "phone_verified": false}	\N	2026-07-06 10:00:47.341284+00	2026-07-06 10:59:24.020226+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	13554111-b50c-44ad-af7b-4988c8209afb	authenticated	authenticated	asarkar@ar.iitr.ac.in	\N	2026-07-05 06:25:33.40525+00	\N		\N	6be92d11f3eff66bd66a9e261ba5f928c9216c6fdb50c2ac988e4ce5	2026-07-05 16:41:27.987041+00			\N	2026-08-12 14:03:05.215365+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "106699219073814621582", "name": "ASESH SARKAR", "email": "asarkar@ar.iitr.ac.in", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKXVAHj_DqjoizbTLbp6xpLfLXYrHpvSYwYagKZchrsSWNWC8U=s96-c", "full_name": "ASESH SARKAR", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKXVAHj_DqjoizbTLbp6xpLfLXYrHpvSYwYagKZchrsSWNWC8U=s96-c", "provider_id": "106699219073814621582", "custom_claims": {"hd": "ar.iitr.ac.in"}, "email_verified": true, "phone_verified": false}	\N	2026-07-05 06:25:33.385872+00	2026-08-12 14:03:05.246828+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	57022196-7fc3-4bb8-88f9-578c4c3832c6	authenticated	authenticated	yogitaright@gmail.com	\N	2026-07-11 06:55:44.745417+00	\N		\N		\N			\N	2026-07-11 06:55:44.754615+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "112434780019931353114", "name": "Yogita Choudhari", "email": "yogitaright@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKWPIbcbCxgE_lhOzayWSMsi-UZNgwj6jltWHX0sSgwqx7oyFhM=s96-c", "full_name": "Yogita Choudhari", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKWPIbcbCxgE_lhOzayWSMsi-UZNgwj6jltWHX0sSgwqx7oyFhM=s96-c", "provider_id": "112434780019931353114", "email_verified": true, "phone_verified": false}	\N	2026-07-11 06:55:44.721035+00	2026-07-11 06:55:44.767382+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	81ade54b-a78a-497b-9181-dc06376c7d9f	authenticated	authenticated	queenbee.contact1@gmail.com	\N	2026-07-14 18:29:15.085563+00	\N		\N		\N			\N	2026-07-14 18:29:15.094771+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "110898796349013929292", "name": "Queen Bee", "email": "queenbee.contact1@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKK8tUA110Y7zc0MMf_UlaZyE4Yxd3AuV4w17M1Cippv-2GKTs=s96-c", "full_name": "Queen Bee", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKK8tUA110Y7zc0MMf_UlaZyE4Yxd3AuV4w17M1Cippv-2GKTs=s96-c", "provider_id": "110898796349013929292", "email_verified": true, "phone_verified": false}	\N	2026-07-14 18:29:15.049223+00	2026-07-14 20:08:22.961931+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	16ffc989-0287-4969-b279-bb957c906c51	authenticated	authenticated	rahuldas066@gmail.com	\N	2026-07-15 07:04:00.354578+00	\N		\N		\N			\N	2026-07-15 07:04:00.36538+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "116600578525987489830", "name": "Rahul Das", "email": "rahuldas066@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJZ4ZyJzv0f9yhikN21cEvLejRl0w_y5jGVK6KvMBd1mAUQLpow=s96-c", "full_name": "Rahul Das", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJZ4ZyJzv0f9yhikN21cEvLejRl0w_y5jGVK6KvMBd1mAUQLpow=s96-c", "provider_id": "116600578525987489830", "email_verified": true, "phone_verified": false}	\N	2026-07-15 07:04:00.306027+00	2026-07-16 00:40:50.302233+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	9751051b-d866-4336-a7ce-a2b3f4605835	authenticated	authenticated	debjitsardar743426@gmail.com	\N	2026-07-16 19:18:57.911801+00	\N		\N		\N			\N	2026-07-16 19:18:57.919995+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "100965135966347500128", "name": "Debjit Sardar", "email": "debjitsardar743426@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocL8cfBVEWSF4QaVxGqLBQnQ8TMa22RBHCkLSCsen7On6-2MDFZb=s96-c", "full_name": "Debjit Sardar", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocL8cfBVEWSF4QaVxGqLBQnQ8TMa22RBHCkLSCsen7On6-2MDFZb=s96-c", "provider_id": "100965135966347500128", "email_verified": true, "phone_verified": false}	\N	2026-07-16 19:18:57.870562+00	2026-07-16 19:18:57.958041+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	88f68f9f-5af9-4a19-9252-842e5e0a1776	authenticated	authenticated	varsha292627@gmail.com	\N	2026-07-22 13:51:57.617631+00	\N		\N		\N			\N	2026-07-22 13:51:57.626168+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "118004784576018256175", "name": "Varshini", "email": "varsha292627@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKHictThU49X61qQDXmEULl1uSdWQv4gYJvTrX3WTb4y_Wx5Tw=s96-c", "full_name": "Varshini", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKHictThU49X61qQDXmEULl1uSdWQv4gYJvTrX3WTb4y_Wx5Tw=s96-c", "provider_id": "118004784576018256175", "email_verified": true, "phone_verified": false}	\N	2026-07-22 13:51:57.575643+00	2026-07-22 13:51:57.664481+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	93b861a6-d5bd-4248-a0b1-63d6bb067b66	authenticated	authenticated	monithakumar147k@gmail.com	\N	2026-07-17 09:38:44.463357+00	\N		\N		\N			\N	2026-07-17 09:38:44.472777+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "101458068404335430271", "name": "Monithakumar", "email": "monithakumar147k@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocL86WqrYnOwsKel0Xg3VtvnfyKHU9gDpJiDNIRvthQzIbGKP3Y=s96-c", "full_name": "Monithakumar", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocL86WqrYnOwsKel0Xg3VtvnfyKHU9gDpJiDNIRvthQzIbGKP3Y=s96-c", "provider_id": "101458068404335430271", "email_verified": true, "phone_verified": false}	\N	2026-07-17 09:38:44.432539+00	2026-07-17 09:38:44.500146+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	0b3bf0ee-58ef-4f17-8567-ed5c07964c96	authenticated	authenticated	thakur.nitendra24@gmail.com	\N	2026-07-06 16:30:43.686989+00	\N		\N		\N			\N	2026-07-06 16:42:53.280937+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "113608888260705650384", "name": "Nitendra Thakur", "email": "thakur.nitendra24@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocIcn16KVyQJRiozhuz6dasbeYOMyDpznIdLiViI8doSS71iS2t9mw=s96-c", "full_name": "Nitendra Thakur", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocIcn16KVyQJRiozhuz6dasbeYOMyDpznIdLiViI8doSS71iS2t9mw=s96-c", "provider_id": "113608888260705650384", "email_verified": true, "phone_verified": false}	\N	2026-07-06 16:30:43.664074+00	2026-07-07 01:40:00.636577+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	65fae4b9-0c10-4dc8-b57c-b4d1d1cecb1f	authenticated	authenticated	suryaps@tkmce.ac.in	\N	2026-07-17 04:03:54.589585+00	\N		\N		\N			\N	2026-07-17 04:03:54.604752+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "103588304559153768719", "name": "Prof. Surya P.S", "email": "suryaps@tkmce.ac.in", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKobCDYmqKiu1F7X7Cr5692lN3kTHM83jkU2YT0gFKKVcf35CM=s96-c", "full_name": "Prof. Surya P.S", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKobCDYmqKiu1F7X7Cr5692lN3kTHM83jkU2YT0gFKKVcf35CM=s96-c", "provider_id": "103588304559153768719", "custom_claims": {"hd": "tkmce.ac.in"}, "email_verified": true, "phone_verified": false}	\N	2026-07-17 04:03:54.549279+00	2026-07-17 07:28:55.386895+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	70d6dcbc-b05a-408e-b0a6-519a1e2e3cef	authenticated	authenticated	niravrakar2@gmail.com	\N	2026-07-10 02:36:39.415298+00	\N		\N		\N			\N	2026-07-10 02:36:39.425956+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "114431921419462930201", "name": "Niravra", "email": "niravrakar2@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKohQnXk3K76q5p4xWQEwkRmpeGPWzh9eEyXGFYjVijz6aTrW_4=s96-c", "full_name": "Niravra", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKohQnXk3K76q5p4xWQEwkRmpeGPWzh9eEyXGFYjVijz6aTrW_4=s96-c", "provider_id": "114431921419462930201", "email_verified": true, "phone_verified": false}	\N	2026-07-10 02:36:39.376784+00	2026-07-10 17:52:32.683169+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	674599f7-e03b-4c53-8d8f-4d3bbc50bf64	authenticated	authenticated	goginenisamarth@gmail.com	\N	2026-07-18 06:58:05.9719+00	\N		\N		\N			\N	2026-07-18 06:58:05.98501+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "102003226648820322119", "name": "Samarth Gogineni", "email": "goginenisamarth@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocLFBJOnD3Srrp2D2j1C7681P49GikIs8c6Aq9Nu1FTlG_jW8Q=s96-c", "full_name": "Samarth Gogineni", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocLFBJOnD3Srrp2D2j1C7681P49GikIs8c6Aq9Nu1FTlG_jW8Q=s96-c", "provider_id": "102003226648820322119", "email_verified": true, "phone_verified": false}	\N	2026-07-18 06:58:05.923845+00	2026-07-22 16:16:06.276541+00	\N	\N			\N		0	\N		\N	f	\N	f
\.


--
-- Data for Name: webauthn_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.webauthn_challenges (id, user_id, challenge_type, session_data, created_at, expires_at) FROM stdin;
\.


--
-- Data for Name: webauthn_credentials; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.webauthn_credentials (id, user_id, credential_id, public_key, attestation_type, aaguid, sign_count, transports, backup_eligible, backed_up, friendly_name, created_at, updated_at, last_used_at) FROM stdin;
\.


--
-- Data for Name: album_photos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.album_photos (id, profile_id, signer_user_id, url, lat, lng, place_name, taken_at, created_at, album_id) FROM stdin;
63ab4a75-3670-417b-98dc-5e1abde58060	51323e47-38a0-405d-b597-a56cc534ba12	794c5058-c511-4509-ad40-938ce0d45eae	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/album_794c5058-c511-4509-ad40-938ce0d45eae_1785302179410_iq71p7?v=1785302180542	12.97	77.59	Bengaluru	2025-03-05 05:40:24+00	2026-07-29 05:16:20.620395+00	\N
5c8b6bbe-308c-4bb5-bab3-2ca77f89e68a	51323e47-38a0-405d-b597-a56cc534ba12	794c5058-c511-4509-ad40-938ce0d45eae	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/album_794c5058-c511-4509-ad40-938ce0d45eae_1785425644793_0uunuz?v=1785425645009	29.38	79.46	Nainital	\N	2026-07-30 15:34:05.088066+00	cf16f2b8-c4fc-46f8-ade8-4d21c136c821
\.


--
-- Data for Name: albums; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.albums (id, profile_id, name, created_at) FROM stdin;
cf16f2b8-c4fc-46f8-ade8-4d21c136c821	51323e47-38a0-405d-b597-a56cc534ba12	hello	2026-07-30 15:33:18.194445+00
\.


--
-- Data for Name: blocks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.blocks (id, blocker_user_id, blocked_profile_id, created_at) FROM stdin;
\.


--
-- Data for Name: circle_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.circle_members (id, circle_id, user_id, profile_id, name, username, ink, created_at) FROM stdin;
b0d80684-31f7-49f8-9978-09b0d3c7dbbd	b4699fa3-c5f5-497a-b7f7-9c23afabad8e	794c5058-c511-4509-ad40-938ce0d45eae	51323e47-38a0-405d-b597-a56cc534ba12	asesh	aseshsarkar	#4E7065	2026-07-30 04:34:56.282921+00
6fa56dc2-10ff-45ae-9555-b026739ca084	b4699fa3-c5f5-497a-b7f7-9c23afabad8e	13554111-b50c-44ad-af7b-4988c8209afb	591eb8c2-38f2-4b3d-9b13-f619aa185c5d	Rakesh	rakesh	#57614A	2026-07-30 04:34:56.282921+00
\.


--
-- Data for Name: circle_messages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.circle_messages (id, circle_id, sender_user_id, sender_name, body, image_url, created_at, key_wraps) FROM stdin;
71d648a7-6ab6-49ab-919f-8d9e3cf8e438	b4699fa3-c5f5-497a-b7f7-9c23afabad8e	794c5058-c511-4509-ad40-938ce0d45eae	asesh	\N	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/circle_794c5058-c511-4509-ad40-938ce0d45eae_1785386106439_w69um0?v=1785386106778	2026-07-30 04:35:10.665552+00	\N
c50069ff-e7b7-4a5f-b591-f44f66077096	b4699fa3-c5f5-497a-b7f7-9c23afabad8e	794c5058-c511-4509-ad40-938ce0d45eae	asesh	ok	\N	2026-07-30 04:35:49.281546+00	\N
8f78c6f8-d29c-4991-ab7f-1d13ab71651a	b4699fa3-c5f5-497a-b7f7-9c23afabad8e	794c5058-c511-4509-ad40-938ce0d45eae	asesh	QA test circle message	\N	2026-07-30 18:39:10.215961+00	\N
427b3dec-854a-413a-a86f-b54ccbfa6200	b4699fa3-c5f5-497a-b7f7-9c23afabad8e	794c5058-c511-4509-ad40-938ce0d45eae	asesh	\N	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/circle_794c5058-c511-4509-ad40-938ce0d45eae_1785436779332_su75xc?v=1785436779513	2026-07-30 18:39:39.585679+00	\N
\.


--
-- Data for Name: circles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.circles (id, name, created_by, created_at) FROM stdin;
b4699fa3-c5f5-497a-b7f7-9c23afabad8e	hostel	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-30 04:34:56.165903+00
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.comments (id, entry_id, author_user_id, name, body, created_at, parent_id) FROM stdin;
cecc1bf8-7fd5-42be-9487-6ddef809ea4e	88c79fdb-12b5-43a2-a7d5-daee30dccf53	794c5058-c511-4509-ad40-938ce0d45eae	asesh	Hello Boss :)	2026-07-16 17:27:29.955566+00	\N
2700e887-89a8-4dba-bd79-6aa01cd83b17	88c79fdb-12b5-43a2-a7d5-daee30dccf53	b9e20678-6e1b-4a4a-9cde-e30e6cfc80eb	Parakh Katre	This is amazing	2026-07-16 17:29:34.306504+00	\N
69c0d2c2-03bd-43c0-9ffd-e009ad097dee	29d2255c-e66b-45c0-9dfe-2a5be6965d3a	794c5058-c511-4509-ad40-938ce0d45eae	asesh	Thank you @surya.	2026-07-17 07:59:40.243222+00	\N
4c0f8fc8-bd32-4b1b-84c6-5587361840bf	ed26c3e0-5785-4213-9907-c8dba2ceefa8	\N	RLS test guest	rls-check-guest	2026-07-31 08:27:47.885102+00	\N
4c474c01-cd1d-474e-8285-0efba6b1612c	ed26c3e0-5785-4213-9907-c8dba2ceefa8	\N	RLS test guest	rls-check-guest	2026-07-31 08:28:06.169018+00	\N
\.


--
-- Data for Name: conversations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.conversations (id, requester_profile_id, recipient_profile_id, status, created_at, requester_last_read_at, recipient_last_read_at) FROM stdin;
0cd59d0a-25de-4c73-a1e4-e9678e1f113a	51323e47-38a0-405d-b597-a56cc534ba12	5bff5eff-3dce-430b-a249-979fd0a92b84	pending	2026-08-01 18:51:22.145692+00	2026-08-01 20:57:01.280846+00	2026-08-01 18:51:22.145692+00
c19a3ca3-e1cd-4fd3-9965-59e792ba356e	51323e47-38a0-405d-b597-a56cc534ba12	ba1ee5d4-3b9a-46b9-8ec3-988874dc0256	pending	2026-07-13 07:10:07.192412+00	2026-07-30 17:46:02.601176+00	2026-07-13 07:10:07.192412+00
1cb72ec5-ed3f-4559-be44-83b3aef4f00e	51323e47-38a0-405d-b597-a56cc534ba12	88a5065b-8e97-45f0-942a-cfeb71e8ad73	pending	2026-07-06 14:44:43.221975+00	2026-08-05 19:03:07.530969+00	2026-07-06 14:44:43.221975+00
fc0e1ea9-e7df-4961-9c0d-6fd57e632619	51323e47-38a0-405d-b597-a56cc534ba12	6166861b-a5cd-41c8-8f85-ad94095c6abb	pending	2026-07-11 10:23:28.3904+00	2026-08-05 19:03:10.960625+00	2026-07-11 10:23:28.3904+00
3d319947-4bca-4dba-8035-beae5693b835	51323e47-38a0-405d-b597-a56cc534ba12	4bde932d-2f8b-448d-8b49-0c3b6973ecc9	accepted	2026-08-01 18:51:32.158181+00	2026-08-05 19:03:14.013028+00	2026-08-02 17:41:49.737113+00
677492cb-aa76-4258-82d1-f7a796c00e79	51323e47-38a0-405d-b597-a56cc534ba12	2116276d-a809-47d1-94c0-6a3a97f9ab3a	pending	2026-08-01 20:54:41.385319+00	2026-08-06 06:33:57.516406+00	2026-08-01 20:54:41.385319+00
f6b6f2f7-f3db-441c-912c-7e009a019184	51323e47-38a0-405d-b597-a56cc534ba12	40cfc39f-3473-41ac-943a-0d804fb34f7a	accepted	2026-07-05 17:13:05.24183+00	2026-08-11 15:41:28.677676+00	2026-07-05 17:18:40.962542+00
8c9351f7-ef2d-41a9-871c-34adcc5b4c89	51323e47-38a0-405d-b597-a56cc534ba12	347570df-4df5-408f-9d3e-71e6952063ff	pending	2026-07-06 04:14:34.088279+00	2026-08-01 18:57:41.578942+00	2026-07-06 04:14:34.088279+00
d5ac24bc-04bc-4497-a8b9-6153c85a44eb	f6b1d166-6e02-4134-bf30-56cc67a5d038	51323e47-38a0-405d-b597-a56cc534ba12	accepted	2026-08-01 18:49:58.008889+00	2026-08-12 14:03:45.53266+00	2026-08-11 15:46:14.141074+00
\.


--
-- Data for Name: diary_entries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.diary_entries (id, author_user_id, title, body, visibility, shared_with_user_id, shared_with_name, created_at, updated_at, photos, notes) FROM stdin;
3d02ef40-5345-4ba7-a191-36327ec2db56	794c5058-c511-4509-ad40-938ce0d45eae	\N	roorkee	private	\N	\N	2026-07-24 12:47:12.379655+00	2026-07-24 12:47:12.379655+00	["https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/diary_794c5058-c511-4509-ad40-938ce0d45eae_1784897231650_0?v=1784897232253"]	[{"at": "2026-08-01T20:02:05.298Z", "text": "ok"}]
827c25cb-ddce-4808-a8d6-292138489acf	794c5058-c511-4509-ad40-938ce0d45eae	\N	e2e:v1:9e7gmMz5MbznaxOl:IslmmNkDtU8VFQfM34tDfQos2AlkWEF2VL2BkvPvg4vFfdOZBiiJkEK2QrNkbnUr	private	\N	\N	2026-08-01 19:49:34.422538+00	2026-08-01 19:49:34.422538+00	[]	[]
f82b6e0f-11a1-40eb-b8aa-2f20482e81ab	13554111-b50c-44ad-af7b-4988c8209afb	\N	this seems fine.	private	\N	\N	2026-08-02 04:44:01.444058+00	2026-08-02 04:44:01.444058+00	[]	[]
c6e707b9-07ac-443b-b92d-5639281af2b8	794c5058-c511-4509-ad40-938ce0d45eae	\N	I am perfectly fine.	private	\N	\N	2026-07-18 09:47:19.968956+00	2026-07-18 09:47:19.968956+00	[]	[]
40be652d-bacc-45e8-871b-de16bb5202ac	794c5058-c511-4509-ad40-938ce0d45eae	\N	e2e:v1:hZFW17NsZtYsbGfz:cwMtbublZGpjqTXVVDDyT/Ukwgw=	private	\N	\N	2026-08-02 15:13:52.791076+00	2026-08-02 15:13:52.791076+00	[]	[]
db2bf360-0547-49fc-b494-0d4febdc452d	794c5058-c511-4509-ad40-938ce0d45eae	\N	e2e:v1:tYJyrL0EygIZNGWw:Zc2D2+ouzXPXj7umjY7ek8mopxMdhbCH	private	\N	\N	2026-08-04 17:24:16.562137+00	2026-08-04 17:24:16.562137+00	[]	[]
497967b4-fbec-474b-a9b0-9ae0ba6b08cf	794c5058-c511-4509-ad40-938ce0d45eae	\N	Today I made the changes.\nNext changes: refresh button its going to my book page.	private	\N	\N	2026-07-19 13:29:18.011499+00	2026-07-19 13:29:18.011499+00	[]	[]
48437a96-a175-4ada-9a05-279fe87bf854	794c5058-c511-4509-ad40-938ce0d45eae	\N	e2e:v1:FTQJ2ObzuygomdvI:PtN8K2aDZVGs9bpwHGHOocaMzS76fi1u5dgc	private	\N	\N	2026-08-06 06:32:46.634074+00	2026-08-06 06:32:46.634074+00	[]	[]
1005ebee-9246-43d5-8d30-ccc30afb7573	794c5058-c511-4509-ad40-938ce0d45eae	\N	hello	shared_person	13554111-b50c-44ad-af7b-4988c8209afb	Rakesh	2026-07-19 14:57:08.038715+00	2026-07-19 14:57:08.038715+00	[]	[]
3fef98a5-2d00-49ba-a965-a49a426f7e2a	794c5058-c511-4509-ad40-938ce0d45eae	456	235425	private	\N	\N	2026-07-21 05:56:47.784601+00	2026-07-21 05:56:47.784601+00	[]	[]
50882455-a483-4def-a90f-fa66759279a7	794c5058-c511-4509-ad40-938ce0d45eae	\N	mfwkjhfkj	shared_person	13826d95-961c-494e-a2c2-018298bbda09	Kaushik Das	2026-07-25 18:17:41.559009+00	2026-07-25 18:17:41.559009+00	[]	[]
f387fab7-6953-40ee-9865-f25b56ec5090	794c5058-c511-4509-ad40-938ce0d45eae	\N	fine.	private	\N	\N	2026-07-29 07:05:32.30367+00	2026-07-29 07:05:32.30367+00	[]	[]
7d48a5c1-7894-4d41-9ed0-5c96ca98eb12	794c5058-c511-4509-ad40-938ce0d45eae	wonderful		private	\N	\N	2026-07-30 07:44:45.530133+00	2026-07-30 07:44:45.530133+00	[]	[]
68c1e4f6-223b-4be8-af82-027b06583216	794c5058-c511-4509-ad40-938ce0d45eae	\N	add music/songs \nattachment song\nVideo	private	\N	\N	2026-07-28 15:42:18.57259+00	2026-07-28 15:42:18.57259+00	[]	[{"at": "2026-07-31T17:23:24.342Z", "text": "hello"}]
353dc816-e95a-4447-92f3-0c73bc6b2cf7	794c5058-c511-4509-ad40-938ce0d45eae	e2e:v1:lS4HKlUBqzUc28Gj:JRklHE1a0LNF264PT7hK3NwUOYFPu+M=		private	\N	\N	2026-08-11 13:49:54.041104+00	2026-08-11 13:49:54.041104+00	[]	[]
b71e6d74-ddd6-4f94-af5b-d0f429534309	794c5058-c511-4509-ad40-938ce0d45eae	e2e:v1:yqL06g5WH+Ufm7C3:2Sham1ofnp2swTg9BMVS7ggvTDYRAYADXTOfhaCC+Q==		private	\N	\N	2026-07-30 17:57:28.212989+00	2026-07-30 17:57:28.212989+00	[]	[{"at": "2026-07-31T17:23:43.617Z", "text": "hello"}, {"at": "2026-07-31T17:23:59.949Z", "text": "hello"}]
96170187-364c-4f31-9e05-7d12c005b247	794c5058-c511-4509-ad40-938ce0d45eae	e2e:v1:DngtR1CU054yZ7Qh:c9HwmXEfDAajLD8I6nNaQZ3PB/Ajjas=	e2e:v1:srvzG9OZWYc9a4p+:JxH2Xo1SfRW4GRYZg7oIa/yq1bqaMehNsxFR1VuPrgQDh6bOL1g2ew/y79Njz86uSSfK0mjjGKM=	private	\N	\N	2026-08-01 18:03:48.645352+00	2026-08-01 18:03:48.645352+00	["https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/diary_794c5058-c511-4509-ad40-938ce0d45eae_1785607421162_0?v=1785607422015"]	[]
\.


--
-- Data for Name: diary_moods; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.diary_moods (user_id, mood_date, mood, created_at) FROM stdin;
794c5058-c511-4509-ad40-938ce0d45eae	2026-07-18	calm	2026-07-18 16:02:48.036114+00
794c5058-c511-4509-ad40-938ce0d45eae	2026-07-19	notgood	2026-07-19 13:29:21.089798+00
794c5058-c511-4509-ad40-938ce0d45eae	2026-07-28	calm	2026-07-28 15:42:40.925992+00
794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29	okay	2026-07-29 07:05:27.189189+00
794c5058-c511-4509-ad40-938ce0d45eae	2026-07-30	great	2026-07-30 07:44:36.911762+00
794c5058-c511-4509-ad40-938ce0d45eae	2026-08-01	great	2026-08-01 13:17:35.427286+00
13554111-b50c-44ad-af7b-4988c8209afb	2026-08-02	calm	2026-08-02 04:43:46.282927+00
794c5058-c511-4509-ad40-938ce0d45eae	2026-08-02	calm	2026-08-02 15:13:40.855018+00
794c5058-c511-4509-ad40-938ce0d45eae	2026-08-04	great	2026-08-04 17:24:06.679089+00
794c5058-c511-4509-ad40-938ce0d45eae	2026-08-06	calm	2026-08-06 06:32:29.196857+00
794c5058-c511-4509-ad40-938ce0d45eae	2026-08-11	great	2026-08-11 13:49:38.225814+00
794c5058-c511-4509-ad40-938ce0d45eae	2026-08-19	calm	2026-08-19 17:39:21.587269+00
\.


--
-- Data for Name: entries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.entries (id, profile_id, signer_user_id, name, nickname, relation, word, answers, message, city, photos, color, status, created_at, unlock_at, diary_entry_id, guest_email, voice_url, voice_seconds, kind) FROM stdin;
ed26c3e0-5785-4213-9907-c8dba2ceefa8	40cfc39f-3473-41ac-943a-0d804fb34f7a	794c5058-c511-4509-ad40-938ce0d45eae	asesh (@aseshsarkar)			Hard working	[{"label": "Most likely to...", "value": "Genius"}, {"label": "A superpower you’d give them", "value": "Leadership"}, {"label": "A song that reminds you of them", "value": "Support"}, {"label": "Your best memory together", "value": "Joining"}, {"label": "One piece of advice for them", "value": "adventure"}, {"label": "Where you see them in 10 years", "value": "Chennai"}]	Be happy	{"lat": 13.08, "lng": 80.27, "name": "Chennai"}	{https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/e_1783271697615_0_fcv06r?v=1783271697820}	#3C4A5E	approved	2026-07-05 17:14:57.896213+00	\N	\N	\N	\N	\N	\N
f9d050f8-aa65-4e94-8055-04e3cc93d734	88a5065b-8e97-45f0-942a-cfeb71e8ad73	794c5058-c511-4509-ad40-938ce0d45eae	asesh (@aseshsarkar)		Best friend	Cool	[{"label": "Most likely to...", "value": "Become Billionaire"}, {"label": "A superpower you’d give them", "value": "Intelligence"}, {"label": "A song that reminds you of them", "value": "se je bose ache"}, {"label": "Your best memory together", "value": "Nainital"}, {"label": "One piece of advice for them", "value": "Have patience"}, {"label": "Where you see them in 10 years", "value": "Bangalore"}]	Keep dreaming	{"lat": 12.97, "lng": 77.59, "name": "Bengaluru"}	{https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/e_1783352264154_0_40pemv?v=1783352264433}	#3C4A5E	pending	2026-07-06 15:37:44.533705+00	\N	\N	\N	\N	\N	\N
66a324d2-21f4-49a1-851f-236952dccf03	6166861b-a5cd-41c8-8f85-ad94095c6abb	794c5058-c511-4509-ad40-938ce0d45eae	asesh (@aseshsarkar)			Innocent	[{"label": "How we met", "value": "College"}, {"label": "What I’ll miss most", "value": "Happiness"}, {"label": "Favourite memory from this chapter", "value": "First \\"5\\" outing."}, {"label": "My prediction for you", "value": "Team Captain [Women Cricket]"}, {"label": "How we’ll stay in touch", "value": "Always"}]	Always be confident of what you do.	{"lat": 12.97, "lng": 77.59, "name": "Bengaluru"}	{}	#3C4A5E	approved	2026-07-11 07:12:28.610043+00	\N	\N	\N	\N	\N	\N
1d536119-a88a-487f-b6a5-d866e313e001	51323e47-38a0-405d-b597-a56cc534ba12	57022196-7fc3-4bb8-88f9-578c4c3832c6	Dr. Yogita (@yogita)			mischievous smile	[]	miss our 4th floor cabin	{"lat": 12.97, "lng": 77.59, "name": "Bengaluru"}	{https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/e_1783753387603_0_hqrx8i?v=1783753387837}	#3C4A5E	approved	2026-07-11 07:03:08.096835+00	2026-07-11 18:30:00+00	\N	\N	\N	\N	\N
88c79fdb-12b5-43a2-a7d5-daee30dccf53	2116276d-a809-47d1-94c0-6a3a97f9ab3a	794c5058-c511-4509-ad40-938ce0d45eae	asesh (@aseshsarkar)			Machoman	[{"label": "Your best memory together", "value": "IIT Roorkee Hostel Cautley Bhawan"}, {"label": "One piece of advice for them", "value": "No advice, I need from you."}]	When are we meeting again?	{"lat": 30.32, "lng": 78.03, "name": "Dehradun"}	{https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/e_1784222781354_0_vz03c2?v=1784222781689}	#57614A	approved	2026-07-16 17:26:21.776437+00	\N	\N	\N	\N	\N	\N
33ba03b5-105a-4d3e-834c-49168ceee25f	347570df-4df5-408f-9d3e-71e6952063ff	794c5058-c511-4509-ad40-938ce0d45eae	asesh (@aseshsarkar)			Brotherhood	[{"label": "Your best memory together", "value": "School Canteen."}]	Stay well and happy.	{"lat": 22.57, "lng": 88.36, "name": "Kolkata"}	{https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/e_1784215980639_0_sxwpo7?v=1784215981045}	#4E7065	approved	2026-07-16 15:33:01.125717+00	\N	\N	\N	\N	\N	\N
c7a0f692-7b86-421a-ba52-3f188a4067a2	347570df-4df5-408f-9d3e-71e6952063ff	73cad07a-ae07-4ad6-be61-1e59d3943953	Kalyan Sarkar				[]	Hi	\N	{}	#57614A	approved	2026-07-15 02:22:34.116105+00	\N	\N	\N	\N	\N	\N
29d2255c-e66b-45c0-9dfe-2a5be6965d3a	51323e47-38a0-405d-b597-a56cc534ba12	65fae4b9-0c10-4dc8-b57c-b4d1d1cecb1f	Surya (@surya)		Close friend	Intellect	[{"label": "Something they taught you without knowing it", "value": "Reaserch ideas"}, {"label": "A moment they made you feel seen", "value": "Many"}, {"label": "If this were your last note to them", "value": "No"}, {"label": "Something they should forgive themselves for", "value": "😄"}, {"label": "The quality you hope they never lose", "value": "Philosophical"}]	Hi Asesh. Best wishes 🤞	\N	{}	#57614A	approved	2026-07-17 04:11:36.934434+00	\N	\N	\N	\N	\N	\N
db412ae2-4f61-4987-b325-e59afb36c6c9	5bff5eff-3dce-430b-a249-979fd0a92b84	794c5058-c511-4509-ad40-938ce0d45eae	asesh (@aseshsarkar)			Energetic	[{"label": "Most likely to...", "value": "A great Mother"}, {"label": "A superpower you’d give them", "value": "So much energy to talk..."}, {"label": "A song that reminds you of them", "value": "I cant remember any song but definitely remember the day when we were not allowed to board flight in Chicago."}, {"label": "Your best memory together", "value": "so many US, Roorkee, Dehradun and lastly Mysore."}, {"label": "One piece of advice for them", "value": "Take care of your health."}, {"label": "Where you see them in 10 years", "value": "Kochi."}]	Thanks for getting us the US VIsa.\nGet your Phd Asap.	{"lat": 12.3, "lng": 76.64, "name": "Mysuru"}	{https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/e_1784275600595_0_nm0mol?v=1784275601095}	#57614A	pending	2026-07-17 08:06:40.769053+00	\N	\N	\N	\N	\N	\N
9453e94f-02d5-4e80-83e4-4a01ac2db7f9	4bde932d-2f8b-448d-8b49-0c3b6973ecc9	f3224654-1357-4933-a356-d10bf55f7354	Rajesh				[]	hello	{"lat": 12.97, "lng": 77.59, "name": "Bengaluru"}	{}	#4E7065	approved	2026-07-24 11:08:48.29735+00	\N	\N	\N	\N	\N	\N
21ee4798-7049-4ce4-a8fc-5fd02b3f1713	f6b1d166-6e02-4134-bf30-56cc67a5d038	13554111-b50c-44ad-af7b-4988c8209afb	sharma				[]	ji	\N	{}	#4E7065	approved	2026-08-01 18:34:38.659222+00	\N	\N	\N	\N	\N	\N
f5e65ff7-5da7-4133-bd78-d985886fb924	51323e47-38a0-405d-b597-a56cc534ba12	794c5058-c511-4509-ad40-938ce0d45eae	asesh				[]	Hello World. Welcome to Earthlive.	{"lat": 26.91, "lng": 75.79, "name": "Jaipur"}	{}	#57614A	approved	2026-07-14 04:17:47.816339+00	\N	\N	\N	\N	\N	\N
4ac2f661-cd53-4870-99ca-cc0dd71cf7af	51323e47-38a0-405d-b597-a56cc534ba12	794c5058-c511-4509-ad40-938ce0d45eae	sharma	\N	\N		[]		\N	{}	#3C4A5E	pending	2026-08-05 18:38:58.389114+00	\N	\N	\N	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/voice_13554111-b50c-44ad-af7b-4988c8209afb_1785953996094_7o0lr.webm	9	msg_voiceprint
a3e06981-5be9-405e-aed1-cb43df5136ef	51323e47-38a0-405d-b597-a56cc534ba12	794c5058-c511-4509-ad40-938ce0d45eae	sharma	\N	\N		[]		\N	{}	#3C4A5E	pending	2026-08-05 19:03:04.492752+00	\N	\N	\N	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/voice_13554111-b50c-44ad-af7b-4988c8209afb_1785955100536_nfh45.webm	10	msg_voiceprint
\.


--
-- Data for Name: event_comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.event_comments (id, entry_id, event_id, author_user_id, author_name, message, created_at, parent_id) FROM stdin;
d1e9ecad-783b-4171-bb32-c1b52daa5750	d9543e81-91c3-4460-832a-20f8b90c55c8	4df2669c-3a95-4efd-856d-ffe272eabb58	794c5058-c511-4509-ad40-938ce0d45eae	asesh	ggg	2026-07-30 19:17:00.442225+00	\N
dc7be386-3c13-4290-840c-476d0b388f0c	d9543e81-91c3-4460-832a-20f8b90c55c8	4df2669c-3a95-4efd-856d-ffe272eabb58	794c5058-c511-4509-ad40-938ce0d45eae	asesh	ok	2026-07-30 19:17:06.592442+00	d1e9ecad-783b-4171-bb32-c1b52daa5750
4f00be21-718b-45ee-af87-3444be8dc92a	d9543e81-91c3-4460-832a-20f8b90c55c8	4df2669c-3a95-4efd-856d-ffe272eabb58	13554111-b50c-44ad-af7b-4988c8209afb	Rakesh	ok	2026-08-01 18:22:12.769408+00	\N
\.


--
-- Data for Name: event_entries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.event_entries (id, event_id, author_name, message, photos, approved, created_at, author_user_id, entry_type, subject_member, one_word, tagged, city, lat, lng, color, edited) FROM stdin;
00615a62-df2e-4343-bb13-641d3795b801	f40738ee-cbcd-413e-b81e-61758d66dee7	sharma	exactly	["https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/event-photos/ev_f40738ee-cbcd-413e-b81e-61758d66dee7_1785646008673_0?v=1785646008891"]	t	2026-08-02 04:46:48.986982+00	13554111-b50c-44ad-af7b-4988c8209afb	post	\N	\N	[]	\N	\N	\N	#4E7065	t
28cf7017-41ec-4e03-ab36-e4b3e76114a5	f40738ee-cbcd-413e-b81e-61758d66dee7	sharma	testing	["https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/event-photos/ev_f40738ee-cbcd-413e-b81e-61758d66dee7_1785646052337_0?v=1785646052554"]	t	2026-08-02 04:47:32.628288+00	13554111-b50c-44ad-af7b-4988c8209afb	post	\N	\N	[]	Roorkee	29.86632	77.89118	#4E7065	f
98f8e8b0-91c5-4902-a1ed-f5ecb35a1b0d	4df2669c-3a95-4efd-856d-ffe272eabb58	asesh	hello	["https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/event-photos/ev_4df2669c-3a95-4efd-856d-ffe272eabb58_1785333726121_0?v=1785333726555"]	t	2026-07-29 14:02:07.011322+00	794c5058-c511-4509-ad40-938ce0d45eae	post	\N	\N	[]	Roorkee	29.86632	77.89118	#4E7065	f
d9543e81-91c3-4460-832a-20f8b90c55c8	4df2669c-3a95-4efd-856d-ffe272eabb58	asesh	hello	[]	t	2026-07-29 15:07:17.872292+00	794c5058-c511-4509-ad40-938ce0d45eae	post	\N	\N	[]	\N	\N	\N	#4E7065	f
a600385a-448f-4690-94b5-67c8f605b1cf	f40738ee-cbcd-413e-b81e-61758d66dee7	sharma	raise the bar	[]	t	2026-08-02 04:52:41.410087+00	13554111-b50c-44ad-af7b-4988c8209afb	about	__EARTHLIVE_WISH__	\N	[]	\N	\N	\N	#4E7065	f
16a22803-584a-46a8-b637-a0c5631f2283	f40738ee-cbcd-413e-b81e-61758d66dee7	asesh	going	[]	t	2026-08-02 04:58:54.419823+00	794c5058-c511-4509-ad40-938ce0d45eae	about	__EARTHLIVE_RSVP__	\N	[]	\N	\N	\N	#57614A	f
8d4325c9-10e6-4762-a3f2-e7b7285b2e61	f40738ee-cbcd-413e-b81e-61758d66dee7	asesh	samjhe	[]	t	2026-08-02 04:59:04.50055+00	794c5058-c511-4509-ad40-938ce0d45eae	about	__EARTHLIVE_WISH__	\N	[]	\N	\N	\N	#57614A	f
eac95afc-d8ea-413e-aff1-72ddbeaa8223	8142cbcf-af80-4152-b6d8-c3e78716dbfc	asesh	testing	["https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/event-photos/ev_8142cbcf-af80-4152-b6d8-c3e78716dbfc_1785606842638_0?v=1785606843139"]	t	2026-08-01 17:54:03.235592+00	794c5058-c511-4509-ad40-938ce0d45eae	post	\N	\N	[]	\N	\N	\N	#57614A	t
857b399a-85d3-43fb-8ba5-6706982c20dc	8142cbcf-af80-4152-b6d8-c3e78716dbfc	asesh	testing 2	["https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/event-photos/ev_8142cbcf-af80-4152-b6d8-c3e78716dbfc_1785606882173_0?v=1785606882539"]	t	2026-08-01 17:54:42.777237+00	794c5058-c511-4509-ad40-938ce0d45eae	post	\N	\N	[]	Bengaluru	12.97	77.59	#57614A	f
22eb38e9-5951-4b76-8c07-af305f9cab56	8142cbcf-af80-4152-b6d8-c3e78716dbfc	asesh	imagination	[]	t	2026-08-01 17:55:01.383967+00	794c5058-c511-4509-ad40-938ce0d45eae	about	__EARTHLIVE_WISH__	\N	[]	\N	\N	\N	#57614A	f
343df15b-8a1f-4545-838e-2dfab1dc2ec1	f40738ee-cbcd-413e-b81e-61758d66dee7	sharma	going	[]	t	2026-08-02 04:46:22.287119+00	13554111-b50c-44ad-af7b-4988c8209afb	about	__EARTHLIVE_RSVP__	\N	[]	\N	\N	\N	#4E7065	f
fac91907-379f-4720-85e4-d989dffb1119	f40738ee-cbcd-413e-b81e-61758d66dee7	sharma	wonderful	[]	t	2026-08-02 04:46:32.865504+00	13554111-b50c-44ad-af7b-4988c8209afb	about	__EARTHLIVE_WISH__	\N	[]	\N	\N	\N	#4E7065	f
4883f6d1-136b-48b7-a8ea-18faa6a9b893	8142cbcf-af80-4152-b6d8-c3e78716dbfc	asesh	Test event post from Claude — verifying the group wall works.	[]	t	2026-08-11 15:36:44.261357+00	794c5058-c511-4509-ad40-938ce0d45eae	post	\N	\N	[]	\N	\N	\N	#57614A	f
\.


--
-- Data for Name: event_guests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.event_guests (id, event_id, guest_name, guest_email, status, created_at, user_id) FROM stdin;
dc846d22-7679-4989-8fc1-e2ae7c981ac9	4df2669c-3a95-4efd-856d-ffe272eabb58	Kalyan Sarkar	\N	invited	2026-07-25 18:19:38.022258+00	73cad07a-ae07-4ad6-be61-1e59d3943953
a8c1cc24-9fa3-4823-907d-167e8171ca1a	4df2669c-3a95-4efd-856d-ffe272eabb58	Rajesh	\N	joined	2026-08-01 08:44:35.909225+00	f3224654-1357-4933-a356-d10bf55f7354
507e658f-12dc-44bc-99c7-fce33f0fa865	4df2669c-3a95-4efd-856d-ffe272eabb58	Rakesh	\N	joined	2026-08-01 15:32:55.797163+00	13554111-b50c-44ad-af7b-4988c8209afb
702530c3-dc78-4a9d-81f0-74ab4dc3da39	8142cbcf-af80-4152-b6d8-c3e78716dbfc	Rakesh	\N	joined	2026-08-01 17:55:32.298375+00	13554111-b50c-44ad-af7b-4988c8209afb
43a6a4d4-4c66-4ba5-a686-7d085c5577cc	f40738ee-cbcd-413e-b81e-61758d66dee7	asesh	\N	joined	2026-08-02 04:58:28.162041+00	794c5058-c511-4509-ad40-938ce0d45eae
\.


--
-- Data for Name: event_likes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.event_likes (id, entry_id, event_id, liker_key, created_at) FROM stdin;
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.events (id, owner_user_id, name, event_date, location, description, slug, visibility, created_at, cover_url, event_time, event_type, organisation, honoree, features) FROM stdin;
4df2669c-3a95-4efd-856d-ffe272eabb58	794c5058-c511-4509-ad40-938ce0d45eae	Farewell	2026-07-24	Bengaluru	Explanantion	nn-ahd8	public	2026-07-18 01:33:39.948367+00	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/event-photos/cover_4df2669c-3a95-4efd-856d-ffe272eabb58_1784377078244?v=1784377078772	\N	\N	\N	\N	[]
8142cbcf-af80-4152-b6d8-c3e78716dbfc	794c5058-c511-4509-ad40-938ce0d45eae	conference	2026-08-15	Bengaluru	perfecto	ravi-y6tm	public	2026-08-01 17:53:30.493545+00	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/event-photos/cover_8142cbcf-af80-4152-b6d8-c3e78716dbfc_1785606920361?v=1785606920630	12:15	farewell	2009	\N	["wall", "photos", "map", "tribute", "wishes", "rsvp"]
f40738ee-cbcd-413e-b81e-61758d66dee7	13554111-b50c-44ad-af7b-4988c8209afb	Batch 2026	2026-08-06	Bengaluru	Perceived	batch-2026-vq3y	public	2026-08-02 04:45:21.282366+00	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/event-photos/cover_f40738ee-cbcd-413e-b81e-61758d66dee7_1785645949282?v=1785645949827	\N	convocation	IIM	\N	["wall", "photos", "map", "wishes", "rsvp", "tribute"]
fafb0317-fe7c-4977-849f-2b2283596c8d	794c5058-c511-4509-ad40-938ce0d45eae	Claude test event — please delete	2026-09-15			claude-test-event-please-delete-h7h7	public	2026-08-11 15:39:53.604784+00	\N	\N	farewell	\N	\N	["wall", "photos", "map", "tribute", "rsvp"]
\.


--
-- Data for Name: follows; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.follows (id, follower_user_id, followed_profile_id, created_at) FROM stdin;
399b3f4d-fd90-4e2a-94f3-2d9e4fc217c3	13554111-b50c-44ad-af7b-4988c8209afb	51323e47-38a0-405d-b597-a56cc534ba12	2026-07-05 16:50:19.054965+00
db45284f-8adb-4931-96e3-db51b5f7b6e0	596b2102-4ae0-430f-93c5-c9847886cf12	51323e47-38a0-405d-b597-a56cc534ba12	2026-07-05 17:13:09.889994+00
9fee3980-b62b-407c-ba4b-9af79f0fdda7	794c5058-c511-4509-ad40-938ce0d45eae	40cfc39f-3473-41ac-943a-0d804fb34f7a	2026-07-05 17:30:28.201883+00
f65ada87-3beb-4a00-8be6-647074d1dc5b	794c5058-c511-4509-ad40-938ce0d45eae	347570df-4df5-408f-9d3e-71e6952063ff	2026-07-06 04:14:07.913413+00
9759bb1d-ec3a-4308-ae32-8b07d942f1af	02989991-856d-4edb-bee7-26569343d07c	51323e47-38a0-405d-b597-a56cc534ba12	2026-07-06 07:57:47.259156+00
183488e6-89c1-49af-8857-45496e699ec9	fae6b5e3-7b7b-4195-910c-e1a0ec3159a5	51323e47-38a0-405d-b597-a56cc534ba12	2026-07-06 10:03:35.22639+00
58843a6f-4d1a-4292-9beb-95db8961ffdb	794c5058-c511-4509-ad40-938ce0d45eae	88a5065b-8e97-45f0-942a-cfeb71e8ad73	2026-07-06 14:44:38.232866+00
c08b0003-0c0a-40e4-ac94-8e61690ef7b3	57022196-7fc3-4bb8-88f9-578c4c3832c6	51323e47-38a0-405d-b597-a56cc534ba12	2026-07-11 07:03:38.397828+00
1d432ade-9f0f-4a8a-85d8-a584b1fc32b9	794c5058-c511-4509-ad40-938ce0d45eae	6166861b-a5cd-41c8-8f85-ad94095c6abb	2026-07-11 07:06:20.176659+00
09c4fa8d-b594-4968-b83b-ed4e80054b3a	794c5058-c511-4509-ad40-938ce0d45eae	2116276d-a809-47d1-94c0-6a3a97f9ab3a	2026-07-16 17:23:43.900432+00
026ef110-e108-4a9f-91d4-e3a3026081c9	794c5058-c511-4509-ad40-938ce0d45eae	5bff5eff-3dce-430b-a249-979fd0a92b84	2026-07-17 08:07:20.253785+00
0d361345-bc5c-4978-9fb0-fadddc094532	794c5058-c511-4509-ad40-938ce0d45eae	23a09b0b-fb05-45db-b01f-0905065f89ef	2026-07-18 10:09:03.955249+00
\.


--
-- Data for Name: growth_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.growth_events (id, event_name, user_id, properties, created_at) FROM stdin;
\.


--
-- Data for Name: likes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.likes (id, entry_id, liker_key, created_at, kind) FROM stdin;
091e4a6a-e275-46d3-ab54-66922755228d	1d536119-a88a-487f-b6a5-d866e313e001	dev_4595slqx48	2026-07-16 19:18:41.71753+00	heart
da6680a8-837b-44d2-93f7-be26a408ba73	c7a0f692-7b86-421a-ba52-3f188a4067a2	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-19 13:04:10.908014+00	heart
263beb0a-a139-4d9f-8c1a-785cd1475146	88c79fdb-12b5-43a2-a7d5-daee30dccf53	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-19 17:33:19.286927+00	heart
70b7528e-d2f5-4341-97a0-5c030a2c27c4	29d2255c-e66b-45c0-9dfe-2a5be6965d3a	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-19 13:08:53.033279+00	cloud
f92cf5a2-d7ff-433d-9bd1-12c3bc633e3f	1d536119-a88a-487f-b6a5-d866e313e001	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-19 19:43:05.356031+00	sun
88d24f08-6668-41d4-981e-32eac922b3e6	66a324d2-21f4-49a1-851f-236952dccf03	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-12 09:00:33.097957+00	leaf
d987e0b5-09af-468b-9aa5-8f66f708a545	33ba03b5-105a-4d3e-834c-49168ceee25f	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-01 18:57:15.895982+00	heart
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.messages (id, conversation_id, sender_profile_id, body, created_at, voice_url, voice_seconds, image_url) FROM stdin;
10f3073c-afb8-417c-9852-4677acb08126	f6b6f2f7-f3db-441c-912c-7e009a019184	51323e47-38a0-405d-b597-a56cc534ba12	hello	2026-07-05 17:13:11.705007+00	\N	\N	\N
31bea973-2432-4858-9396-6f8b9b2f0de7	8c9351f7-ef2d-41a9-871c-34adcc5b4c89	51323e47-38a0-405d-b597-a56cc534ba12	hello	2026-07-06 04:14:39.251993+00	\N	\N	\N
4c231aac-70ed-4cd1-b410-683a94bea0f3	8c9351f7-ef2d-41a9-871c-34adcc5b4c89	51323e47-38a0-405d-b597-a56cc534ba12	check my profile.	2026-07-06 04:15:09.478793+00	\N	\N	\N
bf8de643-ad33-4dd4-b02b-ee512e785cf1	1cb72ec5-ed3f-4559-be44-83b3aef4f00e	51323e47-38a0-405d-b597-a56cc534ba12	Hello	2026-07-06 14:44:51.901066+00	\N	\N	\N
d90c0f0e-91cd-4347-a71b-1f521a310536	fc0e1ea9-e7df-4961-9c0d-6fd57e632619	51323e47-38a0-405d-b597-a56cc534ba12	Hello	2026-07-11 10:23:36.537651+00	\N	\N	\N
38ae5e43-1ff5-4733-8f9a-3bb9265c6f93	c19a3ca3-e1cd-4fd3-9965-59e792ba356e	51323e47-38a0-405d-b597-a56cc534ba12	hello	2026-07-13 07:10:14.565018+00	\N	\N	\N
2499a063-5bf8-4bbb-b7df-58dd1f34123d	8c9351f7-ef2d-41a9-871c-34adcc5b4c89	51323e47-38a0-405d-b597-a56cc534ba12	💛 Thinking of you — no reply needed.	2026-08-01 08:16:49.063262+00	\N	\N	\N
dea4bba6-0b62-4062-b54e-cba86354f1ae	d5ac24bc-04bc-4497-a8b9-6153c85a44eb	f6b1d166-6e02-4134-bf30-56cc67a5d038	💛 Thinking of you — no reply needed.	2026-08-01 18:49:58.075453+00	\N	\N	\N
cc6083fc-b389-4bdb-8863-d3b62aeee7c1	f6b6f2f7-f3db-441c-912c-7e009a019184	51323e47-38a0-405d-b597-a56cc534ba12	💛 Thinking of you — no reply needed.	2026-08-01 18:51:11.163785+00	\N	\N	\N
d5c49c33-46d5-464b-a9e6-fd6ba403666d	1cb72ec5-ed3f-4559-be44-83b3aef4f00e	51323e47-38a0-405d-b597-a56cc534ba12	💛 Thinking of you — no reply needed.	2026-08-01 18:51:17.302544+00	\N	\N	\N
5689219b-d0a9-49e2-b794-558025b372e4	3d319947-4bca-4dba-8035-beae5693b835	51323e47-38a0-405d-b597-a56cc534ba12	💛 Thinking of you — no reply needed.	2026-08-01 18:51:32.20874+00	\N	\N	\N
82d596f0-91a1-4222-ab9b-ba5aa0ec0cde	d5ac24bc-04bc-4497-a8b9-6153c85a44eb	51323e47-38a0-405d-b597-a56cc534ba12	ok	2026-08-01 18:53:46.813985+00	\N	\N	\N
960653e4-b55e-4b34-afc4-ae991417782f	d5ac24bc-04bc-4497-a8b9-6153c85a44eb	f6b1d166-6e02-4134-bf30-56cc67a5d038	ok	2026-08-01 18:54:40.800577+00	\N	\N	\N
c94cbe2f-d50b-4b62-ba91-b2d666097026	d5ac24bc-04bc-4497-a8b9-6153c85a44eb	f6b1d166-6e02-4134-bf30-56cc67a5d038	ok	2026-08-01 18:54:44.274069+00	\N	\N	\N
2e15ace8-a6a1-4e9b-b2ce-20a9f3505918	d5ac24bc-04bc-4497-a8b9-6153c85a44eb	51323e47-38a0-405d-b597-a56cc534ba12	got it	2026-08-01 18:55:06.674916+00	\N	\N	\N
614df888-dcb8-4fe8-8334-295d7bc582e9	d5ac24bc-04bc-4497-a8b9-6153c85a44eb	51323e47-38a0-405d-b597-a56cc534ba12	\N	2026-08-01 18:55:13.237605+00	\N	\N	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/msg_794c5058-c511-4509-ad40-938ce0d45eae_1785610512526_df9pyl?v=1785610513180
0b67897a-918a-4efd-8e64-f663ff8a2668	d5ac24bc-04bc-4497-a8b9-6153c85a44eb	f6b1d166-6e02-4134-bf30-56cc67a5d038	perfect	2026-08-01 18:55:42.711007+00	\N	\N	\N
e709b451-e335-4b5f-a6a7-a265780bf8c1	d5ac24bc-04bc-4497-a8b9-6153c85a44eb	f6b1d166-6e02-4134-bf30-56cc67a5d038		2026-08-01 18:55:59.548592+00	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/voice_13554111-b50c-44ad-af7b-4988c8209afb_1785610559273_fygu5.webm	8	\N
23b60b0a-b49e-46c0-a35a-5624250dd5fd	3d319947-4bca-4dba-8035-beae5693b835	51323e47-38a0-405d-b597-a56cc534ba12	💛 Thinking of you — no reply needed.	2026-08-01 20:15:30.831563+00	\N	\N	\N
c88475cf-d0d7-4d75-b945-61380ad7a09a	fc0e1ea9-e7df-4961-9c0d-6fd57e632619	51323e47-38a0-405d-b597-a56cc534ba12	Testing.	2026-08-01 20:35:59.677968+00	\N	\N	\N
c4414391-ef9e-4c7a-8810-da0f26a8f71b	d5ac24bc-04bc-4497-a8b9-6153c85a44eb	51323e47-38a0-405d-b597-a56cc534ba12	hello	2026-08-01 20:55:14.638408+00	\N	\N	\N
fbaabedf-7df1-4921-8f1b-824946236f65	d5ac24bc-04bc-4497-a8b9-6153c85a44eb	51323e47-38a0-405d-b597-a56cc534ba12	hello	2026-08-02 05:00:29.28346+00	\N	\N	\N
b8bcf66c-a9fc-4eaf-9ce0-36d5df4020dc	1cb72ec5-ed3f-4559-be44-83b3aef4f00e	51323e47-38a0-405d-b597-a56cc534ba12	💛 Thinking of you — no reply needed.	2026-08-02 11:15:12.310828+00	\N	\N	\N
30bc27b9-4fff-4a56-b673-632629858b72	d5ac24bc-04bc-4497-a8b9-6153c85a44eb	f6b1d166-6e02-4134-bf30-56cc67a5d038		2026-08-05 18:19:56.464247+00	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/voice_13554111-b50c-44ad-af7b-4988c8209afb_1785953996094_7o0lr.webm	9	\N
5d520afc-7551-4db8-847b-90cc2b56ec6c	d5ac24bc-04bc-4497-a8b9-6153c85a44eb	f6b1d166-6e02-4134-bf30-56cc67a5d038		2026-08-05 18:38:21.082825+00	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/voice_13554111-b50c-44ad-af7b-4988c8209afb_1785955100536_nfh45.webm	10	\N
8d53840e-eb95-4af9-8e54-e8d02cdeeb5f	677492cb-aa76-4258-82d1-f7a796c00e79	51323e47-38a0-405d-b597-a56cc534ba12	💛 Thinking of you — no reply needed.	2026-08-06 06:33:12.677244+00	\N	\N	\N
fab31fcc-3572-4506-8a3f-7e09069d8949	1cb72ec5-ed3f-4559-be44-83b3aef4f00e	51323e47-38a0-405d-b597-a56cc534ba12	💛 Thinking of you — no reply needed.	2026-08-07 14:28:08.356241+00	\N	\N	\N
c00bc541-eaf1-4c53-afcd-4fb6fdd719c0	f6b6f2f7-f3db-441c-912c-7e009a019184	51323e47-38a0-405d-b597-a56cc534ba12	💛 Thinking of you — no reply needed.	2026-08-11 06:04:42.879343+00	\N	\N	\N
02d97cce-c88a-4f28-b8ed-b9a7cf6972bd	1cb72ec5-ed3f-4559-be44-83b3aef4f00e	51323e47-38a0-405d-b597-a56cc534ba12	💛 Thinking of you — no reply needed.	2026-08-11 06:04:50.698137+00	\N	\N	\N
b19f51b6-34cf-4876-81eb-135d87eca0fd	d5ac24bc-04bc-4497-a8b9-6153c85a44eb	51323e47-38a0-405d-b597-a56cc534ba12	Test DM from Claude — verifying Messages send works ✔	2026-08-11 15:46:13.935907+00	\N	\N	\N
\.


--
-- Data for Name: poll_votes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.poll_votes (id, profile_id, voter_user_id, question_key, option_index, created_at) FROM stdin;
43cc08dc-564c-4aed-91e3-0a6ad96bafba	51323e47-38a0-405d-b597-a56cc534ba12	13554111-b50c-44ad-af7b-4988c8209afb	spark	0	2026-08-02 13:42:14.364968+00
db65e911-13c7-418b-877a-b3e047444a1f	51323e47-38a0-405d-b597-a56cc534ba12	13554111-b50c-44ad-af7b-4988c8209afb	element	2	2026-08-02 13:42:20.230344+00
3d32aeb4-cbe4-453b-8cf3-7f011200c476	51323e47-38a0-405d-b597-a56cc534ba12	13554111-b50c-44ad-af7b-4988c8209afb	word	3	2026-08-02 13:42:22.61036+00
29e177d4-db1e-44b7-a7c9-d99fd52571c1	51323e47-38a0-405d-b597-a56cc534ba12	13554111-b50c-44ad-af7b-4988c8209afb	value	2	2026-08-02 13:42:25.696654+00
79adb22f-0075-4d59-ac4e-5ac7ecf5a2fc	51323e47-38a0-405d-b597-a56cc534ba12	13554111-b50c-44ad-af7b-4988c8209afb	mark	2	2026-08-02 13:42:28.741227+00
95dbaef3-ed79-4b60-9898-26e47cb88bb9	f6b1d166-6e02-4134-bf30-56cc67a5d038	794c5058-c511-4509-ad40-938ce0d45eae	spark	0	2026-08-02 14:07:46.42623+00
5e9f0eae-1fd0-4a4e-8cf0-5076e9905cc5	f6b1d166-6e02-4134-bf30-56cc67a5d038	794c5058-c511-4509-ad40-938ce0d45eae	element	3	2026-08-02 14:07:49.440527+00
2cc6247d-1645-473b-a62e-ebae96e9d211	f6b1d166-6e02-4134-bf30-56cc67a5d038	794c5058-c511-4509-ad40-938ce0d45eae	word	3	2026-08-02 14:07:51.224749+00
861fcf38-51f2-42d5-83e7-f19be77b257f	f6b1d166-6e02-4134-bf30-56cc67a5d038	794c5058-c511-4509-ad40-938ce0d45eae	value	2	2026-08-02 14:07:52.938992+00
14aeea37-3c9c-4b1a-894d-83cb68fe18d9	f6b1d166-6e02-4134-bf30-56cc67a5d038	794c5058-c511-4509-ad40-938ce0d45eae	mark	2	2026-08-02 14:07:55.142791+00
dbd8c0a7-7880-419b-8af5-167164195801	51323e47-38a0-405d-b597-a56cc534ba12	f3224654-1357-4933-a356-d10bf55f7354	spark	1	2026-08-02 14:34:42.229183+00
39184e97-f557-407c-ab65-7920247ab345	51323e47-38a0-405d-b597-a56cc534ba12	f3224654-1357-4933-a356-d10bf55f7354	element	3	2026-08-02 14:34:45.025671+00
b327b016-a554-49ee-b7ef-99378d4df319	51323e47-38a0-405d-b597-a56cc534ba12	f3224654-1357-4933-a356-d10bf55f7354	word	2	2026-08-02 14:34:47.049024+00
4760c8fc-a7e5-492c-ab33-defe62d02a15	51323e47-38a0-405d-b597-a56cc534ba12	f3224654-1357-4933-a356-d10bf55f7354	value	1	2026-08-02 14:35:20.146699+00
72d77720-f94e-422a-935e-ad4f47e2072e	51323e47-38a0-405d-b597-a56cc534ba12	f3224654-1357-4933-a356-d10bf55f7354	mark	3	2026-08-02 14:35:22.914674+00
08654d3b-4c4d-4c34-8c22-23eaf061a785	2116276d-a809-47d1-94c0-6a3a97f9ab3a	794c5058-c511-4509-ad40-938ce0d45eae	spark	1	2026-08-02 15:11:37.434856+00
8fb0cb0e-43d2-42a4-95e3-548045153f7d	2116276d-a809-47d1-94c0-6a3a97f9ab3a	794c5058-c511-4509-ad40-938ce0d45eae	element	1	2026-08-02 15:11:43.772218+00
847cd724-4181-4568-adce-b239a1806f0e	2116276d-a809-47d1-94c0-6a3a97f9ab3a	794c5058-c511-4509-ad40-938ce0d45eae	word	1	2026-08-02 15:11:48.444937+00
242f9c97-4adc-45d0-acd7-55e21b4c6c4d	2116276d-a809-47d1-94c0-6a3a97f9ab3a	794c5058-c511-4509-ad40-938ce0d45eae	value	2	2026-08-02 15:11:53.104487+00
a3827fa8-4c09-47e2-8274-c36cffba07bf	2116276d-a809-47d1-94c0-6a3a97f9ab3a	794c5058-c511-4509-ad40-938ce0d45eae	mark	0	2026-08-02 15:11:58.691479+00
0d43235a-bac4-43a1-9adb-0c5e18d18035	51323e47-38a0-405d-b597-a56cc534ba12	794c5058-c511-4509-ad40-938ce0d45eae	spark	3	2026-08-10 18:24:48.94424+00
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profiles (id, user_id, username, name, bio, ink, avatar_url, cover_url, visibility, template_id, questions, links, created_at, extras, deactivated, album_public) FROM stdin;
ba1ee5d4-3b9a-46b9-8ec3-988874dc0256	fae6b5e3-7b7b-4195-910c-e1a0ec3159a5	naveen	naveen	Just here to collect some words.	#57614A	\N	\N	public	classic	[{"id": "q_likely", "ph": "e.g. Become famous by accident", "long": false, "label": "Most likely to..."}, {"id": "q_power", "ph": "e.g. Reading minds before exams", "long": false, "label": "A superpower you’d give them"}, {"id": "q_song", "ph": "e.g. Whatever’s stuck in your head", "long": false, "label": "A song that reminds you of them"}, {"id": "q_memory", "ph": "That one time when...", "long": true, "label": "Your best memory together"}, {"id": "q_advice", "ph": "Something you actually mean.", "long": true, "label": "One piece of advice for them"}, {"id": "q_future", "ph": "e.g. Running the place, still late", "long": false, "label": "Where you see them in 10 years"}]	{}	2026-07-06 10:04:24.381984+00	{}	f	f
88a5065b-8e97-45f0-942a-cfeb71e8ad73	13826d95-961c-494e-a2c2-018298bbda09	kaushik	Kaushik Das	Designer	#57614A	\N	\N	public	classic	[{"id": "q_likely", "ph": "e.g. Become famous by accident", "long": false, "label": "Most likely to..."}, {"id": "q_power", "ph": "e.g. Reading minds before exams", "long": false, "label": "A superpower you’d give them"}, {"id": "q_song", "ph": "e.g. Whatever’s stuck in your head", "long": false, "label": "A song that reminds you of them"}, {"id": "q_memory", "ph": "That one time when...", "long": true, "label": "Your best memory together"}, {"id": "q_advice", "ph": "Something you actually mean.", "long": true, "label": "One piece of advice for them"}, {"id": "q_future", "ph": "e.g. Running the place, still late", "long": false, "label": "Where you see them in 10 years"}]	{}	2026-07-06 14:30:43.719031+00	{}	f	f
40cfc39f-3473-41ac-943a-0d804fb34f7a	596b2102-4ae0-430f-93c5-c9847886cf12	poojamahesh	Pooja Mahesh	Always dreaming	#6B4C6B	\N	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/covers/596b2102-4ae0-430f-93c5-c9847886cf12/cover?v=1783271992677	public	classic	[{"id": "q_likely", "ph": "e.g. Become famous by accident", "long": false, "label": "Most likely to..."}, {"id": "q_power", "ph": "e.g. Reading minds before exams", "long": false, "label": "A superpower you’d give them"}, {"id": "q_song", "ph": "e.g. Whatever’s stuck in your head", "long": false, "label": "A song that reminds you of them"}, {"id": "q_memory", "ph": "That one time when...", "long": true, "label": "Your best memory together"}, {"id": "q_advice", "ph": "Something you actually mean.", "long": true, "label": "One piece of advice for them"}, {"id": "q_future", "ph": "e.g. Running the place, still late", "long": false, "label": "Where you see them in 10 years"}]	{}	2026-07-05 17:12:43.259032+00	{}	f	f
347570df-4df5-408f-9d3e-71e6952063ff	73cad07a-ae07-4ad6-be61-1e59d3943953	kalyan	Kalyan Sarkar	happy guy	#57614A	\N	\N	public	classic	[{"id": "q_likely", "ph": "e.g. Become famous by accident", "long": false, "label": "Most likely to..."}, {"id": "q_power", "ph": "e.g. Reading minds before exams", "long": false, "label": "A superpower you’d give them"}, {"id": "q_song", "ph": "e.g. Whatever’s stuck in your head", "long": false, "label": "A song that reminds you of them"}, {"id": "q_memory", "ph": "That one time when...", "long": true, "label": "Your best memory together"}, {"id": "q_advice", "ph": "Something you actually mean.", "long": true, "label": "One piece of advice for them"}, {"id": "q_future", "ph": "e.g. Running the place, still late", "long": false, "label": "Where you see them in 10 years"}]	{}	2026-07-05 20:26:30.339797+00	{}	f	f
51323e47-38a0-405d-b597-a56cc534ba12	794c5058-c511-4509-ad40-938ce0d45eae	aseshsarkar	asesh	hi this is asesh	#57614A	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/avatars/794c5058-c511-4509-ad40-938ce0d45eae/avatar?v=1783268637175	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/covers/794c5058-c511-4509-ad40-938ce0d45eae/cover?v=1784361948525	public	classic	[{"id": "q_likely", "ph": "e.g. Become famous by accident", "long": false, "label": "Most likely to..."}, {"id": "q_power", "ph": "e.g. Reading minds before exams", "long": false, "label": "A superpower you’d give them"}, {"id": "q_song", "ph": "e.g. Whatever’s stuck in your head", "long": false, "label": "A song that reminds you of them"}, {"id": "q_memory", "ph": "That one time when...", "long": true, "label": "Your best memory together"}, {"id": "q_advice", "ph": "Something you actually mean.", "long": true, "label": "One piece of advice for them"}, {"id": "q_future", "ph": "e.g. Running the place, still late", "long": false, "label": "Where you see them in 10 years"}]	{"website": "earthlive.in"}	2026-07-05 06:31:13.376444+00	{"bday": "1991-06-15", "city": "Bangalore", "food": "Veg", "home": "Kolkata", "song": "Every night in my dreams..", "trip": "Iceland", "word": "Curious", "movie": "Inception", "birth_year": 1991, "life_years": {"2011": {"text": "THE END OF YOUR BOOKTHE END OF YOUR BOOKOne year at a time, from the year you were born — a hundred words, a photo, a voice note and a short clip. It is entirely optional; tap a year to open it, or jump to any year below.One year at a time, from the year you were born — a hundred words, a photo, a voice note and a short clip. It is entirely optional; tap a year to open it, or jump to any year below.", "video": null, "voice": null, "photos": ["https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/life/51323e47-38a0-405d-b597-a56cc534ba12/2011-1786387490122-l0mo?v=1786387490602"], "updatedAt": "2026-08-10T18:44:50.603Z"}, "2017": {"text": "One year at a time, from the year you were born — a hundred words, a photo, a voice note and a short clip. It is entirely optional; tap a year to open it, or jump to any year below.One year at a time, from the year you were born — a hundred words, a photo, a voice note and a short clip. It is entirely optional; tap a year to open it, or jump to any year below.", "video": null, "voice": null, "photos": ["https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/life/51323e47-38a0-405d-b597-a56cc534ba12/2017-1786384719111?v=1786384719339"], "updatedAt": "2026-08-10T18:20:53.769Z"}, "2023": {"text": "One year at a time, from the year you were born — a hundred words, a photo, a voice note and a short clip. It is entirely optional; tap a year to open it, or jump to any year below.One year at a time, from the year you were born — a hundred words, a photo, a voice note and a short clip. It is entirely optional; tap a year to open it, or jump to any year below.", "photo": "https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/life/51323e47-38a0-405d-b597-a56cc534ba12/2023-1786384680877?v=1786384681396", "video": null, "voice": null, "updatedAt": "2026-08-10T17:58:01.396Z"}, "2024": {"text": "One year at a time, from the year you were born — a hundred words, a photo, a voice note and a short clip. It is entirely optional; tap a year to open it, or jump to any year below.One year at a time, from the year you were born — a hundred words, a photo, a voice note and a short clip. It is entirely optional; tap a year to open it, or jump to any year below.", "video": null, "voice": null, "photos": ["https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/life/51323e47-38a0-405d-b597-a56cc534ba12/2024-1786386716083-b9tc?v=1786386716740", "https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/life/51323e47-38a0-405d-b597-a56cc534ba12/2024-1786386757951-xd5l?v=1786386758415"], "updatedAt": "2026-08-10T18:32:38.415Z"}, "2026": {"text": "One year at a time, from the year you were born — a hundred words, a photo, a voice note and a short clip. It is entirely optional; tap a year to open it, or jump to any year below.", "photo": "https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/life/51323e47-38a0-405d-b597-a56cc534ba12/2026-1786384628160?v=1786384628578", "video": null, "voice": {"url": "https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/entry-photos/life/51323e47-38a0-405d-b597-a56cc534ba12/voice_1786384628579_0fm7y.webm", "seconds": 9}, "updatedAt": "2026-08-10T18:00:12.032Z"}}, "msg_pubkey": {"x": "HxXchWPWpTwqoraeretXIxkL1Povotkd68ouCsHm-lc", "y": "FDmRGZAUAzErYYS7YLO9UdSV3E_ODIR8tjPThSeg6YA", "crv": "P-256", "ext": true, "kty": "EC", "key_ops": []}, "life_layout": "grid", "song_history": [{"title": "Wish You Were Here", "artist": "Pink Floyd", "addedAt": "2026-08-07T06:43:56.103Z", "artworkUrl": "https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/aa/e0/ab/aae0ab6a-d906-a189-81bf-70b56aa43f7a/886445635843.jpg/200x200bb.jpg", "previewUrl": "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/1e/dd/9e/1edd9e7e-e944-8b94-36dd-373bed4e8c52/mzaf_9916504162058969591.plus.aac.p.m4a"}], "favorite_song": {"title": "Coming Back to Life", "artist": "Pink Floyd", "artworkUrl": "https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/f7/47/bf/f747bf4c-6a88-c26f-9545-f0ffed0b8992/886445627572.jpg/200x200bb.jpg", "previewUrl": "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/9a/b6/6c/9ab66c89-97ad-afab-b734-0145bd1cb7af/mzaf_6315117933932647853.plus.aac.p.m4a"}, "diary_e2e_salt": "Jv1C0pRNJyAsOY7IGBD4Qg==", "diary_e2e_enabled": true, "msg_privkey_wrapped": "e2e:v1:OVUKHBp8MGf7KMae:gJ6LuZVl+NlrWISkZa81LFPC2mcKnb8bwVfZHUktuicLnMkulPlJQRvYVpYEOuBbLz1lSCpXnDuQ4LDWVeKEuKWULpYH12GSxJRnFQpa7KfR8/KET+Cdn7hQSzjp0eAbhpqSsTGOISYpZdnDZJmtkgtXaaF/OD508f9dhPT62uAjqwWkJ6SQ3yIfYrwniXCEfX3x2UDeTkY474Q3HcfK1vzIglT+h4QF1ySu/oDdRltyegZpeDkHwsWmFPLfR68XN+3m082zwXl1giCcUFh3Douj3favGgBskgVh3vyINHXNJ4A=", "diary_e2e_wrapped_key": "+vrNizkYrpTPTYJk:G5aWppUHVWqS4pKUK2gVw50Vi8a1C7zohfeJDtiJf68IT0R+Qm6SAoN5d4V8cwmE", "happiness_quiet_until": "2026-08-15T20:03:15.439Z", "activity_events_seen_at": "2026-08-19T17:04:50.688Z", "happiness_support_circle": [{"name": "Dr. Yogita", "user_id": "57022196-7fc3-4bb8-88f9-578c4c3832c6"}, {"name": "Pooja Mahesh", "user_id": "596b2102-4ae0-430f-93c5-c9847886cf12"}, {"name": "Kaushik Das", "user_id": "13826d95-961c-494e-a2c2-018298bbda09"}, {"name": "Parakh Katre", "user_id": "b9e20678-6e1b-4a4a-9cde-e30e6cfc80eb"}], "happiness_circle_nudge_enabled": true}	f	t
6166861b-a5cd-41c8-8f85-ad94095c6abb	57022196-7fc3-4bb8-88f9-578c4c3832c6	yogita	Dr. Yogita	Chai over Coffee	#4E7065	\N	\N	public	yearbook	[{"id": "q_met", "ph": "The origin story", "long": true, "label": "How we met"}, {"id": "q_miss", "ph": "Be specific.", "long": true, "label": "What I’ll miss most"}, {"id": "q_fav", "ph": "A class, a trip, a 2am conversation...", "long": true, "label": "Favourite memory from this chapter"}, {"id": "q_predict", "ph": "Where you’ll be, what you’ll do", "long": false, "label": "My prediction for you"}, {"id": "q_touch", "ph": "A promise, not a plan", "long": false, "label": "How we’ll stay in touch"}, {"id": "q_road", "ph": "One thing to carry with you", "long": true, "label": "Advice for the road"}]	{}	2026-07-11 06:58:08.867233+00	{}	f	f
31fd125f-f206-4619-8c3d-6aa60caacb98	3d1eb4e1-b2da-465b-b9b6-48d13e167d7a	diya6665	Sandhya Sharma	Simple, kind, and unapologetically me. (Kind unless someone doesn’t provoke me)	#A65A3C	\N	\N	public	classic	[{"id": "q_likely", "ph": "e.g. Become famous by accident", "long": false, "label": "Most likely to..."}, {"id": "q_power", "ph": "e.g. Reading minds before exams", "long": false, "label": "A superpower you’d give them"}, {"id": "q_song", "ph": "e.g. Whatever’s stuck in your head", "long": false, "label": "A song that reminds you of them"}, {"id": "q_memory", "ph": "That one time when...", "long": true, "label": "Your best memory together"}, {"id": "q_advice", "ph": "Something you actually mean.", "long": true, "label": "One piece of advice for them"}, {"id": "q_future", "ph": "e.g. Running the place, still late", "long": false, "label": "Where you see them in 10 years"}]	{}	2026-07-14 18:02:36.546942+00	{"bday": "11-09", "city": "Hyderabad", "food": "Pani puri", "home": "Hyderabad", "song": "Manne na maan mera", "trip": "Kailash (I hate foreign countries)", "word": "Kind, selfless, respectful, and deeply patriotic your dedica", "movie": "Many"}	f	f
39397746-8222-41fc-83c7-cecf71d502bb	81ade54b-a78a-497b-9181-dc06376c7d9f	queenbee	Queen Bee	A carby-barbie, who operates on observation, empathy, and kindness.	#4E7065	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/avatars/81ade54b-a78a-497b-9181-dc06376c7d9f/avatar?v=1784054196292	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/covers/81ade54b-a78a-497b-9181-dc06376c7d9f/cover?v=1784055023175	public	classic	[{"id": "q_likely", "ph": "e.g. Become famous by accident", "long": false, "label": "Most likely to..."}, {"id": "q_power", "ph": "e.g. Reading minds before exams", "long": false, "label": "A superpower you’d give them"}, {"id": "q_song", "ph": "e.g. Whatever’s stuck in your head", "long": false, "label": "A song that reminds you of them"}, {"id": "q_memory", "ph": "That one time when...", "long": true, "label": "Your best memory together"}, {"id": "q_advice", "ph": "Something you actually mean.", "long": true, "label": "One piece of advice for them"}, {"id": "q_future", "ph": "e.g. Running the place, still late", "long": false, "label": "Where you see them in 10 years"}]	{}	2026-07-14 18:36:38.028255+00	{"bday": "9/Sep/1996", "food": "Mushroom-Cheese-Corn-Spinach Sandwich/Rice, Curd, Alu Bhaja", "song": "Chandrachooda by Raghu", "trip": "Some island maybe? With my favourite person?", "word": "Exotic (not my words)", "movie": "Dumb and Dumber (actually, all Jim Carrey movies)"}	f	f
2116276d-a809-47d1-94c0-6a3a97f9ab3a	b9e20678-6e1b-4a4a-9cde-e30e6cfc80eb	theparakhyouknow	Parakh Katre	What’d you like to say about me in one line (you can elaborate)	#A65A3C	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/avatars/b9e20678-6e1b-4a4a-9cde-e30e6cfc80eb/avatar?v=1784222531072	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/covers/b9e20678-6e1b-4a4a-9cde-e30e6cfc80eb/cover?v=1784222727388	public	classic	[{"id": "q_song", "ph": "e.g. Whatever’s stuck in your head", "long": false, "label": "A song that reminds you of them"}, {"id": "q_memory", "ph": "That one time when...", "long": true, "label": "Your best memory together"}, {"id": "q_advice", "ph": "Something you actually mean.", "long": true, "label": "One piece of advice for them"}]	{}	2026-07-16 17:22:11.204949+00	{}	f	f
5bff5eff-3dce-430b-a249-979fd0a92b84	65fae4b9-0c10-4dc8-b57c-b4d1d1cecb1f	surya	Surya	Just here to collect some words.	#57614A	\N	\N	public	classic	[{"id": "q_likely", "ph": "e.g. Become famous by accident", "long": false, "label": "Most likely to..."}, {"id": "q_power", "ph": "e.g. Reading minds before exams", "long": false, "label": "A superpower you’d give them"}, {"id": "q_song", "ph": "e.g. Whatever’s stuck in your head", "long": false, "label": "A song that reminds you of them"}, {"id": "q_memory", "ph": "That one time when...", "long": true, "label": "Your best memory together"}, {"id": "q_advice", "ph": "Something you actually mean.", "long": true, "label": "One piece of advice for them"}, {"id": "q_future", "ph": "e.g. Running the place, still late", "long": false, "label": "Where you see them in 10 years"}]	{}	2026-07-17 04:05:38.09093+00	{}	f	f
ac7db8d1-eddf-49e6-9055-9e34e1b5025a	93b861a6-d5bd-4248-a0b1-63d6bb067b66	gfhh	H	Just here to collect some words.	#57614A	\N	\N	public	classic	[{"id": "q_likely", "ph": "e.g. Become famous by accident", "long": false, "label": "Most likely to..."}, {"id": "q_power", "ph": "e.g. Reading minds before exams", "long": false, "label": "A superpower you’d give them"}, {"id": "q_song", "ph": "e.g. Whatever’s stuck in your head", "long": false, "label": "A song that reminds you of them"}, {"id": "q_memory", "ph": "That one time when...", "long": true, "label": "Your best memory together"}, {"id": "q_advice", "ph": "Something you actually mean.", "long": true, "label": "One piece of advice for them"}, {"id": "q_future", "ph": "e.g. Running the place, still late", "long": false, "label": "Where you see them in 10 years"}]	{}	2026-07-17 09:39:10.361734+00	{}	f	f
23a09b0b-fb05-45db-b01f-0905065f89ef	674599f7-e03b-4c53-8d8f-4d3bbc50bf64	sam	Samarth	Thinker.cold coffee.love the game of life	#3C4A5E	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/avatars/674599f7-e03b-4c53-8d8f-4d3bbc50bf64/avatar?v=1784357979274	https://uehnlopsazcwguhrqtnh.supabase.co/storage/v1/object/public/covers/674599f7-e03b-4c53-8d8f-4d3bbc50bf64/cover?v=1784357979631	public	classic	[{"id": "q_likely", "ph": "e.g. Become famous by accident", "long": false, "label": "Most likely to..."}, {"id": "q_power", "ph": "e.g. Reading minds before exams", "long": false, "label": "A superpower you’d give them"}, {"id": "q_song", "ph": "e.g. Whatever’s stuck in your head", "long": false, "label": "A song that reminds you of them"}, {"id": "q_memory", "ph": "That one time when...", "long": true, "label": "Your best memory together"}, {"id": "q_advice", "ph": "Something you actually mean.", "long": true, "label": "One piece of advice for them"}, {"id": "q_future", "ph": "e.g. Running the place, still late", "long": false, "label": "Where you see them in 10 years"}]	{}	2026-07-18 06:59:39.725091+00	{}	f	f
4bde932d-2f8b-448d-8b49-0c3b6973ecc9	f3224654-1357-4933-a356-d10bf55f7354	rajesh	Rajesh	Just here to collect some words.	#4E7065	\N	\N	public	yearbook	[{"id": "q_met", "ph": "The origin story", "long": true, "label": "How we met"}, {"id": "q_miss", "ph": "Be specific.", "long": true, "label": "What I’ll miss most"}, {"id": "q_fav", "ph": "A class, a trip, a 2am conversation...", "long": true, "label": "Favourite memory from this chapter"}, {"id": "q_predict", "ph": "Where you’ll be, what you’ll do", "long": false, "label": "My prediction for you"}, {"id": "q_touch", "ph": "A promise, not a plan", "long": false, "label": "How we’ll stay in touch"}, {"id": "q_road", "ph": "One thing to carry with you", "long": true, "label": "Advice for the road"}]	{}	2026-07-19 14:26:27.405549+00	{"activity_events_seen_at": "2026-08-02T17:41:57.755Z"}	f	f
264744a6-08eb-4d1e-9401-547ae95fbf05	88f68f9f-5af9-4a19-9252-842e5e0a1776	varsh_ini	Varshini	Just here to collect some words.	#6B4C6B	\N	\N	public	deep	[{"id": "q_taught", "ph": "They probably have no idea...", "long": true, "label": "Something they taught you without knowing it"}, {"id": "q_seen", "ph": "It might seem small to them...", "long": true, "label": "A moment they made you feel seen"}, {"id": "q_lastnote", "ph": "Say the thing.", "long": true, "label": "If this were your last note to them"}, {"id": "q_forgive", "ph": "Gently.", "long": true, "label": "Something they should forgive themselves for"}, {"id": "q_neverlose", "ph": "e.g. The way they check on people", "long": false, "label": "The quality you hope they never lose"}]	{}	2026-07-22 13:53:53.532224+00	{}	f	f
f6b1d166-6e02-4134-bf30-56cc67a5d038	13554111-b50c-44ad-af7b-4988c8209afb	sharma	sharma	Just here to collect some words.	#4E7065	\N	\N	public	laughs	[{"id": "q_unhinged", "ph": "We both know which one.", "long": true, "label": "Their most unhinged moment"}, {"id": "q_remind", "ph": "Explain yourself.", "long": false, "label": "A food, smell, or animal they remind you of"}, {"id": "q_search", "ph": "Be honest.", "long": false, "label": "What their search history probably looks like"}, {"id": "q_movie", "ph": "e.g. The chaotic sidekick who steals the film", "long": false, "label": "If they were a movie character"}, {"id": "q_phrase", "ph": "The thing they always say", "long": false, "label": "Their catchphrase"}, {"id": "q_arrested", "ph": "Hypothetically. Obviously.", "long": false, "label": "What they’d get arrested for"}]	{}	2026-08-01 18:20:56.052454+00	{"referred_by": "aseshsarkar", "favorite_song": {"title": "Laal Ishq", "artist": "Sanjay Leela Bhansali, Arijit Singh & Siddharth-Garima", "artworkUrl": "https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/0a/c2/6a/0ac26af9-78c9-d0f2-9292-316925bed3d8/196871079914.jpg/200x200bb.jpg", "previewUrl": "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/a0/4e/42/a04e42b5-f2ba-6eb5-4ca3-5b156f7c342f/mzaf_15396203027231667728.plus.aac.p.m4a"}, "activity_events_seen_at": "2026-08-12T14:04:52.744Z", "happiness_support_circle": [{"name": "sharma", "user_id": "13554111-b50c-44ad-af7b-4988c8209afb"}, {"name": "asesh", "user_id": "794c5058-c511-4509-ad40-938ce0d45eae"}]}	f	f
\.


--
-- Data for Name: reports; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reports (id, target_type, target_id, reason, reporter_key, created_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2026-07-05 01:12:59
20211116045059	2026-07-05 01:12:59
20211116050929	2026-07-05 01:12:59
20211116051442	2026-07-05 01:12:59
20211116212300	2026-07-05 05:09:11
20211116213355	2026-07-05 05:09:11
20211116213934	2026-07-05 05:09:11
20211116214523	2026-07-05 05:09:11
20211122062447	2026-07-05 05:09:11
20211124070109	2026-07-05 05:09:11
20211202204204	2026-07-05 05:09:11
20211202204605	2026-07-05 05:09:11
20211210212804	2026-07-05 05:09:11
20211228014915	2026-07-05 05:09:11
20220107221237	2026-07-05 05:09:11
20220228202821	2026-07-05 05:09:11
20220312004840	2026-07-05 05:09:12
20220603231003	2026-07-05 05:09:12
20220603232444	2026-07-05 05:09:12
20220615214548	2026-07-05 05:09:12
20220712093339	2026-07-05 05:09:12
20220908172859	2026-07-05 05:09:12
20220916233421	2026-07-05 05:09:12
20230119133233	2026-07-05 05:09:12
20230128025114	2026-07-05 05:09:12
20230128025212	2026-07-05 05:09:12
20230227211149	2026-07-05 05:09:12
20230228184745	2026-07-05 05:09:12
20230308225145	2026-07-05 05:09:12
20230328144023	2026-07-05 05:09:12
20231018144023	2026-07-05 05:09:12
20231204144023	2026-07-05 05:09:12
20231204144024	2026-07-05 05:09:12
20231204144025	2026-07-05 05:09:12
20240108234812	2026-07-05 05:09:12
20240109165339	2026-07-05 05:09:12
20240227174441	2026-07-05 05:09:12
20240311171622	2026-07-05 05:09:12
20240321100241	2026-07-05 05:09:12
20240401105812	2026-07-05 05:09:12
20240418121054	2026-07-05 05:09:12
20240523004032	2026-07-05 05:09:12
20240618124746	2026-07-05 05:09:12
20240801235015	2026-07-05 05:09:12
20240805133720	2026-07-05 05:09:12
20240827160934	2026-07-05 05:09:12
20240919163303	2026-07-05 05:09:12
20240919163305	2026-07-05 05:09:12
20241019105805	2026-07-05 05:09:12
20241030150047	2026-07-05 05:09:12
20241108114728	2026-07-05 05:09:12
20241121104152	2026-07-05 05:09:12
20241130184212	2026-07-05 05:09:12
20241220035512	2026-07-05 05:09:12
20241220123912	2026-07-05 05:09:12
20241224161212	2026-07-05 05:09:12
20250107150512	2026-07-05 05:09:12
20250110162412	2026-07-05 05:09:12
20250123174212	2026-07-05 05:09:12
20250128220012	2026-07-05 05:09:12
20250506224012	2026-07-05 05:09:12
20250523164012	2026-07-05 05:09:12
20250714121412	2026-07-05 05:09:12
20250905041441	2026-07-05 05:09:12
20251103001201	2026-07-05 05:09:12
20251120212548	2026-07-05 05:09:12
20251120215549	2026-07-05 05:09:12
20260218120000	2026-07-05 05:09:12
20260326120000	2026-07-05 05:09:12
20260514120000	2026-07-05 05:09:12
20260527120000	2026-07-05 05:09:12
20260528120000	2026-07-05 05:09:12
20260603120000	2026-07-05 05:09:12
20260605120000	2026-07-05 05:09:12
20260606110000	2026-07-05 05:09:12
20260616120000	2026-07-05 05:09:12
20260624120000	2026-07-05 05:09:12
20260626120000	2026-07-05 05:09:12
20260706120000	2026-07-09 19:19:30
20260707120000	2026-07-16 07:41:26
20260709120000	2026-07-16 07:41:26
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at, action_filter, selected_columns) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type) FROM stdin;
avatars	avatars	\N	2026-07-05 05:10:35.111062+00	2026-07-05 05:10:35.111062+00	t	f	\N	\N	\N	STANDARD
covers	covers	\N	2026-07-05 05:10:35.111062+00	2026-07-05 05:10:35.111062+00	t	f	\N	\N	\N	STANDARD
entry-photos	entry-photos	\N	2026-07-05 05:10:35.111062+00	2026-07-05 05:10:35.111062+00	t	f	\N	\N	\N	STANDARD
event-photos	event-photos	\N	2026-07-12 05:00:00.549807+00	2026-07-12 05:00:00.549807+00	t	f	\N	\N	\N	STANDARD
event-share	event-share	\N	2026-08-01 13:54:40.89103+00	2026-08-01 13:54:40.89103+00	t	f	\N	\N	\N	STANDARD
\.


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_analytics (name, type, format, created_at, updated_at, id, deleted_at) FROM stdin;
\.


--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_vectors (id, type, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2026-07-05 01:13:26.144011
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2026-07-05 01:13:26.189853
2	storage-schema	f6a1fa2c93cbcd16d4e487b362e45fca157a8dbd	2026-07-05 01:13:26.193275
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2026-07-05 01:13:26.213519
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2026-07-05 01:13:26.225134
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2026-07-05 01:13:26.227078
6	change-column-name-in-get-size	ded78e2f1b5d7e616117897e6443a925965b30d2	2026-07-05 01:13:26.230365
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2026-07-05 01:13:26.232671
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2026-07-05 01:13:26.235237
9	fix-search-function	af597a1b590c70519b464a4ab3be54490712796b	2026-07-05 01:13:26.237234
10	search-files-search-function	b595f05e92f7e91211af1bbfe9c6a13bb3391e16	2026-07-05 01:13:26.238979
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2026-07-05 01:13:26.24172
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2026-07-05 01:13:26.244146
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2026-07-05 01:13:26.246038
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2026-07-05 01:13:26.2478
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2026-07-05 01:13:26.271181
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2026-07-05 01:13:26.274489
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2026-07-05 01:13:26.276572
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2026-07-05 01:13:26.27849
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2026-07-05 01:13:26.281992
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2026-07-05 01:13:26.284392
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2026-07-05 01:13:26.288332
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2026-07-05 01:13:26.300137
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2026-07-05 01:13:26.30856
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2026-07-05 01:13:26.312244
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2026-07-05 01:13:26.314568
26	objects-prefixes	215cabcb7f78121892a5a2037a09fedf9a1ae322	2026-07-05 01:13:26.317846
27	search-v2	859ba38092ac96eb3964d83bf53ccc0b141663a6	2026-07-05 01:13:26.319509
28	object-bucket-name-sorting	c73a2b5b5d4041e39705814fd3a1b95502d38ce4	2026-07-05 01:13:26.320908
29	create-prefixes	ad2c1207f76703d11a9f9007f821620017a66c21	2026-07-05 01:13:26.322349
30	update-object-levels	2be814ff05c8252fdfdc7cfb4b7f5c7e17f0bed6	2026-07-05 01:13:26.323777
31	objects-level-index	b40367c14c3440ec75f19bbce2d71e914ddd3da0	2026-07-05 01:13:26.326101
32	backward-compatible-index-on-objects	e0c37182b0f7aee3efd823298fb3c76f1042c0f7	2026-07-05 01:13:26.327795
33	backward-compatible-index-on-prefixes	b480e99ed951e0900f033ec4eb34b5bdcb4e3d49	2026-07-05 01:13:26.329263
34	optimize-search-function-v1	ca80a3dc7bfef894df17108785ce29a7fc8ee456	2026-07-05 01:13:26.330805
35	add-insert-trigger-prefixes	458fe0ffd07ec53f5e3ce9df51bfdf4861929ccc	2026-07-05 01:13:26.332377
36	optimise-existing-functions	6ae5fca6af5c55abe95369cd4f93985d1814ca8f	2026-07-05 01:13:26.333954
37	add-bucket-name-length-trigger	3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1	2026-07-05 01:13:26.335491
38	iceberg-catalog-flag-on-buckets	02716b81ceec9705aed84aa1501657095b32e5c5	2026-07-05 01:13:26.338339
39	add-search-v2-sort-support	6706c5f2928846abee18461279799ad12b279b78	2026-07-05 01:13:26.347147
40	fix-prefix-race-conditions-optimized	7ad69982ae2d372b21f48fc4829ae9752c518f6b	2026-07-05 01:13:26.348702
41	add-object-level-update-trigger	07fcf1a22165849b7a029deed059ffcde08d1ae0	2026-07-05 01:13:26.350145
42	rollback-prefix-triggers	771479077764adc09e2ea2043eb627503c034cd4	2026-07-05 01:13:26.351577
43	fix-object-level	84b35d6caca9d937478ad8a797491f38b8c2979f	2026-07-05 01:13:26.353177
44	vector-bucket-type	99c20c0ffd52bb1ff1f32fb992f3b351e3ef8fb3	2026-07-05 01:13:26.354587
45	vector-buckets	049e27196d77a7cb76497a85afae669d8b230953	2026-07-05 01:13:26.356808
46	buckets-objects-grants	fedeb96d60fefd8e02ab3ded9fbde05632f84aed	2026-07-05 01:13:26.365174
47	iceberg-table-metadata	649df56855c24d8b36dd4cc1aeb8251aa9ad42c2	2026-07-05 01:13:26.367953
48	iceberg-catalog-ids	e0e8b460c609b9999ccd0df9ad14294613eed939	2026-07-05 01:13:26.369676
49	buckets-objects-grants-postgres	072b1195d0d5a2f888af6b2302a1938dd94b8b3d	2026-07-05 01:13:26.386246
50	search-v2-optimised	6323ac4f850aa14e7387eb32102869578b5bd478	2026-07-05 01:13:26.389406
51	index-backward-compatible-search	2ee395d433f76e38bcd3856debaf6e0e5b674011	2026-07-05 01:13:27.253479
52	drop-not-used-indexes-and-functions	5cc44c8696749ac11dd0dc37f2a3802075f3a171	2026-07-05 01:13:27.254568
53	drop-index-lower-name	d0cb18777d9e2a98ebe0bc5cc7a42e57ebe41854	2026-07-05 01:13:27.261688
54	drop-index-object-level	6289e048b1472da17c31a7eba1ded625a6457e67	2026-07-05 01:13:27.263176
55	prevent-direct-deletes	262a4798d5e0f2e7c8970232e03ce8be695d5819	2026-07-05 01:13:27.264039
56	fix-optimized-search-function	b823ed1e418101032fa01374edc9a436e54e3ed4	2026-07-05 01:13:27.267042
57	s3-multipart-uploads-metadata	f127886e00d1b374fadbc7c6b31e09336aad5287	2026-07-05 01:13:27.270707
58	operation-ergonomics	00ca5d483b3fe0d522133d9002ccc5df98365120	2026-07-05 01:13:27.272803
59	drop-unused-functions	38456f13e39691c2bbb4b5151d0d1cdbabd4a8c4	2026-07-05 01:13:27.275439
60	optimize-existing-functions-again	db35e1c91a9201e59f4fef8d972c2f277d68b157	2026-07-05 01:13:27.277542
61	mark-filename-immutable	fe0096517ae9d60aaec1d110172ba9036dc66bb7	2026-08-11 11:02:04.942092
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata) FROM stdin;
5c874f60-8727-401c-9c90-8439ffedf8c8	entry-photos	e_1783265209899_0_xqiyvk	13554111-b50c-44ad-af7b-4988c8209afb	2026-07-05 15:26:50.210575+00	2026-07-05 15:26:50.210575+00	2026-07-05 15:26:50.210575+00	{"eTag": "\\"b1ffe00bb9b8ef73b2925e56b789c9b3\\"", "size": 1819850, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-07-05T15:26:51.000Z", "contentLength": 1819850, "httpStatusCode": 200}	4ef3ab9b-b4d4-4836-a298-843d606297fe	13554111-b50c-44ad-af7b-4988c8209afb	{}
d123032a-03bc-4963-8470-abe347c34115	covers	596b2102-4ae0-430f-93c5-c9847886cf12/cover	596b2102-4ae0-430f-93c5-c9847886cf12	2026-07-05 17:16:42.113255+00	2026-07-05 17:19:52.624092+00	2026-07-05 17:16:42.113255+00	{"eTag": "\\"a0c5489cbb2f73ae6fa3b0b5dbd4b633\\"", "size": 73132, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-05T17:19:53.000Z", "contentLength": 73132, "httpStatusCode": 200}	66d0dbe0-89fa-4a50-a254-17a16cc51786	596b2102-4ae0-430f-93c5-c9847886cf12	{}
f5eb2eca-01cc-4dbf-8724-ec4358faebc7	entry-photos	e_1783352264154_0_40pemv	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-06 15:37:44.418766+00	2026-07-06 15:37:44.418766+00	2026-07-06 15:37:44.418766+00	{"eTag": "\\"553d726bc2cb29c55d1087f6ef36a04d\\"", "size": 119959, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-06T15:37:45.000Z", "contentLength": 119959, "httpStatusCode": 200}	42eae15b-89c2-4b41-973a-7d4f018773a8	794c5058-c511-4509-ad40-938ce0d45eae	{}
cf451f35-77f2-4f13-80c2-90f80e529792	avatars	794c5058-c511-4509-ad40-938ce0d45eae/avatar	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-05 10:25:39.761632+00	2026-07-05 16:23:57.129402+00	2026-07-05 10:25:39.761632+00	{"eTag": "\\"b8eaae89bb25936d0ac4b8806e9dc159\\"", "size": 466491, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-05T16:23:58.000Z", "contentLength": 466491, "httpStatusCode": 200}	c44979ee-7d2c-49f8-81ef-b7942dcaab5c	794c5058-c511-4509-ad40-938ce0d45eae	{}
6b1a904f-004a-4a01-83ed-d0f9b8944b9b	event-photos	ev_f16fa9eb-7ebb-4538-8942-d1e5f216f2f6_1783833204648_a0	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-12 05:13:24.838828+00	2026-07-12 05:13:24.838828+00	2026-07-12 05:13:24.838828+00	{"eTag": "\\"553d726bc2cb29c55d1087f6ef36a04d\\"", "size": 119959, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-12T05:13:25.000Z", "contentLength": 119959, "httpStatusCode": 200}	413ca3ac-208a-425f-9a46-5dd3d31edb02	794c5058-c511-4509-ad40-938ce0d45eae	{}
123ead4b-477d-4c8c-a2db-0aeeb9f94730	entry-photos	e_1783270375814_0_pz8txe	13554111-b50c-44ad-af7b-4988c8209afb	2026-07-05 16:52:56.057998+00	2026-07-05 16:52:56.057998+00	2026-07-05 16:52:56.057998+00	{"eTag": "\\"c14ad5f02ff21ab36801417a07a2f65a\\"", "size": 99507, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-05T16:52:57.000Z", "contentLength": 99507, "httpStatusCode": 200}	f2772294-072a-4a15-9e1f-d919f8eb5a87	13554111-b50c-44ad-af7b-4988c8209afb	{}
8f2664f6-609a-449a-8079-c2062036d8bd	entry-photos	e_1783271697615_0_fcv06r	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-05 17:14:57.792486+00	2026-07-05 17:14:57.792486+00	2026-07-05 17:14:57.792486+00	{"eTag": "\\"4c56301f14b57e77e5f0bf9688724167\\"", "size": 41168, "mimetype": "image/avif", "cacheControl": "max-age=3600", "lastModified": "2026-07-05T17:14:58.000Z", "contentLength": 41168, "httpStatusCode": 200}	e897ae83-f17a-4472-9900-d2e0d1a80cec	794c5058-c511-4509-ad40-938ce0d45eae	{}
851f64d9-afc3-4bb5-9ab2-adaf1daffcaa	event-photos	cover_f16fa9eb-7ebb-4538-8942-d1e5f216f2f6_1783856540047	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-12 11:42:20.227586+00	2026-07-12 11:42:20.227586+00	2026-07-12 11:42:20.227586+00	{"eTag": "\\"c14ad5f02ff21ab36801417a07a2f65a\\"", "size": 99507, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-12T11:42:21.000Z", "contentLength": 99507, "httpStatusCode": 200}	292500ea-a677-4b12-9a59-1d6629868838	794c5058-c511-4509-ad40-938ce0d45eae	{}
c9a6a852-d9cc-45aa-8477-a4f32a69d17e	entry-photos	e_1783753387603_0_hqrx8i	57022196-7fc3-4bb8-88f9-578c4c3832c6	2026-07-11 07:03:07.982191+00	2026-07-11 07:03:07.982191+00	2026-07-11 07:03:07.982191+00	{"eTag": "\\"b0863fea7c5319343f33bd35e4e86f15\\"", "size": 50760, "mimetype": "image/webp", "cacheControl": "max-age=3600", "lastModified": "2026-07-11T07:03:08.000Z", "contentLength": 50760, "httpStatusCode": 200}	75adcf34-ef43-4eb2-9c77-e99262691928	57022196-7fc3-4bb8-88f9-578c4c3832c6	{}
c0be3cc4-493d-4c0a-877e-e4fe09004c49	event-photos	ev_f16fa9eb-7ebb-4538-8942-d1e5f216f2f6_1783832853223_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-12 05:07:33.490945+00	2026-07-12 05:07:33.490945+00	2026-07-12 05:07:33.490945+00	{"eTag": "\\"c14ad5f02ff21ab36801417a07a2f65a\\"", "size": 99507, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-12T05:07:34.000Z", "contentLength": 99507, "httpStatusCode": 200}	18c326ec-ead7-49d3-9b5a-d8d79a1e330d	794c5058-c511-4509-ad40-938ce0d45eae	{}
d62d789b-391e-4ba6-976c-aacb9e079b3f	event-photos	ev_f16fa9eb-7ebb-4538-8942-d1e5f216f2f6_1783856777031_a0	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-12 11:46:17.248004+00	2026-07-12 11:46:17.248004+00	2026-07-12 11:46:17.248004+00	{"eTag": "\\"b8eaae89bb25936d0ac4b8806e9dc159\\"", "size": 466491, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-12T11:46:18.000Z", "contentLength": 466491, "httpStatusCode": 200}	73564265-da4e-4064-84f5-c31c60b491ef	794c5058-c511-4509-ad40-938ce0d45eae	{}
29fcb599-78cb-40cd-be8f-ab9d40bc8b39	covers	f3224654-1357-4933-a356-d10bf55f7354/cover	f3224654-1357-4933-a356-d10bf55f7354	2026-07-14 10:27:10.350245+00	2026-07-14 10:27:10.350245+00	2026-07-14 10:27:10.350245+00	{"eTag": "\\"2c035f1ab08228466d562099d1f2e56f\\"", "size": 51964, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-14T10:27:11.000Z", "contentLength": 51964, "httpStatusCode": 200}	b90c0246-0c57-483c-a491-557da38d9cb6	f3224654-1357-4933-a356-d10bf55f7354	{}
bbd14afd-5a58-47ad-9f39-d020ada31481	avatars	81ade54b-a78a-497b-9181-dc06376c7d9f/avatar	81ade54b-a78a-497b-9181-dc06376c7d9f	2026-07-14 18:36:37.243781+00	2026-07-14 18:36:37.243781+00	2026-07-14 18:36:37.243781+00	{"eTag": "\\"352c30d1592a6ed6a7954678b455a7af\\"", "size": 23211, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-14T18:36:38.000Z", "contentLength": 23211, "httpStatusCode": 200}	55aa94fa-53f2-4d8e-b80c-3532d5c1462e	81ade54b-a78a-497b-9181-dc06376c7d9f	{}
a341c663-3ba6-47f2-af70-1da16cf0f97a	covers	794c5058-c511-4509-ad40-938ce0d45eae/cover	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-05 10:25:45.370632+00	2026-07-18 08:05:48.512133+00	2026-07-05 10:25:45.370632+00	{"eTag": "\\"e7e1c32462db0a3aec60e709e44234b9\\"", "size": 200897, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-18T08:05:49.000Z", "contentLength": 200897, "httpStatusCode": 200}	f18152da-a5f7-47e8-bbf9-3380977dd1e1	794c5058-c511-4509-ad40-938ce0d45eae	{}
b0e60684-1fa1-49ca-a4e1-c74407ddb996	event-photos	ev_f16fa9eb-7ebb-4538-8942-d1e5f216f2f6_1783857046545_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-12 11:50:46.809661+00	2026-07-12 11:50:46.809661+00	2026-07-12 11:50:46.809661+00	{"eTag": "\\"b8eaae89bb25936d0ac4b8806e9dc159\\"", "size": 466491, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-12T11:50:47.000Z", "contentLength": 466491, "httpStatusCode": 200}	34db9487-29c4-4cde-8b3c-0bfa8902c6b2	794c5058-c511-4509-ad40-938ce0d45eae	{}
73fdd91d-084e-49bb-a51e-0a31a6312d33	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784627216483_qu50ai	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 09:46:56.672841+00	2026-07-21 09:46:56.672841+00	2026-07-21 09:46:56.672841+00	{"eTag": "\\"a900a7e1957cc6f855ba204797694b8c\\"", "size": 139843, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T09:46:57.000Z", "contentLength": 139843, "httpStatusCode": 200}	9a5f1a37-63f7-4ba9-9613-fb51b84129a8	794c5058-c511-4509-ad40-938ce0d45eae	{}
a796eb76-bbf5-4ab5-8082-1294ab8aaa69	event-photos	ev_f16fa9eb-7ebb-4538-8942-d1e5f216f2f6_1783857095480_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-12 11:51:35.693877+00	2026-07-12 11:51:35.693877+00	2026-07-12 11:51:35.693877+00	{"eTag": "\\"b8eaae89bb25936d0ac4b8806e9dc159\\"", "size": 466491, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-12T11:51:36.000Z", "contentLength": 466491, "httpStatusCode": 200}	7ac5a508-b441-4c5f-93ee-39b8c3cce7a3	794c5058-c511-4509-ad40-938ce0d45eae	{}
acfc63a3-0301-4ef2-ae7f-9f20b32dbdac	event-photos	cover_f16fa9eb-7ebb-4538-8942-d1e5f216f2f6_1783872156418	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-12 16:02:36.750187+00	2026-07-12 16:02:36.750187+00	2026-07-12 16:02:36.750187+00	{"eTag": "\\"c14ad5f02ff21ab36801417a07a2f65a\\"", "size": 99507, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-12T16:02:37.000Z", "contentLength": 99507, "httpStatusCode": 200}	a4c3560a-afd8-43d9-96a0-1346ae3b3893	794c5058-c511-4509-ad40-938ce0d45eae	{}
361139f4-6def-44e9-b9ef-21d5bfebb077	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784627216780_4yiquc	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 09:46:56.919013+00	2026-07-21 09:46:56.919013+00	2026-07-21 09:46:56.919013+00	{"eTag": "\\"78c7e5a6e77ed25092d5956b66ef496d\\"", "size": 154358, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T09:46:57.000Z", "contentLength": 154358, "httpStatusCode": 200}	b4fbea48-b1d0-44ef-a182-e2f3136c8dc6	794c5058-c511-4509-ad40-938ce0d45eae	{}
933f7a6c-eaff-4ae5-99a9-f7df288c165d	entry-photos	e_1783876360088_0_4g0t4i	13554111-b50c-44ad-af7b-4988c8209afb	2026-07-12 17:12:40.263298+00	2026-07-12 17:12:40.263298+00	2026-07-12 17:12:40.263298+00	{"eTag": "\\"e5ae3ab02717c7282d7facae3a086990\\"", "size": 56951, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-12T17:12:41.000Z", "contentLength": 56951, "httpStatusCode": 200}	71f9f5d8-0ff1-439a-bec8-b2b549a284af	13554111-b50c-44ad-af7b-4988c8209afb	{}
1546720c-4753-45c7-8a23-2a0e7e30a733	entry-photos	e_1783876822667_0_tu2abc	13554111-b50c-44ad-af7b-4988c8209afb	2026-07-12 17:20:22.89205+00	2026-07-12 17:20:22.89205+00	2026-07-12 17:20:22.89205+00	{"eTag": "\\"c14ad5f02ff21ab36801417a07a2f65a\\"", "size": 99507, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-12T17:20:23.000Z", "contentLength": 99507, "httpStatusCode": 200}	e1bcb47f-fbb7-4c6a-9c91-710339f60416	13554111-b50c-44ad-af7b-4988c8209afb	{}
bd4eb9d0-fea0-451a-92c9-18cd7071a128	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784627217036_me3k8d	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 09:46:57.279596+00	2026-07-21 09:46:57.279596+00	2026-07-21 09:46:57.279596+00	{"eTag": "\\"1f49eae06644aea1390b511069c9b794\\"", "size": 225321, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T09:46:58.000Z", "contentLength": 225321, "httpStatusCode": 200}	a916f291-5791-4aeb-a839-e6fae97150a6	794c5058-c511-4509-ad40-938ce0d45eae	{}
22d33666-d38d-4f82-804d-f3c3888680fa	event-photos	cover_f16fa9eb-7ebb-4538-8942-d1e5f216f2f6_1783927469248	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-13 07:24:29.684328+00	2026-07-13 07:24:29.684328+00	2026-07-13 07:24:29.684328+00	{"eTag": "\\"b8eaae89bb25936d0ac4b8806e9dc159\\"", "size": 466491, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-13T07:24:30.000Z", "contentLength": 466491, "httpStatusCode": 200}	f6f0fea7-813a-4cb2-b509-71ed6e914e89	794c5058-c511-4509-ad40-938ce0d45eae	{}
00a12380-b0b1-40a5-aca2-4d165c0b17ae	entry-photos	life/51323e47-38a0-405d-b597-a56cc534ba12/2011-1786387490122-l0mo	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-10 18:44:50.480909+00	2026-08-10 18:44:50.480909+00	2026-08-10 18:44:50.480909+00	{"eTag": "\\"a8e7b7cb6ae447e8730b33fd72755323\\"", "size": 76429, "mimetype": "image/avif", "cacheControl": "max-age=3600", "lastModified": "2026-08-10T18:44:51.000Z", "contentLength": 76429, "httpStatusCode": 200}	6628283d-0077-409f-b226-b0612174a017	794c5058-c511-4509-ad40-938ce0d45eae	{}
47612d89-0473-4677-b4f1-bfaa0e2e7dd7	entry-photos	diary_794c5058-c511-4509-ad40-938ce0d45eae_1783952333800_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-13 14:18:54.044572+00	2026-07-13 14:18:54.044572+00	2026-07-13 14:18:54.044572+00	{"eTag": "\\"b8eaae89bb25936d0ac4b8806e9dc159\\"", "size": 466491, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-13T14:18:55.000Z", "contentLength": 466491, "httpStatusCode": 200}	5b46fe58-d803-48f7-a6bb-51ab198658b1	794c5058-c511-4509-ad40-938ce0d45eae	{}
6d8f2d86-4fb1-434f-8e6f-8f9f3f003ba4	entry-photos	diary_794c5058-c511-4509-ad40-938ce0d45eae_1783952345162_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-13 14:19:05.343439+00	2026-07-13 14:19:05.343439+00	2026-07-13 14:19:05.343439+00	{"eTag": "\\"b8eaae89bb25936d0ac4b8806e9dc159\\"", "size": 466491, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-13T14:19:06.000Z", "contentLength": 466491, "httpStatusCode": 200}	f99b0413-7361-410c-8d89-659722fde078	794c5058-c511-4509-ad40-938ce0d45eae	{}
bf3d4c5e-29ce-4dc4-9800-c4625188e555	entry-photos	diary_794c5058-c511-4509-ad40-938ce0d45eae_1783952355094_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-13 14:19:15.343421+00	2026-07-13 14:19:15.343421+00	2026-07-13 14:19:15.343421+00	{"eTag": "\\"b8eaae89bb25936d0ac4b8806e9dc159\\"", "size": 466491, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-13T14:19:16.000Z", "contentLength": 466491, "httpStatusCode": 200}	31001aaa-65ce-4955-9c80-fb46989af315	794c5058-c511-4509-ad40-938ce0d45eae	{}
065182af-323e-4ec8-bf21-5bb1c22f85f4	entry-photos	diary_794c5058-c511-4509-ad40-938ce0d45eae_1783952363749_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-13 14:19:23.975247+00	2026-07-13 14:19:23.975247+00	2026-07-13 14:19:23.975247+00	{"eTag": "\\"b8eaae89bb25936d0ac4b8806e9dc159\\"", "size": 466491, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-13T14:19:24.000Z", "contentLength": 466491, "httpStatusCode": 200}	968ef244-935a-4236-a0c8-db58daca7893	794c5058-c511-4509-ad40-938ce0d45eae	{}
46759e2c-8eca-4687-975b-827f08194a76	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784627217375_yblgb7	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 09:46:57.545186+00	2026-07-21 09:46:57.545186+00	2026-07-21 09:46:57.545186+00	{"eTag": "\\"1f49eae06644aea1390b511069c9b794\\"", "size": 225321, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T09:46:58.000Z", "contentLength": 225321, "httpStatusCode": 200}	9e2ac3f2-f33f-4f6b-bdec-cf54002f5439	794c5058-c511-4509-ad40-938ce0d45eae	{}
cfb820f0-5446-401f-b0e2-75cc7186fce9	entry-photos	diary_794c5058-c511-4509-ad40-938ce0d45eae_1783952424308_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-13 14:20:24.556959+00	2026-07-13 14:20:24.556959+00	2026-07-13 14:20:24.556959+00	{"eTag": "\\"b8eaae89bb25936d0ac4b8806e9dc159\\"", "size": 466491, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-13T14:20:25.000Z", "contentLength": 466491, "httpStatusCode": 200}	ba14b06c-c36f-42bb-bb91-92f485d33f45	794c5058-c511-4509-ad40-938ce0d45eae	{}
735225cb-ed09-4f89-85a9-f6ace874d2b8	entry-photos	diary_794c5058-c511-4509-ad40-938ce0d45eae_1783952427625_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-13 14:20:27.801155+00	2026-07-13 14:20:27.801155+00	2026-07-13 14:20:27.801155+00	{"eTag": "\\"b8eaae89bb25936d0ac4b8806e9dc159\\"", "size": 466491, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-13T14:20:28.000Z", "contentLength": 466491, "httpStatusCode": 200}	a1282a53-9f2a-46cb-8d5a-6509356d0b61	794c5058-c511-4509-ad40-938ce0d45eae	{}
a5198b30-3c10-496e-a7a0-917766ad4154	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784627217662_j380l3	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 09:46:57.798746+00	2026-07-21 09:46:57.798746+00	2026-07-21 09:46:57.798746+00	{"eTag": "\\"440970b5bdf962789404136128f5723b\\"", "size": 145960, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T09:46:58.000Z", "contentLength": 145960, "httpStatusCode": 200}	3bc5de02-92b6-4273-913d-18beabab6e31	794c5058-c511-4509-ad40-938ce0d45eae	{}
a34abc2b-98dc-47d4-8d86-9593f641f693	entry-photos	diary_794c5058-c511-4509-ad40-938ce0d45eae_1783952508752_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-13 14:21:48.99122+00	2026-07-13 14:21:48.99122+00	2026-07-13 14:21:48.99122+00	{"eTag": "\\"b8eaae89bb25936d0ac4b8806e9dc159\\"", "size": 466491, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-13T14:21:49.000Z", "contentLength": 466491, "httpStatusCode": 200}	6a2dd1c4-7aa2-4c46-a740-d14eafb6527b	794c5058-c511-4509-ad40-938ce0d45eae	{}
6494fe12-a1e4-492b-9c6c-fdfd547ea72a	entry-photos	voice_13554111-b50c-44ad-af7b-4988c8209afb_1785953996094_7o0lr.webm	13554111-b50c-44ad-af7b-4988c8209afb	2026-08-05 18:19:56.352142+00	2026-08-05 18:19:56.352142+00	2026-08-05 18:19:56.352142+00	{"eTag": "\\"0e7440c2fd57bebfc2f52def6852c1b7\\"", "size": 145196, "mimetype": "audio/webm", "cacheControl": "max-age=3600", "lastModified": "2026-08-05T18:19:57.000Z", "contentLength": 145196, "httpStatusCode": 200}	3660a1bf-adb6-4bc4-b047-3cf364d2c5a8	13554111-b50c-44ad-af7b-4988c8209afb	{}
20e69814-2d5c-4bf5-a490-ebbb16195928	entry-photos	diary_794c5058-c511-4509-ad40-938ce0d45eae_1784002386765_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-14 04:13:06.987597+00	2026-07-14 04:13:06.987597+00	2026-07-14 04:13:06.987597+00	{"eTag": "\\"df8b59de370427b279079370da8a8b29\\"", "size": 574775, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-07-14T04:13:07.000Z", "contentLength": 574775, "httpStatusCode": 200}	14b9afe5-c684-4e38-980e-c772507046cb	794c5058-c511-4509-ad40-938ce0d45eae	{}
99f7993f-b3a1-4b5e-a413-a266f16fce8d	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784627217888_lwu5ba	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 09:46:58.060428+00	2026-07-21 09:46:58.060428+00	2026-07-21 09:46:58.060428+00	{"eTag": "\\"9f789b035a484bf5f53c0ad548b8ae1c\\"", "size": 241349, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T09:46:59.000Z", "contentLength": 241349, "httpStatusCode": 200}	893ec420-5604-4307-a08f-16c17456e52b	794c5058-c511-4509-ad40-938ce0d45eae	{}
33033a37-8906-4a71-b2f6-85d596059fdf	entry-photos	wall_794c5058-c511-4509-ad40-938ce0d45eae_1784021115783_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-14 09:25:16.08136+00	2026-07-14 09:25:16.08136+00	2026-07-14 09:25:16.08136+00	{"eTag": "\\"b4ce5092f14556d39b848d33c7044622\\"", "size": 124720, "mimetype": "image/webp", "cacheControl": "max-age=3600", "lastModified": "2026-07-14T09:25:17.000Z", "contentLength": 124720, "httpStatusCode": 200}	c9dbf01c-71ef-4c47-b1d3-0e4cadc22215	794c5058-c511-4509-ad40-938ce0d45eae	{}
fd8492dc-5ff2-4139-b40d-3c1810d187e9	entry-photos	wall_794c5058-c511-4509-ad40-938ce0d45eae_1784021147663_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-14 09:25:47.930858+00	2026-07-14 09:25:47.930858+00	2026-07-14 09:25:47.930858+00	{"eTag": "\\"d2aa778740c054ad5420041e78d7f3c2\\"", "size": 111205, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-14T09:25:48.000Z", "contentLength": 111205, "httpStatusCode": 200}	130070a2-5420-435a-92ba-1ce385b50f59	794c5058-c511-4509-ad40-938ce0d45eae	{}
8644d487-66bf-4226-a6e3-686ca1409c24	entry-photos	wall_794c5058-c511-4509-ad40-938ce0d45eae_1784021147945_1	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-14 09:25:48.11206+00	2026-07-14 09:25:48.11206+00	2026-07-14 09:25:48.11206+00	{"eTag": "\\"33da80cf7a60eab38322c1d33b3f24ec\\"", "size": 39378, "mimetype": "image/webp", "cacheControl": "max-age=3600", "lastModified": "2026-07-14T09:25:49.000Z", "contentLength": 39378, "httpStatusCode": 200}	831a2339-0c0b-4a5d-902d-59313469ca8b	794c5058-c511-4509-ad40-938ce0d45eae	{}
fb76b087-eb24-4406-8c54-6a60e62a5ab8	avatars	f3224654-1357-4933-a356-d10bf55f7354/avatar	f3224654-1357-4933-a356-d10bf55f7354	2026-07-14 10:27:10.168119+00	2026-07-14 10:27:10.168119+00	2026-07-14 10:27:10.168119+00	{"eTag": "\\"c190a0531bcdf6dbb06ff8aa24ae3f9c\\"", "size": 15477, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-14T10:27:11.000Z", "contentLength": 15477, "httpStatusCode": 200}	8fe23434-0a42-495c-ab1b-96c1e8fb95d4	f3224654-1357-4933-a356-d10bf55f7354	{}
1a49ddfb-7646-4f19-a26c-324cdf6c04d7	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784627218161_uazn75	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 09:46:58.336216+00	2026-07-21 09:46:58.336216+00	2026-07-21 09:46:58.336216+00	{"eTag": "\\"c995550c962c8d00b114c4f64ec4988f\\"", "size": 53561, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T09:46:59.000Z", "contentLength": 53561, "httpStatusCode": 200}	341d37c8-c493-40a6-adc0-6c6b2b31b280	794c5058-c511-4509-ad40-938ce0d45eae	{}
d1d36746-1672-49b6-a4e6-ea24fed2243b	entry-photos	e_1784275600595_0_nm0mol	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-17 08:06:40.655037+00	2026-07-17 08:06:40.655037+00	2026-07-17 08:06:40.655037+00	{"eTag": "\\"3410b48d60112cc4352c923b81e6f203\\"", "size": 263468, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-17T08:06:41.000Z", "contentLength": 263468, "httpStatusCode": 200}	a9e51813-b607-4c1e-9180-796a34ea5753	794c5058-c511-4509-ad40-938ce0d45eae	{}
4bdab8ab-850d-4409-8370-d42ec9b4a378	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784627218454_frls3e	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 09:46:58.608949+00	2026-07-21 09:46:58.608949+00	2026-07-21 09:46:58.608949+00	{"eTag": "\\"d6e6904803573b18ead1b2769b57ea51\\"", "size": 370663, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T09:46:59.000Z", "contentLength": 370663, "httpStatusCode": 200}	ca21372f-cdc5-4df9-8d74-d564cab18ce1	794c5058-c511-4509-ad40-938ce0d45eae	{}
0c92d7fc-dee5-43de-a345-c12be5e2487b	covers	81ade54b-a78a-497b-9181-dc06376c7d9f/cover	81ade54b-a78a-497b-9181-dc06376c7d9f	2026-07-14 18:36:37.679532+00	2026-07-14 18:50:24.118463+00	2026-07-14 18:36:37.679532+00	{"eTag": "\\"1142c411b548e56a9823b3f865cff0dd\\"", "size": 72810, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-14T18:50:25.000Z", "contentLength": 72810, "httpStatusCode": 200}	1562f6a6-89b2-403d-a923-3592f00d0be2	81ade54b-a78a-497b-9181-dc06376c7d9f	{}
a9e16f49-ff07-46b2-b2e4-016b98138e4d	entry-photos	voice_13554111-b50c-44ad-af7b-4988c8209afb_1785955100536_nfh45.webm	13554111-b50c-44ad-af7b-4988c8209afb	2026-08-05 18:38:20.991664+00	2026-08-05 18:38:20.991664+00	2026-08-05 18:38:20.991664+00	{"eTag": "\\"f47f0f6ba8419749537897472d7c1d84\\"", "size": 168380, "mimetype": "audio/webm", "cacheControl": "max-age=3600", "lastModified": "2026-08-05T18:38:21.000Z", "contentLength": 168380, "httpStatusCode": 200}	3660ed42-7e76-4512-8007-bf0f8631b122	13554111-b50c-44ad-af7b-4988c8209afb	{}
fbf34d77-9e16-4d97-8b3d-905465699001	entry-photos	e_1784215980639_0_sxwpo7	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-16 15:33:01.022969+00	2026-07-16 15:33:01.022969+00	2026-07-16 15:33:01.022969+00	{"eTag": "\\"7e144b0ba9ce18bf3e1e86049a7bc37c\\"", "size": 31931, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-16T15:33:01.000Z", "contentLength": 31931, "httpStatusCode": 200}	80aea6d6-2c98-41da-b2d6-cf99a91255cf	794c5058-c511-4509-ad40-938ce0d45eae	{}
209abce5-78f9-4f30-92c8-dcbd8ba4acab	avatars	b9e20678-6e1b-4a4a-9cde-e30e6cfc80eb/avatar	b9e20678-6e1b-4a4a-9cde-e30e6cfc80eb	2026-07-16 17:22:11.032147+00	2026-07-16 17:22:11.032147+00	2026-07-16 17:22:11.032147+00	{"eTag": "\\"4c9a419141d03cbbcee22e7fa029b411\\"", "size": 76022, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-16T17:22:12.000Z", "contentLength": 76022, "httpStatusCode": 200}	d626b4a3-35f9-472a-93ab-62a31bb7cf9c	b9e20678-6e1b-4a4a-9cde-e30e6cfc80eb	{}
6b982ed4-c65c-43e1-81c7-8b4694718f4c	covers	b9e20678-6e1b-4a4a-9cde-e30e6cfc80eb/cover	b9e20678-6e1b-4a4a-9cde-e30e6cfc80eb	2026-07-16 17:25:27.361398+00	2026-07-16 17:25:27.361398+00	2026-07-16 17:25:27.361398+00	{"eTag": "\\"d8b8ce43a319e04fa83dbf067b63397c\\"", "size": 120348, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-16T17:25:28.000Z", "contentLength": 120348, "httpStatusCode": 200}	50d97dd9-abaa-4db2-859c-1a6195f96d30	b9e20678-6e1b-4a4a-9cde-e30e6cfc80eb	{}
60a008bf-7fb0-4ed0-86d0-1fd18f1640bc	entry-photos	e_1784222781354_0_vz03c2	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-16 17:26:21.688095+00	2026-07-16 17:26:21.688095+00	2026-07-16 17:26:21.688095+00	{"eTag": "\\"8e9eeab3f3d7d3e64cc2256b1dd66b6d\\"", "size": 762947, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-16T17:26:22.000Z", "contentLength": 762947, "httpStatusCode": 200}	9f8c9ae7-2171-4369-9078-07926e57dfcf	794c5058-c511-4509-ad40-938ce0d45eae	{}
04c43623-bb29-4bd9-b6c3-7cc7566bd99a	event-photos	cover_f16fa9eb-7ebb-4538-8942-d1e5f216f2f6_1784230764757	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-16 19:39:25.350359+00	2026-07-16 19:39:25.350359+00	2026-07-16 19:39:25.350359+00	{"eTag": "\\"970226a3dc0079191ccda288e589f1eb\\"", "size": 29931, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-16T19:39:26.000Z", "contentLength": 29931, "httpStatusCode": 200}	098771b2-4203-4ed7-852f-a0913f703206	794c5058-c511-4509-ad40-938ce0d45eae	{}
0f1139a6-6b6c-4d8b-8366-95453fe4e6f1	event-photos	cover_f16fa9eb-7ebb-4538-8942-d1e5f216f2f6_1784230778300	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-16 19:39:38.468382+00	2026-07-16 19:39:38.468382+00	2026-07-16 19:39:38.468382+00	{"eTag": "\\"970226a3dc0079191ccda288e589f1eb\\"", "size": 29931, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-16T19:39:39.000Z", "contentLength": 29931, "httpStatusCode": 200}	8fedccb2-80a1-4d00-bd41-5a681af6b575	794c5058-c511-4509-ad40-938ce0d45eae	{}
1f7dc22e-6c80-4f4c-93bb-e3d2e305a616	event-photos	cover_f16fa9eb-7ebb-4538-8942-d1e5f216f2f6_1784337793494	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-18 01:23:13.930107+00	2026-07-18 01:23:13.930107+00	2026-07-18 01:23:13.930107+00	{"eTag": "\\"931ed03e6af53fd2b12bd8e9c9b5e31a\\"", "size": 167693, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-18T01:23:14.000Z", "contentLength": 167693, "httpStatusCode": 200}	eb3cb5f0-0e7f-40b3-addd-8d7fcef6b44d	794c5058-c511-4509-ad40-938ce0d45eae	{}
717b1380-aa09-4895-8817-74d8d88031ee	event-photos	cover_f16fa9eb-7ebb-4538-8942-d1e5f216f2f6_1784337818060	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-18 01:23:38.267529+00	2026-07-18 01:23:38.267529+00	2026-07-18 01:23:38.267529+00	{"eTag": "\\"931ed03e6af53fd2b12bd8e9c9b5e31a\\"", "size": 167693, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-18T01:23:39.000Z", "contentLength": 167693, "httpStatusCode": 200}	84568dab-8990-4ac9-8d88-6603a64dd228	794c5058-c511-4509-ad40-938ce0d45eae	{}
2b2696f7-dc1a-4b19-8fff-e82b841e952f	event-photos	cover_4df2669c-3a95-4efd-856d-ffe272eabb58_1784355441873	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-18 06:17:22.210216+00	2026-07-18 06:17:22.210216+00	2026-07-18 06:17:22.210216+00	{"eTag": "\\"970226a3dc0079191ccda288e589f1eb\\"", "size": 29931, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-18T06:17:23.000Z", "contentLength": 29931, "httpStatusCode": 200}	035a69dd-f700-434f-b896-8a171ca67090	794c5058-c511-4509-ad40-938ce0d45eae	{}
17a1f1b5-5e00-4c44-96f4-6ef999c878f4	event-photos	cover_4df2669c-3a95-4efd-856d-ffe272eabb58_1784355519231	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-18 06:18:39.851157+00	2026-07-18 06:18:39.851157+00	2026-07-18 06:18:39.851157+00	{"eTag": "\\"8e9eeab3f3d7d3e64cc2256b1dd66b6d\\"", "size": 762947, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-18T06:18:40.000Z", "contentLength": 762947, "httpStatusCode": 200}	1fb9fcf4-6ba6-4378-a6ef-73cba9730515	794c5058-c511-4509-ad40-938ce0d45eae	{}
2eb019cb-c1bd-4628-b44a-adc1fc2c8ee2	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784627218709_dsa20a	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 09:46:58.871086+00	2026-07-21 09:46:58.871086+00	2026-07-21 09:46:58.871086+00	{"eTag": "\\"12682c6eeb4c42ac9a211e48d903b19e\\"", "size": 349523, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T09:46:59.000Z", "contentLength": 349523, "httpStatusCode": 200}	3f1bc81b-58db-41d8-9ee2-ea86817384d6	794c5058-c511-4509-ad40-938ce0d45eae	{}
9bb0b57b-7247-4739-b989-0de85838b065	avatars	674599f7-e03b-4c53-8d8f-4d3bbc50bf64/avatar	674599f7-e03b-4c53-8d8f-4d3bbc50bf64	2026-07-18 06:59:39.185478+00	2026-07-18 06:59:39.185478+00	2026-07-18 06:59:39.185478+00	{"eTag": "\\"e465c8145f1e64399ce7c50674ac9f7a\\"", "size": 83394, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-18T06:59:40.000Z", "contentLength": 83394, "httpStatusCode": 200}	8be76b8a-fbca-43b8-aed4-d6ea6292a778	674599f7-e03b-4c53-8d8f-4d3bbc50bf64	{}
9c69b24e-c126-440d-b9ac-ce769232f28a	covers	674599f7-e03b-4c53-8d8f-4d3bbc50bf64/cover	674599f7-e03b-4c53-8d8f-4d3bbc50bf64	2026-07-18 06:59:39.538324+00	2026-07-18 06:59:39.538324+00	2026-07-18 06:59:39.538324+00	{"eTag": "\\"1bf00ede542183e11061c568f7027840\\"", "size": 102819, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-18T06:59:40.000Z", "contentLength": 102819, "httpStatusCode": 200}	01732057-4f2d-4403-bd3d-bad6af68de51	674599f7-e03b-4c53-8d8f-4d3bbc50bf64	{}
bf80cb30-3849-441f-b316-48ab33d9ba4e	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784627218972_035c1u	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 09:46:59.103381+00	2026-07-21 09:46:59.103381+00	2026-07-21 09:46:59.103381+00	{"eTag": "\\"3fc629233158ffc62fc10afaca851b60\\"", "size": 146702, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T09:47:00.000Z", "contentLength": 146702, "httpStatusCode": 200}	f96b1cb9-cd1c-4a6a-b445-bd3b1d9878cf	794c5058-c511-4509-ad40-938ce0d45eae	{}
439a7384-9e9d-4220-be36-693480f119d3	event-photos	cover_4df2669c-3a95-4efd-856d-ffe272eabb58_1784360959255	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-18 07:49:19.595474+00	2026-07-18 07:49:19.595474+00	2026-07-18 07:49:19.595474+00	{"eTag": "\\"8e9eeab3f3d7d3e64cc2256b1dd66b6d\\"", "size": 762947, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-18T07:49:20.000Z", "contentLength": 762947, "httpStatusCode": 200}	1857c404-5842-44c5-b286-982ce32a7bc9	794c5058-c511-4509-ad40-938ce0d45eae	{}
c4834c07-291c-4566-a68e-7d0febea1674	event-photos	cover_4df2669c-3a95-4efd-856d-ffe272eabb58_1784361538557	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-18 07:58:59.016388+00	2026-07-18 07:58:59.016388+00	2026-07-18 07:58:59.016388+00	{"eTag": "\\"8e9eeab3f3d7d3e64cc2256b1dd66b6d\\"", "size": 762947, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-18T07:58:59.000Z", "contentLength": 762947, "httpStatusCode": 200}	cfabc8ca-4114-4ad7-9769-8751689c29c2	794c5058-c511-4509-ad40-938ce0d45eae	{}
15f6f758-4cf7-43e0-a330-5426768bc060	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784627219213_pahw8q	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 09:46:59.353836+00	2026-07-21 09:46:59.353836+00	2026-07-21 09:46:59.353836+00	{"eTag": "\\"61fe61cfc563ed940fb4d5fd75f15c71\\"", "size": 99091, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T09:47:00.000Z", "contentLength": 99091, "httpStatusCode": 200}	dca78bd6-9bb5-45a6-b2bb-9b01a68da662	794c5058-c511-4509-ad40-938ce0d45eae	{}
e644af8c-9665-4ac4-bc41-3c3951fe79e6	event-photos	cover_4df2669c-3a95-4efd-856d-ffe272eabb58_1784361552535	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-18 07:59:12.836697+00	2026-07-18 07:59:12.836697+00	2026-07-18 07:59:12.836697+00	{"eTag": "\\"8e9eeab3f3d7d3e64cc2256b1dd66b6d\\"", "size": 762947, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-18T07:59:13.000Z", "contentLength": 762947, "httpStatusCode": 200}	3873225a-ba60-4c5c-b1f8-553f63a6a881	794c5058-c511-4509-ad40-938ce0d45eae	{}
f0ffa4d8-dc9c-4fa5-a7dc-6834b3ca6835	entry-photos	life/51323e47-38a0-405d-b597-a56cc534ba12/2005-1786388236139-zqh7	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-10 18:57:16.459537+00	2026-08-10 18:57:16.459537+00	2026-08-10 18:57:16.459537+00	{"eTag": "\\"00feb4f1882f778dfbab809a662627ec\\"", "size": 96996, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-08-10T18:57:17.000Z", "contentLength": 96996, "httpStatusCode": 200}	0d7628c2-aefa-49f8-9cbf-c117f82c2e8f	794c5058-c511-4509-ad40-938ce0d45eae	{}
7e581af9-d25b-411e-8c52-99d9b54f1d56	event-photos	cover_4df2669c-3a95-4efd-856d-ffe272eabb58_1784368006499	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-18 09:46:46.819456+00	2026-07-18 09:46:46.819456+00	2026-07-18 09:46:46.819456+00	{"eTag": "\\"1225851c3447bc982ed2e84ec51bd5bc\\"", "size": 504605, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-18T09:46:47.000Z", "contentLength": 504605, "httpStatusCode": 200}	cc302ddc-f564-4e86-a519-3765247f52d5	794c5058-c511-4509-ad40-938ce0d45eae	{}
cce75967-8e2c-42a5-85a3-d5834985c0eb	event-photos	cover_4df2669c-3a95-4efd-856d-ffe272eabb58_1784377078244	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-18 12:17:58.696498+00	2026-07-18 12:17:58.696498+00	2026-07-18 12:17:58.696498+00	{"eTag": "\\"1225851c3447bc982ed2e84ec51bd5bc\\"", "size": 504605, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-18T12:17:59.000Z", "contentLength": 504605, "httpStatusCode": 200}	9f514395-2b07-4882-935f-1f8d4a7a2342	794c5058-c511-4509-ad40-938ce0d45eae	{}
c2a15f27-b642-48e9-a428-f202c9dbbc49	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784618875934_d17057	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 07:27:55.651085+00	2026-07-21 07:27:55.651085+00	2026-07-21 07:27:55.651085+00	{"eTag": "\\"a72928a94da02a3e84e2c0dd20a3abc0\\"", "size": 26940, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T07:27:56.000Z", "contentLength": 26940, "httpStatusCode": 200}	5d1c98c6-2232-440c-afb4-3e90470bc79b	794c5058-c511-4509-ad40-938ce0d45eae	{}
e54298a5-1b89-4845-975a-c16f7fa55434	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784619058125_x3nvtn	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 07:30:57.731364+00	2026-07-21 07:30:57.731364+00	2026-07-21 07:30:57.731364+00	{"eTag": "\\"a72928a94da02a3e84e2c0dd20a3abc0\\"", "size": 26940, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T07:30:58.000Z", "contentLength": 26940, "httpStatusCode": 200}	899e5ad8-0db5-4731-b3b4-72b7765c3a57	794c5058-c511-4509-ad40-938ce0d45eae	{}
fc6a83cf-d73f-483a-9b78-132fa1c32bb3	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784619596270_h4aisr	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 07:39:55.930711+00	2026-07-21 07:39:55.930711+00	2026-07-21 07:39:55.930711+00	{"eTag": "\\"78c7e5a6e77ed25092d5956b66ef496d\\"", "size": 154358, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T07:39:56.000Z", "contentLength": 154358, "httpStatusCode": 200}	b19c416a-8a58-41a2-99b2-051ff2285dfb	794c5058-c511-4509-ad40-938ce0d45eae	{}
a983b020-b0a6-4e5b-b846-0d47d11af56d	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784627687428_br3npb	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 09:54:47.872479+00	2026-07-21 09:54:47.872479+00	2026-07-21 09:54:47.872479+00	{"eTag": "\\"a900a7e1957cc6f855ba204797694b8c\\"", "size": 139843, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T09:54:48.000Z", "contentLength": 139843, "httpStatusCode": 200}	8af34d4c-8ad7-4f82-ac1a-4c0d3990c583	794c5058-c511-4509-ad40-938ce0d45eae	{}
2f2f659d-3193-4b4b-8213-547b5b2c8087	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784619852998_f65ork	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 07:44:12.823061+00	2026-07-21 07:44:12.823061+00	2026-07-21 07:44:12.823061+00	{"eTag": "\\"78c7e5a6e77ed25092d5956b66ef496d\\"", "size": 154358, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T07:44:13.000Z", "contentLength": 154358, "httpStatusCode": 200}	95c00b46-ac97-4fc9-befa-73f5bc24b4c4	794c5058-c511-4509-ad40-938ce0d45eae	{}
4806201a-98e5-42dd-80e4-5f5d5056f256	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784627706979_coewgx	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 09:55:07.357541+00	2026-07-21 09:55:07.357541+00	2026-07-21 09:55:07.357541+00	{"eTag": "\\"1f49eae06644aea1390b511069c9b794\\"", "size": 225321, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T09:55:08.000Z", "contentLength": 225321, "httpStatusCode": 200}	f722d63d-8bae-4ccd-8cac-8d05e6b4418a	794c5058-c511-4509-ad40-938ce0d45eae	{}
80af24ca-90b6-450c-81af-8fa04ac90040	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784627170009_11qyww	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 09:46:10.384614+00	2026-07-21 09:46:10.384614+00	2026-07-21 09:46:10.384614+00	{"eTag": "\\"a900a7e1957cc6f855ba204797694b8c\\"", "size": 139843, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T09:46:11.000Z", "contentLength": 139843, "httpStatusCode": 200}	42b6f7f4-ecfa-4b7a-a4e0-935b4809e454	794c5058-c511-4509-ad40-938ce0d45eae	{}
c9163375-13d3-4a90-9723-d20d67e08cc2	entry-photos	diary_794c5058-c511-4509-ad40-938ce0d45eae_1784897231650_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-24 12:47:12.208019+00	2026-07-24 12:47:12.208019+00	2026-07-24 12:47:12.208019+00	{"eTag": "\\"8e9eeab3f3d7d3e64cc2256b1dd66b6d\\"", "size": 762947, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-24T12:47:13.000Z", "contentLength": 762947, "httpStatusCode": 200}	89e8b9f6-53b9-4d95-9183-46f6a862305d	794c5058-c511-4509-ad40-938ce0d45eae	{}
e1efe89a-a8a3-435e-88da-9d5bf7d41b60	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784627170500_hihpo3	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 09:46:10.646603+00	2026-07-21 09:46:10.646603+00	2026-07-21 09:46:10.646603+00	{"eTag": "\\"78c7e5a6e77ed25092d5956b66ef496d\\"", "size": 154358, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T09:46:11.000Z", "contentLength": 154358, "httpStatusCode": 200}	d31f3b9f-6d5b-46cb-9629-76829cb91811	794c5058-c511-4509-ad40-938ce0d45eae	{}
4e09bc21-8f65-4648-95c9-1ef1de667d13	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784627171723_sexxfa	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 09:46:12.003069+00	2026-07-21 09:46:12.003069+00	2026-07-21 09:46:12.003069+00	{"eTag": "\\"1f49eae06644aea1390b511069c9b794\\"", "size": 225321, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T09:46:12.000Z", "contentLength": 225321, "httpStatusCode": 200}	91ddc86d-0309-4cb5-b909-0161b60eb517	794c5058-c511-4509-ad40-938ce0d45eae	{}
dc13992c-72d3-458e-800d-c04e038c3c08	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784627172688_hdz8i7	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 09:46:12.865941+00	2026-07-21 09:46:12.865941+00	2026-07-21 09:46:12.865941+00	{"eTag": "\\"1f49eae06644aea1390b511069c9b794\\"", "size": 225321, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T09:46:13.000Z", "contentLength": 225321, "httpStatusCode": 200}	0e91f29a-3875-493e-8d79-5a3b016da47a	794c5058-c511-4509-ad40-938ce0d45eae	{}
20517197-217c-4a50-a070-3439db1c4383	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784627193386_zwon6x	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 09:46:33.618044+00	2026-07-21 09:46:33.618044+00	2026-07-21 09:46:33.618044+00	{"eTag": "\\"a900a7e1957cc6f855ba204797694b8c\\"", "size": 139843, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T09:46:34.000Z", "contentLength": 139843, "httpStatusCode": 200}	9bd0349c-b167-4a59-8517-189677a948eb	794c5058-c511-4509-ad40-938ce0d45eae	{}
66b300b2-c0e7-4cb3-a4de-3bdde2c140f1	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1784627193817_1siq0v	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-21 09:46:33.995053+00	2026-07-21 09:46:33.995053+00	2026-07-21 09:46:33.995053+00	{"eTag": "\\"78c7e5a6e77ed25092d5956b66ef496d\\"", "size": 154358, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-21T09:46:34.000Z", "contentLength": 154358, "httpStatusCode": 200}	74b3e848-40ab-4ef0-a8b5-a0f4d2215ab2	794c5058-c511-4509-ad40-938ce0d45eae	{}
16879d14-f0db-4556-b961-db26421313a1	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1785253622101_enymnm	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-28 15:47:02.651016+00	2026-07-28 15:47:02.651016+00	2026-07-28 15:47:02.651016+00	{"eTag": "\\"8e9eeab3f3d7d3e64cc2256b1dd66b6d\\"", "size": 762947, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-28T15:47:03.000Z", "contentLength": 762947, "httpStatusCode": 200}	daf1e2b8-960c-455a-871c-54d04387190d	794c5058-c511-4509-ad40-938ce0d45eae	{}
cbc7e310-a23e-406f-a388-4cca8c88592f	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1785253659288_7br7fs	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-28 15:47:39.465165+00	2026-07-28 15:47:39.465165+00	2026-07-28 15:47:39.465165+00	{"eTag": "\\"970226a3dc0079191ccda288e589f1eb\\"", "size": 29931, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-28T15:47:40.000Z", "contentLength": 29931, "httpStatusCode": 200}	7ad2bb8e-13b6-402a-835b-2315f06c7991	794c5058-c511-4509-ad40-938ce0d45eae	{}
9074b734-c0e1-455f-be67-8c60b128bbcf	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1785253702440_5oqig7	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-28 15:48:22.584046+00	2026-07-28 15:48:22.584046+00	2026-07-28 15:48:22.584046+00	{"eTag": "\\"c61792c75c438b77dd98b623553875be\\"", "size": 57246, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-28T15:48:23.000Z", "contentLength": 57246, "httpStatusCode": 200}	1ac8e192-5c79-4e4b-8cfd-bc10893d0ff1	794c5058-c511-4509-ad40-938ce0d45eae	{}
35eca1f9-3ccc-44b4-bbcc-efb45f763a7c	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1785253729322_5rdsjv	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-28 15:48:49.678221+00	2026-07-28 15:48:49.678221+00	2026-07-28 15:48:49.678221+00	{"eTag": "\\"8e9eeab3f3d7d3e64cc2256b1dd66b6d\\"", "size": 762947, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-28T15:48:50.000Z", "contentLength": 762947, "httpStatusCode": 200}	8e7b6d4f-5dbb-4813-988f-8176732e0a8e	794c5058-c511-4509-ad40-938ce0d45eae	{}
ef9ea624-66e7-4ce8-87f1-664a471c86a0	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1785302179410_iq71p7	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 05:16:19.983058+00	2026-07-29 05:16:19.983058+00	2026-07-29 05:16:19.983058+00	{"eTag": "\\"8e9eeab3f3d7d3e64cc2256b1dd66b6d\\"", "size": 762947, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T05:16:20.000Z", "contentLength": 762947, "httpStatusCode": 200}	3f9b1321-12d7-451a-8a04-2242d0b88204	794c5058-c511-4509-ad40-938ce0d45eae	{}
abc35e37-4aea-41cc-bce8-908a641aad15	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1785302592878_qewnqx	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 05:23:13.606352+00	2026-07-29 05:23:13.606352+00	2026-07-29 05:23:13.606352+00	{"eTag": "\\"5e43c7484ae4f31edb9e93e4fc53606e\\"", "size": 415182, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T05:23:14.000Z", "contentLength": 415182, "httpStatusCode": 200}	b0f2bc8a-d0bf-41ac-bdaa-aa7a4ff83f1a	794c5058-c511-4509-ad40-938ce0d45eae	{}
66b97ede-ffc0-4b8b-ba88-9029a28610cb	event-share	deploy/border-1786036361492.html.txt	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-06 17:12:42.13473+00	2026-08-06 17:12:42.13473+00	2026-08-06 17:12:42.13473+00	{"eTag": "\\"fdde349ac9cba5c19930a0d7a6f8266f\\"", "size": 1261130, "mimetype": "text/plain", "cacheControl": "max-age=3600", "lastModified": "2026-08-06T17:12:43.000Z", "contentLength": 1261130, "httpStatusCode": 200}	51d9b051-7b32-4e05-88a5-a64c4cd57419	794c5058-c511-4509-ad40-938ce0d45eae	{}
765bfce6-f37f-40df-af58-f25ff5a73185	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1785302613319_jruoli	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 05:23:33.705955+00	2026-07-29 05:23:33.705955+00	2026-07-29 05:23:33.705955+00	{"eTag": "\\"5e43c7484ae4f31edb9e93e4fc53606e\\"", "size": 415182, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T05:23:34.000Z", "contentLength": 415182, "httpStatusCode": 200}	3ecd6cc8-6599-45ad-b438-a99cf662ac6c	794c5058-c511-4509-ad40-938ce0d45eae	{}
b5181c07-ef45-49c8-9d52-9d4dfc9ac2cb	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1785304562919_p36pru	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 05:56:03.194394+00	2026-07-29 05:56:03.194394+00	2026-07-29 05:56:03.194394+00	{"eTag": "\\"03266893ca8e1433287543cc60bedbf7\\"", "size": 4679, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T05:56:04.000Z", "contentLength": 4679, "httpStatusCode": 200}	76ad7081-ba4c-415b-a1b5-a62ba2ad5519	794c5058-c511-4509-ad40-938ce0d45eae	{}
622bb85b-91bf-49ea-9e23-98fadd191fe6	entry-photos	voice_794c5058-c511-4509-ad40-938ce0d45eae_1785308946163_2skxg.webm	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 07:09:07.010905+00	2026-07-29 07:09:07.010905+00	2026-07-29 07:09:07.010905+00	{"eTag": "\\"3b41ab83f2cb98eb7c000a66ada8b2b1\\"", "size": 84454, "mimetype": "audio/webm", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T07:09:07.000Z", "contentLength": 84454, "httpStatusCode": 200}	24e02ea1-a30b-4fbc-82f8-cd9eb08bcc6e	794c5058-c511-4509-ad40-938ce0d45eae	{}
59339ebf-6671-462f-a34c-c9b394267d11	entry-photos	voice_794c5058-c511-4509-ad40-938ce0d45eae_1785308958758_2nbm8.webm	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 07:09:23.175534+00	2026-07-29 07:09:23.175534+00	2026-07-29 07:09:23.175534+00	{"eTag": "\\"864af0dfbd1f56419e2d2cabb1be3a2c\\"", "size": 48054, "mimetype": "audio/webm", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T07:09:24.000Z", "contentLength": 48054, "httpStatusCode": 200}	1370966a-48c3-4c3b-8094-03d5c8b5b088	794c5058-c511-4509-ad40-938ce0d45eae	{}
d69a50a5-b718-4129-99e3-8498948eb7a3	event-photos	cover_9dafdb62-fecd-4de3-b61b-418b48664ae1_1785309704203	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 07:21:44.886709+00	2026-07-29 07:21:44.886709+00	2026-07-29 07:21:44.886709+00	{"eTag": "\\"8e9eeab3f3d7d3e64cc2256b1dd66b6d\\"", "size": 762947, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T07:21:45.000Z", "contentLength": 762947, "httpStatusCode": 200}	a3df8020-ed5e-4576-8eed-4b5640b8cf34	794c5058-c511-4509-ad40-938ce0d45eae	{}
2160a1c3-e465-45b4-9a38-19b2a6ed39b9	event-photos	ev_4df2669c-3a95-4efd-856d-ffe272eabb58_1785333726121_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 14:02:06.508778+00	2026-07-29 14:02:06.508778+00	2026-07-29 14:02:06.508778+00	{"eTag": "\\"5e43c7484ae4f31edb9e93e4fc53606e\\"", "size": 415182, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T14:02:07.000Z", "contentLength": 415182, "httpStatusCode": 200}	abd987c8-a5a8-48fc-bd14-6243eaf3e525	794c5058-c511-4509-ad40-938ce0d45eae	{}
15a15f8b-4ee9-475e-b4cc-b1e7c99ae50a	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1785335146626_9l011t	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 14:25:47.18599+00	2026-07-29 14:25:47.18599+00	2026-07-29 14:25:47.18599+00	{"eTag": "\\"572c7c5b151ad788d04353f8c81f92a3\\"", "size": 212257, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T14:25:48.000Z", "contentLength": 212257, "httpStatusCode": 200}	2996ba12-6891-4cf1-80cd-774e76508832	794c5058-c511-4509-ad40-938ce0d45eae	{}
85904a98-82b7-40b0-9d91-d4882f64d362	entry-photos	voice_13554111-b50c-44ad-af7b-4988c8209afb_1785336393623_e3wiu.webm	13554111-b50c-44ad-af7b-4988c8209afb	2026-07-29 14:46:34.086623+00	2026-07-29 14:46:34.086623+00	2026-07-29 14:46:34.086623+00	{"eTag": "\\"16784a6edfd4f90b730751b0429173cc\\"", "size": 149353, "mimetype": "audio/webm", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T14:46:35.000Z", "contentLength": 149353, "httpStatusCode": 200}	3bf9eed7-f62a-499d-9511-5e9acb23cb5b	13554111-b50c-44ad-af7b-4988c8209afb	{}
7738e4d1-35a0-4d32-b7db-3daf49ddcf2c	entry-photos	life/51323e47-38a0-405d-b597-a56cc534ba12/2025-1786374892803	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-10 15:14:53.307369+00	2026-08-10 15:14:53.307369+00	2026-08-10 15:14:53.307369+00	{"eTag": "\\"2faad63b172f5ed6c4e7e68f4f9d3778\\"", "size": 178617, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-08-10T15:14:54.000Z", "contentLength": 178617, "httpStatusCode": 200}	1ae913ad-09e2-4612-a79b-a2560d6d02b9	794c5058-c511-4509-ad40-938ce0d45eae	{}
f9c3dd04-7da0-441c-8ffe-2164e2287a69	entry-photos	msg_794c5058-c511-4509-ad40-938ce0d45eae_1785345438154_ds1aa7	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 17:17:18.600441+00	2026-07-29 17:17:18.600441+00	2026-07-29 17:17:18.600441+00	{"eTag": "\\"5e43c7484ae4f31edb9e93e4fc53606e\\"", "size": 415182, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T17:17:19.000Z", "contentLength": 415182, "httpStatusCode": 200}	84661c2b-ac5c-45ee-9f30-6e4846bfb7b6	794c5058-c511-4509-ad40-938ce0d45eae	{}
20198350-f84b-4398-b7c1-7f7cdac8b72b	entry-photos	msg_794c5058-c511-4509-ad40-938ce0d45eae_1785345447992_89xps0	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 17:17:28.21981+00	2026-07-29 17:17:28.21981+00	2026-07-29 17:17:28.21981+00	{"eTag": "\\"5e43c7484ae4f31edb9e93e4fc53606e\\"", "size": 415182, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T17:17:29.000Z", "contentLength": 415182, "httpStatusCode": 200}	32b4db25-3205-44c8-81f2-ba7c7404cf4d	794c5058-c511-4509-ad40-938ce0d45eae	{}
9446fac1-1db5-46fa-8c3f-6a53bc1581df	entry-photos	life/51323e47-38a0-405d-b597-a56cc534ba12/2009-1786374922485	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-10 15:15:22.797551+00	2026-08-10 15:15:22.797551+00	2026-08-10 15:15:22.797551+00	{"eTag": "\\"9d83f993780fd8122d94e8e9800b94e9\\"", "size": 577210, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-08-10T15:15:23.000Z", "contentLength": 577210, "httpStatusCode": 200}	0a84a298-ac44-4bd4-b18e-743375d9a236	794c5058-c511-4509-ad40-938ce0d45eae	{}
b303ac3e-bf59-4a98-b1a2-5f51104753a5	entry-photos	msg_794c5058-c511-4509-ad40-938ce0d45eae_1785345473485_qp10lu	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 17:17:53.769463+00	2026-07-29 17:17:53.769463+00	2026-07-29 17:17:53.769463+00	{"eTag": "\\"5e43c7484ae4f31edb9e93e4fc53606e\\"", "size": 415182, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T17:17:54.000Z", "contentLength": 415182, "httpStatusCode": 200}	f57102e1-e9f3-49c5-9ffa-8624897c3294	794c5058-c511-4509-ad40-938ce0d45eae	{}
aa074bff-aba9-4edb-9f44-7b7e6bb36916	entry-photos	msg_794c5058-c511-4509-ad40-938ce0d45eae_1785345696990_rqtmzd	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 17:21:37.435639+00	2026-07-29 17:21:37.435639+00	2026-07-29 17:21:37.435639+00	{"eTag": "\\"5e43c7484ae4f31edb9e93e4fc53606e\\"", "size": 415182, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T17:21:38.000Z", "contentLength": 415182, "httpStatusCode": 200}	c3984f99-2a5f-41f8-866b-b98a9f931d9c	794c5058-c511-4509-ad40-938ce0d45eae	{}
294b410f-35b4-4108-8643-6b7012e519c6	entry-photos	msg_794c5058-c511-4509-ad40-938ce0d45eae_1785345708106_yf0lhc	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 17:21:48.31965+00	2026-07-29 17:21:48.31965+00	2026-07-29 17:21:48.31965+00	{"eTag": "\\"5e43c7484ae4f31edb9e93e4fc53606e\\"", "size": 415182, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T17:21:49.000Z", "contentLength": 415182, "httpStatusCode": 200}	d35dbd4c-cc4f-48c7-9bf5-4c513a22baf5	794c5058-c511-4509-ad40-938ce0d45eae	{}
960c0fd3-3ed5-448b-9dbc-00332e4d9593	entry-photos	msg_794c5058-c511-4509-ad40-938ce0d45eae_1785346000341_j2iuni	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 17:26:40.718723+00	2026-07-29 17:26:40.718723+00	2026-07-29 17:26:40.718723+00	{"eTag": "\\"5e43c7484ae4f31edb9e93e4fc53606e\\"", "size": 415182, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T17:26:41.000Z", "contentLength": 415182, "httpStatusCode": 200}	adf8c2aa-3753-403c-88ba-1a864fd75177	794c5058-c511-4509-ad40-938ce0d45eae	{}
8c42ce03-45b1-4477-8e19-679fcd2d45df	entry-photos	msg_794c5058-c511-4509-ad40-938ce0d45eae_1785346010970_0xaiim	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 17:26:51.187729+00	2026-07-29 17:26:51.187729+00	2026-07-29 17:26:51.187729+00	{"eTag": "\\"5e43c7484ae4f31edb9e93e4fc53606e\\"", "size": 415182, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T17:26:52.000Z", "contentLength": 415182, "httpStatusCode": 200}	2a764f01-68f7-478b-b686-f1bea27cbdf0	794c5058-c511-4509-ad40-938ce0d45eae	{}
e3c30e9e-264e-41d6-9611-7f4c936379d6	entry-photos	msg_794c5058-c511-4509-ad40-938ce0d45eae_1785346050686_r38nmu	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 17:27:31.050047+00	2026-07-29 17:27:31.050047+00	2026-07-29 17:27:31.050047+00	{"eTag": "\\"5e43c7484ae4f31edb9e93e4fc53606e\\"", "size": 415182, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T17:27:32.000Z", "contentLength": 415182, "httpStatusCode": 200}	5e7c3de5-397d-4a52-b0dc-17e1dfa2b177	794c5058-c511-4509-ad40-938ce0d45eae	{}
cf181a0e-234d-4cf6-bbce-52804ea15efc	entry-photos	msg_794c5058-c511-4509-ad40-938ce0d45eae_1785346059474_yxwyou	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 17:27:39.680112+00	2026-07-29 17:27:39.680112+00	2026-07-29 17:27:39.680112+00	{"eTag": "\\"5e43c7484ae4f31edb9e93e4fc53606e\\"", "size": 415182, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T17:27:40.000Z", "contentLength": 415182, "httpStatusCode": 200}	27b9d1ad-315e-4c32-8b9c-2488699e1eca	794c5058-c511-4509-ad40-938ce0d45eae	{}
9a5893f6-159b-40a3-9588-82a5b2b0aa9a	entry-photos	life/51323e47-38a0-405d-b597-a56cc534ba12/2023-1786374908443	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-10 15:15:08.755041+00	2026-08-10 15:15:08.755041+00	2026-08-10 15:15:08.755041+00	{"eTag": "\\"d152f407c676f380edaa5c7a60cae628\\"", "size": 151292, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-08-10T15:15:09.000Z", "contentLength": 151292, "httpStatusCode": 200}	8fee9080-e2bf-4b83-8e2c-092f984a8dc4	794c5058-c511-4509-ad40-938ce0d45eae	{}
312c3967-caf0-46a7-8b4e-2b384b5ed1bb	entry-photos	msg_794c5058-c511-4509-ad40-938ce0d45eae_1785346076287_qwpabf	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 17:27:56.747692+00	2026-07-29 17:27:56.747692+00	2026-07-29 17:27:56.747692+00	{"eTag": "\\"5e43c7484ae4f31edb9e93e4fc53606e\\"", "size": 415182, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T17:27:57.000Z", "contentLength": 415182, "httpStatusCode": 200}	e2d73256-0796-4103-b917-0bd7fbda1b2a	794c5058-c511-4509-ad40-938ce0d45eae	{}
21c1087c-1aa4-4e26-919f-99d276e4324f	entry-photos	msg_794c5058-c511-4509-ad40-938ce0d45eae_1785346087648_fqshxr	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 17:28:07.85627+00	2026-07-29 17:28:07.85627+00	2026-07-29 17:28:07.85627+00	{"eTag": "\\"5e43c7484ae4f31edb9e93e4fc53606e\\"", "size": 415182, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T17:28:08.000Z", "contentLength": 415182, "httpStatusCode": 200}	e948cfce-9bdf-4594-9a6c-65dbba295394	794c5058-c511-4509-ad40-938ce0d45eae	{}
3ca2cca8-d48e-474f-954f-6dfac41f4aa5	entry-photos	msg_794c5058-c511-4509-ad40-938ce0d45eae_1785346153901_tcvprx	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 17:29:14.231264+00	2026-07-29 17:29:14.231264+00	2026-07-29 17:29:14.231264+00	{"eTag": "\\"5e43c7484ae4f31edb9e93e4fc53606e\\"", "size": 415182, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T17:29:15.000Z", "contentLength": 415182, "httpStatusCode": 200}	1d472c59-b44e-4585-85ba-19901d9d922e	794c5058-c511-4509-ad40-938ce0d45eae	{}
df42a713-2b6e-4d8e-9d28-d08a407fc7b5	entry-photos	msg_794c5058-c511-4509-ad40-938ce0d45eae_1785346166253_t9wdwl	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-29 17:29:26.666705+00	2026-07-29 17:29:26.666705+00	2026-07-29 17:29:26.666705+00	{"eTag": "\\"5e43c7484ae4f31edb9e93e4fc53606e\\"", "size": 415182, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-29T17:29:27.000Z", "contentLength": 415182, "httpStatusCode": 200}	2c2632b2-0d16-481a-b95c-c1c07ce5847a	794c5058-c511-4509-ad40-938ce0d45eae	{}
b15d8267-d7d7-4edf-bd5f-db2017247b07	entry-photos	circle_794c5058-c511-4509-ad40-938ce0d45eae_1785386106439_w69um0	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-30 04:35:10.500054+00	2026-07-30 04:35:10.500054+00	2026-07-30 04:35:10.500054+00	{"eTag": "\\"66a8c3e6edb074d0b38bb216e2846568\\"", "size": 42374, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-30T04:35:11.000Z", "contentLength": 42374, "httpStatusCode": 200}	3828a6ad-9d09-40bd-892d-7b17af712e5e	794c5058-c511-4509-ad40-938ce0d45eae	{}
29035730-fcd0-4116-b271-9cda6907b3a9	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1785425611980_p29afx	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-30 15:33:32.451479+00	2026-07-30 15:33:32.451479+00	2026-07-30 15:33:32.451479+00	{"eTag": "\\"b3f90d3517e316675466c993f9fa4fcf\\"", "size": 86131, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-30T15:33:33.000Z", "contentLength": 86131, "httpStatusCode": 200}	d7980cdc-76c5-4cf5-b245-36282f434ae1	794c5058-c511-4509-ad40-938ce0d45eae	{}
524b0c06-59d1-433d-8e83-f425a83b8ba3	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1785425644793_0uunuz	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-30 15:34:04.99246+00	2026-07-30 15:34:04.99246+00	2026-07-30 15:34:04.99246+00	{"eTag": "\\"c14ad5f02ff21ab36801417a07a2f65a\\"", "size": 99507, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-30T15:34:05.000Z", "contentLength": 99507, "httpStatusCode": 200}	89e026a0-1c27-42ba-8074-ca80eff92e48	794c5058-c511-4509-ad40-938ce0d45eae	{}
1d791085-df4d-43bc-bd5a-f8cc03aa5b90	entry-photos	album_794c5058-c511-4509-ad40-938ce0d45eae_1785434930222_jv7zwa	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-30 18:08:50.501535+00	2026-07-30 18:08:50.501535+00	2026-07-30 18:08:50.501535+00	{"eTag": "\\"6f9d20b6961d3385effb74d34c8b4c6c\\"", "size": 2528, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-30T18:08:51.000Z", "contentLength": 2528, "httpStatusCode": 200}	32101861-c053-4cd7-a79c-9c5c57624044	794c5058-c511-4509-ad40-938ce0d45eae	{}
7e77ca93-bddb-40ec-9b3f-03f7b126f48e	entry-photos	life/51323e47-38a0-405d-b597-a56cc534ba12/2026-1786384628160	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-10 17:57:08.589626+00	2026-08-10 17:57:08.589626+00	2026-08-10 17:57:08.589626+00	{"eTag": "\\"2faad63b172f5ed6c4e7e68f4f9d3778\\"", "size": 178617, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-08-10T17:57:09.000Z", "contentLength": 178617, "httpStatusCode": 200}	f8d85476-321a-407b-8bf9-36597e5caee6	794c5058-c511-4509-ad40-938ce0d45eae	{}
3f72ed34-41ab-46e3-9249-cb7abe0ab8ce	entry-photos	msg_794c5058-c511-4509-ad40-938ce0d45eae_1785435405742_wbppvo	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-30 18:16:46.482066+00	2026-07-30 18:16:46.482066+00	2026-07-30 18:16:46.482066+00	{"eTag": "\\"10014d1902bc0e7009006513b985cfb9\\"", "size": 58371, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-30T18:16:47.000Z", "contentLength": 58371, "httpStatusCode": 200}	951695c7-a62f-40a0-9243-9a8419e2b4a0	794c5058-c511-4509-ad40-938ce0d45eae	{}
50c91fe8-e5e9-4c61-b345-e5762140e551	entry-photos	msg_794c5058-c511-4509-ad40-938ce0d45eae_1785435603463_3nxrbh	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-30 18:20:03.70504+00	2026-07-30 18:20:03.70504+00	2026-07-30 18:20:03.70504+00	{"eTag": "\\"d973c022e519465fbc99b60973e155b5\\"", "size": 762, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-30T18:20:04.000Z", "contentLength": 762, "httpStatusCode": 200}	e1c25d84-1f03-478e-84b2-7e88bdde4675	794c5058-c511-4509-ad40-938ce0d45eae	{}
eb454def-dfb6-4e7a-bdcc-31070af03120	entry-photos	life/51323e47-38a0-405d-b597-a56cc534ba12/voice_1786384628579_0fm7y.webm	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-10 17:57:08.790114+00	2026-08-10 17:57:08.790114+00	2026-08-10 17:57:08.790114+00	{"eTag": "\\"e6563d8a7e18c5a5b60ba63a67292e43\\"", "size": 103495, "mimetype": "audio/webm", "cacheControl": "max-age=3600", "lastModified": "2026-08-10T17:57:09.000Z", "contentLength": 103495, "httpStatusCode": 200}	d1dd4e1a-dee8-43cd-835c-586357f8db8a	794c5058-c511-4509-ad40-938ce0d45eae	{}
52d872d1-f771-45b0-9f44-6c22e6510dcc	entry-photos	circle_794c5058-c511-4509-ad40-938ce0d45eae_1785436779332_su75xc	794c5058-c511-4509-ad40-938ce0d45eae	2026-07-30 18:39:39.493562+00	2026-07-30 18:39:39.493562+00	2026-07-30 18:39:39.493562+00	{"eTag": "\\"041d511b6e6cd4e123dd1504079c6e3c\\"", "size": 762, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-07-30T18:39:40.000Z", "contentLength": 762, "httpStatusCode": 200}	33edc437-e615-4689-a691-c4bc70089c63	794c5058-c511-4509-ad40-938ce0d45eae	{}
e5906422-ad88-4a8d-a22e-0e005801dc1e	entry-photos	life/51323e47-38a0-405d-b597-a56cc534ba12/2023-1786384680877	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-10 17:58:01.33169+00	2026-08-10 17:58:01.33169+00	2026-08-10 17:58:01.33169+00	{"eTag": "\\"9d83f993780fd8122d94e8e9800b94e9\\"", "size": 577210, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-08-10T17:58:02.000Z", "contentLength": 577210, "httpStatusCode": 200}	f229c545-0978-4ca1-add1-1c6af3975b27	794c5058-c511-4509-ad40-938ce0d45eae	{}
dc844bb1-16b9-4651-b277-082a5e64e3d2	event-photos	ev_7c868046-adc8-4788-8d5e-c855a36e29a9_1785590203733_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-01 13:16:43.923478+00	2026-08-01 13:16:43.923478+00	2026-08-01 13:16:43.923478+00	{"eTag": "\\"b28c8df1da32e4567948942f3f3b24cb\\"", "size": 2528, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-08-01T13:16:44.000Z", "contentLength": 2528, "httpStatusCode": 200}	271e499a-0cc4-47c2-9fdd-fea5667c45dd	794c5058-c511-4509-ad40-938ce0d45eae	{}
6cacf3d1-b20f-42bc-9dd5-91b707ff116c	entry-photos	life/51323e47-38a0-405d-b597-a56cc534ba12/2017-1786384719111	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-10 17:58:39.362934+00	2026-08-10 17:58:39.362934+00	2026-08-10 17:58:39.362934+00	{"eTag": "\\"c1fccfcbef4a14b11b9fd854f0522c3f\\"", "size": 100041, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-08-10T17:58:40.000Z", "contentLength": 100041, "httpStatusCode": 200}	448c0dd2-dce0-48f4-a343-980dccf5b464	794c5058-c511-4509-ad40-938ce0d45eae	{}
39a69136-9632-4a3b-8aa1-8f8595233457	event-share	nn-ahd8.html	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-01 14:00:34.673658+00	2026-08-01 14:00:34.679407+00	2026-08-01 14:00:34.673658+00	{"eTag": "\\"c56f1feae0d094b9d269f937212d9ebb\\"", "size": 1723, "mimetype": "text/html", "cacheControl": "max-age=3600", "lastModified": "2026-08-01T14:00:35.000Z", "contentLength": 1723, "httpStatusCode": 200}	4c53f7a8-831d-4a27-9795-e253d2e66677	794c5058-c511-4509-ad40-938ce0d45eae	{}
bafcb1e8-1bdd-4660-b2e0-66d939c3fa48	event-photos	ev_8142cbcf-af80-4152-b6d8-c3e78716dbfc_1785606842638_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-01 17:54:03.015347+00	2026-08-01 17:54:03.015347+00	2026-08-01 17:54:03.015347+00	{"eTag": "\\"d55c656c8d7d9ba3182184c39f496652\\"", "size": 85458, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-08-01T17:54:03.000Z", "contentLength": 85458, "httpStatusCode": 200}	8384bb8d-89be-4f5b-b1d4-4820abe1ba09	794c5058-c511-4509-ad40-938ce0d45eae	{}
e59e94b9-ed72-456f-a623-01aef8636ec5	event-photos	ev_8142cbcf-af80-4152-b6d8-c3e78716dbfc_1785606882173_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-01 17:54:42.489746+00	2026-08-01 17:54:42.489746+00	2026-08-01 17:54:42.489746+00	{"eTag": "\\"084aecfcc9aa1e604332e8a423e5e607\\"", "size": 111108, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-08-01T17:54:43.000Z", "contentLength": 111108, "httpStatusCode": 200}	6405ed38-f330-493a-af3d-d64ea1701890	794c5058-c511-4509-ad40-938ce0d45eae	{}
a9999295-512d-464a-91f3-27183725e5d6	event-photos	cover_8142cbcf-af80-4152-b6d8-c3e78716dbfc_1785606920361	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-01 17:55:20.593949+00	2026-08-01 17:55:20.593949+00	2026-08-01 17:55:20.593949+00	{"eTag": "\\"084aecfcc9aa1e604332e8a423e5e607\\"", "size": 111108, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-08-01T17:55:21.000Z", "contentLength": 111108, "httpStatusCode": 200}	2315d6d5-2d55-4cfa-8ec8-35e0263138c1	794c5058-c511-4509-ad40-938ce0d45eae	{}
b27a3141-95ea-43a6-b5a4-622c30e1e702	entry-photos	diary_794c5058-c511-4509-ad40-938ce0d45eae_1785607421162_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-01 18:03:41.851505+00	2026-08-01 18:03:41.851505+00	2026-08-01 18:03:41.851505+00	{"eTag": "\\"084aecfcc9aa1e604332e8a423e5e607\\"", "size": 111108, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-08-01T18:03:42.000Z", "contentLength": 111108, "httpStatusCode": 200}	5a503017-1d62-449e-9091-57539afb2046	794c5058-c511-4509-ad40-938ce0d45eae	{}
a5cf3c65-451f-4901-b78c-ca1e666e1ea2	entry-photos	wall_794c5058-c511-4509-ad40-938ce0d45eae_1785607660061_0	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-01 18:07:40.416448+00	2026-08-01 18:07:40.416448+00	2026-08-01 18:07:40.416448+00	{"eTag": "\\"084aecfcc9aa1e604332e8a423e5e607\\"", "size": 111108, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-08-01T18:07:41.000Z", "contentLength": 111108, "httpStatusCode": 200}	de73f5d9-c6b9-472a-996b-9911e3bdab2c	794c5058-c511-4509-ad40-938ce0d45eae	{}
987a621d-b794-4dce-a8c8-d6caddfc8bc7	entry-photos	msg_794c5058-c511-4509-ad40-938ce0d45eae_1785610512526_df9pyl	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-01 18:55:13.119171+00	2026-08-01 18:55:13.119171+00	2026-08-01 18:55:13.119171+00	{"eTag": "\\"084aecfcc9aa1e604332e8a423e5e607\\"", "size": 111108, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-08-01T18:55:14.000Z", "contentLength": 111108, "httpStatusCode": 200}	a3bd7ec8-48c1-45d3-a241-c857ec99f6e1	794c5058-c511-4509-ad40-938ce0d45eae	{}
f3841660-fb4b-4af5-b966-ca80ad74082c	entry-photos	voice_13554111-b50c-44ad-af7b-4988c8209afb_1785610559273_fygu5.webm	13554111-b50c-44ad-af7b-4988c8209afb	2026-08-01 18:55:59.468882+00	2026-08-01 18:55:59.468882+00	2026-08-01 18:55:59.468882+00	{"eTag": "\\"dda6349c79f8a27550c221fb8720513d\\"", "size": 177323, "mimetype": "audio/webm", "cacheControl": "max-age=3600", "lastModified": "2026-08-01T18:56:00.000Z", "contentLength": 177323, "httpStatusCode": 200}	892e57d7-cb16-4b5b-9f10-ffa9d0c34cf1	13554111-b50c-44ad-af7b-4988c8209afb	{}
0fa1cc44-9877-456f-9df8-8eb380b09185	event-photos	cover_f40738ee-cbcd-413e-b81e-61758d66dee7_1785645949282	13554111-b50c-44ad-af7b-4988c8209afb	2026-08-02 04:45:49.7361+00	2026-08-02 04:45:49.7361+00	2026-08-02 04:45:49.7361+00	{"eTag": "\\"084aecfcc9aa1e604332e8a423e5e607\\"", "size": 111108, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-08-02T04:45:50.000Z", "contentLength": 111108, "httpStatusCode": 200}	7582e7bf-fc28-4255-b5a9-c09fb373d6be	13554111-b50c-44ad-af7b-4988c8209afb	{}
759f5cef-d78b-4e23-81dd-08240d0c8688	event-photos	ev_f40738ee-cbcd-413e-b81e-61758d66dee7_1785646008673_0	13554111-b50c-44ad-af7b-4988c8209afb	2026-08-02 04:46:48.876114+00	2026-08-02 04:46:48.876114+00	2026-08-02 04:46:48.876114+00	{"eTag": "\\"084aecfcc9aa1e604332e8a423e5e607\\"", "size": 111108, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-08-02T04:46:49.000Z", "contentLength": 111108, "httpStatusCode": 200}	e927380b-6a57-4908-b815-255e200b7ceb	13554111-b50c-44ad-af7b-4988c8209afb	{}
5d4dc1ba-9e38-4be7-ba51-4b2c00356e8d	event-photos	ev_f40738ee-cbcd-413e-b81e-61758d66dee7_1785646052337_0	13554111-b50c-44ad-af7b-4988c8209afb	2026-08-02 04:47:32.533804+00	2026-08-02 04:47:32.533804+00	2026-08-02 04:47:32.533804+00	{"eTag": "\\"65cbc9584463e5b038676506546cc70d\\"", "size": 122376, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-08-02T04:47:33.000Z", "contentLength": 122376, "httpStatusCode": 200}	dc8dda8b-ddbe-4549-95e9-de991ffdb419	13554111-b50c-44ad-af7b-4988c8209afb	{}
df51c8f6-0427-49cc-acd9-e30863816d82	entry-photos	life/51323e47-38a0-405d-b597-a56cc534ba12/2024-1786386716083-b9tc	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-10 18:31:56.677696+00	2026-08-10 18:31:56.677696+00	2026-08-10 18:31:56.677696+00	{"eTag": "\\"2d863323bbfc3ec9529a71d90cfb3883\\"", "size": 83608, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-08-10T18:31:57.000Z", "contentLength": 83608, "httpStatusCode": 200}	81189d9e-0353-4632-b07c-987ec2637faf	794c5058-c511-4509-ad40-938ce0d45eae	{}
8b0c8d4a-54fe-4327-9c97-e4637724c0fb	entry-photos	life/51323e47-38a0-405d-b597-a56cc534ba12/2024-1786386757951-xd5l	794c5058-c511-4509-ad40-938ce0d45eae	2026-08-10 18:32:38.400382+00	2026-08-10 18:32:38.400382+00	2026-08-10 18:32:38.400382+00	{"eTag": "\\"38d0578848339b0263afbd8fe11db6f6\\"", "size": 218781, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-08-10T18:32:39.000Z", "contentLength": 218781, "httpStatusCode": 200}	f8b6c929-c7b8-47bf-8ce4-92965ee95567	794c5058-c511-4509-ad40-938ce0d45eae	{}
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata, metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.vector_indexes (id, name, bucket_id, data_type, dimension, distance_metric, metadata_configuration, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: supabase_migrations; Owner: -
--

COPY supabase_migrations.schema_migrations (version, statements, name, created_by, idempotency_key, rollback) FROM stdin;
20260731081512	{"\n-- These 4 buckets are all public=true, so object fetch-by-URL already works\n-- without any RLS SELECT policy (Supabase serves public bucket objects\n-- directly). The app itself never calls storage.list()/download() — only\n-- upload()/getPublicUrl()/remove() — so these broad SELECT policies serve\n-- no legitimate purpose and only let clients enumerate every file in the\n-- bucket. Dropping them removes that listing/enumeration exposure with zero\n-- functional impact.\ndrop policy if exists \\"allow uploads 1cmn924_2\\" on storage.objects; -- covers SELECT\ndrop policy if exists \\"allow uploads 1oj01fe_2\\" on storage.objects; -- avatars SELECT\ndrop policy if exists \\"allow uploads 1rtzjgc_2\\" on storage.objects; -- entry-photos SELECT\ndrop policy if exists \\"event photos read\\" on storage.objects; -- event-photos SELECT\n"}	restrict_public_bucket_listing	aseshsarkar51@gmail.com	\N	\N
20260731082631	{"\n-- comments: author_user_id is legitimately null for guest comments (app sets\n-- currentUser ? currentUser.id : null), so we can't require it to always\n-- equal auth.uid(). What we CAN and should block is a request claiming to be\n-- a *specific other* real user (identity spoofing) while still allowing true\n-- guest comments and genuine self-authored ones.\ndrop policy if exists \\"comments: anyone may post\\" on public.comments;\ncreate policy \\"comments: post as self or as guest\\"\n  on public.comments for insert\n  with check (author_user_id is null or author_user_id = auth.uid());\n\n-- likes: liker_key is auth.uid()::text when signed in, or a random per-device\n-- string when anonymous (see myLikerKey() in the client). The DELETE policy\n-- already encodes the right rule with a COALESCE trick; apply the same rule\n-- to INSERT and UPDATE so a signed-in user can't spoof someone else's like.\ndrop policy if exists \\"likes: anyone may like\\" on public.likes;\ndrop policy if exists \\"anyone can add a reaction\\" on public.likes;\ncreate policy \\"likes: react as self or as guest device\\"\n  on public.likes for insert\n  with check (liker_key = coalesce((auth.uid())::text, liker_key));\n\ndrop policy if exists \\"anyone can change their reaction\\" on public.likes;\ncreate policy \\"likes: change own reaction\\"\n  on public.likes for update\n  using (liker_key = coalesce((auth.uid())::text, liker_key))\n  with check (liker_key = coalesce((auth.uid())::text, liker_key));\n\n-- reports: intentionally low-friction/anonymous-friendly (no login required\n-- to report abuse), target_type is already constrained by a CHECK constraint\n-- (entry/comment/profile). The gap was that literally empty/junk rows were\n-- accepted; require the actual required fields to be present.\ndrop policy if exists \\"reports: anyone may report\\" on public.reports;\ncreate policy \\"reports: submit with required fields\\"\n  on public.reports for insert\n  with check (\n    reporter_key is not null and length(reporter_key) > 0\n    and reason is not null and length(reason) > 0\n    and target_id is not null\n  );\n"}	tighten_comments_likes_reports_insert_policies	aseshsarkar51@gmail.com	\N	\N
20260731082916	{"\n-- \\"likes: remove own like\\" already correctly restricts DELETE to the row's\n-- own liker_key (self or matching guest device key). This older, redundant\n-- policy grants USING (true) for the same command — since Postgres OR's\n-- multiple permissive policies together, its mere presence let anyone\n-- delete any other user's like regardless of the correct policy above.\ndrop policy if exists \\"anyone can remove a reaction\\" on public.likes;\n"}	drop_redundant_permissive_likes_delete_policy	aseshsarkar51@gmail.com	\N	\N
20260731083051	{"\n-- The previous COALESCE(auth.uid()::text, liker_key) pattern only protects\n-- authenticated requests (their liker_key must equal their own auth.uid()).\n-- For anonymous requests, auth.uid() is null, so COALESCE(null, liker_key)\n-- collapses to \\"liker_key = liker_key\\" -- always true, for ANY liker_key,\n-- including a real signed-in user's auth.uid() if that value were ever\n-- learned (e.g. because likes rows were readable by everyone, see below).\n-- Client-side, myLikerKey() only ever generates two shapes of key:\n--   - a real user's own auth.uid() (a uuid), when signed in\n--   - a random 'dev_xxxxxxxxxx' string, when anonymous\n-- So we can close the gap precisely: authenticated requests must match\n-- their own uid; anonymous requests may only touch 'dev_' device keys,\n-- never a bare uuid-shaped identity key.\ndrop policy if exists \\"likes: react as self or as guest device\\" on public.likes;\ncreate policy \\"likes: react as self or as guest device\\"\n  on public.likes for insert\n  with check (\n    (auth.uid() is not null and liker_key = auth.uid()::text)\n    or (auth.uid() is null and liker_key like 'dev_%')\n  );\n\ndrop policy if exists \\"likes: change own reaction\\" on public.likes;\ncreate policy \\"likes: change own reaction\\"\n  on public.likes for update\n  using (\n    (auth.uid() is not null and liker_key = auth.uid()::text)\n    or (auth.uid() is null and liker_key like 'dev_%')\n  )\n  with check (\n    (auth.uid() is not null and liker_key = auth.uid()::text)\n    or (auth.uid() is null and liker_key like 'dev_%')\n  );\n\ndrop policy if exists \\"likes: remove own like\\" on public.likes;\ncreate policy \\"likes: remove own like\\"\n  on public.likes for delete\n  using (\n    (auth.uid() is not null and liker_key = auth.uid()::text)\n    or (auth.uid() is null and liker_key like 'dev_%')\n  );\n\n-- \\"anyone can read reactions\\" was a blanket USING(true) SELECT policy that\n-- made the properly visibility-scoped \\"likes: read where entry visible\\"\n-- policy moot (Postgres OR's all matching permissive policies together),\n-- and was the actual source of exposure: it let anyone read every liker_key\n-- -- including real users' auth.uid() values -- for entries they shouldn't\n-- even be able to see. Dropping it leaves the visibility-scoped policy as\n-- the only path to reading likes.\ndrop policy if exists \\"anyone can read reactions\\" on public.likes;\n"}	close_anon_liker_key_spoofing_gap	aseshsarkar51@gmail.com	\N	\N
20260801131352	{"\n-- storage.objects had zero SELECT policies, which silently broke every\n-- photo upload in the app: Supabase's .upload() does an INSERT ... RETURNING,\n-- and Postgres RLS requires the newly-inserted row to also pass a SELECT\n-- policy to be returned. With no SELECT policy at all, every insert failed\n-- with \\"new row violates row-level security policy\\" even though the INSERT\n-- itself was permitted by the existing (correct) INSERT policies.\n-- All four buckets in use (avatars, covers, entry-photos, event-photos) are\n-- marked public in storage.buckets, so a public read policy matches intent.\ncreate policy \\"public read for public buckets\\"\non storage.objects\nfor select\nto public\nusing (bucket_id in ('avatars', 'covers', 'entry-photos', 'event-photos'));\n"}	add_storage_objects_select_policy	aseshsarkar51@gmail.com	\N	\N
20260801135453	{"\n-- Let signed-in users publish/update the static share-card HTML for an event\ncreate policy \\"event share upload\\"\non storage.objects\nfor insert\nto public\nwith check (bucket_id = 'event-share' and auth.role() = 'authenticated');\n\ncreate policy \\"event share update\\"\non storage.objects\nfor update\nto public\nusing (bucket_id = 'event-share' and auth.role() = 'authenticated');\n\n-- Public read so chat-app crawlers (no auth) and browsers can fetch it\ncreate policy \\"event share public read\\"\non storage.objects\nfor select\nto public\nusing (bucket_id = 'event-share');\n"}	event_share_bucket_policies	aseshsarkar51@gmail.com	\N	\N
20260801204308	{"-- The Unsend button in Messages and Circle chat deletes the row client-side,\n-- but there was no DELETE RLS policy on either table. Without one, RLS\n-- silently matches zero rows on delete (no error), so the message looked\n-- gone in the UI but was never actually removed from the database and\n-- reappeared on refresh. This adds \\"you can delete your own message\\" rules,\n-- matching the existing INSERT policies' ownership checks on each table.\n\ncreate policy \\"messages: sender can unsend own message\\"\non public.messages\nfor delete\nto authenticated\nusing (owns_profile(sender_profile_id));\n\ncreate policy \\"circle_messages: sender can unsend own message\\"\non public.circle_messages\nfor delete\nto public\nusing (sender_user_id = auth.uid());\n"}	add_delete_policy_for_messages_and_circle_messages	aseshsarkar51@gmail.com	\N	\N
20260802132924	{"create table public.poll_votes (\n  id uuid primary key default gen_random_uuid(),\n  profile_id uuid not null references public.profiles(id) on delete cascade,\n  voter_user_id uuid not null references auth.users(id) on delete cascade,\n  question_key text not null check (question_key in ('spark','element','word','value','mark')),\n  option_index int not null check (option_index >= 0 and option_index <= 4),\n  created_at timestamptz not null default now(),\n  unique (profile_id, voter_user_id, question_key)\n);\n\nalter table public.poll_votes enable row level security;\n\ncreate policy \\"poll_votes: insert own\\" on public.poll_votes\n  for insert\n  with check (voter_user_id = auth.uid());\n\ncreate policy \\"poll_votes: read public profile or own profile or own vote\\" on public.poll_votes\n  for select\n  using (\n    voter_user_id = auth.uid()\n    or exists (\n      select 1 from public.profiles p\n      where p.id = poll_votes.profile_id\n        and (p.visibility = 'public' or p.user_id = auth.uid())\n    )\n  );\n\ncreate index poll_votes_profile_question_idx on public.poll_votes (profile_id, question_key);\n"}	create_poll_votes	aseshsarkar51@gmail.com	\N	\N
20260803174511	{"create policy \\"comments: author removes own\\"\non public.comments\nfor delete\nusing (author_user_id = auth.uid());"}	comments_author_can_delete_own	aseshsarkar51@gmail.com	\N	\N
20260805182904	{"ALTER TABLE public.entries ADD COLUMN IF NOT EXISTS kind text;"}	add_kind_column_to_entries	aseshsarkar51@gmail.com	\N	\N
20260818191954	{"create table if not exists public.growth_events (\n  id uuid primary key default gen_random_uuid(),\n  event_name text not null,\n  user_id uuid references auth.users(id) on delete set null,\n  properties jsonb not null default '{}'::jsonb,\n  created_at timestamptz not null default now()\n);\n\nalter table public.growth_events enable row level security;\n\n-- Authenticated users may only log events attributed to themselves.\ncreate policy \\"growth_events insert own\\" on public.growth_events\n  for insert to authenticated\n  with check (user_id = auth.uid());\n\n-- No select/update/delete policies for anon/authenticated: this table is\n-- write-only from the client. Reporting happens via the Supabase dashboard\n-- or service-role access, not the app itself.\n"}	add_growth_events_table	aseshsarkar51@gmail.com	\N	\N
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: -
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 981, true);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: -
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: custom_oauth_providers custom_oauth_providers_identifier_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_identifier_key UNIQUE (identifier);


--
-- Name: custom_oauth_providers custom_oauth_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- Name: oauth_client_states oauth_client_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_client_states
    ADD CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webauthn_challenges webauthn_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_pkey PRIMARY KEY (id);


--
-- Name: webauthn_credentials webauthn_credentials_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_pkey PRIMARY KEY (id);


--
-- Name: album_photos album_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.album_photos
    ADD CONSTRAINT album_photos_pkey PRIMARY KEY (id);


--
-- Name: albums albums_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.albums
    ADD CONSTRAINT albums_pkey PRIMARY KEY (id);


--
-- Name: blocks blocks_blocker_user_id_blocked_profile_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_blocker_user_id_blocked_profile_id_key UNIQUE (blocker_user_id, blocked_profile_id);


--
-- Name: blocks blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_pkey PRIMARY KEY (id);


--
-- Name: circle_members circle_members_circle_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.circle_members
    ADD CONSTRAINT circle_members_circle_id_user_id_key UNIQUE (circle_id, user_id);


--
-- Name: circle_members circle_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.circle_members
    ADD CONSTRAINT circle_members_pkey PRIMARY KEY (id);


--
-- Name: circle_messages circle_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.circle_messages
    ADD CONSTRAINT circle_messages_pkey PRIMARY KEY (id);


--
-- Name: circles circles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.circles
    ADD CONSTRAINT circles_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


--
-- Name: conversations conversations_requester_profile_id_recipient_profile_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_requester_profile_id_recipient_profile_id_key UNIQUE (requester_profile_id, recipient_profile_id);


--
-- Name: diary_entries diary_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diary_entries
    ADD CONSTRAINT diary_entries_pkey PRIMARY KEY (id);


--
-- Name: diary_moods diary_moods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diary_moods
    ADD CONSTRAINT diary_moods_pkey PRIMARY KEY (user_id, mood_date);


--
-- Name: entries entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entries
    ADD CONSTRAINT entries_pkey PRIMARY KEY (id);


--
-- Name: event_comments event_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_comments
    ADD CONSTRAINT event_comments_pkey PRIMARY KEY (id);


--
-- Name: event_entries event_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_entries
    ADD CONSTRAINT event_entries_pkey PRIMARY KEY (id);


--
-- Name: event_guests event_guests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_guests
    ADD CONSTRAINT event_guests_pkey PRIMARY KEY (id);


--
-- Name: event_likes event_likes_entry_id_liker_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_likes
    ADD CONSTRAINT event_likes_entry_id_liker_key_key UNIQUE (entry_id, liker_key);


--
-- Name: event_likes event_likes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_likes
    ADD CONSTRAINT event_likes_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: events events_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_slug_key UNIQUE (slug);


--
-- Name: follows follows_follower_user_id_followed_profile_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follows_follower_user_id_followed_profile_id_key UNIQUE (follower_user_id, followed_profile_id);


--
-- Name: follows follows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follows_pkey PRIMARY KEY (id);


--
-- Name: growth_events growth_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.growth_events
    ADD CONSTRAINT growth_events_pkey PRIMARY KEY (id);


--
-- Name: likes likes_entry_id_liker_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_entry_id_liker_key_key UNIQUE (entry_id, liker_key);


--
-- Name: likes likes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: poll_votes poll_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT poll_votes_pkey PRIMARY KEY (id);


--
-- Name: poll_votes poll_votes_profile_id_voter_user_id_question_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT poll_votes_profile_id_voter_user_id_question_key_key UNIQUE (profile_id, voter_user_id, question_key);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_key UNIQUE (user_id);


--
-- Name: profiles profiles_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_username_key UNIQUE (username);


--
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- Name: messages messages_payload_exclusive; Type: CHECK CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages
    ADD CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL))) NOT VALID;


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: buckets_vectors buckets_vectors_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: vector_indexes vector_indexes_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_idempotency_key_key; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY supabase_migrations.schema_migrations
    ADD CONSTRAINT schema_migrations_idempotency_key_key UNIQUE (idempotency_key);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY supabase_migrations.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: custom_oauth_providers_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_created_at_idx ON auth.custom_oauth_providers USING btree (created_at);


--
-- Name: custom_oauth_providers_enabled_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_enabled_idx ON auth.custom_oauth_providers USING btree (enabled);


--
-- Name: custom_oauth_providers_identifier_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_identifier_idx ON auth.custom_oauth_providers USING btree (identifier);


--
-- Name: custom_oauth_providers_provider_type_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_provider_type_idx ON auth.custom_oauth_providers USING btree (provider_type);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_oauth_client_states_created_at; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: idx_users_created_at_desc; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_users_created_at_desc ON auth.users USING btree (created_at DESC);


--
-- Name: idx_users_email; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_users_email ON auth.users USING btree (email);


--
-- Name: idx_users_last_sign_in_at_desc; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_users_last_sign_in_at_desc ON auth.users USING btree (last_sign_in_at DESC);


--
-- Name: idx_users_name; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_users_name ON auth.users USING btree (((raw_user_meta_data ->> 'name'::text))) WHERE ((raw_user_meta_data ->> 'name'::text) IS NOT NULL);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: webauthn_challenges_expires_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_challenges_expires_at_idx ON auth.webauthn_challenges USING btree (expires_at);


--
-- Name: webauthn_challenges_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_challenges_user_id_idx ON auth.webauthn_challenges USING btree (user_id);


--
-- Name: webauthn_credentials_credential_id_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX webauthn_credentials_credential_id_key ON auth.webauthn_credentials USING btree (credential_id);


--
-- Name: webauthn_credentials_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_credentials_user_id_idx ON auth.webauthn_credentials USING btree (user_id);


--
-- Name: album_photos_profile_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX album_photos_profile_created_idx ON public.album_photos USING btree (profile_id, created_at DESC);


--
-- Name: comments_author_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_author_time_idx ON public.comments USING btree (author_user_id, created_at DESC);


--
-- Name: comments_entry_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_entry_idx ON public.comments USING btree (entry_id);


--
-- Name: diary_author_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX diary_author_time_idx ON public.diary_entries USING btree (author_user_id, created_at DESC);


--
-- Name: diary_entries_author_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX diary_entries_author_idx ON public.diary_entries USING btree (author_user_id, created_at DESC);


--
-- Name: entries_diary_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX entries_diary_idx ON public.entries USING btree (diary_entry_id);


--
-- Name: entries_profile_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX entries_profile_status_idx ON public.entries USING btree (profile_id, status);


--
-- Name: entries_signer_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX entries_signer_time_idx ON public.entries USING btree (signer_user_id, created_at DESC);


--
-- Name: event_entries_author_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_entries_author_time_idx ON public.event_entries USING btree (author_user_id, created_at DESC);


--
-- Name: event_guests_user_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_guests_user_time_idx ON public.event_guests USING btree (user_id, created_at DESC);


--
-- Name: events_owner_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_owner_time_idx ON public.events USING btree (owner_user_id, created_at DESC);


--
-- Name: likes_entry_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX likes_entry_idx ON public.likes USING btree (entry_id);


--
-- Name: likes_entry_liker_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX likes_entry_liker_uniq ON public.likes USING btree (entry_id, liker_key);


--
-- Name: messages_conv_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX messages_conv_idx ON public.messages USING btree (conversation_id, created_at);


--
-- Name: poll_votes_profile_question_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX poll_votes_profile_question_idx ON public.poll_votes USING btree (profile_id, question_key);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_action_filter_selec; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_action_filter_selec ON realtime.subscription USING btree (subscription_id, entity, filters, action_filter, COALESCE(selected_columns, '{}'::text[]));


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: buckets_analytics_unique_name_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_bucket_id_name_lower; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name_lower ON storage.objects USING btree (bucket_id, lower(name) COLLATE "C");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: vector_indexes_name_bucket_id_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);


--
-- Name: comments trg_comment_rate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_comment_rate BEFORE INSERT ON public.comments FOR EACH ROW EXECUTE FUNCTION public.check_comment_rate();


--
-- Name: diary_entries trg_diary_rate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_diary_rate BEFORE INSERT ON public.diary_entries FOR EACH ROW EXECUTE FUNCTION public.check_diary_rate();


--
-- Name: entries trg_entry_rate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_entry_rate BEFORE INSERT ON public.entries FOR EACH ROW EXECUTE FUNCTION public.check_entry_rate();


--
-- Name: event_entries trg_event_entry_rate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_event_entry_rate BEFORE INSERT ON public.event_entries FOR EACH ROW EXECUTE FUNCTION public.check_event_entry_rate();


--
-- Name: events trg_event_rate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_event_rate BEFORE INSERT ON public.events FOR EACH ROW EXECUTE FUNCTION public.check_event_rate();


--
-- Name: event_guests trg_guest_rate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_guest_rate BEFORE INSERT ON public.event_guests FOR EACH ROW EXECUTE FUNCTION public.check_guest_rate();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: buckets protect_buckets_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_buckets_delete BEFORE DELETE ON storage.buckets FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects protect_objects_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_objects_delete BEFORE DELETE ON storage.objects FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: webauthn_challenges webauthn_challenges_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: webauthn_credentials webauthn_credentials_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: album_photos album_photos_album_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.album_photos
    ADD CONSTRAINT album_photos_album_id_fkey FOREIGN KEY (album_id) REFERENCES public.albums(id) ON DELETE SET NULL;


--
-- Name: album_photos album_photos_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.album_photos
    ADD CONSTRAINT album_photos_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: album_photos album_photos_signer_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.album_photos
    ADD CONSTRAINT album_photos_signer_user_id_fkey FOREIGN KEY (signer_user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: albums albums_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.albums
    ADD CONSTRAINT albums_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: blocks blocks_blocked_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_blocked_profile_id_fkey FOREIGN KEY (blocked_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: blocks blocks_blocker_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_blocker_user_id_fkey FOREIGN KEY (blocker_user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: circle_members circle_members_circle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.circle_members
    ADD CONSTRAINT circle_members_circle_id_fkey FOREIGN KEY (circle_id) REFERENCES public.circles(id) ON DELETE CASCADE;


--
-- Name: circle_messages circle_messages_circle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.circle_messages
    ADD CONSTRAINT circle_messages_circle_id_fkey FOREIGN KEY (circle_id) REFERENCES public.circles(id) ON DELETE CASCADE;


--
-- Name: comments comments_author_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_author_user_id_fkey FOREIGN KEY (author_user_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: comments comments_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_entry_id_fkey FOREIGN KEY (entry_id) REFERENCES public.entries(id) ON DELETE CASCADE;


--
-- Name: comments comments_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- Name: conversations conversations_recipient_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_recipient_profile_id_fkey FOREIGN KEY (recipient_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: conversations conversations_requester_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_requester_profile_id_fkey FOREIGN KEY (requester_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: diary_entries diary_entries_author_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diary_entries
    ADD CONSTRAINT diary_entries_author_user_id_fkey FOREIGN KEY (author_user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: diary_entries diary_entries_shared_with_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diary_entries
    ADD CONSTRAINT diary_entries_shared_with_user_id_fkey FOREIGN KEY (shared_with_user_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: diary_moods diary_moods_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diary_moods
    ADD CONSTRAINT diary_moods_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: entries entries_diary_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entries
    ADD CONSTRAINT entries_diary_entry_id_fkey FOREIGN KEY (diary_entry_id) REFERENCES public.diary_entries(id) ON DELETE CASCADE;


--
-- Name: entries entries_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entries
    ADD CONSTRAINT entries_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: entries entries_signer_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entries
    ADD CONSTRAINT entries_signer_user_id_fkey FOREIGN KEY (signer_user_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: event_comments event_comments_author_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_comments
    ADD CONSTRAINT event_comments_author_user_id_fkey FOREIGN KEY (author_user_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: event_comments event_comments_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_comments
    ADD CONSTRAINT event_comments_entry_id_fkey FOREIGN KEY (entry_id) REFERENCES public.event_entries(id) ON DELETE CASCADE;


--
-- Name: event_comments event_comments_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_comments
    ADD CONSTRAINT event_comments_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: event_comments event_comments_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_comments
    ADD CONSTRAINT event_comments_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.event_comments(id) ON DELETE CASCADE;


--
-- Name: event_entries event_entries_author_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_entries
    ADD CONSTRAINT event_entries_author_user_id_fkey FOREIGN KEY (author_user_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: event_entries event_entries_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_entries
    ADD CONSTRAINT event_entries_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: event_guests event_guests_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_guests
    ADD CONSTRAINT event_guests_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: event_guests event_guests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_guests
    ADD CONSTRAINT event_guests_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: event_likes event_likes_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_likes
    ADD CONSTRAINT event_likes_entry_id_fkey FOREIGN KEY (entry_id) REFERENCES public.event_entries(id) ON DELETE CASCADE;


--
-- Name: event_likes event_likes_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_likes
    ADD CONSTRAINT event_likes_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: events events_owner_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_owner_user_id_fkey FOREIGN KEY (owner_user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: follows follows_followed_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follows_followed_profile_id_fkey FOREIGN KEY (followed_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: follows follows_follower_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follows_follower_user_id_fkey FOREIGN KEY (follower_user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: growth_events growth_events_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.growth_events
    ADD CONSTRAINT growth_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: likes likes_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_entry_id_fkey FOREIGN KEY (entry_id) REFERENCES public.entries(id) ON DELETE CASCADE;


--
-- Name: messages messages_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: messages messages_sender_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_profile_id_fkey FOREIGN KEY (sender_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: poll_votes poll_votes_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT poll_votes_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: poll_votes poll_votes_voter_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT poll_votes_voter_user_id_fkey FOREIGN KEY (voter_user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: vector_indexes vector_indexes_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: diary_entries Author deletes own diary; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Author deletes own diary" ON public.diary_entries FOR DELETE USING ((author_user_id = auth.uid()));


--
-- Name: event_entries Author edits own entries; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Author edits own entries" ON public.event_entries FOR UPDATE USING ((author_user_id = auth.uid()));


--
-- Name: event_comments Author or host deletes comments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Author or host deletes comments" ON public.event_comments FOR DELETE USING (((author_user_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.events e
  WHERE ((e.id = event_comments.event_id) AND (e.owner_user_id = auth.uid()))))));


--
-- Name: event_entries Author or host deletes entries; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Author or host deletes entries" ON public.event_entries FOR DELETE USING (((author_user_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.events e
  WHERE ((e.id = event_entries.event_id) AND (e.owner_user_id = auth.uid()))))));


--
-- Name: diary_entries Author reads own diary; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Author reads own diary" ON public.diary_entries FOR SELECT USING ((author_user_id = auth.uid()));


--
-- Name: diary_entries Author updates own diary; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Author updates own diary" ON public.diary_entries FOR UPDATE USING ((author_user_id = auth.uid()));


--
-- Name: diary_entries Author writes own diary; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Author writes own diary" ON public.diary_entries FOR INSERT WITH CHECK ((author_user_id = auth.uid()));


--
-- Name: events Events readable by link; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Events readable by link" ON public.events FOR SELECT USING (true);


--
-- Name: event_guests Guests readable; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Guests readable" ON public.event_guests FOR SELECT USING (true);


--
-- Name: event_likes Members add event likes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Members add event likes" ON public.event_likes FOR INSERT WITH CHECK (public.is_event_member(event_id));


--
-- Name: event_comments Members read comments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Members read comments" ON public.event_comments FOR SELECT USING (public.is_event_member(event_id));


--
-- Name: event_entries Members read entries; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Members read entries" ON public.event_entries FOR SELECT USING (public.is_event_member(event_id));


--
-- Name: event_likes Members read event likes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Members read event likes" ON public.event_likes FOR SELECT USING (public.is_event_member(event_id));


--
-- Name: event_likes Members remove event likes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Members remove event likes" ON public.event_likes FOR DELETE USING (public.is_event_member(event_id));


--
-- Name: event_comments Members write comments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Members write comments" ON public.event_comments FOR INSERT WITH CHECK ((public.is_event_member(event_id) AND (author_user_id = auth.uid())));


--
-- Name: event_entries Members write entries; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Members write entries" ON public.event_entries FOR INSERT WITH CHECK ((public.is_event_member(event_id) AND (author_user_id = auth.uid())));


--
-- Name: entries Owner adds own entry to own book; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Owner adds own entry to own book" ON public.entries FOR INSERT WITH CHECK (((signer_user_id = auth.uid()) AND (EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = entries.profile_id) AND (p.user_id = auth.uid()))))));


--
-- Name: entries Owner deletes own entry on own book; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Owner deletes own entry on own book" ON public.entries FOR DELETE USING (((signer_user_id = auth.uid()) AND (EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = entries.profile_id) AND (p.user_id = auth.uid()))))));


--
-- Name: event_guests Owner or self remove guest; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Owner or self remove guest" ON public.event_guests FOR DELETE USING (((EXISTS ( SELECT 1
   FROM public.events e
  WHERE ((e.id = event_guests.event_id) AND (e.owner_user_id = auth.uid())))) OR (user_id = auth.uid())));


--
-- Name: event_guests Owner or self update guest; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Owner or self update guest" ON public.event_guests FOR UPDATE USING (((EXISTS ( SELECT 1
   FROM public.events e
  WHERE ((e.id = event_guests.event_id) AND (e.owner_user_id = auth.uid())))) OR (user_id = auth.uid())));


--
-- Name: entries Owner updates own entry on own book; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Owner updates own entry on own book" ON public.entries FOR UPDATE USING (((signer_user_id = auth.uid()) AND (EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = entries.profile_id) AND (p.user_id = auth.uid()))))));


--
-- Name: events Owners delete events; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Owners delete events" ON public.events FOR DELETE USING ((owner_user_id = auth.uid()));


--
-- Name: events Owners insert events; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Owners insert events" ON public.events FOR INSERT WITH CHECK ((owner_user_id = auth.uid()));


--
-- Name: events Owners update events; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Owners update events" ON public.events FOR UPDATE USING ((owner_user_id = auth.uid()));


--
-- Name: profiles Public profiles are searchable; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public profiles are searchable" ON public.profiles FOR SELECT USING (((visibility = 'public'::text) AND (COALESCE(deactivated, false) = false)));


--
-- Name: diary_entries Recipient reads shared diary entry; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Recipient reads shared diary entry" ON public.diary_entries FOR SELECT USING (((visibility = 'shared_person'::text) AND (shared_with_user_id = auth.uid())));


--
-- Name: event_guests Request or be invited; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Request or be invited" ON public.event_guests FOR INSERT WITH CHECK ((((user_id = auth.uid()) AND (status = 'requested'::text)) OR (EXISTS ( SELECT 1
   FROM public.events e
  WHERE ((e.id = event_guests.event_id) AND (e.owner_user_id = auth.uid()))))));


--
-- Name: album_photos Users can update their own album photos; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their own album photos" ON public.album_photos FOR UPDATE USING ((auth.uid() = signer_user_id)) WITH CHECK ((auth.uid() = signer_user_id));


--
-- Name: album_photos album owner can delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "album owner can delete" ON public.album_photos FOR DELETE USING ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = album_photos.profile_id) AND (p.user_id = auth.uid())))));


--
-- Name: album_photos album owner can insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "album owner can insert" ON public.album_photos FOR INSERT WITH CHECK (((signer_user_id = auth.uid()) AND (EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = album_photos.profile_id) AND (p.user_id = auth.uid()))))));


--
-- Name: album_photos album owner can read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "album owner can read" ON public.album_photos FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = album_photos.profile_id) AND (p.user_id = auth.uid())))));


--
-- Name: album_photos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.album_photos ENABLE ROW LEVEL SECURITY;

--
-- Name: albums; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.albums ENABLE ROW LEVEL SECURITY;

--
-- Name: blocks; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.blocks ENABLE ROW LEVEL SECURITY;

--
-- Name: blocks blocks: block as yourself; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "blocks: block as yourself" ON public.blocks FOR INSERT TO authenticated WITH CHECK ((blocker_user_id = auth.uid()));


--
-- Name: blocks blocks: see your own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "blocks: see your own" ON public.blocks FOR SELECT TO authenticated USING ((blocker_user_id = auth.uid()));


--
-- Name: blocks blocks: unblock your own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "blocks: unblock your own" ON public.blocks FOR DELETE TO authenticated USING ((blocker_user_id = auth.uid()));


--
-- Name: circle_members; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.circle_members ENABLE ROW LEVEL SECURITY;

--
-- Name: circle_messages; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.circle_messages ENABLE ROW LEVEL SECURITY;

--
-- Name: circle_messages circle_messages: sender can unsend own message; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "circle_messages: sender can unsend own message" ON public.circle_messages FOR DELETE USING ((sender_user_id = auth.uid()));


--
-- Name: circles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.circles ENABLE ROW LEVEL SECURITY;

--
-- Name: comments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

--
-- Name: comments comments: author removes own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "comments: author removes own" ON public.comments FOR DELETE USING ((author_user_id = auth.uid()));


--
-- Name: comments comments: page owner removes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "comments: page owner removes" ON public.comments FOR DELETE USING ((EXISTS ( SELECT 1
   FROM (public.entries e
     JOIN public.profiles p ON ((p.id = e.profile_id)))
  WHERE ((e.id = comments.entry_id) AND (p.user_id = auth.uid())))));


--
-- Name: comments comments: post as self or as guest; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "comments: post as self or as guest" ON public.comments FOR INSERT WITH CHECK (((author_user_id IS NULL) OR (author_user_id = auth.uid())));


--
-- Name: comments comments: read where entry visible; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "comments: read where entry visible" ON public.comments FOR SELECT USING ((EXISTS ( SELECT 1
   FROM (public.entries e
     JOIN public.profiles p ON ((p.id = e.profile_id)))
  WHERE ((e.id = comments.entry_id) AND ((p.user_id = auth.uid()) OR ((e.status = 'approved'::text) AND (p.visibility = 'public'::text)))))));


--
-- Name: conversations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;

--
-- Name: conversations conversations: participants read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "conversations: participants read" ON public.conversations FOR SELECT TO authenticated USING ((public.owns_profile(requester_profile_id) OR public.owns_profile(recipient_profile_id)));


--
-- Name: conversations conversations: recipient decides; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "conversations: recipient decides" ON public.conversations FOR UPDATE TO authenticated USING (public.owns_profile(recipient_profile_id));


--
-- Name: conversations conversations: start as yourself, pending only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "conversations: start as yourself, pending only" ON public.conversations FOR INSERT TO authenticated WITH CHECK ((public.owns_profile(requester_profile_id) AND (status = 'pending'::text)));


--
-- Name: circle_members creator adds members; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "creator adds members" ON public.circle_members FOR INSERT WITH CHECK ((auth.uid() = ( SELECT circles.created_by
   FROM public.circles
  WHERE (circles.id = circle_members.circle_id))));


--
-- Name: circles creator deletes circle; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "creator deletes circle" ON public.circles FOR DELETE USING ((created_by = auth.uid()));


--
-- Name: diary_entries; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.diary_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: diary_moods; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.diary_moods ENABLE ROW LEVEL SECURITY;

--
-- Name: entries; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.entries ENABLE ROW LEVEL SECURITY;

--
-- Name: entries entries: anyone may sign (pending only); Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "entries: anyone may sign (pending only)" ON public.entries FOR INSERT WITH CHECK ((status = 'pending'::text));


--
-- Name: entries entries: owner deletes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "entries: owner deletes" ON public.entries FOR DELETE USING ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = entries.profile_id) AND (p.user_id = auth.uid())))));


--
-- Name: entries entries: owner moderates; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "entries: owner moderates" ON public.entries FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = entries.profile_id) AND (p.user_id = auth.uid())))));


--
-- Name: entries entries: read approved on public pages, or own page; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "entries: read approved on public pages, or own page" ON public.entries FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = entries.profile_id) AND ((p.user_id = auth.uid()) OR ((entries.status = 'approved'::text) AND (p.visibility = 'public'::text)))))));


--
-- Name: event_comments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.event_comments ENABLE ROW LEVEL SECURITY;

--
-- Name: event_entries; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.event_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: event_guests; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.event_guests ENABLE ROW LEVEL SECURITY;

--
-- Name: event_likes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.event_likes ENABLE ROW LEVEL SECURITY;

--
-- Name: events; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

--
-- Name: follows; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;

--
-- Name: follows follows: follow as yourself; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "follows: follow as yourself" ON public.follows FOR INSERT TO authenticated WITH CHECK ((follower_user_id = auth.uid()));


--
-- Name: follows follows: read (signed in); Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "follows: read (signed in)" ON public.follows FOR SELECT TO authenticated USING (true);


--
-- Name: follows follows: unfollow your own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "follows: unfollow your own" ON public.follows FOR DELETE TO authenticated USING ((follower_user_id = auth.uid()));


--
-- Name: growth_events; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.growth_events ENABLE ROW LEVEL SECURITY;

--
-- Name: growth_events growth_events insert own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "growth_events insert own" ON public.growth_events FOR INSERT TO authenticated WITH CHECK ((user_id = auth.uid()));


--
-- Name: entries guests_can_submit_pending_entries; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY guests_can_submit_pending_entries ON public.entries FOR INSERT TO anon WITH CHECK (((status = 'pending'::text) AND (signer_user_id IS NULL)));


--
-- Name: circle_members leave or be removed by creator; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "leave or be removed by creator" ON public.circle_members FOR DELETE USING (((user_id = auth.uid()) OR (auth.uid() = ( SELECT circles.created_by
   FROM public.circles
  WHERE (circles.id = circle_members.circle_id)))));


--
-- Name: likes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;

--
-- Name: likes likes: change own reaction; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "likes: change own reaction" ON public.likes FOR UPDATE USING ((((auth.uid() IS NOT NULL) AND (liker_key = (auth.uid())::text)) OR ((auth.uid() IS NULL) AND (liker_key ~~ 'dev_%'::text)))) WITH CHECK ((((auth.uid() IS NOT NULL) AND (liker_key = (auth.uid())::text)) OR ((auth.uid() IS NULL) AND (liker_key ~~ 'dev_%'::text))));


--
-- Name: likes likes: react as self or as guest device; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "likes: react as self or as guest device" ON public.likes FOR INSERT WITH CHECK ((((auth.uid() IS NOT NULL) AND (liker_key = (auth.uid())::text)) OR ((auth.uid() IS NULL) AND (liker_key ~~ 'dev_%'::text))));


--
-- Name: likes likes: read where entry visible; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "likes: read where entry visible" ON public.likes FOR SELECT USING ((EXISTS ( SELECT 1
   FROM (public.entries e
     JOIN public.profiles p ON ((p.id = e.profile_id)))
  WHERE ((e.id = likes.entry_id) AND ((p.user_id = auth.uid()) OR ((e.status = 'approved'::text) AND (p.visibility = 'public'::text)))))));


--
-- Name: likes likes: remove own like; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "likes: remove own like" ON public.likes FOR DELETE USING ((((auth.uid() IS NOT NULL) AND (liker_key = (auth.uid())::text)) OR ((auth.uid() IS NULL) AND (liker_key ~~ 'dev_%'::text))));


--
-- Name: circles members read circles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "members read circles" ON public.circles FOR SELECT USING ((public.is_circle_member(id) OR (created_by = auth.uid())));


--
-- Name: circle_members members read members; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "members read members" ON public.circle_members FOR SELECT USING (public.is_circle_member(circle_id));


--
-- Name: circle_messages members read messages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "members read messages" ON public.circle_messages FOR SELECT USING (public.is_circle_member(circle_id));


--
-- Name: circle_messages members write messages; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "members write messages" ON public.circle_messages FOR INSERT WITH CHECK (((sender_user_id = auth.uid()) AND public.is_circle_member(circle_id)));


--
-- Name: messages; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: messages messages: participants read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "messages: participants read" ON public.messages FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.conversations c
  WHERE ((c.id = messages.conversation_id) AND (public.owns_profile(c.requester_profile_id) OR public.owns_profile(c.recipient_profile_id))))));


--
-- Name: messages messages: send within your conversation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "messages: send within your conversation" ON public.messages FOR INSERT TO authenticated WITH CHECK ((public.owns_profile(sender_profile_id) AND (EXISTS ( SELECT 1
   FROM public.conversations c
  WHERE ((c.id = messages.conversation_id) AND (((c.status = 'accepted'::text) AND (public.owns_profile(c.requester_profile_id) OR public.owns_profile(c.recipient_profile_id))) OR ((c.status = 'pending'::text) AND (c.requester_profile_id = messages.sender_profile_id))))))));


--
-- Name: messages messages: sender can unsend own message; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "messages: sender can unsend own message" ON public.messages FOR DELETE TO authenticated USING (public.owns_profile(sender_profile_id));


--
-- Name: diary_moods own moods; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "own moods" ON public.diary_moods USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));


--
-- Name: albums owner manages albums; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "owner manages albums" ON public.albums USING ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.user_id = auth.uid())))) WITH CHECK ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.user_id = auth.uid()))));


--
-- Name: poll_votes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.poll_votes ENABLE ROW LEVEL SECURITY;

--
-- Name: poll_votes poll_votes: insert own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "poll_votes: insert own" ON public.poll_votes FOR INSERT WITH CHECK ((voter_user_id = auth.uid()));


--
-- Name: poll_votes poll_votes: read public profile or own profile or own vote; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "poll_votes: read public profile or own profile or own vote" ON public.poll_votes FOR SELECT USING (((voter_user_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = poll_votes.profile_id) AND ((p.visibility = 'public'::text) OR (p.user_id = auth.uid())))))));


--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles profiles: create own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "profiles: create own" ON public.profiles FOR INSERT WITH CHECK ((user_id = auth.uid()));


--
-- Name: profiles profiles: delete own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "profiles: delete own" ON public.profiles FOR DELETE USING ((user_id = auth.uid()));


--
-- Name: profiles profiles: read public or own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "profiles: read public or own" ON public.profiles FOR SELECT USING (((visibility = 'public'::text) OR (user_id = auth.uid())));


--
-- Name: profiles profiles: update own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "profiles: update own" ON public.profiles FOR UPDATE USING ((user_id = auth.uid()));


--
-- Name: album_photos public can read public albums; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "public can read public albums" ON public.album_photos FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = album_photos.profile_id) AND (p.album_public = true) AND (p.visibility = 'public'::text)))));


--
-- Name: reports; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

--
-- Name: reports reports: submit with required fields; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "reports: submit with required fields" ON public.reports FOR INSERT WITH CHECK (((reporter_key IS NOT NULL) AND (length(reporter_key) > 0) AND (reason IS NOT NULL) AND (length(reason) > 0) AND (target_id IS NOT NULL)));


--
-- Name: circles signed-in create circles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "signed-in create circles" ON public.circles FOR INSERT WITH CHECK ((created_by = auth.uid()));


--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: objects allow uploads 1cmn924_0; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "allow uploads 1cmn924_0" ON storage.objects FOR INSERT WITH CHECK ((bucket_id = 'covers'::text));


--
-- Name: objects allow uploads 1cmn924_1; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "allow uploads 1cmn924_1" ON storage.objects FOR UPDATE USING ((bucket_id = 'covers'::text));


--
-- Name: objects allow uploads 1oj01fe_0; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "allow uploads 1oj01fe_0" ON storage.objects FOR INSERT TO authenticated WITH CHECK ((bucket_id = 'avatars'::text));


--
-- Name: objects allow uploads 1oj01fe_1; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "allow uploads 1oj01fe_1" ON storage.objects FOR UPDATE TO authenticated USING ((bucket_id = 'avatars'::text));


--
-- Name: objects allow uploads 1rtzjgc_0; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "allow uploads 1rtzjgc_0" ON storage.objects FOR INSERT WITH CHECK ((bucket_id = 'entry-photos'::text));


--
-- Name: objects allow uploads 1rtzjgc_1; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "allow uploads 1rtzjgc_1" ON storage.objects FOR UPDATE USING ((bucket_id = 'entry-photos'::text));


--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_vectors; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

--
-- Name: objects event photos upload; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "event photos upload" ON storage.objects FOR INSERT WITH CHECK (((bucket_id = 'event-photos'::text) AND (auth.role() = 'authenticated'::text)));


--
-- Name: objects event share public read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "event share public read" ON storage.objects FOR SELECT USING ((bucket_id = 'event-share'::text));


--
-- Name: objects event share update; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "event share update" ON storage.objects FOR UPDATE USING (((bucket_id = 'event-share'::text) AND (auth.role() = 'authenticated'::text)));


--
-- Name: objects event share upload; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "event share upload" ON storage.objects FOR INSERT WITH CHECK (((bucket_id = 'event-share'::text) AND (auth.role() = 'authenticated'::text)));


--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: objects public read for public buckets; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "public read for public buckets" ON storage.objects FOR SELECT USING ((bucket_id = ANY (ARRAY['avatars'::text, 'covers'::text, 'entry-photos'::text, 'event-photos'::text])));


--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: objects storage: anyone uploads entry photos; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "storage: anyone uploads entry photos" ON storage.objects FOR INSERT TO authenticated, anon WITH CHECK ((bucket_id = 'entry-photos'::text));


--
-- Name: objects storage: authenticated upload avatars; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "storage: authenticated upload avatars" ON storage.objects FOR INSERT TO authenticated WITH CHECK ((bucket_id = ANY (ARRAY['avatars'::text, 'covers'::text])));


--
-- Name: objects storage: owner deletes own uploads; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "storage: owner deletes own uploads" ON storage.objects FOR DELETE TO authenticated USING ((owner = auth.uid()));


--
-- Name: objects storage: owner manages own uploads; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "storage: owner manages own uploads" ON storage.objects FOR UPDATE TO authenticated USING ((owner = auth.uid()));


--
-- Name: vector_indexes; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


--
-- PostgreSQL database dump complete
--

\unrestrict CrUbwIllYU471bJ3DuriosWA1cCOptgCZ2FzfpbePg6vuDnvfZeDc7dzRkBAZL7

