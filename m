Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36262 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751384AbdDCUTg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Apr 2017 16:19:36 -0400
Subject: Re: [RFC nfs-utils PATCH 1/2] idmapd: move the pipefs-directory
 config option to nfs.conf
To: Scott Mayhew <smayhew@redhat.com>
References: <20170331215654.31570-1-smayhew@redhat.com>
 <20170331215654.31570-2-smayhew@redhat.com>
Cc: neilb@suse.com, linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <7c7be2b9-f888-b44c-08e0-f305394abacf@RedHat.com>
Date: Mon, 3 Apr 2017 16:19:34 -0400
MIME-Version: 1.0
In-Reply-To: <20170331215654.31570-2-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the delayed response... A long weekend ;-)

On 03/31/2017 05:56 PM, Scott Mayhew wrote:
> Changed idmapd to read its value for the pipefs-directory from
> /etc/nfs.conf rather than /etc/idmapd.conf.  All other configurations
> related to id mapping still reside in /etc/idmapd.conf for now.
> 
> Removed the -c option, since it would be confusing as whether it should
> override nfs.conf, idmapd.conf, or both.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  nfs.conf                |  3 +++
>  systemd/nfs.conf.man    |  9 +++++++++
>  utils/idmapd/idmapd.c   | 35 ++++++++++++++---------------------
>  utils/idmapd/idmapd.man | 19 ++++++++++++++++++-
>  4 files changed, 44 insertions(+), 22 deletions(-)
> 
> diff --git a/nfs.conf b/nfs.conf
> index 81ece06..4359904 100644
> --- a/nfs.conf
> +++ b/nfs.conf
> @@ -17,6 +17,9 @@
>  # cred-cache-directory=
>  # preferred-realm=
>  #
> +#[idmapd]
> +# pipefs-directory=/var/lib/nfs/rpc_pipefs
> +#
>  #[lockd]
>  # port=0
>  # udp-port=0
> diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
> index bdc0988..83cf84a 100644
> --- a/systemd/nfs.conf.man
> +++ b/systemd/nfs.conf.man
> @@ -215,6 +215,15 @@ See
>  for details.
>  
>  .TP
> +.B idmapd
> +Recognized values:
> +.BR pipefs-directory .
> +
> +See
> +.BR rpc.idmapd (8)
> +for details.
> +
> +.TP
>  .B svcgssd
>  Recognized values:
>  .BR principal .
Now that the pipefs-directory define for both gssd and idmap, let move the
definition into a [global] section so it does not have to changed
in two different places. 

> diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
> index f4e083a..561a4b8 100644
> --- a/utils/idmapd/idmapd.c
> +++ b/utils/idmapd/idmapd.c
> @@ -214,13 +214,11 @@ main(int argc, char **argv)
>  	struct event initialize;
>  	struct passwd *pw;
>  	struct group *gr;
> -	struct stat sb;
>  	char *xpipefsdir = NULL;
>  	int serverstart = 1, clientstart = 1;
>  	int ret;
>  	char *progname;
>  
> -	conf_path = _PATH_IDMAPDCONF;
>  	nobodyuser = NFS4NOBODY_USER;
>  	nobodygroup = NFS4NOBODY_GROUP;
>  	strlcpy(pipefsdir, PIPEFS_DIR, sizeof(pipefsdir));
> @@ -231,11 +229,9 @@ main(int argc, char **argv)
>  		progname = argv[0];
>  	xlog_open(progname);
>  
> -#define GETOPTSTR "hvfd:p:U:G:c:CS"
> +#define GETOPTSTR "hvfd:p:U:G:CS"
>  	opterr=0; /* Turn off error messages */
>  	while ((opt = getopt(argc, argv, GETOPTSTR)) != -1) {
> -		if (opt == 'c')
> -			conf_path = optarg;
Removing command line argument (aka changing API) is always a 
difficult thing... IMHO. You never know what you are going
to break... 

How about this... Instead just removing the flag, deprecated it. 
Meaning when the flag is use throw out an error message
saying the flag has be deprecated, please use /etc/nfs.conf.
Also mentioning in the man page will probably give us
enough cover :-)

BTW, thanks for do this work!

steved.

>  		if (opt == '?') {
>  			if (strchr(GETOPTSTR, optopt))
>  				warnx("'-%c' option requires an argument.", optopt);
> @@ -247,20 +243,19 @@ main(int argc, char **argv)
>  	}
>  	optind = 1;
>  
> -	if (stat(conf_path, &sb) == -1 && (errno == ENOENT || errno == EACCES)) {
> -		warn("Skipping configuration file \"%s\"", conf_path);
> -		conf_path = NULL;
> -	} else {
> -		conf_init();
> -		verbose = conf_get_num("General", "Verbosity", 0);
> -		cache_entry_expiration = conf_get_num("General",
> -				"Cache-Expiration", DEFAULT_IDMAP_CACHE_EXPIRY);
> -		CONF_SAVE(xpipefsdir, conf_get_str("General", "Pipefs-Directory"));
> -		if (xpipefsdir != NULL)
> -			strlcpy(pipefsdir, xpipefsdir, sizeof(pipefsdir));
> -		CONF_SAVE(nobodyuser, conf_get_str("Mapping", "Nobody-User"));
> -		CONF_SAVE(nobodygroup, conf_get_str("Mapping", "Nobody-Group"));
> -	}
> +	conf_path = NFS_CONFFILE;
> +	conf_init();
> +	CONF_SAVE(xpipefsdir, conf_get_str("idmapd", "pipefs-directory"));
> +	if (xpipefsdir != NULL)
> +		strlcpy(pipefsdir, xpipefsdir, sizeof(pipefsdir));
> +
> +	conf_path = _PATH_IDMAPDCONF;
> +	conf_init();
> +	verbose = conf_get_num("General", "Verbosity", 0);
> +	cache_entry_expiration = conf_get_num("General",
> +			"cache-expiration", DEFAULT_IDMAP_CACHE_EXPIRY);
> +	CONF_SAVE(nobodyuser, conf_get_str("Mapping", "Nobody-User"));
> +	CONF_SAVE(nobodygroup, conf_get_str("Mapping", "Nobody-Group"));
>  
>  	while ((opt = getopt(argc, argv, GETOPTSTR)) != -1)
>  		switch (opt) {
> @@ -307,8 +302,6 @@ main(int argc, char **argv)
>  #ifdef HAVE_NFS4_SET_DEBUG
>  	nfs4_set_debug(verbose, xlog_warn);
>  #endif
> -	if (conf_path == NULL)
> -		conf_path = _PATH_IDMAPDCONF;
>  	if (nfs4_init_name_mapping(conf_path))
>  		errx(1, "Unable to create name to user id mappings.");
>  
> diff --git a/utils/idmapd/idmapd.man b/utils/idmapd/idmapd.man
> index d4ab894..0fbc24c 100644
> --- a/utils/idmapd/idmapd.man
> +++ b/utils/idmapd/idmapd.man
> @@ -78,6 +78,21 @@ Client-only: perform no idmapping for any NFS server, even if one is detected.
>  .It Fl S
>  Server-only: perform no idmapping for any NFS client, even if one is detected.
>  .El
> +.Sh CONFIGURATION FILES
> +The
> +.Sy [idmapd]
> +section of the
> +.Pa /etc/nfs.conf
> +configuration file recognizes the following value:
> +.Bl -tag -width Ds_imagedir
> +.It Sy pipefs-directory
> +Equivalent to
> +.Sy -p .
> +.El
> +.Pp
> +All other settings related to id mapping are found in the
> +.Pa /etc/idmapd.conf
> +configuration file.
>  .Sh EXAMPLES
>  .Cm rpc.idmapd -f -vvv
>  .Pp
> @@ -94,9 +109,11 @@ messages to console, and with a verbosity level of 3.
>  .\" This next request is for sections 1, 6, 7 & 8 only.
>  .\" .Sh ENVIRONMENT
>  .Sh FILES
> -.Pa /etc/idmapd.conf
> +.Pa /etc/idmapd.conf ,
> +.Pa /etc/nfs.conf
>  .Sh SEE ALSO
>  .Xr idmapd.conf 5 ,
> +.Xr nfs.conf 5 ,
>  .Xr nfsidmap 8
>  .\".Sh SEE ALSO
>  .\".Xr nylon.conf 4
> 
