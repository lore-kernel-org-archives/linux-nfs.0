Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43882 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752284AbdKIO4Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 09:56:16 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Remove the flock check for matching open mode
Date: Thu, 09 Nov 2017 09:56:14 -0500
Message-ID: <6B458A09-CDD9-4997-BBF0-0CC5614539EA@redhat.com>
In-Reply-To: <1c7f83fe32ca8699c745629a3ad0581c7f75b1ee.1508337840.git.bcodding@redhat.com>
References: <1c7f83fe32ca8699c745629a3ad0581c7f75b1ee.1508337840.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Self-NACK.  I think the client assumes that it always sends operations
matching the openmode, so NFS4ERR_OPENMODE returned from the server can 
be
assumed to be the result of a revoked or expired state.  In order to 
pass
the server's results back up to fcntl(), we'd need a way to determine if 
the
LOCK's state hasn't been revoked.

I don't think its worth the work or time to fix up error handling for 
this
one case, so probably the best thing to do is accept that commit
e12937279c8b was just plain wrong and revert it.

Ben

On 18 Oct 2017, at 10:44, Benjamin Coddington wrote:

> Commit e12937279c8b "NFS: Move the flock open mode check into 
> nfs_flock()"
> changed NFSv3 behavior for flock() such that the open mode must match 
> the
> lock type, however this requirement shouldn't be enforced for flock().
>
> Since FL_POSIX locks are already checked in fs/locks.c, remove this 
> check
> in NFS altogether.  For NFSv4, allow the server to determine whether 
> or not
> the mode should match the lock type for flock().
>
> Suggested-by: Trond Myklebust <trond.myklebust@primarydata.com>
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/file.c | 16 +---------------
>  1 file changed, 1 insertion(+), 15 deletions(-)
>
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index af330c31f627..ca7e737810e4 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -822,22 +822,8 @@ int nfs_flock(struct file *filp, int cmd, struct 
> file_lock *fl)
>  	if (NFS_SERVER(inode)->flags & NFS_MOUNT_LOCAL_FLOCK)
>  		is_local = 1;
>
> -	/*
> -	 * VFS doesn't require the open mode to match a flock() lock's type.
> -	 * NFS, however, may simulate flock() locking with posix locking 
> which
> -	 * requires the open mode to match the lock type.
> -	 */
> -	switch (fl->fl_type) {
> -	case F_UNLCK:
> +	if (fl->fl_type == F_UNLCK)
>  		return do_unlk(filp, cmd, fl, is_local);
> -	case F_RDLCK:
> -		if (!(filp->f_mode & FMODE_READ))
> -			return -EBADF;
> -		break;
> -	case F_WRLCK:
> -		if (!(filp->f_mode & FMODE_WRITE))
> -			return -EBADF;
> -	}
>
>  	return do_setlk(filp, cmd, fl, is_local);
>  }
> -- 
> 2.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
