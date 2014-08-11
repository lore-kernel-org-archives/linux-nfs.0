Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:46529 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100AbaHKQqM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Aug 2014 12:46:12 -0400
Received: by mail-qa0-f46.google.com with SMTP id v10so8004952qac.5
        for <linux-nfs@vger.kernel.org>; Mon, 11 Aug 2014 09:46:11 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 11 Aug 2014 12:46:10 -0400
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 3/3 v2] NFSD: Increase the reference of lockowner when
 coping file_lock
Message-ID: <20140811124610.16f49168@tlielax.poochiereds.net>
In-Reply-To: <53E7933D.80504@gmail.com>
References: <53BAAAC5.9000106@gmail.com>
	<53E22EA5.70708@gmail.com>
	<20140809065112.700e0ecc@tlielax.poochiereds.net>
	<53E791F1.40802@gmail.com>
	<53E7933D.80504@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 10 Aug 2014 23:43:57 +0800
Kinglong Mee <kinglongmee@gmail.com> wrote:

> v2: Fix bad using of struct file_lock_operations for handle the owner.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4state.c | 32 ++++++++++++++++++++++++++++++--
>  1 file changed, 30 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 2e80a59..24a8d91 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4867,9 +4867,33 @@ nfs4_transform_lock_offset(struct file_lock *lock)
>  		lock->fl_end = OFFSET_MAX;
>  }
>  
> +static inline struct nfs4_lockowner *get_lockowner(struct nfs4_lockowner *lo)
> +{
> +	atomic_inc(&lo->lo_owner.so_count);
> +	return lo;
> +}
> +

The other places that increment the so_count on a lockowner should
probably be changed to use get_lockowner.

Or what may be better is to make a nfs4_get_stateowner call and change
all of the places that bump the so_count to use it. Then you could just
do something like this in the right spot below:

    file_lock->fl_owner = (fl_owner_t)lockowner(nfs4_get_stateowner(lock_sop));

...
> +static void nfsd4_fl_copy_owner(struct file_lock *dst, struct file_lock *src)
> +{
> +	struct nfs4_lockowner *lo = (struct nfs4_lockowner *) src->fl_owner;
> +	dst->fl_owner = (fl_owner_t) get_lockowner(lo);
> +}
> +
> +static void nfsd4_fl_release_owner(struct file_lock *fl)
> +{
> +	struct nfs4_lockowner *lo = (struct nfs4_lockowner *) fl->fl_owner;
> +
> +	if (lo) {
> +		nfs4_put_stateowner(&lo->lo_owner);
> +		fl->fl_owner = NULL;
> +	}
> +}
> +
>  /* Hack!: For now, we're defining this just so we can use a pointer to it
>   * as a unique cookie to identify our (NFSv4's) posix locks. */

The above comment should be removed now.

>  static const struct lock_manager_operations nfsd_posix_mng_ops  = {
> +	.lm_copy_owner = nfsd4_fl_copy_owner,
> +	.lm_release_owner = nfsd4_fl_release_owner,
>  };
>  
>  static inline void
> @@ -5238,7 +5262,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		status = nfserr_openmode;
>  		goto out;
>  	}
> -	file_lock->fl_owner = (fl_owner_t)lock_sop;
> +
> +	file_lock->fl_owner = (fl_owner_t)get_lockowner(lock_sop);
>  	file_lock->fl_pid = current->tgid;
>  	file_lock->fl_file = filp;
>  	file_lock->fl_flags = FL_POSIX;
> @@ -5405,6 +5430,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	struct nfs4_ol_stateid *stp;
>  	struct file *filp = NULL;
>  	struct file_lock *file_lock = NULL;
> +	struct nfs4_lockowner *lock_sop = NULL;
>  	__be32 status;
>  	int err;
>  	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
> @@ -5426,6 +5452,8 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		status = nfserr_lock_range;
>  		goto put_stateid;
>  	}
> +
> +	lock_sop = lockowner(stp->st_stateowner);
>  	file_lock = locks_alloc_lock();
>  	if (!file_lock) {
>  		dprintk("NFSD: %s: unable to allocate lock!\n", __func__);
> @@ -5434,7 +5462,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	}
>  	locks_init_lock(file_lock);
>  	file_lock->fl_type = F_UNLCK;
> -	file_lock->fl_owner = (fl_owner_t)lockowner(stp->st_stateowner);
> +	file_lock->fl_owner = (fl_owner_t)get_lockowner(lock_sop);
>  	file_lock->fl_pid = current->tgid;
>  	file_lock->fl_file = filp;
>  	file_lock->fl_flags = FL_POSIX;


-- 
Jeff Layton <jlayton@primarydata.com>
