Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:42265 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119AbaGAOnR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2014 10:43:17 -0400
Received: by mail-qc0-f179.google.com with SMTP id x3so8626374qcv.10
        for <linux-nfs@vger.kernel.org>; Tue, 01 Jul 2014 07:43:17 -0700 (PDT)
Date: Tue, 1 Jul 2014 10:43:13 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Joe Perches <joe@perches.com>
Cc: Christine Caulfield <ccaulfie@redhat.com>,
        David Teigland <teigland@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, cluster-devel@redhat.com,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [RFC PATCH] dlm: Remove unused conf from lm_grant
Message-ID: <20140701104313.5317400a@tlielax.poochiereds.net>
In-Reply-To: <1404220810.2717.39.camel@joe-AO725>
References: <1404220810.2717.39.camel@joe-AO725>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 01 Jul 2014 06:20:10 -0700
Joe Perches <joe@perches.com> wrote:

> While doing a bit of adding argument names to fs.h,
> I looked at lm_grant and it seems the 2nd argument
> is always NULL.
> 
> How about removing it?
> 
> This doesn't apply as it depends on some other patches
> but it should be clear enough...
> 

ACK on the general idea from my standpoint. Anything that simplifies
the file locking interfaces is a good thing, particularly the deferred
locking code.

> ---
>  fs/dlm/plock.c     |  8 ++++----
>  fs/lockd/svclock.c | 12 +++---------
>  include/linux/fs.h |  2 +-
>  3 files changed, 8 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/dlm/plock.c b/fs/dlm/plock.c
> index e59d332..e0ab3a9 100644
> --- a/fs/dlm/plock.c
> +++ b/fs/dlm/plock.c
> @@ -30,7 +30,7 @@ struct plock_op {
>  
>  struct plock_xop {
>  	struct plock_op xop;
> -	int (*callback)(struct file_lock *, struct file_lock *, int);
> +	int (*callback)(struct file_lock *fl, int result);
>  	void *fl;
>  	void *file;
>  	struct file_lock flc;
> @@ -190,7 +190,7 @@ static int dlm_plock_callback(struct plock_op *op)
>  	struct file *file;
>  	struct file_lock *fl;
>  	struct file_lock *flc;
> -	int (*notify)(struct file_lock *fl, struct file_lock *cont, int result) = NULL;
> +	int (*notify)(struct file_lock *fl, int result) = NULL;
>  	struct plock_xop *xop = (struct plock_xop *)op;
>  	int rv = 0;
>  
> @@ -209,7 +209,7 @@ static int dlm_plock_callback(struct plock_op *op)
>  	notify = xop->callback;
>  
>  	if (op->info.rv) {
> -		notify(fl, NULL, op->info.rv);
> +		notify(fl, op->info.rv);
>  		goto out;
>  	}
>  
> @@ -228,7 +228,7 @@ static int dlm_plock_callback(struct plock_op *op)
>  			  (unsigned long long)op->info.number, file, fl);
>  	}
>  
> -	rv = notify(fl, NULL, 0);
> +	rv = notify(fl, 0);
>  	if (rv) {
>  		/* XXX: We need to cancel the fs lock here: */
>  		log_print("dlm_plock_callback: lock granted after lock request "
> diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> index ab798a8..2a61701 100644
> --- a/fs/lockd/svclock.c
> +++ b/fs/lockd/svclock.c
> @@ -667,22 +667,16 @@ nlmsvc_cancel_blocked(struct net *net, struct nlm_file *file, struct nlm_lock *l
>   * deferred rpc for GETLK and SETLK.
>   */
>  static void
> -nlmsvc_update_deferred_block(struct nlm_block *block, struct file_lock *conf,
> -			     int result)
> +nlmsvc_update_deferred_block(struct nlm_block *block, int result)
>  {
>  	block->b_flags |= B_GOT_CALLBACK;
>  	if (result == 0)
>  		block->b_granted = 1;
>  	else
>  		block->b_flags |= B_TIMED_OUT;
> -	if (conf) {
> -		if (block->b_fl)
> -			__locks_copy_lock(block->b_fl, conf);
> -	}
>  }
>  
> -static int nlmsvc_grant_deferred(struct file_lock *fl, struct file_lock *conf,
> -					int result)
> +static int nlmsvc_grant_deferred(struct file_lock *fl, int result)
>  {
>  	struct nlm_block *block;
>  	int rc = -ENOENT;
> @@ -697,7 +691,7 @@ static int nlmsvc_grant_deferred(struct file_lock *fl, struct file_lock *conf,
>  					rc = -ENOLCK;
>  					break;
>  				}
> -				nlmsvc_update_deferred_block(block, conf, result);
> +				nlmsvc_update_deferred_block(block, result);
>  			} else if (result == 0)
>  				block->b_granted = 1;
>  
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 36b8648..6150125 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -842,7 +842,7 @@ struct lock_manager_operations {
>  	int (*lm_compare_owner)(struct file_lock *fl1, struct file_lock *fl2);
>  	unsigned long (*lm_owner_key)(struct file_lock *fl);
>  	void (*lm_notify)(struct file_lock *fl);	/* unblock callback */
> -	int (*lm_grant)(struct file_lock *fl, struct file_lock *conf, int result);
> +	int (*lm_grant)(struct file_lock *fl, int result);
>  	void (*lm_break)(struct file_lock *fl);
>  	int (*lm_change)(struct file_lock **fl, int type);
>  };


-- 
Jeff Layton <jlayton@poochiereds.net>
