CLASS /apmg/cl_purl DEFINITION PUBLIC FINAL CREATE PUBLIC.

************************************************************************
* Package-URL
*
* Implementation of Package-URL (purl)
* https://github.com/package-url/purl-spec
*
* Copyright 2025 apm.to Inc. <https://apm.to>
* SPDX-License-Identifier: MIT
************************************************************************
  PUBLIC SECTION.

    CONSTANTS c_version TYPE string VALUE '1.0.0' ##NEEDED.

    TYPES:
      "! key=value
      BEGIN OF ty_qualifier,
        key   TYPE string,
        value TYPE string,
      END OF ty_qualifier,
      ty_qualifiers TYPE STANDARD TABLE OF ty_qualifier WITH KEY key,
      "! scheme:type/namespace/name@version?qualifiers#subpath
      BEGIN OF ty_purl_components,
        scheme     TYPE string,
        type       TYPE string,
        namespace  TYPE string,
        name       TYPE string,
        version    TYPE string,
        qualifiers TYPE ty_qualifiers,
        subpath    TYPE string,
      END OF ty_purl_components.

    DATA components TYPE ty_purl_components READ-ONLY.

    CLASS-METHODS parse
      IMPORTING
        purl          TYPE string
      RETURNING
        VALUE(result) TYPE REF TO /apmg/cl_purl
      RAISING
        /apmg/cx_error.

    CLASS-METHODS serialize
      IMPORTING
        components    TYPE ty_purl_components
      RETURNING
        VALUE(result) TYPE string
      RAISING
        /apmg/cx_error.

    METHODS constructor
      IMPORTING
        components TYPE ty_purl_components.

    CLASS-METHODS is_valid_type
      IMPORTING
        value         TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS type_specifics
      CHANGING
        components TYPE ty_purl_components
      RAISING
        /apmg/cx_error.

ENDCLASS.



CLASS /apmg/cl_purl IMPLEMENTATION.


  METHOD constructor.
    me->components = components.
  ENDMETHOD.


  METHOD is_valid_type.

    " https://github.com/package-url/purl-spec/blob/main/PURL-TYPES.rst + apm :-)

    DATA(list) = `alpm,apk,apm,bitbucket,bitnami,cocoapods,cargo,composer,conan,conda,cpan,cran,deb,docker,`
      & `gem,generic,github,golang,hackage,hex,huggingface,luarocks,maven,mlflow,npm,nuget,qpkg,oci,pub,`
      & `pypi,rpm,swid,swift`.

    SPLIT list AT ',' INTO TABLE DATA(known_types).

    FIND value IN TABLE known_types RESPECTING CASE.
    result = xsdbool( sy-subrc = 0 ).

  ENDMETHOD.


  METHOD parse.

    DATA components TYPE ty_purl_components.

    DATA(url_string) = replace( val = purl regex = '^pkg:/+' with = 'pkg:' ).

    DATA(url) = /apmg/cl_url=>parse( url_string ).

    IF url->components-username IS NOT INITIAL.
      RAISE EXCEPTION TYPE /apmg/cx_error_text EXPORTING text = 'Invalid purl: Username is not allowed'.
    ENDIF.
    IF url->components-password IS NOT INITIAL.
      RAISE EXCEPTION TYPE /apmg/cx_error_text EXPORTING text = 'Invalid purl: Password is not allowed'.
    ENDIF.
    IF url->components-host IS NOT INITIAL.
      RAISE EXCEPTION TYPE /apmg/cx_error_text EXPORTING text = 'Invalid purl: Host is not allowed'.
    ENDIF.
    IF url->components-port IS NOT INITIAL.
      RAISE EXCEPTION TYPE /apmg/cx_error_text EXPORTING text = 'Invalid purl: Port is not allowed'.
    ENDIF.
    IF url->components-scheme <> 'pkg'.
      RAISE EXCEPTION TYPE /apmg/cx_error_text EXPORTING text = 'Invalid purl: Scheme must be "pkg"'.
    ENDIF.
    IF url->components-path IS INITIAL.
      RAISE EXCEPTION TYPE /apmg/cx_error_text EXPORTING text = 'Invalid purl: Type and namespace not found'.
    ENDIF.

    components-scheme = url->components-scheme.

    " path should be "/type/namespace/.../namespace/name@version"
    SPLIT url->components-path+1 AT '/' INTO TABLE DATA(parts).

    IF lines( parts ) < 2.
      RAISE EXCEPTION TYPE /apmg/cx_error_text EXPORTING text = 'Invalid purl: Missing parts'.
    ENDIF.

    READ TABLE parts INTO components-type INDEX 1 ##SUBRC_OK.
    READ TABLE parts INTO DATA(name_version) INDEX lines( parts ) ##SUBRC_OK.

    LOOP AT parts INTO DATA(part) FROM 2 TO lines( parts ) - 1.
      IF components-namespace IS NOT INITIAL.
        components-namespace = components-namespace && '/'.
      ENDIF.
      components-namespace = components-namespace && part.
    ENDLOOP.

    components-type = to_lower( components-type ).

    IF name_version CS '@'.
      SPLIT name_version AT '@' INTO components-name components-version.
    ELSE.
      components-name = name_version.
    ENDIF.

    IF is_valid_type( components-type ) = abap_false.
      RAISE EXCEPTION TYPE /apmg/cx_error_text EXPORTING text = 'Invalid purl: Unknown type'.
    ENDIF.

    IF components-name IS INITIAL.
      RAISE EXCEPTION TYPE /apmg/cx_error_text EXPORTING text = 'Invalid purl: Name is required'.
    ENDIF.

    components-qualifiers = /apmg/cl_url_params=>parse( url->components-query )->params.

    LOOP AT components-qualifiers ASSIGNING FIELD-SYMBOL(<qualifier>).
      <qualifier>-key = to_lower( <qualifier>-key ).
      IF <qualifier>-key CN 'abcdefghijklmnopqrstuvwxyz0123456789.-_'.
        RAISE EXCEPTION TYPE /apmg/cx_error_text EXPORTING text = 'Invalid purl: Invalid qualifier key'.
      ENDIF.
    ENDLOOP.
    DELETE components-qualifiers WHERE value IS INITIAL.

    components-subpath = url->components-fragment.

    " Strip leading and trailing slashes
    IF components-subpath IS NOT INITIAL AND components-subpath(1) = '/'.
      components-subpath = components-subpath+1.
    ENDIF.
    DATA(len) = strlen( components-subpath ).
    IF len > 1 AND substring( val = components-subpath off = len - 1 len = 1 ) = '/'.
      len = len - 1.
      components-subpath = components-subpath(len).
    ENDIF.

    type_specifics( CHANGING components = components ).

    result = NEW #( components ).

  ENDMETHOD.


  METHOD serialize.

    DATA(qualifiers) = ''.

    LOOP AT components-qualifiers ASSIGNING FIELD-SYMBOL(<qualifier>).
      IF qualifiers IS NOT INITIAL.
        qualifiers = qualifiers && '&'.
      ENDIF.
      qualifiers = <qualifier>-key && '=' && <qualifier>-value.
    ENDLOOP.

    result = |{ components-scheme }:{ components-type }/{ components-namespace }/{ components-name }|
          && |@{ components-version }?{ qualifiers }#{ components-subpath }|.

  ENDMETHOD.


  METHOD type_specifics.

    CASE components-type.
      WHEN 'bitbucket' OR 'composer' OR 'github'.
        components-namespace = to_lower( components-namespace ).
        components-name      = to_lower( components-name ).
      WHEN 'conan'.
        IF components-namespace IS INITIAL.
          IF line_exists( components-qualifiers[ key = 'channel' ] ).
            RAISE EXCEPTION TYPE /apmg/cx_error_text
              EXPORTING
                text = 'Invalid purl: Namespace is required with channel qualifier for conan'.
          ENDIF.
        ELSEIF components-qualifiers IS INITIAL.
          RAISE EXCEPTION TYPE /apmg/cx_error_text
            EXPORTING
              text = 'Invalid purl: Channel qualifier is required with namespace for conan'.
        ENDIF.
      WHEN 'cpan'.
        IF components-namespace IS INITIAL.
          IF components-name CA '-'.
            RAISE EXCEPTION TYPE /apmg/cx_error_text
              EXPORTING
                text = 'Invalid purl: Module name must not contain "-" for cpan'.
          ENDIF.
        ELSE.
          IF to_upper( components-namespace ) <> components-namespace.
            RAISE EXCEPTION TYPE /apmg/cx_error_text
              EXPORTING
                text = 'Invalid purl: Distribution name must be upper case for cpan'.
          ENDIF.
          IF components-name CS '::'.
            RAISE EXCEPTION TYPE /apmg/cx_error_text
              EXPORTING
                text = 'Invalid purl: Module name must not contain "::" for cpan'.
          ENDIF.
        ENDIF.
      WHEN 'cran'.
        IF components-version IS INITIAL.
          RAISE EXCEPTION TYPE /apmg/cx_error_text
            EXPORTING
              text = 'Invalid purl: Version is required for cran'.
        ENDIF.
      WHEN 'huggingface'.
        components-version = to_lower( components-version ).
      WHEN 'mlflow'.
        READ TABLE components-qualifiers WITH KEY key = 'repository_url' ASSIGNING FIELD-SYMBOL(<qualifier>).
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE /apmg/cx_error_text
            EXPORTING
              text = 'Invalid purl: Repository URL qualifier is required for mlflow'.
        ENDIF.
        IF <qualifier>-value CS 'azuredatabricks.net'.
          components-name = to_lower( components-name ).
        ENDIF.
      WHEN 'pypi'.
        components-name = replace(
          val  = to_lower( components-name )
          sub  = '_'
          with = '-'
          occ  = 0 ).
      WHEN 'swift'.
        IF components-namespace IS INITIAL.
          RAISE EXCEPTION TYPE /apmg/cx_error_text
            EXPORTING
              text = 'Invalid purl: Namespace is required for swift'.
        ENDIF.
        IF components-version IS INITIAL.
          RAISE EXCEPTION TYPE /apmg/cx_error_text
            EXPORTING
              text = 'Invalid purl: Version is required for swift'.
        ENDIF.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
