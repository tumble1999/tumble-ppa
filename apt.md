---
title: Debian
---

<ul>
{% for package in site.apt %}
<li>
{% include apt.html package=package %}

</li>
{% endfor %}
</ul>
