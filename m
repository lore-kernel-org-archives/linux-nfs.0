Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43467 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754757Ab2JOUz0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 16:55:26 -0400
Message-ID: <507C6D9B.9070009@RedHat.com>
Date: Mon, 15 Oct 2012 16:10:03 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Wolfram Gloger <wmglo@dent.med.uni-muenchen.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: Backgrounding mount broken with NFS versions
 <4
References: <20121012120030.18411.qmail@md.dent.med.uni-muenchen.de>
In-Reply-To: <20121012120030.18411.qmail@md.dent.med.uni-muenchen.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/10/12 08:00, Wolfram Gloger wrote:
> When the NFS version isn't specified in the mount options, mount.nfs
> attempts V4 first and appends 'vers=4' to the extra_options string in
> the mount options.  If the server isn't immediately reachable, this
> attempt fails.  However, if the background option is specified and the
> server comes up later on, the extra_options are used again for all
> further attempts and thus they fail if the server only supports
> vers<4.
> 
> Fix this by only amending extra_options on a successful vers=4 mount.
> 
> This is now Debian bug #690181 and has apparently been around for
> ages.
> 
> Signed-off-by: Wolfram Gloger <bugzilla1@malloc.de>
Committed....

steved.
> 
> --- utils/mount/stropts.c.orig	2012-08-23 19:41:56.000000000 +0200
> +++ utils/mount/stropts.c	2012-10-11 13:46:25.000000000 +0200
> @@ -680,6 +680,7 @@
>  {
>  	struct mount_options *options = po_dup(mi->options);
>  	int result = 0;
> +	char *extra_opts = NULL;
>  
>  	if (!options) {
>  		errno = ENOMEM;
> @@ -715,20 +716,26 @@
>  		goto out_fail;
>  	}
>  
> -	/*
> -	 * Update option string to be recorded in /etc/mtab.
> -	 */
> -	if (po_join(options, mi->extra_opts) == PO_FAILED) {
> +	if (po_join(options, &extra_opts) == PO_FAILED) {
>  		errno = ENOMEM;
>  		goto out_fail;
>  	}
>  
>  	if (verbose)
>  		printf(_("%s: trying text-based options '%s'\n"),
> -			progname, *mi->extra_opts);
> +			progname, extra_opts);
>  
>  	result = nfs_sys_mount(mi, options);
>  
> +	/*
> +	 * If success, update option string to be recorded in /etc/mtab.
> +	 */
> +	if (result) {
> +	    free(*mi->extra_opts);
> +	    *mi->extra_opts = extra_opts;
> +	} else
> +	    free(extra_opts);
> +
>  out_fail:
>  	po_destroy(options);
>  	return result;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
