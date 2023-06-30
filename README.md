## About this repository: ##
This repository contains all necessary files in order to create metasfresh in a docker environment.

Additionally you will find the source files for modifying the core images in case you want to build and publish a modified version of metasfresh-docker.

## Installation: ##
In order to install metasfresh in a docker environment you're free to follow this guide:

[Install metasfresh on Docker](https://docs.metasfresh.org/installation_collection/EN/How_do_I_setup_the_metasfresh_stack_using_Docker.html)

[Install metasfresh on Docker - SSL](https://docs.metasfresh.org/installation_collection/EN/How_do_I_setup_metasfresh_docker_with_ssl.html)
## Guides: ##

 * [Create a database backup](https://docs.metasfresh.org/installation_collection/EN/How_do_I_backup_metasfresh_docker.html)

 * [Update your metasfresh-docker installation](https://docs.metasfresh.org/howto_collection/EN/How_do_I_update_metasfresh_using_Docker.html)

 * [Use the Java Swing Client with metasfresh-docker](https://docs.metasfresh.org/howto_collection/EN/How_do_I_use_Java_Client_using_Docker.html)

 * [Run multiple metasfresh-docker stacks / Change webui ports](https://docs.metasfresh.org/installation_collection/EN/How_do_I_change_the_webui_ports_for_metasfresh_docker.html)

## Frequent Questions: ##
*  **Q:  Where are the database files located at?**
   * A: You can find the database files and logs in your metasfresh-docker directory in `./volumes/db`


*  **Q: I heard docker-containers are ephermal - is it safe to use in production?**
   * A: Docker containers are ephermal, yes. However: as shown above, your database- and log-files are stored on the **docker-host** in `./volumes/`. So if you decide to stop and remove your containers, your database is still existent and will be used if you're building a new container at the exact place your old metasfresh-docker directory was. If the database container finds usable data in `./volumes/db/data` relative to the `docker-compose.yml` file, this data will be used by the db-container.


*  **Q: I want to run multiple metasfresh-docker instances on the same docker-host - what do I need to change?**
   * A: Create a directory for each metasfresh-docker stack you want to run. Then clone this repository directly in the new directories and [change the exposing ports](http://docs.metasfresh.org/installation_collection/EN/How_do_I_change_the_webui_ports_for_metasfresh_docker.html) so each stack uses different exposed ports.

*  **Q: I have additional questions not listed here. Is there some form to get in contact with you?**
   * A: Of course there is. The best place to get your questions answered is using our forum, which you can find here: https://forum.metasfresh.org/

*  **Q: After applying an update, `search` container is displaying errors like this:**
        ```
        search_1    | ElasticsearchException[failed to bind service]; nested: AccessDeniedException[/usr/share/elasticsearch/data/nodes];
        search_1    | Likely root cause: java.nio.file.AccessDeniedException: /usr/share/elasticsearch/data/nodes
        ```
   * A: Unfortunately elasticsearch does not provide an easy way to upgrade already collected data on an update to a new elasticsearch version and changed permission requirements of the data and config files.
        With metasfresh upgrade to 5.165 we upgraded elasticsearch to v. `7.9.3` https://github.com/metasfresh/metasfresh-docker/issues/63 in order to support new functions for metasfresh.
        To solve this issue, you will need to stop your instance `docker-compose down`, remove the `./volumes/search` folder including already collected elasticsearch data and restart `docker-compose up -d`.
        This will deploy the correct permissions and settings including the updated elasticsearch container.
        
## Do you want to help? ##
   Do you want to help improving documentation, contribute some code or participate in functional requirements. That's great, you're welcome! Please read our contibutor guidelines first. You can find them here: [CONTRIBUTING.md](https://github.com/metasfresh/metasfresh/blob/master/CONTRIBUTING.md)
   If you would like to get in touch with other contributors then just join our chat on Gitter: [metasfresh Gitter](https://gitter.im/metasfresh/metasfresh?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## What's new in metasfresh ERP? ##
   If you are interested in latest improvements or bug fixes of metasfresh ERP, then take a look in our [Release Notes](https://github.com/metasfresh/metasfresh/blob/master/ReleaseNotes.md).
