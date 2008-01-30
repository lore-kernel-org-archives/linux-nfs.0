From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/3] NLM enable per-ip base grace period
Date: Tue, 29 Jan 2008 19:23:13 -0500
Message-ID: <20080130002313.GS28032@fieldses.org>
References: <4799714B.9070900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43204 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754614AbYA3AXP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jan 2008 19:23:15 -0500
In-Reply-To: <4799714B.9070900@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for the patches; a few more comments below:

On Fri, Jan 25, 2008 at 12:19:07AM -0500, Wendy Cheng wrote:
> Hooks are added into the existing lockd global grace period checking to  
> enable per-ip base grace period.
>
> -- Wendy
>
>

> Hooks are added into the existing lockd global grace period checking
> to enable per-ip base grace period. 
> 
> Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
> Signed-off-by: Lon Hohberger  <lhh@redhat.com>
> 
>  fs/lockd/svc.c              |    3 ++-
>  fs/lockd/svc4proc.c         |   13 ++++++-------
>  fs/lockd/svcproc.c          |   12 ++++++------
>  include/linux/lockd/lockd.h |   20 ++++++++++++++++++++
>  4 files changed, 34 insertions(+), 14 deletions(-)
> 
> --- linux-3/fs/lockd/svc4proc.c	2008-01-22 12:01:33.000000000 -0500
> +++ linux-4/fs/lockd/svc4proc.c	2008-01-24 17:44:12.000000000 -0500
> @@ -18,7 +18,6 @@
>  #include <linux/lockd/share.h>
>  #include <linux/lockd/sm_inter.h>
>  
> -
>  #define NLMDBG_FACILITY		NLMDBG_CLIENT
>  
>  /*
> @@ -89,7 +88,7 @@ nlm4svc_proc_test(struct svc_rqst *rqstp
>  	resp->cookie = argp->cookie;
>  
>  	/* Don't accept test requests during grace period */
> -	if (nlmsvc_grace_period) {
> +	if (nlmsvc_check_grace_period(rqstp, argp)) {
>  		resp->status = nlm_lck_denied_grace_period;
>  		return rpc_success;
>  	}
> @@ -121,7 +120,7 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp
>  	resp->cookie = argp->cookie;
>  
>  	/* Don't accept new lock requests during grace period */
> -	if (nlmsvc_grace_period && !argp->reclaim) {
> +	if (nlmsvc_check_grace_period(rqstp, argp) && !argp->reclaim) {
>  		resp->status = nlm_lck_denied_grace_period;
>  		return rpc_success;
>  	}
> @@ -166,7 +165,7 @@ nlm4svc_proc_cancel(struct svc_rqst *rqs
>  	resp->cookie = argp->cookie;
>  
>  	/* Don't accept requests during grace period */
> -	if (nlmsvc_grace_period) {
> +	if (nlmsvc_check_grace_period(rqstp, argp)) {
>  		resp->status = nlm_lck_denied_grace_period;
>  		return rpc_success;
>  	}
> @@ -199,7 +198,7 @@ nlm4svc_proc_unlock(struct svc_rqst *rqs
>  	resp->cookie = argp->cookie;
>  
>  	/* Don't accept new lock requests during grace period */
> -	if (nlmsvc_grace_period) {
> +	if (nlmsvc_check_grace_period(rqstp, argp)) {
>  		resp->status = nlm_lck_denied_grace_period;
>  		return rpc_success;
>  	}
> @@ -336,7 +335,7 @@ nlm4svc_proc_share(struct svc_rqst *rqst
>  	resp->cookie = argp->cookie;
>  
>  	/* Don't accept new lock requests during grace period */
> -	if (nlmsvc_grace_period && !argp->reclaim) {
> +	if (nlmsvc_check_grace_period(rqstp, argp) && !argp->reclaim) {
>  		resp->status = nlm_lck_denied_grace_period;
>  		return rpc_success;
>  	}
> @@ -369,7 +368,7 @@ nlm4svc_proc_unshare(struct svc_rqst *rq
>  	resp->cookie = argp->cookie;
>  
>  	/* Don't accept requests during grace period */
> -	if (nlmsvc_grace_period) {
> +	if (nlmsvc_check_grace_period(rqstp, argp)) {
>  		resp->status = nlm_lck_denied_grace_period;
>  		return rpc_success;
>  	}
> --- linux-3/fs/lockd/svcproc.c	2008-01-22 12:01:33.000000000 -0500
> +++ linux-4/fs/lockd/svcproc.c	2008-01-24 17:45:04.000000000 -0500
> @@ -118,7 +118,7 @@ nlmsvc_proc_test(struct svc_rqst *rqstp,
>  	resp->cookie = argp->cookie;
>  
>  	/* Don't accept test requests during grace period */
> -	if (nlmsvc_grace_period) {
> +	if (nlmsvc_check_grace_period(rqstp, argp)) {
>  		resp->status = nlm_lck_denied_grace_period;
>  		return rpc_success;
>  	}
> @@ -151,7 +151,7 @@ nlmsvc_proc_lock(struct svc_rqst *rqstp,
>  	resp->cookie = argp->cookie;
>  
>  	/* Don't accept new lock requests during grace period */
> -	if (nlmsvc_grace_period && !argp->reclaim) {
> +	if (nlmsvc_check_grace_period(rqstp, argp) && !argp->reclaim) {
>  		resp->status = nlm_lck_denied_grace_period;
>  		return rpc_success;
>  	}
> @@ -196,7 +196,7 @@ nlmsvc_proc_cancel(struct svc_rqst *rqst
>  	resp->cookie = argp->cookie;
>  
>  	/* Don't accept requests during grace period */
> -	if (nlmsvc_grace_period) {
> +	if (nlmsvc_check_grace_period(rqstp, argp)) {
>  		resp->status = nlm_lck_denied_grace_period;
>  		return rpc_success;
>  	}
> @@ -229,7 +229,7 @@ nlmsvc_proc_unlock(struct svc_rqst *rqst
>  	resp->cookie = argp->cookie;
>  
>  	/* Don't accept new lock requests during grace period */
> -	if (nlmsvc_grace_period) {
> +	if (nlmsvc_check_grace_period(rqstp, argp)) {
>  		resp->status = nlm_lck_denied_grace_period;
>  		return rpc_success;
>  	}
> @@ -368,7 +368,7 @@ nlmsvc_proc_share(struct svc_rqst *rqstp
>  	resp->cookie = argp->cookie;
>  
>  	/* Don't accept new lock requests during grace period */
> -	if (nlmsvc_grace_period && !argp->reclaim) {
> +	if (nlmsvc_check_grace_period(rqstp, argp) && !argp->reclaim) {
>  		resp->status = nlm_lck_denied_grace_period;
>  		return rpc_success;
>  	}
> @@ -401,7 +401,7 @@ nlmsvc_proc_unshare(struct svc_rqst *rqs
>  	resp->cookie = argp->cookie;
>  
>  	/* Don't accept requests during grace period */
> -	if (nlmsvc_grace_period) {
> +	if (nlmsvc_check_grace_period(rqstp, argp)) {
>  		resp->status = nlm_lck_denied_grace_period;
>  		return rpc_success;
>  	}
> --- linux-3/fs/lockd/svc.c	2008-01-24 17:30:55.000000000 -0500
> +++ linux-4/fs/lockd/svc.c	2008-01-24 17:41:40.000000000 -0500
> @@ -97,7 +97,7 @@ unsigned long get_nfs_grace_period(void)
>  }
>  EXPORT_SYMBOL(get_nfs_grace_period);
>  
> -static unsigned long set_grace_period(void)
> +unsigned long set_grace_period(void)

If this is needed, then it belongs with the previous patch, doesn't it?

>  {
>  	nlmsvc_grace_period = 1;
>  	return get_nfs_grace_period() + jiffies;
> @@ -208,6 +208,7 @@ lockd(struct svc_rqst *rqstp)
>  		nlm_shutdown_hosts();
>  		nlmsvc_pid = 0;
>  		nlmsvc_serv = NULL;
> +		nlmsvc_failover_reset();

Ditto.  But I thought the previous patch already added an
nlmsvc_failover_reset() call just a few lines below.

>  	} else
>  		printk(KERN_DEBUG
>  			"lockd: new process, skipping host shutdown\n");
> --- linux-3/include/linux/lockd/lockd.h	2008-01-24 17:09:26.000000000 -0500
> +++ linux-4/include/linux/lockd/lockd.h	2008-01-24 17:41:40.000000000 -0500
> @@ -222,6 +222,7 @@ int           nlmsvc_failover_path(struc
>  int           nlmsvc_failover_ip(__be32 server_addr);
>  int           nlmsvc_failover_setgrace(void *server_ip, int ip_size);
>  void          nlmsvc_failover_reset(void);
> +int           nlmsvc_failover_check(struct svc_rqst *rqstp);
>  
>  #define NLM_FO_MAX_GP_CNT	1024
>  
> @@ -236,6 +237,25 @@ struct nlm_failover_struct {
>  #define g_ip			g_key.ipv6
>  };
>  
> +extern struct list_head nlm_failover_list;
> +
> +/*Check for grace period: return TRUE or FALSE */
> +static inline int
> +nlmsvc_check_grace_period(struct svc_rqst *rqstp, struct nlm_args *argp)
> +{
> +	/* check for system wide grace period */
> +	if (nlmsvc_grace_period)
> +		return 1;
> +
> +	/* check for per exported fsid grace period */

The "per exported fsid" comment seems to be out of date.

> +	if (unlikely(!list_empty(&nlm_failover_list)))
> +		return(nlmsvc_failover_check(rqstp));

Drop the parentheses after "return".

Is the "unlikely" a good idea?  I don't know what the rule of thumb is
for those.

> +
> +	return 0;
> +}
> +
> +/* end of cluster failover addition */
> +
>  static __inline__ struct inode *
>  nlmsvc_file_inode(struct nlm_file *file)
>  {

