Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:46466 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753746Ab2JMQZZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Oct 2012 12:25:25 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH] nfs-utils: Backgrounding mount broken with NFS versions <4
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20121012120030.18411.qmail@md.dent.med.uni-muenchen.de>
Date: Sat, 13 Oct 2012 12:23:18 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <6AB50360-BADE-4544-85CF-700C63A44FDE@oracle.com>
References: <20121012120030.18411.qmail@md.dent.med.uni-muenchen.de>
To: Wolfram Gloger <wmglo@dent.med.uni-muenchen.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 12, 2012, at 8:00 AM, Wolfram Gloger <wmglo@dent.med.uni-muenchen.de> wrote:

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
> 
> --- utils/mount/stropts.c.orig	2012-08-23 19:41:56.000000000 +0200
> +++ utils/mount/stropts.c	2012-10-11 13:46:25.000000000 +0200
> @@ -680,6 +680,7 @@
> {
> 	struct mount_options *options = po_dup(mi->options);
> 	int result = 0;
> +	char *extra_opts = NULL;
> 
> 	if (!options) {
> 		errno = ENOMEM;
> @@ -715,20 +716,26 @@
> 		goto out_fail;
> 	}
> 
> -	/*
> -	 * Update option string to be recorded in /etc/mtab.
> -	 */
> -	if (po_join(options, mi->extra_opts) == PO_FAILED) {
> +	if (po_join(options, &extra_opts) == PO_FAILED) {

This doesn't look right to me, but I haven't had time to test it.  Doesn't this hunk cause the mount system call to ignore what's in mi->extra_opts?

> 		errno = ENOMEM;
> 		goto out_fail;
> 	}
> 
> 	if (verbose)
> 		printf(_("%s: trying text-based options '%s'\n"),
> -			progname, *mi->extra_opts);
> +			progname, extra_opts);

> 	result = nfs_sys_mount(mi, options);
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
> out_fail:
> 	po_destroy(options);
> 	return result;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



