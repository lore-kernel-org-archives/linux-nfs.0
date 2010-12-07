Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47613 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751289Ab0LGWis convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Dec 2010 17:38:48 -0500
Subject: Re: [PATCH] NFS: Fix fcntl F_GETLK not reporting some conflicts
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Sergey Vlasov <vsu@altlinux.ru>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Alexander Morozov <amorozov@etersoft.ru>, stable@kernel.org
In-Reply-To: <1290978245-14415-1-git-send-email-vsu@altlinux.ru>
References: <1290978245-14415-1-git-send-email-vsu@altlinux.ru>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Dec 2010 17:38:46 -0500
Message-ID: <1291761526.3049.48.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-11-29 at 00:04 +0300, Sergey Vlasov wrote:
> The commit 129a84de2347002f09721cda3155ccfd19fade40 (locks: fix F_GETLK
> regression (failure to find conflicts)) fixed the posix_test_lock()
> function by itself, however, its usage in NFS changed by the commit
> 9d6a8c5c213e34c475e72b245a8eb709258e968c (locks: give posix_test_lock
> same interface as ->lock) remained broken - subsequent NFS-specific
> locking code received F_UNLCK instead of the user-specified lock type.
> To fix the problem, fl->fl_type needs to be saved before the
> posix_test_lock() call and restored if no local conflicts were reported.
> 
> Reference: https://bugzilla.kernel.org/show_bug.cgi?id=23892
> Tested-by: Alexander Morozov <amorozov@etersoft.ru>
> Signed-off-by: Sergey Vlasov <vsu@altlinux.ru>
> Cc: <stable@kernel.org>
> ---
>  fs/nfs/file.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
>  There seems to be a similar bug in fs/9p/vfs_file.c:v9fs_file_getlock()
>  and an even worse confusion in fs/afs/flock.c:afs_do_getlk(), but I
>  can't test them.
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 60677f9..7bf029e 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -693,6 +693,7 @@ do_getlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
>  {
>  	struct inode *inode = filp->f_mapping->host;
>  	int status = 0;
> +	unsigned int saved_type = fl->fl_type;
>  
>  	/* Try local locking first */
>  	posix_test_lock(filp, fl);
> @@ -700,6 +701,7 @@ do_getlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
>  		/* found a conflict */
>  		goto out;
>  	}
> +	fl->fl_type = saved_type;
>  
>  	if (nfs_have_delegation(inode, FMODE_READ))
>  		goto out_noconflict;

Thanks! Applied...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

