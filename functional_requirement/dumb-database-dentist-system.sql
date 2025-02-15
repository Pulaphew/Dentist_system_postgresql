PGDMP  /                     }            dentist_booking_system    17.2    17.2 �    {           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            |           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            }           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            ~           1262    16388    dentist_booking_system    DATABASE     �   CREATE DATABASE dentist_booking_system WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Thai_Thailand.874';
 &   DROP DATABASE dentist_booking_system;
                     postgres    false                        3079    24581    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                        false                       0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                             false    3                        3079    17598    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                        false            �           0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
                             false    2            �           1247    18840    booking_status    TYPE     p   CREATE TYPE public.booking_status AS ENUM (
    'confirmed',
    'process',
    'cancelled',
    'completed'
);
 !   DROP TYPE public.booking_status;
       public               postgres    false            �           1255    24661    admin_user_history()    FUNCTION     q  CREATE FUNCTION public.admin_user_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
 	BEGIN
 		INSERT INTO admin_user_log 
 		VALUES(now() , OLD.tel , OLD.email , OLD.password_hash , OLD.gender , OLD.birth_date , OLD.first_name , OLD.last_name , 
 				OLD.province , OLD.district , OLD.sub_district , OLD.street_name , OLD.zip_code);
 		RETURN NEW;
 	END;
 	$$;
 +   DROP FUNCTION public.admin_user_history();
       public               postgres    false                       1255    25035    admin_view_booking()    FUNCTION     ?  CREATE FUNCTION public.admin_view_booking() RETURNS TABLE(booking_id integer, user_tel character varying, dentist_tel character varying, service_name character varying, clinic_id integer, date_range date, time_range time with time zone, status public.booking_status)
    LANGUAGE plpgsql
    AS $$ 
BEGIN
    -- Return all booking details
    RETURN QUERY
    SELECT 
        b.booking_id, 
        b.user_tel, 
        b.dentist_tel, 
        b.service_name, 
        b.clinic_id, 
        b.date_range, 
        b.time_range, 
        b.status
    FROM booking b;
END;
$$;
 +   DROP FUNCTION public.admin_view_booking();
       public               postgres    false    1741            �           1255    24873 .   admin_view_booking(character varying, integer)    FUNCTION     �  CREATE FUNCTION public.admin_view_booking(p_admin_tel character varying, p_booking_id integer) RETURNS TABLE(booking_id integer, user_tel character varying, dentist_tel character varying, service_name character varying, clinic_id integer, date_range date, time_range time with time zone, status public.booking_status)
    LANGUAGE plpgsql
    AS $$ 
BEGIN
    -- Check if the booking exists before logging
    IF EXISTS (SELECT 1 FROM booking b WHERE b.booking_id = admin_view_booking.p_booking_id) THEN
        -- Log the admin viewing the booking
        INSERT INTO admin_booking_log (admin_tel, action_type, booking_id, details)
        VALUES (p_admin_tel, 'VIEW', p_booking_id, 'Booking viewed');

        -- Return booking details
        RETURN QUERY
        SELECT 
            b.booking_id, 
            b.user_tel, 
            b.dentist_tel, 
            b.service_name, 
            b.clinic_id, 
            b.date_range, 
            b.time_range, 
            b.status
        FROM booking b
        WHERE b.booking_id = admin_view_booking.p_booking_id;
    ELSE
        -- If booking does not exist, return an empty result
        RETURN;
    END IF;
END;
$$;
 ^   DROP FUNCTION public.admin_view_booking(p_admin_tel character varying, p_booking_id integer);
       public               postgres    false    1741                        1255    24836 *   cancel_booking(integer, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.cancel_booking(IN p_booking_id integer, IN p_user_tel character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_existing_booking INT;
BEGIN
    -- Check if the booking exists and belongs to the user
    SELECT COUNT(*) INTO v_existing_booking
    FROM booking
    WHERE booking_id = p_booking_id 
    AND user_tel = p_user_tel;

    IF v_existing_booking = 0 THEN
        RAISE EXCEPTION 'Booking not found or does not belong to the user';
    END IF;

    -- Update the booking status to "cancelled"
    UPDATE booking
    SET status = 'cancelled'
    WHERE booking_id = p_booking_id 
    AND user_tel = p_user_tel;

    RAISE NOTICE 'Booking cancelled successfully!';
END;
$$;
 `   DROP PROCEDURE public.cancel_booking(IN p_booking_id integer, IN p_user_tel character varying);
       public               postgres    false            z           1255    24835 r   edit_booking(integer, character varying, character varying, character varying, integer, date, time with time zone) 	   PROCEDURE     �  CREATE PROCEDURE public.edit_booking(IN p_booking_id integer, IN p_user_tel character varying, IN p_new_dentist_tel character varying, IN p_new_service_name character varying, IN p_new_clinic_id integer, IN p_new_booking_date date, IN p_new_booking_time time with time zone)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_existing_booking INT;
    v_dentist_available INT;
BEGIN
    -- Check if the booking exists and belongs to the user
    SELECT COUNT(*) INTO v_existing_booking
    FROM booking
    WHERE booking_id = p_booking_id AND user_tel = p_user_tel;

    IF v_existing_booking = 0 THEN
        RAISE EXCEPTION 'Booking not found or does not belong to the user';
    END IF;

    -- Check if the dentist is available at the new date and time
    SELECT COUNT(*) INTO v_dentist_available
    FROM dentist_time_slot
    WHERE tel = p_new_dentist_tel 
    AND date_time = p_new_booking_date
    AND start_time <= p_new_booking_time
    AND end_time > p_new_booking_time;

    IF v_dentist_available = 0 THEN
        RAISE EXCEPTION 'The selected dentist is not available at this time';
    END IF;

    -- Update the booking details
    UPDATE booking
    SET dentist_tel = p_new_dentist_tel,
        service_name = p_new_service_name,
        clinic_id = p_new_clinic_id,
        date_range = p_new_booking_date,
        time_range = p_new_booking_time,
        status = 'confirmed'
    WHERE booking_id = p_booking_id AND user_tel = p_user_tel;
END;
$$;
   DROP PROCEDURE public.edit_booking(IN p_booking_id integer, IN p_user_tel character varying, IN p_new_dentist_tel character varying, IN p_new_service_name character varying, IN p_new_clinic_id integer, IN p_new_booking_date date, IN p_new_booking_time time with time zone);
       public               postgres    false            2           1255    24783 A   get_available_dentist(character varying, character varying, date)    FUNCTION     �  CREATE FUNCTION public.get_available_dentist(p_patient_tel character varying, p_service_name character varying, p_booking_date date) RETURNS TABLE(dentist_tel character varying, dentist_name character varying, exp_year integer, expertise character varying, clinic_id integer, clinic_name character varying, clinic_location public.geography)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN query
	SELECT
		d.tel AS dentist_tel,
		CONCAT(u.first_name,' ',u.last_name) AS dentist_name,
		EXTRACT(YEAR FROM AGE(CURRENT_DATE,d.employment_date))
		AS exp_year,
		d.certificate_of_proficiency AS expertise,
		c.clinic_id,
		c.clinic_street AS clinic_name,
		c.gps_location AS clinic_location
	FROM dentist_account d
	JOIN user_account ON d.tel = tel
	JOIN clinic c ON d.clinic_id = c.clinic_id
	JOIN service_available sa ON sa.clinic_id = c.clinic_id
	JOIN dentist_time_slot ts ON ts.tel = d.tel
	WHERE sa.service_name = p_service_name
	AND ts.start_time::DATE = p_booking_date ;
END;
$$;
 �   DROP FUNCTION public.get_available_dentist(p_patient_tel character varying, p_service_name character varying, p_booking_date date);
       public               postgres    false    2    2    2    2    2    2    2    2            �           1255    24815 B   get_available_dentists(character varying, character varying, date)    FUNCTION     �  CREATE FUNCTION public.get_available_dentists(p_patient_tel character varying, p_service_name character varying, p_booking_date date) RETURNS TABLE(dentist_tel character varying, dentist_name character varying, exp_year numeric, expertise character varying, clinic_id integer, clinic_name character varying, clinic_location public.geography)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN query
	SELECT
		d.tel AS dentist_tel,
		CONCAT(u.first_name,' ',u.last_name)::VARCHAR AS dentist_name,
		EXTRACT(YEAR FROM AGE(CURRENT_DATE,d.employement_date))
		AS exp_year,
		d.certificate_of_proficiency AS expertise,
		c.clinic_id,
		c.clinic_street::VARCHAR AS clinic_name,
		c.gps_location AS clinic_location
	FROM dentist_account d
	JOIN user_account u ON d.tel = u.tel
	JOIN clinic c ON d.clinic_id = c.clinic_id
	JOIN service_available sa ON sa.clinic_id = c.clinic_id
	JOIN dentist_time_slot ts ON ts.tel = d.tel
	WHERE sa.service_name = p_service_name
	AND ts.date_time = p_booking_date ;
END;
$$;
 �   DROP FUNCTION public.get_available_dentists(p_patient_tel character varying, p_service_name character varying, p_booking_date date);
       public               postgres    false    2    2    2    2    2    2    2    2                       1255    24830 +   get_user_booking_details(character varying)    FUNCTION     �  CREATE FUNCTION public.get_user_booking_details(p_user_tel character varying) RETURNS TABLE(booking_id integer, user_name character varying, dentist_name character varying, service_name character varying, clinic_name character varying, booking_date date, booking_time time with time zone, status public.booking_status)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.booking_id,
        CONCAT(u.first_name, ' ', u.last_name)::VARCHAR AS user_name,
        CONCAT(d.first_name, ' ', d.last_name)::VARCHAR AS dentist_name,
        b.service_name::VARCHAR,
        c.clinic_street::VARCHAR AS clinic_name,
        b.date_range AS booking_date,
        b.time_range AS booking_time,
        b.status
    FROM booking b
    JOIN user_account u ON b.user_tel = u.tel
    JOIN user_account d ON b.dentist_tel = d.tel
    JOIN clinic c ON b.clinic_id = c.clinic_id
    WHERE b.user_tel = p_user_tel;
END;
$$;
 M   DROP FUNCTION public.get_user_booking_details(p_user_tel character varying);
       public               postgres    false    1741            W           1255    24870    log_admin_booking_action()    FUNCTION     z  CREATE FUNCTION public.log_admin_booking_action() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
BEGIN
    INSERT INTO admin_booking_log (admin_tel, action_type, booking_id, details)
    VALUES (
        current_setting('app.current_admin', true), 
        CASE 
            WHEN TG_OP = 'INSERT' THEN 'ADD_PATIENT'
            WHEN TG_OP = 'UPDATE' THEN 'EDIT'
            WHEN TG_OP = 'DELETE' THEN 'DELETE'
            ELSE 'UNKNOWN'
        END, 
        CASE 
            WHEN TG_OP = 'DELETE' THEN NULL  -- Don't insert deleted booking_id
            ELSE COALESCE(NEW.booking_id, OLD.booking_id)
        END, 
        CASE 
            WHEN TG_OP = 'INSERT' THEN 'New patient booking added'
            WHEN TG_OP = 'UPDATE' THEN 'Booking edited'
            WHEN TG_OP = 'DELETE' THEN 'Booking deleted'
            ELSE 'Unknown action'
        END
    );
    RETURN NEW;
END;
$$;
 1   DROP FUNCTION public.log_admin_booking_action();
       public               postgres    false            �           1255    24677    log_user_action()    FUNCTION     �   CREATE FUNCTION public.log_user_action() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO user_log (tel, action_type)
    VALUES (NEW.tel, TG_ARGV[0]);  
    RETURN NEW;
END;
$$;
 (   DROP FUNCTION public.log_user_action();
       public               postgres    false            �           1255    24824 n   patient_booking(character varying, character varying, character varying, date, integer, public.booking_status) 	   PROCEDURE     P  CREATE PROCEDURE public.patient_booking(IN p_patient_tel character varying, IN p_dentist_tel character varying, IN p_service_name character varying, IN p_booking_date date, IN p_clinic_id integer, IN p_status public.booking_status DEFAULT 'confirmed'::public.booking_status)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_existing_booking INT;
    v_start_time TIME WITH TIME ZONE;
BEGIN
    -- Check if the patient already has a booking on the same day
    SELECT COUNT(*) INTO v_existing_booking 
    FROM booking 
    WHERE user_tel = p_patient_tel 
    AND date_range = p_booking_date 
    AND status IN ('confirmed', 'process');

    IF v_existing_booking > 0 THEN
        RAISE EXCEPTION 'Patient already has a booking on this date';
    END IF;

    -- Get the earliest available time slot for the dentist on that date
    SELECT start_time INTO v_start_time
    FROM dentist_time_slot 
    WHERE tel = p_dentist_tel 
    AND date_time = p_booking_date
    ORDER BY start_time 
    LIMIT 1;

    IF v_start_time IS NULL THEN
        RAISE EXCEPTION 'Dentist is not available on this date';
    END IF;

    -- Insert the booking
    INSERT INTO booking (user_tel, dentist_tel, service_name, clinic_id, date_range, time_range, status)
    VALUES (p_patient_tel, p_dentist_tel, p_service_name, p_clinic_id, p_booking_date, v_start_time, p_status);
END;
$$;
 �   DROP PROCEDURE public.patient_booking(IN p_patient_tel character varying, IN p_dentist_tel character varying, IN p_service_name character varying, IN p_booking_date date, IN p_clinic_id integer, IN p_status public.booking_status);
       public               postgres    false    1741    1741                       1255    24818 �   patient_booking(character varying, character varying, character varying, character varying, character varying, date, integer, public.booking_status, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.patient_booking(IN p_patient_name character varying, IN p_patient_tel character varying, IN p_dentist_name character varying, IN p_dentist_tel character varying, IN p_service_name character varying, IN p_booking_date date, IN p_clinic_id integer, IN p_status public.booking_status DEFAULT 'confirmed'::public.booking_status, IN p_promotion_id integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_existing_booking INT;
    v_start_time TIME WITH TIME ZONE;
    v_end_time TIME WITH TIME ZONE;
BEGIN
    -- Check if the patient already has a booking on the same day
    SELECT COUNT(*) INTO v_existing_booking 
    FROM booking 
    WHERE user_tel = p_patient_tel 
    AND date_range = p_booking_date 
    AND status IN ('confirmed', 'process'); 

    IF v_existing_booking > 0 THEN
        RAISE EXCEPTION 'Patient already has a booking on this date';
    END IF;

    -- Get available time slot for the dentist on that date
    SELECT start_time, end_time INTO v_start_time, v_end_time
    FROM dentist_time_slot 
    WHERE tel = p_dentist_tel 
    AND date_time = p_booking_date
    LIMIT 1;

    IF v_start_time IS NULL OR v_end_time IS NULL THEN
        RAISE EXCEPTION 'Dentist is not available on this date';
    END IF;

    -- Insert the booking (time_range stored as TEXT)
    INSERT INTO booking (user_tel, dentist_tel, service_name, clinic_id, date_range, time_range, status, promotion_id)
    VALUES (
        p_patient_tel, 
        p_dentist_tel, 
        p_service_name, 
        p_clinic_id, 
        p_booking_date, 
		 -- Store as text: "08:00:00+07 - 12:00:00+07"
        v_start_time || ' - ' || v_end_time, 
        p_status,
        p_promotion_id
    );
END;
$$;
 L  DROP PROCEDURE public.patient_booking(IN p_patient_name character varying, IN p_patient_tel character varying, IN p_dentist_name character varying, IN p_dentist_tel character varying, IN p_service_name character varying, IN p_booking_date date, IN p_clinic_id integer, IN p_status public.booking_status, IN p_promotion_id integer);
       public               postgres    false    1741    1741            x           1255    24694    track_user_session()    FUNCTION     �   CREATE FUNCTION public.track_user_session() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO user_session (tel, action_type) VALUES (NEW.tel, TG_ARGV[0]);
    RETURN NEW;
END;
$$;
 +   DROP FUNCTION public.track_user_session();
       public               postgres    false            �           1255    24716 0   user_login(character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.user_login(p_email character varying, p_password character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_tel VARCHAR(10);
    v_password VARCHAR(255);
BEGIN
    -- Get the user's telephone number and password hash
    SELECT tel, password_hash INTO v_tel, v_password 
    FROM user_account 
    WHERE email = p_email;

    -- Check if user exists and password matches
    IF v_tel IS NULL OR v_password != p_password THEN
        RAISE EXCEPTION 'Invalid email or password';
    END IF;

    -- Insert login record
    INSERT INTO user_session (tel, action_type) 
    VALUES (v_tel, 'login');
END;
$$;
 Z   DROP FUNCTION public.user_login(p_email character varying, p_password character varying);
       public               postgres    false            �           1255    24717    user_logout(character varying)    FUNCTION     �  CREATE FUNCTION public.user_logout(p_email character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_tel VARCHAR(10);
BEGIN
    -- Get the user's telephone number from email
    SELECT tel INTO v_tel FROM user_account WHERE email = p_email;

    -- Check if user exists
    IF v_tel IS NULL THEN
        RAISE EXCEPTION 'Invalid email';
    END IF;

    -- Insert logout record
    INSERT INTO user_session (tel, action_type) 
    VALUES (v_tel, 'logout');
END;
$$;
 =   DROP FUNCTION public.user_logout(p_email character varying);
       public               postgres    false            �            1259    24837    admin_account    TABLE     �   CREATE TABLE public.admin_account (
    tel character varying(10) NOT NULL,
    role character varying(50) DEFAULT 'admin'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);
 !   DROP TABLE public.admin_account;
       public         heap r       postgres    false            �            1259    25008    admin_booking_log    TABLE     �  CREATE TABLE public.admin_booking_log (
    log_id integer NOT NULL,
    exec_time timestamp without time zone DEFAULT now(),
    admin_tel character varying(10),
    action_type character varying(20),
    booking_id integer,
    details text,
    CONSTRAINT admin_booking_log_action_type_check CHECK (((action_type)::text = ANY ((ARRAY['VIEW'::character varying, 'EDIT'::character varying, 'DELETE'::character varying, 'ADD_PATIENT'::character varying])::text[])))
);
 %   DROP TABLE public.admin_booking_log;
       public         heap r       postgres    false            �            1259    25007    admin_booking_log_log_id_seq    SEQUENCE     �   CREATE SEQUENCE public.admin_booking_log_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.admin_booking_log_log_id_seq;
       public               postgres    false    250            �           0    0    admin_booking_log_log_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.admin_booking_log_log_id_seq OWNED BY public.admin_booking_log.log_id;
          public               postgres    false    249            �            1259    25036    admin_booking_view    VIEW     <  CREATE VIEW public.admin_booking_view AS
 SELECT booking_id,
    user_tel,
    dentist_tel,
    service_name,
    clinic_id,
    date_range,
    time_range,
    status
   FROM public.admin_view_booking() admin_view_booking(booking_id, user_tel, dentist_tel, service_name, clinic_id, date_range, time_range, status);
 %   DROP VIEW public.admin_booking_view;
       public       v       postgres    false    793    1741            �           0    0    TABLE admin_booking_view    ACL     ?   GRANT SELECT ON TABLE public.admin_booking_view TO admin_role;
          public               postgres    false    251            �            1259    24656    admin_user_log    TABLE     a  CREATE TABLE public.admin_user_log (
    exec_time timestamp without time zone NOT NULL,
    tel character varying(10),
    email character varying(50) NOT NULL,
    password_hash character varying(255) NOT NULL,
    gender character varying(10) NOT NULL,
    birth_date date NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    province character varying(255) NOT NULL,
    district character varying(255) NOT NULL,
    sub_district character varying(255) NOT NULL,
    street_name character varying(255),
    zip_code character varying(5) NOT NULL
);
 "   DROP TABLE public.admin_user_log;
       public         heap r       postgres    false            �            1259    18850    booking    TABLE     �  CREATE TABLE public.booking (
    booking_id integer NOT NULL,
    user_tel character varying(10) NOT NULL,
    dentist_tel character varying(10) NOT NULL,
    service_name character varying(255) NOT NULL,
    clinic_id integer NOT NULL,
    date_range date NOT NULL,
    time_range time with time zone NOT NULL,
    status public.booking_status DEFAULT 'confirmed'::public.booking_status NOT NULL,
    promotion_id integer
);
    DROP TABLE public.booking;
       public         heap r       postgres    false    1741    1741            �           0    0    TABLE booking    ACL     B   GRANT SELECT,DELETE,UPDATE ON TABLE public.booking TO admin_role;
          public               postgres    false    241            �            1259    18849    booking_booking_id_seq    SEQUENCE     �   CREATE SEQUENCE public.booking_booking_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.booking_booking_id_seq;
       public               postgres    false    241            �           0    0    booking_booking_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.booking_booking_id_seq OWNED BY public.booking.booking_id;
          public               postgres    false    240            �           0    0    SEQUENCE booking_booking_id_seq    ACL     L   GRANT SELECT,USAGE ON SEQUENCE public.booking_booking_id_seq TO admin_role;
          public               postgres    false    240            �            1259    18686    clinic    TABLE     �  CREATE TABLE public.clinic (
    clinic_id integer NOT NULL,
    clinic_tel character varying(10) NOT NULL,
    gps_location public.geography(Point,4326) NOT NULL,
    clinic_province character varying(255) NOT NULL,
    clinic_district character varying(255) NOT NULL,
    clinic_sub_district character varying(255) NOT NULL,
    clinic_street character varying(255) NOT NULL,
    clinic_number character varying(255) NOT NULL,
    clinic_zip character varying(5) NOT NULL
);
    DROP TABLE public.clinic;
       public         heap r       postgres    false    2    2    2    2    2    2    2    2            �            1259    18685    clinic_clinic_id_seq    SEQUENCE     �   CREATE SEQUENCE public.clinic_clinic_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.clinic_clinic_id_seq;
       public               postgres    false    226            �           0    0    clinic_clinic_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.clinic_clinic_id_seq OWNED BY public.clinic.clinic_id;
          public               postgres    false    225            �            1259    18695    clinic_income    TABLE     �   CREATE TABLE public.clinic_income (
    clinic_id integer NOT NULL,
    date_income date NOT NULL,
    total_amount numeric NOT NULL,
    CONSTRAINT clinic_income_total_amount_check CHECK ((total_amount >= (0)::numeric))
);
 !   DROP TABLE public.clinic_income;
       public         heap r       postgres    false            �            1259    18694    clinic_income_clinic_id_seq    SEQUENCE     �   CREATE SEQUENCE public.clinic_income_clinic_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.clinic_income_clinic_id_seq;
       public               postgres    false    228            �           0    0    clinic_income_clinic_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.clinic_income_clinic_id_seq OWNED BY public.clinic_income.clinic_id;
          public               postgres    false    227            �            1259    18710    clinic_outcome    TABLE     �   CREATE TABLE public.clinic_outcome (
    clinic_id integer NOT NULL,
    date_outcome date NOT NULL,
    total_amount numeric NOT NULL,
    CONSTRAINT clinic_outcome_total_amount_check CHECK ((total_amount >= (0)::numeric))
);
 "   DROP TABLE public.clinic_outcome;
       public         heap r       postgres    false            �            1259    18709    clinic_outcome_clinic_id_seq    SEQUENCE     �   CREATE SEQUENCE public.clinic_outcome_clinic_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.clinic_outcome_clinic_id_seq;
       public               postgres    false    230            �           0    0    clinic_outcome_clinic_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.clinic_outcome_clinic_id_seq OWNED BY public.clinic_outcome.clinic_id;
          public               postgres    false    229            �            1259    18736    dentist_account    TABLE     w  CREATE TABLE public.dentist_account (
    tel character varying(10) NOT NULL,
    certificate_of_proficiency character varying(255) NOT NULL,
    employement_date date NOT NULL,
    previous_work character varying(255),
    clinic_id integer NOT NULL,
    base_salary numeric NOT NULL,
    CONSTRAINT dentist_account_base_salary_check CHECK ((base_salary > (0)::numeric))
);
 #   DROP TABLE public.dentist_account;
       public         heap r       postgres    false            �            1259    24802    dentist_education    TABLE     �   CREATE TABLE public.dentist_education (
    tel character varying(10) NOT NULL,
    dentist_college character varying(255) NOT NULL,
    dentist_degree character varying(255) NOT NULL,
    field character varying(255) NOT NULL
);
 %   DROP TABLE public.dentist_education;
       public         heap r       postgres    false            �            1259    24771    dentist_time_slot    TABLE     �   CREATE TABLE public.dentist_time_slot (
    tel character varying(10) NOT NULL,
    date_time date NOT NULL,
    start_time time with time zone NOT NULL,
    end_time time with time zone NOT NULL
);
 %   DROP TABLE public.dentist_time_slot;
       public         heap r       postgres    false            �            1259    18794    offer    TABLE     �   CREATE TABLE public.offer (
    service_name character varying(255) NOT NULL,
    tel character varying(10) NOT NULL,
    dentist_cut numeric NOT NULL,
    CONSTRAINT offer_dentist_cut_check CHECK ((dentist_cut >= (0)::numeric))
);
    DROP TABLE public.offer;
       public         heap r       postgres    false            �            1259    18724    patient_account    TABLE     �   CREATE TABLE public.patient_account (
    tel character varying(10) NOT NULL,
    medical_history text,
    allergies character varying(50),
    ongoing_medications character varying(50)
);
 #   DROP TABLE public.patient_account;
       public         heap r       postgres    false            �            1259    18813 	   promotion    TABLE     �   CREATE TABLE public.promotion (
    promotion_id integer NOT NULL,
    promotion_detail text NOT NULL,
    promotion_duration interval
);
    DROP TABLE public.promotion;
       public         heap r       postgres    false            �            1259    18822    promotion_info    TABLE     �   CREATE TABLE public.promotion_info (
    clinic_id integer NOT NULL,
    promotion_id integer NOT NULL,
    status boolean NOT NULL,
    promotion_limit integer,
    CONSTRAINT promotion_info_promotion_limit_check CHECK ((promotion_limit >= 1))
);
 "   DROP TABLE public.promotion_info;
       public         heap r       postgres    false            �            1259    18821    promotion_info_promotion_id_seq    SEQUENCE     �   CREATE SEQUENCE public.promotion_info_promotion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.promotion_info_promotion_id_seq;
       public               postgres    false    239            �           0    0    promotion_info_promotion_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.promotion_info_promotion_id_seq OWNED BY public.promotion_info.promotion_id;
          public               postgres    false    238            �            1259    18812    promotion_promotion_id_seq    SEQUENCE     �   CREATE SEQUENCE public.promotion_promotion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.promotion_promotion_id_seq;
       public               postgres    false    237            �           0    0    promotion_promotion_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.promotion_promotion_id_seq OWNED BY public.promotion.promotion_id;
          public               postgres    false    236            �            1259    18771    service    TABLE     �   CREATE TABLE public.service (
    service_name character varying(255) NOT NULL,
    service_price numeric NOT NULL,
    service_duration interval NOT NULL,
    CONSTRAINT service_service_price_check CHECK ((service_price > (0)::numeric))
);
    DROP TABLE public.service;
       public         heap r       postgres    false            �            1259    18779    service_available    TABLE     |   CREATE TABLE public.service_available (
    service_name character varying(255) NOT NULL,
    clinic_id integer NOT NULL
);
 %   DROP TABLE public.service_available;
       public         heap r       postgres    false            �            1259    18678    user_account    TABLE     4  CREATE TABLE public.user_account (
    tel character varying(10) NOT NULL,
    email character varying(50) NOT NULL,
    password_hash character varying(255) NOT NULL,
    gender character varying(10) NOT NULL,
    birth_date date NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    province character varying(255) NOT NULL,
    district character varying(255) NOT NULL,
    sub_district character varying(255) NOT NULL,
    street_name character varying(255),
    zip_code character varying(5) NOT NULL
);
     DROP TABLE public.user_account;
       public         heap r       postgres    false            �            1259    24831    user_booking_view    VIEW     �  CREATE VIEW public.user_booking_view AS
 SELECT booking_id,
    user_name,
    dentist_name,
    service_name,
    clinic_name,
    booking_date,
    booking_time,
    status
   FROM public.get_user_booking_details(p_user_tel => '0812345678'::character varying) get_user_booking_details(booking_id, user_name, dentist_name, service_name, clinic_name, booking_date, booking_time, status);
 $   DROP VIEW public.user_booking_view;
       public       v       postgres    false    262    1741            �            1259    24699    user_session    TABLE     |  CREATE TABLE public.user_session (
    session_id integer NOT NULL,
    tel character varying(10) NOT NULL,
    action_type character varying(10) NOT NULL,
    action_timestamp timestamp without time zone DEFAULT now(),
    CONSTRAINT user_session_action_type_check CHECK (((action_type)::text = ANY ((ARRAY['login'::character varying, 'logout'::character varying])::text[])))
);
     DROP TABLE public.user_session;
       public         heap r       postgres    false            �            1259    24698    user_session_session_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_session_session_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.user_session_session_id_seq;
       public               postgres    false    244            �           0    0    user_session_session_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.user_session_session_id_seq OWNED BY public.user_session.session_id;
          public               postgres    false    243            |           2604    25011    admin_booking_log log_id    DEFAULT     �   ALTER TABLE ONLY public.admin_booking_log ALTER COLUMN log_id SET DEFAULT nextval('public.admin_booking_log_log_id_seq'::regclass);
 G   ALTER TABLE public.admin_booking_log ALTER COLUMN log_id DROP DEFAULT;
       public               postgres    false    250    249    250            v           2604    18853    booking booking_id    DEFAULT     x   ALTER TABLE ONLY public.booking ALTER COLUMN booking_id SET DEFAULT nextval('public.booking_booking_id_seq'::regclass);
 A   ALTER TABLE public.booking ALTER COLUMN booking_id DROP DEFAULT;
       public               postgres    false    241    240    241            q           2604    18689    clinic clinic_id    DEFAULT     t   ALTER TABLE ONLY public.clinic ALTER COLUMN clinic_id SET DEFAULT nextval('public.clinic_clinic_id_seq'::regclass);
 ?   ALTER TABLE public.clinic ALTER COLUMN clinic_id DROP DEFAULT;
       public               postgres    false    225    226    226            r           2604    18698    clinic_income clinic_id    DEFAULT     �   ALTER TABLE ONLY public.clinic_income ALTER COLUMN clinic_id SET DEFAULT nextval('public.clinic_income_clinic_id_seq'::regclass);
 F   ALTER TABLE public.clinic_income ALTER COLUMN clinic_id DROP DEFAULT;
       public               postgres    false    227    228    228            s           2604    18713    clinic_outcome clinic_id    DEFAULT     �   ALTER TABLE ONLY public.clinic_outcome ALTER COLUMN clinic_id SET DEFAULT nextval('public.clinic_outcome_clinic_id_seq'::regclass);
 G   ALTER TABLE public.clinic_outcome ALTER COLUMN clinic_id DROP DEFAULT;
       public               postgres    false    229    230    230            t           2604    18816    promotion promotion_id    DEFAULT     �   ALTER TABLE ONLY public.promotion ALTER COLUMN promotion_id SET DEFAULT nextval('public.promotion_promotion_id_seq'::regclass);
 E   ALTER TABLE public.promotion ALTER COLUMN promotion_id DROP DEFAULT;
       public               postgres    false    237    236    237            u           2604    18825    promotion_info promotion_id    DEFAULT     �   ALTER TABLE ONLY public.promotion_info ALTER COLUMN promotion_id SET DEFAULT nextval('public.promotion_info_promotion_id_seq'::regclass);
 J   ALTER TABLE public.promotion_info ALTER COLUMN promotion_id DROP DEFAULT;
       public               postgres    false    238    239    239            x           2604    24702    user_session session_id    DEFAULT     �   ALTER TABLE ONLY public.user_session ALTER COLUMN session_id SET DEFAULT nextval('public.user_session_session_id_seq'::regclass);
 F   ALTER TABLE public.user_session ALTER COLUMN session_id DROP DEFAULT;
       public               postgres    false    243    244    244            v          0    24837    admin_account 
   TABLE DATA                 public               postgres    false    248   ��       x          0    25008    admin_booking_log 
   TABLE DATA                 public               postgres    false    250   ��       q          0    24656    admin_user_log 
   TABLE DATA                 public               postgres    false    242   ��       p          0    18850    booking 
   TABLE DATA                 public               postgres    false    241   ��       a          0    18686    clinic 
   TABLE DATA                 public               postgres    false    226   ��       c          0    18695    clinic_income 
   TABLE DATA                 public               postgres    false    228   d�       e          0    18710    clinic_outcome 
   TABLE DATA                 public               postgres    false    230   ��       g          0    18736    dentist_account 
   TABLE DATA                 public               postgres    false    232   ��       u          0    24802    dentist_education 
   TABLE DATA                 public               postgres    false    246   ��       t          0    24771    dentist_time_slot 
   TABLE DATA                 public               postgres    false    245   1�       j          0    18794    offer 
   TABLE DATA                 public               postgres    false    235   [�       f          0    18724    patient_account 
   TABLE DATA                 public               postgres    false    231   �       l          0    18813 	   promotion 
   TABLE DATA                 public               postgres    false    237   ��       n          0    18822    promotion_info 
   TABLE DATA                 public               postgres    false    239   ��       h          0    18771    service 
   TABLE DATA                 public               postgres    false    233   %�       i          0    18779    service_available 
   TABLE DATA                 public               postgres    false    234   ��       p          0    17920    spatial_ref_sys 
   TABLE DATA                 public               postgres    false    220   ��       _          0    18678    user_account 
   TABLE DATA                 public               postgres    false    224   ��       s          0    24699    user_session 
   TABLE DATA                 public               postgres    false    244   5�       �           0    0    admin_booking_log_log_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.admin_booking_log_log_id_seq', 12, true);
          public               postgres    false    249            �           0    0    booking_booking_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.booking_booking_id_seq', 29, true);
          public               postgres    false    240            �           0    0    clinic_clinic_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.clinic_clinic_id_seq', 6, true);
          public               postgres    false    225            �           0    0    clinic_income_clinic_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.clinic_income_clinic_id_seq', 1, false);
          public               postgres    false    227            �           0    0    clinic_outcome_clinic_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.clinic_outcome_clinic_id_seq', 1, false);
          public               postgres    false    229            �           0    0    promotion_info_promotion_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.promotion_info_promotion_id_seq', 1, false);
          public               postgres    false    238            �           0    0    promotion_promotion_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.promotion_promotion_id_seq', 4, true);
          public               postgres    false    236            �           0    0    user_session_session_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.user_session_session_id_seq', 2, true);
          public               postgres    false    243            �           2606    24843     admin_account admin_account_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.admin_account
    ADD CONSTRAINT admin_account_pkey PRIMARY KEY (tel);
 J   ALTER TABLE ONLY public.admin_account DROP CONSTRAINT admin_account_pkey;
       public                 postgres    false    248            �           2606    25017 (   admin_booking_log admin_booking_log_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.admin_booking_log
    ADD CONSTRAINT admin_booking_log_pkey PRIMARY KEY (log_id);
 R   ALTER TABLE ONLY public.admin_booking_log DROP CONSTRAINT admin_booking_log_pkey;
       public                 postgres    false    250            �           2606    18856    booking booking_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_pkey PRIMARY KEY (booking_id);
 >   ALTER TABLE ONLY public.booking DROP CONSTRAINT booking_pkey;
       public                 postgres    false    241            �           2606    18703     clinic_income clinic_income_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.clinic_income
    ADD CONSTRAINT clinic_income_pkey PRIMARY KEY (clinic_id, date_income);
 J   ALTER TABLE ONLY public.clinic_income DROP CONSTRAINT clinic_income_pkey;
       public                 postgres    false    228    228            �           2606    18718 "   clinic_outcome clinic_outcome_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY public.clinic_outcome
    ADD CONSTRAINT clinic_outcome_pkey PRIMARY KEY (clinic_id, date_outcome);
 L   ALTER TABLE ONLY public.clinic_outcome DROP CONSTRAINT clinic_outcome_pkey;
       public                 postgres    false    230    230            �           2606    18693    clinic clinic_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.clinic
    ADD CONSTRAINT clinic_pkey PRIMARY KEY (clinic_id);
 <   ALTER TABLE ONLY public.clinic DROP CONSTRAINT clinic_pkey;
       public                 postgres    false    226            �           2606    18743 $   dentist_account dentist_account_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.dentist_account
    ADD CONSTRAINT dentist_account_pkey PRIMARY KEY (tel);
 N   ALTER TABLE ONLY public.dentist_account DROP CONSTRAINT dentist_account_pkey;
       public                 postgres    false    232            �           2606    24808 (   dentist_education dentist_education_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.dentist_education
    ADD CONSTRAINT dentist_education_pkey PRIMARY KEY (tel, dentist_college, dentist_degree, field);
 R   ALTER TABLE ONLY public.dentist_education DROP CONSTRAINT dentist_education_pkey;
       public                 postgres    false    246    246    246    246            �           2606    24775 (   dentist_time_slot dentist_time_slot_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.dentist_time_slot
    ADD CONSTRAINT dentist_time_slot_pkey PRIMARY KEY (tel, date_time, start_time, end_time);
 R   ALTER TABLE ONLY public.dentist_time_slot DROP CONSTRAINT dentist_time_slot_pkey;
       public                 postgres    false    245    245    245    245            �           2606    18801    offer offer_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.offer
    ADD CONSTRAINT offer_pkey PRIMARY KEY (service_name, tel);
 :   ALTER TABLE ONLY public.offer DROP CONSTRAINT offer_pkey;
       public                 postgres    false    235    235            �           2606    18730 $   patient_account patient_account_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.patient_account
    ADD CONSTRAINT patient_account_pkey PRIMARY KEY (tel);
 N   ALTER TABLE ONLY public.patient_account DROP CONSTRAINT patient_account_pkey;
       public                 postgres    false    231            �           2606    18828 "   promotion_info promotion_info_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY public.promotion_info
    ADD CONSTRAINT promotion_info_pkey PRIMARY KEY (clinic_id, promotion_id);
 L   ALTER TABLE ONLY public.promotion_info DROP CONSTRAINT promotion_info_pkey;
       public                 postgres    false    239    239            �           2606    18820    promotion promotion_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_pkey PRIMARY KEY (promotion_id);
 B   ALTER TABLE ONLY public.promotion DROP CONSTRAINT promotion_pkey;
       public                 postgres    false    237            �           2606    18783 (   service_available service_available_pkey 
   CONSTRAINT     {   ALTER TABLE ONLY public.service_available
    ADD CONSTRAINT service_available_pkey PRIMARY KEY (service_name, clinic_id);
 R   ALTER TABLE ONLY public.service_available DROP CONSTRAINT service_available_pkey;
       public                 postgres    false    234    234            �           2606    18778    service service_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.service
    ADD CONSTRAINT service_pkey PRIMARY KEY (service_name);
 >   ALTER TABLE ONLY public.service DROP CONSTRAINT service_pkey;
       public                 postgres    false    233            �           2606    18684    user_account user_account_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT user_account_pkey PRIMARY KEY (tel);
 H   ALTER TABLE ONLY public.user_account DROP CONSTRAINT user_account_pkey;
       public                 postgres    false    224            �           2606    24706    user_session user_session_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.user_session
    ADD CONSTRAINT user_session_pkey PRIMARY KEY (session_id);
 H   ALTER TABLE ONLY public.user_session DROP CONSTRAINT user_session_pkey;
       public                 postgres    false    244            �           2620    25033 !   booking admin_add_booking_trigger    TRIGGER     �   CREATE TRIGGER admin_add_booking_trigger AFTER INSERT ON public.booking FOR EACH ROW EXECUTE FUNCTION public.log_admin_booking_action();
 :   DROP TRIGGER admin_add_booking_trigger ON public.booking;
       public               postgres    false    241    855            �           2620    25034 $   booking admin_delete_booking_trigger    TRIGGER     �   CREATE TRIGGER admin_delete_booking_trigger AFTER DELETE ON public.booking FOR EACH ROW EXECUTE FUNCTION public.log_admin_booking_action();
 =   DROP TRIGGER admin_delete_booking_trigger ON public.booking;
       public               postgres    false    855    241            �           2620    25031 "   booking admin_edit_booking_trigger    TRIGGER     �   CREATE TRIGGER admin_edit_booking_trigger AFTER UPDATE ON public.booking FOR EACH ROW EXECUTE FUNCTION public.log_admin_booking_action();
 ;   DROP TRIGGER admin_edit_booking_trigger ON public.booking;
       public               postgres    false    855    241            �           2620    24662    user_account update_user_data    TRIGGER     �   CREATE TRIGGER update_user_data BEFORE UPDATE ON public.user_account FOR EACH ROW EXECUTE FUNCTION public.admin_user_history();
 6   DROP TRIGGER update_user_data ON public.user_account;
       public               postgres    false    416    224            �           2620    24678    user_account user_login_trigger    TRIGGER     �   CREATE TRIGGER user_login_trigger AFTER UPDATE OF email ON public.user_account FOR EACH ROW WHEN ((new.email IS NOT NULL)) EXECUTE FUNCTION public.log_user_action('login');
 8   DROP TRIGGER user_login_trigger ON public.user_account;
       public               postgres    false    224    439    224    224            �           2620    24679     user_account user_logout_trigger    TRIGGER     �   CREATE TRIGGER user_logout_trigger AFTER UPDATE OF password_hash ON public.user_account FOR EACH ROW WHEN ((new.password_hash IS NOT NULL)) EXECUTE FUNCTION public.log_user_action('logout');
 9   DROP TRIGGER user_logout_trigger ON public.user_account;
       public               postgres    false    224    439    224    224            �           2606    24844 $   admin_account admin_account_tel_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.admin_account
    ADD CONSTRAINT admin_account_tel_fkey FOREIGN KEY (tel) REFERENCES public.user_account(tel) ON DELETE CASCADE;
 N   ALTER TABLE ONLY public.admin_account DROP CONSTRAINT admin_account_tel_fkey;
       public               postgres    false    5770    248    224            �           2606    25018 2   admin_booking_log admin_booking_log_admin_tel_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.admin_booking_log
    ADD CONSTRAINT admin_booking_log_admin_tel_fkey FOREIGN KEY (admin_tel) REFERENCES public.admin_account(tel) ON DELETE SET NULL;
 \   ALTER TABLE ONLY public.admin_booking_log DROP CONSTRAINT admin_booking_log_admin_tel_fkey;
       public               postgres    false    5800    250    248            �           2606    25023 3   admin_booking_log admin_booking_log_booking_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.admin_booking_log
    ADD CONSTRAINT admin_booking_log_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.booking(booking_id) ON DELETE SET NULL;
 ]   ALTER TABLE ONLY public.admin_booking_log DROP CONSTRAINT admin_booking_log_booking_id_fkey;
       public               postgres    false    5792    241    250            �           2606    18872    booking booking_clinic_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinic(clinic_id);
 H   ALTER TABLE ONLY public.booking DROP CONSTRAINT booking_clinic_id_fkey;
       public               postgres    false    226    241    5772            �           2606    18862     booking booking_dentist_tel_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_dentist_tel_fkey FOREIGN KEY (dentist_tel) REFERENCES public.dentist_account(tel);
 J   ALTER TABLE ONLY public.booking DROP CONSTRAINT booking_dentist_tel_fkey;
       public               postgres    false    5780    232    241            �           2606    18877 !   booking booking_promotion_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_promotion_id_fkey FOREIGN KEY (promotion_id) REFERENCES public.promotion(promotion_id);
 K   ALTER TABLE ONLY public.booking DROP CONSTRAINT booking_promotion_id_fkey;
       public               postgres    false    5788    241    237            �           2606    18867 !   booking booking_service_name_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_service_name_fkey FOREIGN KEY (service_name) REFERENCES public.service(service_name);
 K   ALTER TABLE ONLY public.booking DROP CONSTRAINT booking_service_name_fkey;
       public               postgres    false    233    5782    241            �           2606    18857    booking booking_user_tel_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_user_tel_fkey FOREIGN KEY (user_tel) REFERENCES public.patient_account(tel);
 G   ALTER TABLE ONLY public.booking DROP CONSTRAINT booking_user_tel_fkey;
       public               postgres    false    5778    231    241            �           2606    18704 *   clinic_income clinic_income_clinic_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.clinic_income
    ADD CONSTRAINT clinic_income_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinic(clinic_id);
 T   ALTER TABLE ONLY public.clinic_income DROP CONSTRAINT clinic_income_clinic_id_fkey;
       public               postgres    false    228    5772    226            �           2606    18719 ,   clinic_outcome clinic_outcome_clinic_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.clinic_outcome
    ADD CONSTRAINT clinic_outcome_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinic(clinic_id);
 V   ALTER TABLE ONLY public.clinic_outcome DROP CONSTRAINT clinic_outcome_clinic_id_fkey;
       public               postgres    false    226    230    5772            �           2606    18749 .   dentist_account dentist_account_clinic_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.dentist_account
    ADD CONSTRAINT dentist_account_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinic(clinic_id);
 X   ALTER TABLE ONLY public.dentist_account DROP CONSTRAINT dentist_account_clinic_id_fkey;
       public               postgres    false    5772    226    232            �           2606    18744 (   dentist_account dentist_account_tel_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.dentist_account
    ADD CONSTRAINT dentist_account_tel_fkey FOREIGN KEY (tel) REFERENCES public.user_account(tel);
 R   ALTER TABLE ONLY public.dentist_account DROP CONSTRAINT dentist_account_tel_fkey;
       public               postgres    false    232    5770    224            �           2606    24809 ,   dentist_education dentist_education_tel_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.dentist_education
    ADD CONSTRAINT dentist_education_tel_fkey FOREIGN KEY (tel) REFERENCES public.dentist_account(tel);
 V   ALTER TABLE ONLY public.dentist_education DROP CONSTRAINT dentist_education_tel_fkey;
       public               postgres    false    232    246    5780            �           2606    24776 ,   dentist_time_slot dentist_time_slot_tel_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.dentist_time_slot
    ADD CONSTRAINT dentist_time_slot_tel_fkey FOREIGN KEY (tel) REFERENCES public.dentist_account(tel);
 V   ALTER TABLE ONLY public.dentist_time_slot DROP CONSTRAINT dentist_time_slot_tel_fkey;
       public               postgres    false    232    5780    245            �           2606    18802    offer offer_service_name_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.offer
    ADD CONSTRAINT offer_service_name_fkey FOREIGN KEY (service_name) REFERENCES public.service(service_name);
 G   ALTER TABLE ONLY public.offer DROP CONSTRAINT offer_service_name_fkey;
       public               postgres    false    233    5782    235            �           2606    18807    offer offer_tel_fkey    FK CONSTRAINT     z   ALTER TABLE ONLY public.offer
    ADD CONSTRAINT offer_tel_fkey FOREIGN KEY (tel) REFERENCES public.dentist_account(tel);
 >   ALTER TABLE ONLY public.offer DROP CONSTRAINT offer_tel_fkey;
       public               postgres    false    5780    232    235            �           2606    18731 (   patient_account patient_account_tel_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.patient_account
    ADD CONSTRAINT patient_account_tel_fkey FOREIGN KEY (tel) REFERENCES public.user_account(tel);
 R   ALTER TABLE ONLY public.patient_account DROP CONSTRAINT patient_account_tel_fkey;
       public               postgres    false    231    5770    224            �           2606    18829 ,   promotion_info promotion_info_clinic_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.promotion_info
    ADD CONSTRAINT promotion_info_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinic(clinic_id);
 V   ALTER TABLE ONLY public.promotion_info DROP CONSTRAINT promotion_info_clinic_id_fkey;
       public               postgres    false    226    5772    239            �           2606    18834 /   promotion_info promotion_info_promotion_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.promotion_info
    ADD CONSTRAINT promotion_info_promotion_id_fkey FOREIGN KEY (promotion_id) REFERENCES public.promotion(promotion_id);
 Y   ALTER TABLE ONLY public.promotion_info DROP CONSTRAINT promotion_info_promotion_id_fkey;
       public               postgres    false    239    237    5788            �           2606    18789 2   service_available service_available_clinic_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_available
    ADD CONSTRAINT service_available_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinic(clinic_id);
 \   ALTER TABLE ONLY public.service_available DROP CONSTRAINT service_available_clinic_id_fkey;
       public               postgres    false    226    234    5772            �           2606    18784 5   service_available service_available_service_name_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_available
    ADD CONSTRAINT service_available_service_name_fkey FOREIGN KEY (service_name) REFERENCES public.service(service_name);
 _   ALTER TABLE ONLY public.service_available DROP CONSTRAINT service_available_service_name_fkey;
       public               postgres    false    233    5782    234            �           2606    24707 "   user_session user_session_tel_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_session
    ADD CONSTRAINT user_session_tel_fkey FOREIGN KEY (tel) REFERENCES public.user_account(tel);
 L   ALTER TABLE ONLY public.user_session DROP CONSTRAINT user_session_tel_fkey;
       public               postgres    false    5770    244    224            v   �   x���A�0�ỿ�MAe�:�NaV�� WWYs�Tl���S������᢮�
�P���w&���m̸|g�汷!��jg�F� ��ӥ��G��$�X�Z��c��ܼ���f�N��"�f1�3��PJ�?�R�N�����a���M���w���� dw      x   %  x�Փ_K�0���)�ml%�&�Z��5PRq���[�v�����MC�⣸�ܟ�%���Z�R��/��m���ݡڴ�;쪦��(�3�ov[y��8Ey�u�]��c��pc}��1<.��X��N`�����0@�(��fqL�[B1f<������A�uQ���4X�5�1�
���)�RC^�*��T�W��P؇�y4�����ӈ#�Sv�P�7�8c$�qF�����Bh��2�����~�@�tkE�Z%�g��<��Z
��
��R���w����̯p����>�      q   
   x���          p     x�͐�N�0��<�mmE�Ӓ&T
D����9Įl���n�;�����_.6��rQ������Z51M尋�A�ȺC��I�T�c�#Er�7���Ԫ����w��v��agt�i��	<߬�V�,�[$�b6�L��~B��F��vo`Ӣ��}�8��)�ӄ0�]1��KC�Z���	�
�Bܭ�e	���|���u��/i�vb��(��a��f�����v��?$�ڀ�m!�� -i�[      a   c  x��Kk�@�����SA��<�+'��PM��v)c:h�h����fT҅.\Z:sι�0�q�x����v�|�ӻt��B�3���ٖ٦��a�٦��ۢ����o�H�f�Їr�Ӳ���a�ϲ�XT�<�7�S���>��X=h#!�q�q��IV��E0��e?B�#�\JC�S�$$�䔡y%T�\o��>�rU��
�&Z�F�*W�xa�E�Q�Rlw!��Ob9��)	��t����P$��g��)Ė\�ㇾG	C��X�Jd�ى���5G)mҨ��d\��\+���uP�xT���g��^�'x�Z�"s�t+ �=v���V�7�2��8(��.�h�����ɽ�      c   �   x���v
Q���W((M��L�K����L���K��MUЀqStRKR��:
%�%�9���y%�
a�>���
�:
�FF��F���:
�@��������������������n��Ie����77�k? �jL{      e   �   x���v
Q���W((M��L�K����L��/-I��MUЀ�3StRKRa:
%�%�9���y%�
a�>���
�:
�FF��F���:
F@��������������������n��Iu������ {Ns      g   A  x����n�0 �;_� ��t@A;!`�k��۵
�k!��tS�~Ap贩�5�D�#?�Q�n^3��,����wJK��sUI����ҁ8���C^j������Ƴ+���A��Te�/�?\� I<�=3�&����ܽmR��qp?������A#�$5�#������`:�?i��{��ؿ�!$1���q�2X''�Soz�?�M�J�3Z�m̴DNL��:�s�t&ڞT�\�����2Ʊ�n�¦�bV���}����@Λ�-J�L��Ƹ��6�n(?��J�/`���~#&�°}Y{�o|�3      u   ;  x�͓OK1���skE�j��I�Z�v7��z�1����d����lA\E=H=�{0�_�L�����$�R=i�'����?��$z�:�t>ti���>E��Po������r=K��>=�_\��q��IQi�����X~%W������:�����!�\Nn��LΆȱ�wn��.�&"�]F����E����%Q�Ic���=�KO�4^[��rK���M����K��%�b��M�|a�sdy,����b�#�,�U�A��C�&�*l������P4��ܠ,H��9rA::Ӹɴ(B��on^�F}��z}���      t     x�ՕMO�0@���u�G�pBc@�)�X�:�C�2��mB��)���r�}zz�cmV���i-�}<��y綾���/n=�&�t��F�y�_��v�h
�Wˇ�
&9�B�����Ռ����/۽3��)�����57K=o�ڂ��6����kJ.CJE��p��\��\6d\F(yR��(1	�H�%F:�BJI��$���)1	�G��]����K�����%1JL�%sY'q�#��]"5���x����&2�*��$)~=$]b.�d�Y�	��S      j   �   x���1�@���_�m*H��MaZry�(��vpj��� pi��wz^B��ȁP��>\��gmYbF��C�6Y�(��(ѫ4�	�m|
0�苶ն���U�=ut{��_��c��	�B�h��Îe�@�~���8���F4�[w&��_=R~X�z�YM{/�q2      f   �   x��αN�0��=Oq��R��@���*�Z�lDS�ȸV���7����o+��ϯ3|J﷯����=��m&Ϲ������C�O$gC�A)K��`C�q �*B<�ߟL�i��u{��1+�բ��Y�ޭ�
���$�R�|����(��҇���hl�~jզã�6�N��B���7wg���"β FS7���/oQ� �foA      l   �   x���v
Q���W((M��L�+(���/���SЀ3�3St��Ԓ���ҢDCS!��'�5XA�PGA�/�\�9'3/3Y�3V���+V�T��Sp��s��tQp�W�����s���c���;�&�)�)��"�{A���.. ?8\�      n   �   x���v
Q���W((M��L�+(���/��ϋ��K�W�H����L��L�Q@��KKJ��Es2s3K4�}B]�4u����4�00�T��Sp��s��tQp�W�����s���+�t�`�0��.. ��V�      h   �   x���O�0��i 1+#�e5�r�1����9��}���S�^�����$w0a���dXu�� �}Nυ]���wMŵ,��>�����N�tY�+ԍ���]��`#/@Ȝ= J`I�:�K+
��-&����w�x��kQ(���G�ͬÌ{X�	a0I&x!���L��f-����Ų����8      i   �   x���A�0��⽩ A];��d�\u�9_�9cN�o_];������3^eG	�K��1�W#��4�jVdTc��dU�	hC�tMm�]y�*����Ѓ�qr�G��:�!</Y*a/�y`���O�D|�ڠ�d�e̜��`�����;��o2���^      p   
   x���          _   e  x��Q��0���y�nF� ����W��y*ިm�RI��I����7q���^��3YX~���$\=-�h�h_l2�IDq��Н"Y����A�#I��L{hKXBDm�Pi��"=��
�"����^�e�V	�J�X��,6�E�!���t�<!�������
�u�o;�7���.�|ޚ��1�͒��$Q]�m֞u�1�����L�hҍX�T�F|��񝑣T�P3H�x��STf�8��{�!-���d�F�
�I��Sg��0.�n����c��g��oa�rpI�o�啧LrVA��(�-�
�#�B���R 9e5���vnj�40���>��6!qz�ױm�xM�ز�.���DM	��v#�_X�TZ��TL)�XBh��IeZ׽�N�oN��J�V�?z׵ܒ�J7r*/ܻl�wU�4�U�u���xw�`�ш��wZ��U�[?�׶6�&�b�
��y���ZN�2�&��o���s_
xGS �ڵ�m5\�A���)[�zז�9ʪ���$_�oi�#��v.?h�3ГY}��ni�@*	���üe�����o����.���h���h�'�p='�[����t� ��f8      s   �   x����
�@��Oqv*���4�Va�����Q6Ā7�q�ۗ��v���1^l%0^
�k��`��q�Rkյ�|�nY{p�������FjsizN���)�!ؘ:�y��﫻�jǠH#��!����Q�����	��YV�Z ����b�r�)g7�ih�1���Z��!b�     