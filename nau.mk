lms-static-sass:
	docker exec -t edx.devstack.lms bash -c 'source /edx/app/edxapp/edxapp_env && export NO_PREREQ_INSTALL=True && cd /edx/app/edxapp/edx-platform/ && paver update_assets lms --skip-collect'
studio-static-sass:
	docker exec -t edx.devstack.studio bash -c 'source /edx/app/edxapp/edxapp_env && export NO_PREREQ_INSTALL=True && cd /edx/app/edxapp/edx-platform/ && paver update_assets cms --skip-collect'


