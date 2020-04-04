project('dockery', ['vala', 'c'])

cc = meson.get_compiler('c')
libm = cc.find_library('m', required: true)

gtk = dependency('gtk+-3.0', version: '>= 3.22')
gee = dependency('gee-0.8')
json = dependency('json-glib-1.0')
soup = dependency('libsoup-2.4')
vte_290 = dependency('vte-2.90', required: false)
vte_291 = dependency('vte-2.91', required: false)
gio =   dependency('gio-unix-2.0')

vala_args = []
if vte_291.found()
  vte = vte_291
  vala_args += ['-D', 'PPS_LIBVTE_2_91']
elif vte_290.found()
  vte = vte_290
  vala_args += ['-D', 'PPS_LIBVTE_2_90']  
endif  

if json.version().version_compare('>=1.2')
  vala_args += ['-D', 'JSON_PRETTY_PRINT']  
endif

if get_option('travis') == false
  vala_args += ['-D', 'NOT_ON_TRAVIS']
endif

if get_option('debug') == true
  vala_args += ['--ccode', '--debug']
endif

vala_args += ['--target-glib=2.50']

livechart_proj = subproject('livechart')
livechart = livechart_proj.get_variable('livechart_dep')

vala_docker_proj = subproject('vala-docker')
vala_docker = vala_docker_proj.get_variable('vala_docker_dep')

deps = [
  gtk,
  gee,
  json,
  soup,
  vte,
  gio,
  libm,
  vala_docker,
  livechart
]

subdir('data')
subdir('src')
subdir('tests')
