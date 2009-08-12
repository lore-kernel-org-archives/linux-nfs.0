From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [PATCH] Allow passing fine resolution timing options to mount
Date: Wed, 12 Aug 2009 07:06:16 -0400
Message-ID: <20090812070616.61c9d124@tlielax.poochiereds.net>
References: <4A8221CE.2020603@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, trond.myklebust@fys.uio.no,
	steved@redhat.com, juhlenko@akamai.com, gud-OYTqUY/oFF8@public.gmane.org
To: Amit Gud <agud@akamai.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.120]:58530 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932530AbZHLLGT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Aug 2009 07:06:19 -0400
In-Reply-To: <4A8221CE.2020603@akamai.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 11 Aug 2009 18:58:38 -0700
Amit Gud <agud@akamai.com> wrote:

> This patch modifies parsing of mount options to allows passing units
> along with the options. Valid units are "se" for seconds and "ms" for
> milliseconds. When not specified, the unit defaults to seconds.
> 
> For example, "-o acdirmin=20ms" can be specified for 20 milliseconds,
> and "-o acdirmin=3se" or just "-o acdirmin=3" for 3 seconds.
> 
> This code also changes the display of options in /proc/<pid>/mountstats
> from seconds to milliseconds to reflect the accuracy.
> 
> Signed-off-by: Amit Gud <agud@akamai.com>
> 
> 
> Index: linux-2.6/fs/nfs/client.c
> ===================================================================
> --- linux-2.6.orig/fs/nfs/client.c	2009-08-06 12:01:14.000000000 -0700
> +++ linux-2.6/fs/nfs/client.c	2009-08-05 15:03:18.000000000 -0700
> @@ -1295,10 +1295,10 @@
>  	if (data->wsize)
>  		server->wsize = nfs_block_size(data->wsize, NULL);
> 
> -	server->acregmin = data->acregmin * HZ;
> -	server->acregmax = data->acregmax * HZ;
> -	server->acdirmin = data->acdirmin * HZ;
> -	server->acdirmax = data->acdirmax * HZ;
> +	server->acregmin = (data->acregmin * HZ) / 1000;
> +	server->acregmax = (data->acregmax * HZ) / 1000;
> +	server->acdirmin = (data->acdirmin * HZ) / 1000;
> +	server->acdirmax = (data->acdirmax * HZ) / 1000;
> 
>  	server->port = data->nfs_server.port;
> 
> Index: linux-2.6/fs/nfs/super.c
> ===================================================================
> --- linux-2.6.orig/fs/nfs/super.c	2009-08-05 13:03:42.000000000 -0700
> +++ linux-2.6/fs/nfs/super.c	2009-08-11 17:46:17.000000000 -0700
> @@ -53,6 +53,7 @@
>  #include <linux/nfs_xdr.h>
>  #include <linux/magic.h>
>  #include <linux/parser.h>
> +#include <linux/ctype.h>
> 
>  #include <asm/system.h>
>  #include <asm/uaccess.h>
> @@ -558,14 +559,14 @@
>  	if (nfss->bsize != 0)
>  		seq_printf(m, ",bsize=%u", nfss->bsize);
>  	seq_printf(m, ",namlen=%u", nfss->namelen);
> -	if (nfss->acregmin != NFS_DEF_ACREGMIN*HZ || showdefaults)
> -		seq_printf(m, ",acregmin=%u", nfss->acregmin/HZ);
> -	if (nfss->acregmax != NFS_DEF_ACREGMAX*HZ || showdefaults)
> -		seq_printf(m, ",acregmax=%u", nfss->acregmax/HZ);
> -	if (nfss->acdirmin != NFS_DEF_ACDIRMIN*HZ || showdefaults)
> -		seq_printf(m, ",acdirmin=%u", nfss->acdirmin/HZ);
> -	if (nfss->acdirmax != NFS_DEF_ACDIRMAX*HZ || showdefaults)
> -		seq_printf(m, ",acdirmax=%u", nfss->acdirmax/HZ);
> +	if (nfss->acregmin != (NFS_DEF_ACREGMIN * HZ) / 1000 || showdefaults)
> +		seq_printf(m, ",acregmin=%u", (nfss->acregmin * 1000) / HZ);
> +	if (nfss->acregmax != (NFS_DEF_ACREGMAX * HZ) / 1000 || showdefaults)
> +		seq_printf(m, ",acregmax=%u", (nfss->acregmax * 1000) / HZ);
> +	if (nfss->acdirmin != (NFS_DEF_ACDIRMIN * HZ) / 1000 || showdefaults)
> +		seq_printf(m, ",acdirmin=%u", (nfss->acdirmin * 1000) / HZ);
> +	if (nfss->acdirmax != (NFS_DEF_ACDIRMAX * HZ) / 1000 || showdefaults)
> +		seq_printf(m, ",acdirmax=%u", (nfss->acdirmax * 1000) / HZ);
>  	for (nfs_infop = nfs_info; nfs_infop->flag; nfs_infop++) {
>  		if (nfss->flags & nfs_infop->flag)
>  			seq_puts(m, nfs_infop->str);
> @@ -967,6 +968,43 @@
>  }
> 
>  /*
> + * Parse the input string for unit. Return the value which when
> + * multiplied with the user input yields millisecond resolution.
> + *
> + * If user does not specify any unit, it is defaulted to seconds.
> + */
> +static unsigned int nfs_match_unit(char *string)
> +{
> +	unsigned int len = strlen(string);
> +
> +	if (len < 3)
> +		return 1000;
> +
> +	string = string + len - 2;
> +
> +	if (isdigit(*string))
> +		return 1000;
> +
> +	if (!strcmp(string, "se")) {
> +		*string = '\0';
> +		return 1000;
> +	}


"se" isn't a very common notation for seconds. It would probably be
better to drop the "e" and allow people to specify "3s" instead.

> +	if (!strcmp(string, "ms")) {
> +		*string = '\0';
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +/*
> + * This converts the user value in millisecond resolution.
> + */
> +static inline unsigned long nfs_convert_unit(unsigned int unit, unsigned long option)
> +{
> +	return unit * option;
> +}
> +
> +/*
>   * Error-check and convert a string of mount options from user space into
>   * a data structure.  The whole mount string is processed; bad options are
>   * skipped as they are encountered.  If there were no errors, return 1;
> @@ -1003,6 +1041,7 @@
>  		unsigned long option;
>  		int int_option;
>  		int token;
> +		unsigned int unit;
> 
>  		if (!*p)
>  			continue;
> @@ -1174,52 +1213,57 @@
>  			string = match_strdup(args);
>  			if (string == NULL)
>  				goto out_nomem;
> +			unit = nfs_match_unit(string);
>  			rc = strict_strtoul(string, 10, &option);
>  			kfree(string);
>  			if (rc != 0)
>  				goto out_invalid_value;
> -			mnt->acregmin = option;
> +			mnt->acregmin = nfs_convert_unit(option, unit);
>  			break;
>  		case Opt_acregmax:
>  			string = match_strdup(args);
>  			if (string == NULL)
>  				goto out_nomem;
> +			unit = nfs_match_unit(string);
>  			rc = strict_strtoul(string, 10, &option);
>  			kfree(string);
>  			if (rc != 0)
>  				goto out_invalid_value;
> -			mnt->acregmax = option;
> +			mnt->acregmax = nfs_convert_unit(option, unit);
>  			break;
>  		case Opt_acdirmin:
>  			string = match_strdup(args);
>  			if (string == NULL)
>  				goto out_nomem;
> +			unit = nfs_match_unit(string);
>  			rc = strict_strtoul(string, 10, &option);
>  			kfree(string);
>  			if (rc != 0)
>  				goto out_invalid_value;
> -			mnt->acdirmin = option;
> +			mnt->acdirmin = nfs_convert_unit(option, unit);
>  			break;
>  		case Opt_acdirmax:
>  			string = match_strdup(args);
>  			if (string == NULL)
>  				goto out_nomem;
> +			unit = nfs_match_unit(string);
>  			rc = strict_strtoul(string, 10, &option);
>  			kfree(string);
>  			if (rc != 0)
>  				goto out_invalid_value;
> -			mnt->acdirmax = option;
> +			mnt->acdirmax = nfs_convert_unit(option, unit);
>  			break;
>  		case Opt_actimeo:
>  			string = match_strdup(args);
>  			if (string == NULL)
>  				goto out_nomem;
> +			unit = nfs_match_unit(string);
>  			rc = strict_strtoul(string, 10, &option);
>  			kfree(string);
>  			if (rc != 0)
>  				goto out_invalid_value;
>  			mnt->acregmin = mnt->acregmax =
> -			mnt->acdirmin = mnt->acdirmax = option;
> +			mnt->acdirmin = mnt->acdirmax = nfs_convert_unit(option, unit);
>  			break;
>  		case Opt_namelen:
>  			string = match_strdup(args);
> @@ -1715,10 +1759,10 @@
>  		args->wsize		= data->wsize;
>  		args->timeo		= data->timeo;
>  		args->retrans		= data->retrans;
> -		args->acregmin		= data->acregmin;
> -		args->acregmax		= data->acregmax;
> -		args->acdirmin		= data->acdirmin;
> -		args->acdirmax		= data->acdirmax;
> +		args->acregmin		= data->acregmin * 1000;
> +		args->acregmax		= data->acregmax * 1000;
> +		args->acdirmin		= data->acdirmin * 1000;
> +		args->acdirmax		= data->acdirmax * 1000;
> 
>  		memcpy(&args->nfs_server.address, &data->addr,
>  		       sizeof(data->addr));
> @@ -2391,10 +2435,10 @@
>  		args->wsize	= data->wsize;
>  		args->timeo	= data->timeo;
>  		args->retrans	= data->retrans;
> -		args->acregmin	= data->acregmin;
> -		args->acregmax	= data->acregmax;
> -		args->acdirmin	= data->acdirmin;
> -		args->acdirmax	= data->acdirmax;
> +		args->acregmin	= data->acregmin * 1000;
> +		args->acregmax	= data->acregmax * 1000;
> +		args->acdirmin	= data->acdirmin * 1000;
> +		args->acdirmax	= data->acdirmax * 1000;
>  		args->nfs_server.protocol = data->proto;
>  		nfs_validate_transport_protocol(args);
> 
> Index: linux-2.6/include/linux/nfs_fs.h
> ===================================================================
> --- linux-2.6.orig/include/linux/nfs_fs.h	2009-08-05 18:45:16.000000000 -0700
> +++ linux-2.6/include/linux/nfs_fs.h	2009-08-05 18:45:32.000000000 -0700
> @@ -20,10 +20,10 @@
>  #define NFS_MAX_UDP_TIMEOUT	(60*HZ)
>  #define NFS_MAX_TCP_TIMEOUT	(600*HZ)
> 
> -#define NFS_DEF_ACREGMIN	(3)
> -#define NFS_DEF_ACREGMAX	(60)
> -#define NFS_DEF_ACDIRMIN	(30)
> -#define NFS_DEF_ACDIRMAX	(60)
> +#define NFS_DEF_ACREGMIN	(3000)
> +#define NFS_DEF_ACREGMAX	(60000)
> +#define NFS_DEF_ACDIRMIN	(30000)
> +#define NFS_DEF_ACDIRMAX	(60000)
> 
>  /*
>   * When flushing a cluster of dirty pages, there can be different
> 


-- 
Jeff Layton <jlayton@poochiereds.net>
