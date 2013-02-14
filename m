Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32736 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758188Ab3BNPUr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Feb 2013 10:20:47 -0500
Date: Thu, 14 Feb 2013 10:20:38 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Tim Gardner <tim.gardner@canonical.com>
Cc: linux-kernel@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH linux-next v2] lockd: nlmclnt_reclaim(): avoid stack
 overflow
Message-ID: <20130214102038.52b1d292@tlielax.poochiereds.net>
In-Reply-To: <1360770016-69586-1-git-send-email-tim.gardner@canonical.com>
References: <20130212211800.GG10267@fieldses.org>
	<1360770016-69586-1-git-send-email-tim.gardner@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 13 Feb 2013 08:40:16 -0700
Tim Gardner <tim.gardner@canonical.com> wrote:

> Even though nlmclnt_reclaim() is only one call into the stack frame,
> 928 bytes on the stack seems like a lot. Recode to dynamically
> allocate the request structure once from within the reclaimer task,
> then pass this pointer into nlmclnt_reclaim() for reuse on
> subsequent calls.
> 
> smatch analysis:
> 
> fs/lockd/clntproc.c:620 nlmclnt_reclaim() warn: 'reqst' puts
>  928 bytes on stack
> 
> Also remove redundant assignment of 0 after memset.
> 
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: linux-nfs@vger.kernel.org
> Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
> ---
> 
> Changes from v1 -- don't return -ENOMEM from a task thread because it is
> not propagated to the task creator. Instead print an error message and return.
> 
>  fs/lockd/clntlock.c         |   12 +++++++++++-
>  fs/lockd/clntproc.c         |    6 ++----
>  include/linux/lockd/lockd.h |    3 ++-
>  3 files changed, 15 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
> index 4885b53..6cd673d 100644
> --- a/fs/lockd/clntlock.c
> +++ b/fs/lockd/clntlock.c
> @@ -220,10 +220,19 @@ reclaimer(void *ptr)
>  {
>  	struct nlm_host	  *host = (struct nlm_host *) ptr;
>  	struct nlm_wait	  *block;
> +	struct nlm_rqst   *req;
>  	struct file_lock *fl, *next;
>  	u32 nsmstate;
>  	struct net *net = host->net;
>  
> +	req = kmalloc(sizeof(*req), GFP_KERNEL);
> +	if (!req) {
> +		printk(KERN_ERR "lockd: reclaimer unable to alloc memory."
> +				" Locks for %s won't be reclaimed!\n",
> +				host->h_name);
> +		return 0;
> +	}
> +
>  	allow_signal(SIGKILL);
>  
>  	down_write(&host->h_rwsem);
> @@ -253,7 +262,7 @@ restart:
>  		 */
>  		if (signalled())
>  			continue;
> -		if (nlmclnt_reclaim(host, fl) != 0)
> +		if (nlmclnt_reclaim(host, fl, req) != 0)
>  			continue;
>  		list_add_tail(&fl->fl_u.nfs_fl.list, &host->h_granted);
>  		if (host->h_nsmstate != nsmstate) {
> @@ -279,5 +288,6 @@ restart:
>  	/* Release host handle after use */
>  	nlmclnt_release_host(host);
>  	lockd_down(net);
> +	kfree(req);
>  	return 0;
>  }
> diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
> index 54f9e6c..b43114c 100644
> --- a/fs/lockd/clntproc.c
> +++ b/fs/lockd/clntproc.c
> @@ -615,17 +615,15 @@ out_unlock:
>   * RECLAIM: Try to reclaim a lock
>   */
>  int
> -nlmclnt_reclaim(struct nlm_host *host, struct file_lock *fl)
> +nlmclnt_reclaim(struct nlm_host *host, struct file_lock *fl,
> +		struct nlm_rqst *req)
>  {
> -	struct nlm_rqst reqst, *req;
>  	int		status;
>  
> -	req = &reqst;
>  	memset(req, 0, sizeof(*req));
>  	locks_init_lock(&req->a_args.lock.fl);
>  	locks_init_lock(&req->a_res.lock.fl);
>  	req->a_host  = host;
> -	req->a_flags = 0;
>  
>  	/* Set up the argument struct */
>  	nlmclnt_setlockargs(req, fl);
> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
> index f5a051a..a395f1e 100644
> --- a/include/linux/lockd/lockd.h
> +++ b/include/linux/lockd/lockd.h
> @@ -212,7 +212,8 @@ int		  nlmclnt_block(struct nlm_wait *block, struct nlm_rqst *req, long timeout)
>  __be32		  nlmclnt_grant(const struct sockaddr *addr,
>  				const struct nlm_lock *lock);
>  void		  nlmclnt_recovery(struct nlm_host *);
> -int		  nlmclnt_reclaim(struct nlm_host *, struct file_lock *);
> +int		  nlmclnt_reclaim(struct nlm_host *, struct file_lock *,
> +				  struct nlm_rqst *);
>  void		  nlmclnt_next_cookie(struct nlm_cookie *);
>  
>  /*

Oops, just noticed there was a later version of this patch. Please
disregard my earlier mail...

Reviewed-by: Jeff Layton <jlayton@redhat.com>
