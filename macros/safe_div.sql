{% macro safe_div(n, d) -%}
case when {{ d }} = 0 or {{ d }} is null then 0 else {{ n }} / {{ d }} end
{%- endmacro %}