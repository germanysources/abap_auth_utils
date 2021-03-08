CLASS zauth_field_where_used DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF _auth_combination,
        object     TYPE agobject,
        field      TYPE agrfield,
        value_low  TYPE agval,
        value_high TYPE agval,
        deleted    TYPE tpr_st_del,
      END OF _auth_combination .
    TYPES:
      BEGIN OF _role_assignment,
        agr_name TYPE agr_name,
        object   TYPE agobject,
        field    TYPE agrfield,
        low      TYPE agval,
        high     TYPE agval,
      END OF _role_assignment .
    TYPES:
      _fields TYPE RANGE OF fieldname .
    TYPES:
      _objects TYPE STANDARD TABLE OF xuobject .
    TYPES:
      _roles TYPE STANDARD TABLE OF agr_name .
    TYPES:
      _profiles TYPE STANDARD TABLE OF xuauth .
    TYPES:
      _auth_combinations TYPE STANDARD TABLE OF _auth_combination .
    TYPES:
      _role_assignments TYPE STANDARD TABLE OF _role_assignment .

    CLASS-METHODS fetch_objects
      IMPORTING
        !fields  TYPE _fields
      EXPORTING
        !objects TYPE _objects .
    CLASS-METHODS fetch_roles_for_objs_fields
      IMPORTING
        !auth_combinations TYPE _auth_combinations
        !value_check       TYPE sap_bool DEFAULT abap_true
      EXPORTING
        !role_assignments  TYPE _role_assignments .
    CLASS-METHODS fetch_roles_for_fields
      IMPORTING
        !auth_combinations TYPE _auth_combinations
        !value_check       TYPE sap_bool DEFAULT abap_true
      EXPORTING
        !role_assignments  TYPE _role_assignments .
protected section.
PRIVATE SECTION.

  CLASS-METHODS filter_by_value
    IMPORTING
      auth_combinations TYPE _auth_combinations
    CHANGING
      role_assignments TYPE _role_assignments.
ENDCLASS.



CLASS ZAUTH_FIELD_WHERE_USED IMPLEMENTATION.


  METHOD fetch_objects.

    SELECT objct FROM tobj INTO TABLE objects
      WHERE fiel1 IN fields OR fiel2 IN fields OR fiel3 IN fields
      AND fiel4 IN fields AND fiel5 IN fields AND fiel6 IN fields
      AND fiel7 IN fields AND fiel8 IN fields AND fiel9 IN fields
      AND fiel0 IN fields.

  ENDMETHOD.


  METHOD FETCH_ROLES_FOR_FIELDS.

    SELECT agr_name, object, field, low, high FROM agr_1251 AS r INNER JOIN tobj AS o
      ON r~object = o~objct
      INTO TABLE @role_assignments
      FOR ALL ENTRIES IN @auth_combinations
      WHERE r~field = @auth_combinations-field AND deleted = @auth_combinations-deleted AND
      ( fiel1 = @auth_combinations-field OR fiel2 = @auth_combinations-field OR
        fiel3 = @auth_combinations-field OR fiel4 = @auth_combinations-field OR
        fiel5 = @auth_combinations-field OR fiel6 = @auth_combinations-field OR
        fiel7 = @auth_combinations-field OR fiel8 = @auth_combinations-field OR
        fiel9 = @auth_combinations-field OR fiel0 = @auth_combinations-field ).
    IF role_assignments IS INITIAL OR value_check = abap_false.
      RETURN.
    ENDIF.

    filter_by_value( EXPORTING auth_combinations = auth_combinations
      CHANGING role_assignments = role_assignments ).

  ENDMETHOD.


  METHOD FETCH_ROLES_FOR_OBJS_FIELDS.

    SELECT agr_name, object, field, low, high FROM agr_1251
      INTO TABLE @role_assignments
      FOR ALL ENTRIES IN @auth_combinations
      WHERE field = @auth_combinations-field AND deleted = @auth_combinations-deleted AND
      object = @auth_combinations-object AND field = @auth_combinations-field.
    IF role_assignments IS INITIAL OR value_check = abap_false.
      RETURN.
    ENDIF.

    filter_by_value( EXPORTING auth_combinations = auth_combinations
      CHANGING role_assignments = role_assignments ).

  ENDMETHOD.


  METHOD filter_by_value.
    DATA: organization_structure TYPE SORTED TABLE OF agr_1252
          WITH NON-UNIQUE KEY agr_name varbl.

    SELECT * FROM agr_1252
      INTO TABLE @organization_structure
      FOR ALL ENTRIES IN @role_assignments
      WHERE agr_name = @role_assignments-agr_name.

    LOOP AT role_assignments ASSIGNING FIELD-SYMBOL(<assignment>).

      DATA(tabix) = sy-tabix.
      READ TABLE organization_structure REFERENCE INTO DATA(org_structure)
        WITH TABLE KEY agr_name = <assignment>-agr_name
          varbl = <assignment>-low.
      IF sy-subrc = 0.
        <assignment>-low = org_structure->*-low.
        <assignment>-high = org_structure->*-high.
      ENDIF.

      IF NOT line_exists( auth_combinations[ field = <assignment>-field
          value_low = <assignment>-low value_high = <assignment>-high ] ).
        DELETE role_assignments INDEX tabix.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
