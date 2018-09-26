Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33996 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726127AbeI0A0z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 26 Sep 2018 20:26:55 -0400
Received: from smtp.corp.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 1C507307D867
        for <linux-nfs@vger.kernel.org>; Wed, 26 Sep 2018 18:12:46 +0000 (UTC)
Subject: Re: [PATCH] nfs-utils: Add missing nfs.conf entries for various
 cmdline options
To: Justin Mitchell <jumitche@redhat.com>, linux-nfs@vger.kernel.org
References: <1537305318.8639.2.camel@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <291b9cf1-4b13-8493-6389-999649b70552@RedHat.com>
Date: Wed, 26 Sep 2018 14:12:41 -0400
MIME-Version: 1.0
In-Reply-To: <1537305318.8639.2.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 9/18/18 5:15 PM, Justin Mitchell wrote:
> Add nfs.conf entries for various cmdline options
> 
> These options did not have a corresponding nfs.conf entry which is
> currently forcing use of cmdline flags
> 
> 
> Signed-off-by: Justin Mitchell <jumitche@redhat.com>
Committed... 

steved.
> ---
>  utils/gssd/gssd.c       | 3 +++
>  utils/gssd/svcgssd.c    | 4 ++++
>  utils/idmapd/idmapd.c   | 8 ++++++++
>  utils/statd/sm-notify.c | 1 +
>  4 files changed, 16 insertions(+)
> 
> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> index 2c14e5f..00df2fc 100644
> --- a/utils/gssd/gssd.c
> +++ b/utils/gssd/gssd.c
> @@ -888,6 +888,9 @@ main(int argc, char *argv[])
>  
>  	read_gss_conf();
>  
> +	verbosity = conf_get_num("gssd", "Verbosity", verbosity);
> +	rpc_verbosity = conf_get_num("gssd", "RPC-Verbosity", rpc_verbosity);
> +
>  	while ((opt = getopt(argc, argv, "DfvrlmnMp:k:d:t:T:R:")) != -1) {
>  		switch (opt) {
>  			case 'f':
> diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
> index 8e918cc..ec49b61 100644
> --- a/utils/gssd/svcgssd.c
> +++ b/utils/gssd/svcgssd.c
> @@ -113,6 +113,10 @@ main(int argc, char *argv[])
>  	else
>  		principal = s;
>  
> +	verbosity = conf_get_num("svcgssd", "Verbosity", verbosity);
> +	rpc_verbosity = conf_get_num("svcgssd", "RPC-Verbosity", rpc_verbosity);
> +	idmap_verbosity = conf_get_num("svcgssd", "IDMAP-Verbosity", idmap_verbosity);
> +
>  	while ((opt = getopt(argc, argv, "fivrnp:")) != -1) {
>  		switch (opt) {
>  			case 'f':
> diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
> index 4811e0f..d14eef7 100644
> --- a/utils/idmapd/idmapd.c
> +++ b/utils/idmapd/idmapd.c
> @@ -261,6 +261,10 @@ main(int argc, char **argv)
>  				strlcpy(pipefsdir, xpipefsdir, sizeof(pipefsdir));
>  			CONF_SAVE(nobodyuser, conf_get_str("Mapping", "Nobody-User"));
>  			CONF_SAVE(nobodygroup, conf_get_str("Mapping", "Nobody-Group"));
> +			if (conf_get_bool("General", "server-only", false))
> +				clientstart = 0;
> +			if (conf_get_bool("General", "client-only", false))
> +				serverstart = 0;
>  		}
>  	} else {
>  		conf_path = NFS_CONFFILE;
> @@ -276,6 +280,10 @@ main(int argc, char **argv)
>  				"cache-expiration", DEFAULT_IDMAP_CACHE_EXPIRY);
>  		CONF_SAVE(nobodyuser, conf_get_str("Mapping", "Nobody-User"));
>  		CONF_SAVE(nobodygroup, conf_get_str("Mapping", "Nobody-Group"));
> +		if (conf_get_bool("General", "server-only", false))
> +			clientstart = 0;
> +		if (conf_get_bool("General", "client-only", false))
> +			serverstart = 0;
>  	}
>  
>  	while ((opt = getopt(argc, argv, GETOPTSTR)) != -1)
> diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
> index 7a48473..29dad38 100644
> --- a/utils/statd/sm-notify.c
> +++ b/utils/statd/sm-notify.c
> @@ -503,6 +503,7 @@ main(int argc, char **argv)
>  	s = conf_get_str("statd", "state-directory-path");
>  	if (s && !nsm_setup_pathnames(argv[0], s))
>  		exit(1);
> +	opt_update_state = conf_get_bool("sm-notify", "update-state", opt_update_state);
>  
>  	while ((c = getopt(argc, argv, "dm:np:v:P:f")) != -1) {
>  		switch (c) {
> 
