Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60665 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753353Ab3BLVSC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2013 16:18:02 -0500
Date: Tue, 12 Feb 2013 16:18:00 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tim Gardner <tim.gardner@canonical.com>
Cc: linux-kernel@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH linux-next] lockd: nlmclnt_reclaim(): avoid stack overflow
Message-ID: <20130212211800.GG10267@fieldses.org>
References: <1360697595-62460-1-git-send-email-tim.gardner@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1360697595-62460-1-git-send-email-tim.gardner@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 12, 2013 at 12:33:15PM -0700, Tim Gardner wrote:
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
>  fs/lockd/clntlock.c         |    8 +++++++-
>  fs/lockd/clntproc.c         |    6 ++----
>  include/linux/lockd/lockd.h |    3 ++-
>  3 files changed, 11 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
> index 4885b53..5dd23ef 100644
> --- a/fs/lockd/clntlock.c
> +++ b/fs/lockd/clntlock.c
> @@ -220,10 +220,15 @@ reclaimer(void *ptr)
>  {
>  	struct nlm_host	  *host = (struct nlm_host *) ptr;
>  	struct nlm_wait	  *block;
> +	struct nlm_rqst   *req;
>  	struct file_lock *fl, *next;
>  	u32 nsmstate;
>  	struct net *net = host->net;
>  
> +	req = kmalloc(sizeof(*req), GFP_KERNEL);
> +	if (!req)
> +		return -ENOMEM;
> +

It caught my eye that this function has never actually returned anything
but 0 before....

But OK I don't think there's a problem there: it could already fail to
reclaim individual locks due to allocation or other failures, and could
fail to run entirely if kthread_run failed.

But maybe we should log the same "Locks for %s won't be reclaimed!"
error in this case that we would in the case the kthread_run() in
nlmclnt_recovery fails.

--b.

>  	allow_signal(SIGKILL);
>  
>  	down_write(&host->h_rwsem);
> @@ -253,7 +258,7 @@ restart:
>  		 */
>  		if (signalled())
>  			continue;
> -		if (nlmclnt_reclaim(host, fl) != 0)
> +		if (nlmclnt_reclaim(host, fl, req) != 0)
>  			continue;
>  		list_add_tail(&fl->fl_u.nfs_fl.list, &host->h_granted);
>  		if (host->h_nsmstate != nsmstate) {
> @@ -279,5 +284,6 @@ restart:
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
> -- 
> 1.7.9.5
> 
