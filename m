Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53104 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753117Ab2GPM5h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jul 2012 08:57:37 -0400
Message-ID: <50040FBB.8010006@RedHat.com>
Date: Mon, 16 Jul 2012 08:57:31 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] umount.nfs: restore correct error status when umount
 fails.
References: <20120712132757.7f86b86b@notabene.brown>
In-Reply-To: <20120712132757.7f86b86b@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/11/2012 11:27 PM, NeilBrown wrote:
> 
> 
> If nfs-utils is built without --enable-libmount-mount, then
> an unmount that failed due to the filesystem being busy will
> exit with '16' - EX_FILEIO.
> Autofs apparently relies on this.
> 
> When built with --enable-libmount-mount, the same case will
> exit with '32' - EX_FAIL.  Normally this is reserved for
> internal errors.
> 
> This patch restores the use of EX_FILEIO for errors from umount.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed....

steved.

> --
> 
> I confess that I haven't done a complete case analysis to see that we are
> always using the correct error code, but this looks OK and handles the case
> I care about.
> 
> There is a case that I know it doesn't handle.  If you ask umount.nfs to
> unmount a filesystem that is not nfs or nfs4, then the old code will
> refuse
>   umount.nfs: /dev/sda7 on /mnt2 is not an NFS filesystem
> 
> and exit with status '1'.
> The new libmount code will just think that it couldn't find anything in
> fstab and will try to do an nfs23 unmount.  This is clearly different behaviour,
> I'm not sure that anyone would care though.
> 
> NeilBrown
> 
> 
> diff --git a/utils/mount/mount_libmount.c b/utils/mount/mount_libmount.c
> index e8f17a9..5c1116a 100644
> --- a/utils/mount/mount_libmount.c
> +++ b/utils/mount/mount_libmount.c
> @@ -173,6 +173,7 @@ static int umount_main(struct libmnt_context *cxt, int argc, char **argv)
>  {
>  	int rc, c;
>  	char *spec = NULL, *opts = NULL;
> +	int ret = EX_FAIL;
>  
>  	static const struct option longopts[] = {
>  		{ "force", 0, 0, 'f' },
> @@ -243,7 +244,7 @@ static int umount_main(struct libmnt_context *cxt, int argc, char **argv)
>  			/* strange, no entry in mtab or /proc not mounted */
>  			nfs_umount23(spec, "tcp,v3");
>  	}
> -
> +	ret = EX_FILEIO;
>  	rc = mnt_context_do_umount(cxt);	/* call umount(2) syscall */
>  	mnt_context_finalize_mount(cxt);	/* mtab update */
>  
> @@ -252,12 +253,10 @@ static int umount_main(struct libmnt_context *cxt, int argc, char **argv)
>  		umount_error(rc, spec);
>  		goto err;
>  	}
> -
> -	free(opts);
> -	return EX_SUCCESS;
> +	ret = EX_SUCCESS;
>  err:
>  	free(opts);
> -	return EX_FAIL;
> +	return ret;
>  }
>  
>  static int mount_main(struct libmnt_context *cxt, int argc, char **argv)
