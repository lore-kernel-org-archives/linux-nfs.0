Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58484 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757073Ab2AEVmp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jan 2012 16:42:45 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q05Lgjta026494
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 5 Jan 2012 16:42:45 -0500
Message-ID: <4F061954.6030208@RedHat.com>
Date: Thu, 05 Jan 2012 16:42:44 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Karel Zak <kzak@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] mount.nfs: don't overwrite mount options from /etc/nfsmount.conf
References: <1324563292-22058-1-git-send-email-kzak@redhat.com>
In-Reply-To: <1324563292-22058-1-git-send-email-kzak@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/22/2011 09:14 AM, Karel Zak wrote:
> The libmount (as well as mount(8)) ignores mount options from command
> line if running in restricted mode (suid, non-root-user) and all
> options are read from fstab only.
> 
> It means that all options are replaced with stuff from fstab,
> including mount options from nfsmount.conf. This is bug.
> 
> We have to apply fstab and then nfsmount.conf.
> 
> Signed-off-by: Karel Zak <kzak@redhat.com>
Committed...

steved.
> ---
>  utils/mount/mount_libmount.c |   15 +++++++++++++++
>  1 files changed, 15 insertions(+), 0 deletions(-)
> 
> diff --git a/utils/mount/mount_libmount.c b/utils/mount/mount_libmount.c
> index e450d79..e8f17a9 100644
> --- a/utils/mount/mount_libmount.c
> +++ b/utils/mount/mount_libmount.c
> @@ -346,6 +346,21 @@ static int mount_main(struct libmnt_context *cxt, int argc, char **argv)
>  
>  	if (chk_mountpoint(mount_point))
>  		goto err;
> +
> +	/*
> +	 * The libmount strictly uses only options from fstab if running in
> +	 * restricted mode (suid, non-root user). This is done in
> +	 * mnt_context_prepare_mount() by default.
> +	 *
> +	 * We have to read fstab before nfsmount.conf, otherwise the options
> +	 * from nfsmount.conf will be ignored (overwrited).
> +	 */
> +	rc = mnt_context_apply_fstab(cxt);
> +	if (rc) {
> +		nfs_error(_("%s: failed to apply fstab options\n"), progname);
> +		goto err;
> +	}
> +
>  	/*
>  	 * Concatenate mount options from the configuration file
>  	 */
