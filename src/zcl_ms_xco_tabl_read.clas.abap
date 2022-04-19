CLASS zcl_ms_xco_tabl_read DEFINITION PUBLIC FINAL
    INHERITING FROM cl_xco_cp_adt_simple_classrun CREATE PUBLIC.
  PROTECTED SECTION.
    METHODS:
      main REDEFINITION.

  PRIVATE SECTION.
    METHODS:
      read_table
        IMPORTING
          iv_table_name TYPE sxco_ad_object_name
          out           TYPE REF TO if_xco_adt_classrun_out,

      read_database_table
        IMPORTING
          iv_database_table_name TYPE sxco_dbt_object_name
          out                    TYPE REF TO if_xco_adt_classrun_out.
ENDCLASS.

CLASS zcl_ms_xco_tabl_read IMPLEMENTATION.
  METHOD main.
    read_table(
      iv_table_name = 'ZMS_XCO_DBT_A'
      out           = out
    ).

    read_table(
      iv_table_name = 'ZMS_XCO_DBT_L'
      out           = out
    ).

    read_table(
      iv_table_name = 'ZMS_XCO_GTT'
      out           = out
    ).
  ENDMETHOD.

  METHOD read_table.
    DATA(lo_table) = xco_cp_abap_repository=>object->tabl->for( iv_table_name ).

    IF lo_table->is_database_table( ) EQ abap_true.
      out->write( |{ lo_table->name } is a database table.| ).

      read_database_table(
        iv_database_table_name = CONV #( iv_table_name )
        out                    = out
      ).
    ELSEIF lo_table->is_global_temporary_table( ) EQ abap_true.
      out->write( |{ lo_table->name } is a global temporary table.| ).
    ENDIF.
  ENDMETHOD.

  METHOD read_database_table.
    DATA(lo_database_table) = xco_cp_abap_repository=>object->tabl->database_table->for( iv_database_table_name ).

    " Header
    DATA(ls_header) = lo_database_table->content( )->get( ).
    out->write( ls_header ).

    " Determine if there is a client field.
    DATA(lt_fields) = lo_database_table->fields->all->get( ).

    LOOP AT lt_fields INTO DATA(lo_field).
      DATA(lo_underlying_built_in_type) = lo_field->content( )->get_underlying_built_in_type( ).

      IF lo_underlying_built_in_type EQ xco_cp_abap_dictionary=>built_in_type->clnt.
        out->write( |Database table { lo_database_table->name } has a client field.| ).
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
