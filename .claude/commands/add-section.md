Add a new custom section to the Shopify Craft theme. The user will describe the section's purpose and behavior.

## Rules

### Naming convention
- Section file: `sections/lena-{name}.liquid`
- CSS: Add styles to `assets/lena-custom.css` under a new section header comment
- Class prefix: `lena-{name}-*` for all CSS classes
- Never create a new CSS file — all custom styles go in `lena-custom.css`

### Section structure template

```liquid
{%- comment -%}
  Lena: {Description} section
  Created: {date}
{%- endcomment -%}

{{ 'lena-custom.css' | asset_url | stylesheet_tag }}

{%- style -%}
  .section-{{ section.id }}-padding {
    padding-top: {{ section.settings.padding_top | times: 0.75 | round: 0 }}px;
    padding-bottom: {{ section.settings.padding_bottom | times: 0.75 | round: 0 }}px;
  }
  @media screen and (min-width: 750px) {
    .section-{{ section.id }}-padding {
      padding-top: {{ section.settings.padding_top }}px;
      padding-bottom: {{ section.settings.padding_bottom }}px;
    }
  }
{%- endstyle -%}

<div class="lena-{name} color-{{ section.settings.color_scheme }} section-{{ section.id }}-padding">
  <div class="page-width">
    {%- comment -%} Section content here {%- endcomment -%}
  </div>
</div>

{% schema %}
{
  "name": "{Display Name}",
  "tag": "section",
  "class": "section",
  "settings": [
    {
      "type": "color_scheme",
      "id": "color_scheme",
      "label": "Color scheme",
      "default": "scheme-1"
    },
    {
      "type": "range",
      "id": "padding_top",
      "min": 0, "max": 100, "step": 4,
      "unit": "px", "label": "Top padding",
      "default": 40
    },
    {
      "type": "range",
      "id": "padding_bottom",
      "min": 0, "max": 100, "step": 4,
      "unit": "px", "label": "Bottom padding",
      "default": 52
    }
  ],
  "presets": [
    {
      "name": "{Display Name}"
    }
  ]
}
{% endschema %}
```

### Design system compliance

1. Use `--lena-*` CSS variables for all colors (defined in `lena-custom.css`)
2. Include `color_scheme` setting for theme editor integration
3. Add responsive styles at 900px (tablet) and 640px (mobile) breakpoints
4. Use diamond motif (`.dm`) sparingly as visual accents
5. Heading font: `var(--font-heading-family)` (Josefin Sans)
6. Body font: `var(--font-body-family)` (Libre Franklin)
7. Max width: `page-width` class (1200px)

### Checklist before reporting done

1. Section file created at `sections/lena-{name}.liquid`
2. CSS added to `assets/lena-custom.css` with section header comment
3. Schema includes `color_scheme`, `padding_top`, `padding_bottom` at minimum
4. Preset defined so section appears in theme editor
5. Responsive styles for tablet (900px) and mobile (640px)
6. Mobile-first: verify layout doesn't break at small widths
7. Empty-state: if section depends on collections/data, handle empty gracefully
8. Update CLAUDE.md "Custom vs Stock Files" table with new section
9. Update ARCHITECTURE.md if section has complex logic
