Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33792 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754822Ab2E2TS0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 May 2012 15:18:26 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q4TJIPxI014333
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 29 May 2012 15:18:25 -0400
Message-ID: <4FC520D9.7050004@RedHat.com>
Date: Tue, 29 May 2012 15:17:45 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsidmap: Allow verbosity level to be set in the config
 file.
References: <1337715497-30592-1-git-send-email-steved@redhat.com>
In-Reply-To: <1337715497-30592-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/22/2012 03:38 PM, Steve Dickson wrote:
> To make it easier to enable ID mapping debugging, nfsidmap
> should read /etc/idmap.conf to see if the verbosity level
> is set, similar to what rpc.idmapd does
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.
> ---
>  utils/nfsidmap/nfsidmap.c |   19 ++++++++++++++++++-
>  1 files changed, 18 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
> index cf11551..86cddd1 100644
> --- a/utils/nfsidmap/nfsidmap.c
> +++ b/utils/nfsidmap/nfsidmap.c
> @@ -12,6 +12,7 @@
>  
>  #include <unistd.h>
>  #include "xlog.h"
> +#include "conffile.h"
>  
>  int verbose = 0;
>  char *usage="Usage: %s [-v] [-c || [-u|-g|-r key] || [-t timeout] key desc]";
> @@ -26,12 +27,26 @@ char *usage="Usage: %s [-v] [-c || [-u|-g|-r key] || [-t timeout] key desc]";
>  #define DEFAULT_KEYRING "id_resolver"
>  #endif
>  
> +#ifndef PATH_IDMAPDCONF
> +#define PATH_IDMAPDCONF "/etc/idmapd.conf"
> +#endif
> +
>  static int keyring_clear(char *keyring);
>  
>  #define UIDKEYS 0x1
>  #define GIDKEYS 0x2
>  
>  /*
> + * Check to the config file for the verbosity level
> + */
> +get_config_verbose(char *path)
> +{
> +	conf_path = path;
> +	conf_init();
> +	return conf_get_num("General", "Verbosity", 0);
> +}
> +
> +/*
>   * Find either a user or group id based on the name@domain string
>   */
>  int id_lookup(char *name_at_domain, key_serial_t key, int type)
> @@ -266,7 +281,9 @@ int main(int argc, char **argv)
>  			break;
>  		}
>  	}
> -
> +	if (!verbose) {
> +		verbose = get_config_verbose(PATH_IDMAPDCONF);
> +	}
>  	if (keystr) {
>  		rc = key_revoke(keystr, keymask);
>  		return rc;		
