lms-static-sass:
	docker exec -t edx.devstack.lms bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform/ && paver update_assets lms --skip-collect'
cms-static-sass:
	docker exec -t edx.devstack.studio bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform/ && paver update_assets cms --skip-collect'


