PGDMP                         }            Dentist_Company     12.22 (Debian 12.22-1.pgdg120+1)    12.22 _    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    24577    Dentist_Company    DATABASE     �   CREATE DATABASE "Dentist_Company" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';
 !   DROP DATABASE "Dentist_Company";
                admin    false                        3079    24578    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                   false            �           0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
                        false    2            �           1247    25842    booking_status    TYPE     p   CREATE TYPE public.booking_status AS ENUM (
    'confirmed',
    'process',
    'cancelled',
    'completed'
);
 !   DROP TYPE public.booking_status;
       public          admin    false            �           1255    25892    admin_user_history()    FUNCTION     q  CREATE FUNCTION public.admin_user_history() RETURNS trigger
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
       public          admin    false            �            1259    25886    admin_user_log    TABLE     a  CREATE TABLE public.admin_user_log (
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
       public         heap    admin    false            �            1259    25853    booking    TABLE     �  CREATE TABLE public.booking (
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
       public         heap    admin    false    1492    1492            �            1259    25851    booking_booking_id_seq    SEQUENCE     �   CREATE SEQUENCE public.booking_booking_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.booking_booking_id_seq;
       public          admin    false    227            �           0    0    booking_booking_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.booking_booking_id_seq OWNED BY public.booking.booking_id;
          public          admin    false    226            �            1259    25675    clinic    TABLE     �  CREATE TABLE public.clinic (
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
       public         heap    admin    false    2    2    2    2    2    2    2    2            �            1259    25673    clinic_clinic_id_seq    SEQUENCE     �   CREATE SEQUENCE public.clinic_clinic_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.clinic_clinic_id_seq;
       public          admin    false    210            �           0    0    clinic_clinic_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.clinic_clinic_id_seq OWNED BY public.clinic.clinic_id;
          public          admin    false    209            �            1259    25686    clinic_income    TABLE     �   CREATE TABLE public.clinic_income (
    clinic_id integer NOT NULL,
    date_income date NOT NULL,
    total_amount numeric NOT NULL,
    CONSTRAINT clinic_income_total_amount_check CHECK ((total_amount >= (0)::numeric))
);
 !   DROP TABLE public.clinic_income;
       public         heap    admin    false            �            1259    25684    clinic_income_clinic_id_seq    SEQUENCE     �   CREATE SEQUENCE public.clinic_income_clinic_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.clinic_income_clinic_id_seq;
       public          admin    false    212            �           0    0    clinic_income_clinic_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.clinic_income_clinic_id_seq OWNED BY public.clinic_income.clinic_id;
          public          admin    false    211            �            1259    25703    clinic_outcome    TABLE     �   CREATE TABLE public.clinic_outcome (
    clinic_id integer NOT NULL,
    date_outcome date NOT NULL,
    total_amount numeric NOT NULL,
    CONSTRAINT clinic_outcome_total_amount_check CHECK ((total_amount >= (0)::numeric))
);
 "   DROP TABLE public.clinic_outcome;
       public         heap    admin    false            �            1259    25701    clinic_outcome_clinic_id_seq    SEQUENCE     �   CREATE SEQUENCE public.clinic_outcome_clinic_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.clinic_outcome_clinic_id_seq;
       public          admin    false    214            �           0    0    clinic_outcome_clinic_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.clinic_outcome_clinic_id_seq OWNED BY public.clinic_outcome.clinic_id;
          public          admin    false    213            �            1259    25731    dentist_account    TABLE     w  CREATE TABLE public.dentist_account (
    tel character varying(10) NOT NULL,
    certificate_of_proficiency character varying(255) NOT NULL,
    employement_date date NOT NULL,
    previous_work character varying(255),
    clinic_id integer NOT NULL,
    base_salary numeric NOT NULL,
    CONSTRAINT dentist_account_base_salary_check CHECK ((base_salary > (0)::numeric))
);
 #   DROP TABLE public.dentist_account;
       public         heap    admin    false            �            1259    25760    dentist_education    TABLE     �   CREATE TABLE public.dentist_education (
    tel character varying(10) NOT NULL,
    dentist_college character varying(255) NOT NULL,
    dentist_degree character varying(255) NOT NULL,
    field character varying(255) NOT NULL
);
 %   DROP TABLE public.dentist_education;
       public         heap    admin    false            �            1259    25750    dentist_time_slot    TABLE     �   CREATE TABLE public.dentist_time_slot (
    tel character varying(10) NOT NULL,
    start_time time with time zone NOT NULL,
    end_time time with time zone NOT NULL
);
 %   DROP TABLE public.dentist_time_slot;
       public         heap    admin    false            �            1259    25792    offer    TABLE     �   CREATE TABLE public.offer (
    service_name character varying(255) NOT NULL,
    tel character varying(10) NOT NULL,
    dentist_cut numeric NOT NULL,
    CONSTRAINT offer_dentist_cut_check CHECK ((dentist_cut >= (0)::numeric))
);
    DROP TABLE public.offer;
       public         heap    admin    false            �            1259    25718    patient_account    TABLE     �   CREATE TABLE public.patient_account (
    tel character varying(10) NOT NULL,
    medical_history text,
    allergies character varying(50),
    ongoing_medications character varying(50)
);
 #   DROP TABLE public.patient_account;
       public         heap    admin    false            �            1259    25813 	   promotion    TABLE     �   CREATE TABLE public.promotion (
    promotion_id integer NOT NULL,
    promotion_detail text NOT NULL,
    promotion_duration interval
);
    DROP TABLE public.promotion;
       public         heap    admin    false            �            1259    25824    promotion_info    TABLE     �   CREATE TABLE public.promotion_info (
    clinic_id integer NOT NULL,
    promotion_id integer NOT NULL,
    status boolean NOT NULL,
    promotion_limit integer,
    CONSTRAINT promotion_info_promotion_limit_check CHECK ((promotion_limit >= 1))
);
 "   DROP TABLE public.promotion_info;
       public         heap    admin    false            �            1259    25822    promotion_info_promotion_id_seq    SEQUENCE     �   CREATE SEQUENCE public.promotion_info_promotion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.promotion_info_promotion_id_seq;
       public          admin    false    225            �           0    0    promotion_info_promotion_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.promotion_info_promotion_id_seq OWNED BY public.promotion_info.promotion_id;
          public          admin    false    224            �            1259    25811    promotion_promotion_id_seq    SEQUENCE     �   CREATE SEQUENCE public.promotion_promotion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.promotion_promotion_id_seq;
       public          admin    false    223            �           0    0    promotion_promotion_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.promotion_promotion_id_seq OWNED BY public.promotion.promotion_id;
          public          admin    false    222            �            1259    25768    service    TABLE     �   CREATE TABLE public.service (
    service_name character varying(255) NOT NULL,
    service_price numeric NOT NULL,
    service_duration interval NOT NULL,
    CONSTRAINT service_service_price_check CHECK ((service_price > (0)::numeric))
);
    DROP TABLE public.service;
       public         heap    admin    false            �            1259    25777    service_available    TABLE     |   CREATE TABLE public.service_available (
    service_name character varying(255) NOT NULL,
    clinic_id integer NOT NULL
);
 %   DROP TABLE public.service_available;
       public         heap    admin    false            �            1259    25665    user_account    TABLE     4  CREATE TABLE public.user_account (
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
       public         heap    admin    false                       2604    25856    booking booking_id    DEFAULT     x   ALTER TABLE ONLY public.booking ALTER COLUMN booking_id SET DEFAULT nextval('public.booking_booking_id_seq'::regclass);
 A   ALTER TABLE public.booking ALTER COLUMN booking_id DROP DEFAULT;
       public          admin    false    226    227    227                       2604    25678    clinic clinic_id    DEFAULT     t   ALTER TABLE ONLY public.clinic ALTER COLUMN clinic_id SET DEFAULT nextval('public.clinic_clinic_id_seq'::regclass);
 ?   ALTER TABLE public.clinic ALTER COLUMN clinic_id DROP DEFAULT;
       public          admin    false    209    210    210                       2604    25689    clinic_income clinic_id    DEFAULT     �   ALTER TABLE ONLY public.clinic_income ALTER COLUMN clinic_id SET DEFAULT nextval('public.clinic_income_clinic_id_seq'::regclass);
 F   ALTER TABLE public.clinic_income ALTER COLUMN clinic_id DROP DEFAULT;
       public          admin    false    211    212    212                       2604    25706    clinic_outcome clinic_id    DEFAULT     �   ALTER TABLE ONLY public.clinic_outcome ALTER COLUMN clinic_id SET DEFAULT nextval('public.clinic_outcome_clinic_id_seq'::regclass);
 G   ALTER TABLE public.clinic_outcome ALTER COLUMN clinic_id DROP DEFAULT;
       public          admin    false    213    214    214                       2604    25816    promotion promotion_id    DEFAULT     �   ALTER TABLE ONLY public.promotion ALTER COLUMN promotion_id SET DEFAULT nextval('public.promotion_promotion_id_seq'::regclass);
 E   ALTER TABLE public.promotion ALTER COLUMN promotion_id DROP DEFAULT;
       public          admin    false    223    222    223                       2604    25827    promotion_info promotion_id    DEFAULT     �   ALTER TABLE ONLY public.promotion_info ALTER COLUMN promotion_id SET DEFAULT nextval('public.promotion_info_promotion_id_seq'::regclass);
 J   ALTER TABLE public.promotion_info ALTER COLUMN promotion_id DROP DEFAULT;
       public          admin    false    224    225    225            �          0    25886    admin_user_log 
   TABLE DATA                 public          admin    false    228   hx       �          0    25853    booking 
   TABLE DATA                 public          admin    false    227   �y       �          0    25675    clinic 
   TABLE DATA                 public          admin    false    210   �y       �          0    25686    clinic_income 
   TABLE DATA                 public          admin    false    212   {       �          0    25703    clinic_outcome 
   TABLE DATA                 public          admin    false    214   {       �          0    25731    dentist_account 
   TABLE DATA                 public          admin    false    216   5{       �          0    25760    dentist_education 
   TABLE DATA                 public          admin    false    218   �|       �          0    25750    dentist_time_slot 
   TABLE DATA                 public          admin    false    217   �|       �          0    25792    offer 
   TABLE DATA                 public          admin    false    221   �|       �          0    25718    patient_account 
   TABLE DATA                 public          admin    false    215   �|       �          0    25813 	   promotion 
   TABLE DATA                 public          admin    false    223   �}       �          0    25824    promotion_info 
   TABLE DATA                 public          admin    false    225   a~       �          0    25768    service 
   TABLE DATA                 public          admin    false    219   {~       �          0    25777    service_available 
   TABLE DATA                 public          admin    false    220   L                 0    24899    spatial_ref_sys 
   TABLE DATA                 public          admin    false    204   f       �          0    25665    user_account 
   TABLE DATA                 public          admin    false    208   �       �           0    0    booking_booking_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.booking_booking_id_seq', 1, false);
          public          admin    false    226            �           0    0    clinic_clinic_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.clinic_clinic_id_seq', 2, true);
          public          admin    false    209            �           0    0    clinic_income_clinic_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.clinic_income_clinic_id_seq', 1, false);
          public          admin    false    211            �           0    0    clinic_outcome_clinic_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.clinic_outcome_clinic_id_seq', 1, false);
          public          admin    false    213            �           0    0    promotion_info_promotion_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.promotion_info_promotion_id_seq', 1, false);
          public          admin    false    224            �           0    0    promotion_promotion_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.promotion_promotion_id_seq', 2, true);
          public          admin    false    222            ;           2606    25859    booking booking_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_pkey PRIMARY KEY (booking_id);
 >   ALTER TABLE ONLY public.booking DROP CONSTRAINT booking_pkey;
       public            admin    false    227            %           2606    25695     clinic_income clinic_income_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.clinic_income
    ADD CONSTRAINT clinic_income_pkey PRIMARY KEY (clinic_id, date_income);
 J   ALTER TABLE ONLY public.clinic_income DROP CONSTRAINT clinic_income_pkey;
       public            admin    false    212    212            '           2606    25712 "   clinic_outcome clinic_outcome_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY public.clinic_outcome
    ADD CONSTRAINT clinic_outcome_pkey PRIMARY KEY (clinic_id, date_outcome);
 L   ALTER TABLE ONLY public.clinic_outcome DROP CONSTRAINT clinic_outcome_pkey;
       public            admin    false    214    214            #           2606    25683    clinic clinic_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.clinic
    ADD CONSTRAINT clinic_pkey PRIMARY KEY (clinic_id);
 <   ALTER TABLE ONLY public.clinic DROP CONSTRAINT clinic_pkey;
       public            admin    false    210            +           2606    25739 $   dentist_account dentist_account_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.dentist_account
    ADD CONSTRAINT dentist_account_pkey PRIMARY KEY (tel);
 N   ALTER TABLE ONLY public.dentist_account DROP CONSTRAINT dentist_account_pkey;
       public            admin    false    216            /           2606    25767 (   dentist_education dentist_education_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.dentist_education
    ADD CONSTRAINT dentist_education_pkey PRIMARY KEY (tel, dentist_college, dentist_degree, field);
 R   ALTER TABLE ONLY public.dentist_education DROP CONSTRAINT dentist_education_pkey;
       public            admin    false    218    218    218    218            -           2606    25754 (   dentist_time_slot dentist_time_slot_pkey 
   CONSTRAINT     }   ALTER TABLE ONLY public.dentist_time_slot
    ADD CONSTRAINT dentist_time_slot_pkey PRIMARY KEY (tel, start_time, end_time);
 R   ALTER TABLE ONLY public.dentist_time_slot DROP CONSTRAINT dentist_time_slot_pkey;
       public            admin    false    217    217    217            5           2606    25800    offer offer_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.offer
    ADD CONSTRAINT offer_pkey PRIMARY KEY (service_name, tel);
 :   ALTER TABLE ONLY public.offer DROP CONSTRAINT offer_pkey;
       public            admin    false    221    221            )           2606    25725 $   patient_account patient_account_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.patient_account
    ADD CONSTRAINT patient_account_pkey PRIMARY KEY (tel);
 N   ALTER TABLE ONLY public.patient_account DROP CONSTRAINT patient_account_pkey;
       public            admin    false    215            9           2606    25830 "   promotion_info promotion_info_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY public.promotion_info
    ADD CONSTRAINT promotion_info_pkey PRIMARY KEY (clinic_id, promotion_id);
 L   ALTER TABLE ONLY public.promotion_info DROP CONSTRAINT promotion_info_pkey;
       public            admin    false    225    225            7           2606    25821    promotion promotion_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_pkey PRIMARY KEY (promotion_id);
 B   ALTER TABLE ONLY public.promotion DROP CONSTRAINT promotion_pkey;
       public            admin    false    223            3           2606    25781 (   service_available service_available_pkey 
   CONSTRAINT     {   ALTER TABLE ONLY public.service_available
    ADD CONSTRAINT service_available_pkey PRIMARY KEY (service_name, clinic_id);
 R   ALTER TABLE ONLY public.service_available DROP CONSTRAINT service_available_pkey;
       public            admin    false    220    220            1           2606    25776    service service_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.service
    ADD CONSTRAINT service_pkey PRIMARY KEY (service_name);
 >   ALTER TABLE ONLY public.service DROP CONSTRAINT service_pkey;
       public            admin    false    219            !           2606    25672    user_account user_account_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT user_account_pkey PRIMARY KEY (tel);
 H   ALTER TABLE ONLY public.user_account DROP CONSTRAINT user_account_pkey;
       public            admin    false    208            M           2620    25893    user_account update_user_data    TRIGGER     �   CREATE TRIGGER update_user_data BEFORE UPDATE ON public.user_account FOR EACH ROW EXECUTE FUNCTION public.admin_user_history();
 6   DROP TRIGGER update_user_data ON public.user_account;
       public          admin    false    994    208            K           2606    25875    booking booking_clinic_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinic(clinic_id);
 H   ALTER TABLE ONLY public.booking DROP CONSTRAINT booking_clinic_id_fkey;
       public          admin    false    210    227    3875            I           2606    25865     booking booking_dentist_tel_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_dentist_tel_fkey FOREIGN KEY (dentist_tel) REFERENCES public.dentist_account(tel);
 J   ALTER TABLE ONLY public.booking DROP CONSTRAINT booking_dentist_tel_fkey;
       public          admin    false    216    3883    227            L           2606    25880 !   booking booking_promotion_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_promotion_id_fkey FOREIGN KEY (promotion_id) REFERENCES public.promotion(promotion_id);
 K   ALTER TABLE ONLY public.booking DROP CONSTRAINT booking_promotion_id_fkey;
       public          admin    false    3895    223    227            J           2606    25870 !   booking booking_service_name_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_service_name_fkey FOREIGN KEY (service_name) REFERENCES public.service(service_name);
 K   ALTER TABLE ONLY public.booking DROP CONSTRAINT booking_service_name_fkey;
       public          admin    false    219    3889    227            H           2606    25860    booking booking_user_tel_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking
    ADD CONSTRAINT booking_user_tel_fkey FOREIGN KEY (user_tel) REFERENCES public.patient_account(tel);
 G   ALTER TABLE ONLY public.booking DROP CONSTRAINT booking_user_tel_fkey;
       public          admin    false    227    3881    215            <           2606    25696 *   clinic_income clinic_income_clinic_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.clinic_income
    ADD CONSTRAINT clinic_income_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinic(clinic_id);
 T   ALTER TABLE ONLY public.clinic_income DROP CONSTRAINT clinic_income_clinic_id_fkey;
       public          admin    false    212    3875    210            =           2606    25713 ,   clinic_outcome clinic_outcome_clinic_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.clinic_outcome
    ADD CONSTRAINT clinic_outcome_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinic(clinic_id);
 V   ALTER TABLE ONLY public.clinic_outcome DROP CONSTRAINT clinic_outcome_clinic_id_fkey;
       public          admin    false    3875    210    214            @           2606    25745 .   dentist_account dentist_account_clinic_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.dentist_account
    ADD CONSTRAINT dentist_account_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinic(clinic_id);
 X   ALTER TABLE ONLY public.dentist_account DROP CONSTRAINT dentist_account_clinic_id_fkey;
       public          admin    false    216    3875    210            ?           2606    25740 (   dentist_account dentist_account_tel_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.dentist_account
    ADD CONSTRAINT dentist_account_tel_fkey FOREIGN KEY (tel) REFERENCES public.user_account(tel);
 R   ALTER TABLE ONLY public.dentist_account DROP CONSTRAINT dentist_account_tel_fkey;
       public          admin    false    216    208    3873            A           2606    25755 ,   dentist_time_slot dentist_time_slot_tel_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.dentist_time_slot
    ADD CONSTRAINT dentist_time_slot_tel_fkey FOREIGN KEY (tel) REFERENCES public.dentist_account(tel);
 V   ALTER TABLE ONLY public.dentist_time_slot DROP CONSTRAINT dentist_time_slot_tel_fkey;
       public          admin    false    217    3883    216            D           2606    25801    offer offer_service_name_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.offer
    ADD CONSTRAINT offer_service_name_fkey FOREIGN KEY (service_name) REFERENCES public.service(service_name);
 G   ALTER TABLE ONLY public.offer DROP CONSTRAINT offer_service_name_fkey;
       public          admin    false    3889    219    221            E           2606    25806    offer offer_tel_fkey    FK CONSTRAINT     z   ALTER TABLE ONLY public.offer
    ADD CONSTRAINT offer_tel_fkey FOREIGN KEY (tel) REFERENCES public.dentist_account(tel);
 >   ALTER TABLE ONLY public.offer DROP CONSTRAINT offer_tel_fkey;
       public          admin    false    221    3883    216            >           2606    25726 (   patient_account patient_account_tel_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.patient_account
    ADD CONSTRAINT patient_account_tel_fkey FOREIGN KEY (tel) REFERENCES public.user_account(tel);
 R   ALTER TABLE ONLY public.patient_account DROP CONSTRAINT patient_account_tel_fkey;
       public          admin    false    208    215    3873            F           2606    25831 ,   promotion_info promotion_info_clinic_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.promotion_info
    ADD CONSTRAINT promotion_info_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinic(clinic_id);
 V   ALTER TABLE ONLY public.promotion_info DROP CONSTRAINT promotion_info_clinic_id_fkey;
       public          admin    false    210    3875    225            G           2606    25836 /   promotion_info promotion_info_promotion_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.promotion_info
    ADD CONSTRAINT promotion_info_promotion_id_fkey FOREIGN KEY (promotion_id) REFERENCES public.promotion(promotion_id);
 Y   ALTER TABLE ONLY public.promotion_info DROP CONSTRAINT promotion_info_promotion_id_fkey;
       public          admin    false    225    3895    223            C           2606    25787 2   service_available service_available_clinic_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_available
    ADD CONSTRAINT service_available_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinic(clinic_id);
 \   ALTER TABLE ONLY public.service_available DROP CONSTRAINT service_available_clinic_id_fkey;
       public          admin    false    210    220    3875            B           2606    25782 5   service_available service_available_service_name_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_available
    ADD CONSTRAINT service_available_service_name_fkey FOREIGN KEY (service_name) REFERENCES public.service(service_name);
 _   ALTER TABLE ONLY public.service_available DROP CONSTRAINT service_available_service_name_fkey;
       public          admin    false    219    220    3889            �   (  x�MN]O�@|��7���!���V%V0-��e˝p)�8������43;������.�$�3�C��E�4zixݖ0�߲�V5�+kd�j����5�W�W>�Ri|8(c+.Ў�ez�5��ϴ3����Ȅ�Q������Fʿ���x�
9�����fS��$�([.�1a��P]ė���)aB��ե�Eu]��âm��(����XK�t� e%N��E���4hUgP��nQ������jh�O�^����v�TM��x3�RXg��6Y�p�A��I�p5�L~��xy      �   
   x���          �   7  x�ՐAo�0�����&f)m�Ne�iY�mGS��FZ�׏�a��ڤ��|M��I���3Hx�B��
�?�2*��5�j?�[md1�Cu�e.U�����er�����*o�����6���hZ��u�ߪ��|��60r&0D�N=6��t�[�饠x�"���|��|x݉�b�Pd_�N����[��X�(�m����zo����4C�!Ly�L��x�-��8H��El�����Oc7F^���94B�F~�(r��bxT�GX	ei�ʎl�Jka�Bju��h�<�y��}k������`����      �   
   x���          �   
   x���          �   W  x���OO�0 �;��݀d�m��'�Kp3nzmJ����.m�ٷ�d�̨xu=����嵍�t��Ag	�Npv����XBS��г(<`�-�sF-�'�V.�(Y��
�*<��$w<(4�qU����,���܃5HTW}xYl��)���$�Ɠ�l����h{T�re0s�C?�p���J1���F�}HbX&��6Zf�J N��(��v���6u��sj5g��k��w��\���Lƭ@M�Z\���k��e54���ΰ)]*sB{��i��SᲗ���9k:7(QSq��0�e����َ{;���8bZ��̐�i��Z8mE�)���wbJ�Z�ǿ��| ���O      �   
   x���          �   
   x���          �   
   x���          �   �   x��αN�0��=Oq��R��@���*�Z�lDS�ȸV���7����o+��ϯ3|J﷯����=��m&Ϲ������C�O$gC�A)K��`C�q �*B<�ߟL�i��u{��1+�բ��Y�ޭ�
���$�R�|����(��҇���hl�~jզã�6�N��B���7wg���"β FS7���/oQ� �foA      �   �   x���v
Q���W((M��L�+(���/���SЀ3�3St��Ԓ���ҢDCS!��'�5XA�PGA�/�\�9'3/3Y�3V���+V�T��Sp��s��tQp�W�����s���c���;�&�)�)��"�{A���.. ?8\�      �   
   x���          �   �   x���O�0��i 1+#�e5�r�1����9��}���S�^�����$w0a���dXu�� �}Nυ]���wMŵ,��>�����N�tY�+ԍ���]��`#/@Ȝ= J`I�:�K+
��-&����w�x��kQ(���G�ͬÌ{X�	a0I&x!���L��f-����Ų����8      �   
   x���             
   x���          �   �  x�ݖ�o�0���+|K+�ʆ��vY�k��TI��x���m��l�D	�8�2N~��C����M���|�&�r�6����e��L!�D]it�i1D�n�(�2O(6D/�ʩ����9h:D��T:��4q�p#�+�2�\i�3=D�^�G����M���^�׏���|�#�W�h�h �Q��Ŷu���nٞh��{$v��4^P�8=<�Hh�k[n�E�5���^�bm���4�#�	�9+8j�	�1\�Y�nf����f�ng(�-&��Og���i|�t%V�D}��t�E�=7���.����Dn��'�MUMMf���%Thɫ=���!�{u�c�k���HI�[�A�-������-o0K��Zj}�����C��9��&h�;�A?Ў[hs#2�{ն����������</
*�t�P����E�K�~�lɍli��v��/�hS�@�W�����h��(���=Z��p�{�6j��mN�N��)�[�uO�7[|�t=�zM�)S�
bg�F�|gQ@�~ �[HU���D:�0X��p�$���`GkC4e�Y������`ޱ���~/蚋�龿u[�/�!���7'hɡ�612Ek;�)���YQ;uS�E�e2�eLZ�+���9��)k������1[×8�m6�T��fj�>�gg \2��     