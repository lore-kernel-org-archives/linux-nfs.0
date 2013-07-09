Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38370 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751834Ab3GILAi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 07:00:38 -0400
Date: Tue, 9 Jul 2013 07:00:19 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 05/12] locks: introduce new FL_DELEG lock flag
Message-ID: <20130709070019.1ca22086@tlielax.poochiereds.net>
In-Reply-To: <1372882356-14168-6-git-send-email-bfields@redhat.com>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
	<1372882356-14168-6-git-send-email-bfields@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed,  3 Jul 2013 16:12:29 -0400
"J. Bruce Fields" <bfields@redhat.com> wrote:

> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> For now FL_DELEG is just a synonym for FL_LEASE.  So this patch doesn't
> change behavior.
> 
> Next we'll modify break_lease to treat FL_DELEG leases differently, to
> account for the fact that NFSv4 delegations should be broken in more
> situations than Windows oplocks.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/locks.c          |    2 +-
>  fs/nfsd/nfs4state.c |    2 +-
>  include/linux/fs.h  |    1 +
>  3 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index cb424a4..deec4de 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -131,7 +131,7 @@
>  
>  #define IS_POSIX(fl)	(fl->fl_flags & FL_POSIX)
>  #define IS_FLOCK(fl)	(fl->fl_flags & FL_FLOCK)
> -#define IS_LEASE(fl)	(fl->fl_flags & FL_LEASE)
> +#define IS_LEASE(fl)	(fl->fl_flags & (FL_LEASE|FL_DELEG))
>  
>  static bool lease_breaking(struct file_lock *fl)
>  {
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 316ec84..616ff83 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2932,7 +2932,7 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp, int f
>  		return NULL;
>  	locks_init_lock(fl);
>  	fl->fl_lmops = &nfsd_lease_mng_ops;
> -	fl->fl_flags = FL_LEASE;
> +	fl->fl_flags = FL_DELEG;
>  	fl->fl_type = flag == NFS4_OPEN_DELEGATE_READ? F_RDLCK: F_WRLCK;
>  	fl->fl_end = OFFSET_MAX;
>  	fl->fl_owner = (fl_owner_t)(dp->dl_file);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index ec88235..116b3e9 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -884,6 +884,7 @@ static inline int file_check_writeable(struct file *filp)
>  
>  #define FL_POSIX	1
>  #define FL_FLOCK	2
> +#define FL_DELEG	4	/* NFSv4 delegation */
>  #define FL_ACCESS	8	/* not trying to lock, just looking */
>  #define FL_EXISTS	16	/* when unlocking, test for existence */
>  #define FL_LEASE	32	/* lease held on this file */

Acked-by: Jeff Layton <jlayton@redhat.com>
