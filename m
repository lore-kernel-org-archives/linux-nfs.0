From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/3] mount.nfs: fix retry option settings with binary mount options
Date: Thu, 10 Apr 2008 10:43:46 -0400
Message-ID: <B6004229-62F1-4A06-A6A8-47A0EC58FCA3@oracle.com>
References: <1206822608-20154-1-git-send-email-jlayton@redhat.com> <1206822608-20154-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: steved@redhat.com, linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:50715 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755922AbYDJOpT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Apr 2008 10:45:19 -0400
In-Reply-To: <1206822608-20154-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff-

Is this also an issue for text-based mounts?

On Mar 29, 2008, at 4:30 PM, Jeff Layton wrote:
> Currently nfs4mount() sets the retry value to 10000 on both fg and bg
> mounts. It should be 2 for fg and 10000 for bg. nfsmount() sets it
> properly, but there is a potential corner case. If someone explicitly
> sets retry=10000 on a fg mount, then it will be reset to 2.
>
> Fix this by having retry default to -1 for both flavors, and then  
> reset if
> needed after the mount options have been parsed.
>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  utils/mount/nfs4mount.c |   10 +++++++++-
>  utils/mount/nfsmount.c  |   12 ++++++++----
>  2 files changed, 17 insertions(+), 5 deletions(-)
>
> diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
> index 311e5a0..af70551 100644
> --- a/utils/mount/nfs4mount.c
> +++ b/utils/mount/nfs4mount.c
> @@ -238,7 +238,7 @@ int nfs4mount(const char *spec, const char  
> *node, int flags,
>  	nocto = 0;
>  	noac = 0;
>  	unshared = 0;
> -	retry = 10000;		/* 10000 minutes ~ 1 week */
> +	retry = -1;
>
>  	/*
>  	 * NFSv4 specifies that the default port should be 2049
> @@ -332,6 +332,14 @@ int nfs4mount(const char *spec, const char  
> *node, int flags,
>  		}
>  	}
>
> +	/* if retry is still -1, then it wasn't set via an option */
> +	if (retry == -1) {
> +		if (bg)
> +			retry = 10000;	/* 10000 mins == ~1 week */
> +		else
> +			retry = 2;	/* 2 min default on fg mounts */
> +	}
> +
>  	data.flags = (soft ? NFS4_MOUNT_SOFT : 0)
>  		| (intr ? NFS4_MOUNT_INTR : 0)
>  		| (nocto ? NFS4_MOUNT_NOCTO : 0)
> diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
> index ff0ff93..27c46a7 100644
> --- a/utils/mount/nfsmount.c
> +++ b/utils/mount/nfsmount.c
> @@ -571,7 +571,7 @@ nfsmount(const char *spec, const char *node,  
> int flags,
>  #endif
>
>  	bg = 0;
> -	retry = 10000;		/* 10000 minutes ~ 1 week */
> +	retry = -1;
>
>  	memset(mnt_pmap, 0, sizeof(*mnt_pmap));
>  	mnt_pmap->pm_prog = MOUNTPROG;
> @@ -585,9 +585,13 @@ nfsmount(const char *spec, const char *node,  
> int flags,
>  		goto fail;
>  	if (!nfsmnt_check_compat(nfs_pmap, mnt_pmap))
>  		goto fail;
> -	
> -	if (retry == 10000 && !bg)
> -		retry = 2; /* reset for fg mounts */
> +
> +	if (retry == -1) {
> +		if (bg)
> +			retry = 10000;	/* 10000 mins == ~1 week*/
> +		else
> +			retry = 2;	/* 2 min default on fg mounts */
> +	}
>
>  #ifdef NFS_MOUNT_DEBUG
>  	printf(_("rsize = %d, wsize = %d, timeo = %d, retrans = %d\n"),
> -- 
> 1.5.3.6
>
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



