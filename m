Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34555 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754476AbbGaVcv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Jul 2015 17:32:51 -0400
Date: Fri, 31 Jul 2015 17:32:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/9] nfsd: convert laundry_wq to something less nfsd4
 specific
Message-ID: <20150731213250.GB20543@fieldses.org>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438264341-18048-5-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1438264341-18048-5-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 30, 2015 at 09:52:15AM -0400, Jeff Layton wrote:
> Currently, nfsd uses a singlethread workqueue for this, but that's
> probably not necessary. If we have multiple namespaces, then there's no
> need to serialize the laundromat runs. They can run in parallel.

Running a singled-threaded workqueue for each namespace is one thing,
but if we're allowing multiple work items for one namespace to run
simultaneously then this would need more of an argument.

However...  I guess we only requeue this from the end of the work
itself, so there's no risk of concurrent execution here, OK, fine.

--b.

> 
> Also, create_singlethread_workqueue adds the WQ_MEM_RECLAIM flag, which
> doesn't really seem to be necessary. The laundromat jobs are always
> kicked off via a timer, and not from memory reclaim paths. There's no
> need for a rescuer thread.
> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 23 +++++------------------
>  fs/nfsd/nfsd.h      |  1 +
>  fs/nfsd/nfssvc.c    | 14 +++++++++++++-
>  3 files changed, 19 insertions(+), 19 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 79795c898dd1..977a8aee9122 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4376,7 +4376,6 @@ nfs4_laundromat(struct nfsd_net *nn)
>  	return new_timeo;
>  }
>  
> -static struct workqueue_struct *laundry_wq;
>  static void laundromat_main(struct work_struct *);
>  
>  static void
> @@ -4390,7 +4389,7 @@ laundromat_main(struct work_struct *laundry)
>  
>  	t = nfs4_laundromat(nn);
>  	dprintk("NFSD: laundromat_main - sleeping for %ld seconds\n", t);
> -	queue_delayed_work(laundry_wq, &nn->laundromat_work, t*HZ);
> +	queue_delayed_work(nfsd_laundry_wq, &nn->laundromat_work, t*HZ);
>  }
>  
>  static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_stid *stp)
> @@ -6587,7 +6586,8 @@ nfs4_state_start_net(struct net *net)
>  	nfsd4_client_tracking_init(net);
>  	printk(KERN_INFO "NFSD: starting %ld-second grace period (net %p)\n",
>  	       nn->nfsd4_grace, net);
> -	queue_delayed_work(laundry_wq, &nn->laundromat_work, nn->nfsd4_grace * HZ);
> +	queue_delayed_work(nfsd_laundry_wq, &nn->laundromat_work,
> +				nn->nfsd4_grace * HZ);
>  	return 0;
>  }
>  
> @@ -6601,22 +6601,10 @@ nfs4_state_start(void)
>  	ret = set_callback_cred();
>  	if (ret)
>  		return -ENOMEM;
> -	laundry_wq = create_singlethread_workqueue("nfsd4");
> -	if (laundry_wq == NULL) {
> -		ret = -ENOMEM;
> -		goto out_recovery;
> -	}
>  	ret = nfsd4_create_callback_queue();
> -	if (ret)
> -		goto out_free_laundry;
> -
> -	set_max_delegations();
> -
> -	return 0;
> +	if (!ret)
> +		set_max_delegations();
>  
> -out_free_laundry:
> -	destroy_workqueue(laundry_wq);
> -out_recovery:
>  	return ret;
>  }
>  
> @@ -6653,7 +6641,6 @@ nfs4_state_shutdown_net(struct net *net)
>  void
>  nfs4_state_shutdown(void)
>  {
> -	destroy_workqueue(laundry_wq);
>  	nfsd4_destroy_callback_queue();
>  }
>  
> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
> index cf980523898b..0199415344ff 100644
> --- a/fs/nfsd/nfsd.h
> +++ b/fs/nfsd/nfsd.h
> @@ -62,6 +62,7 @@ struct readdir_cd {
>  extern struct svc_program	nfsd_program;
>  extern struct svc_version	nfsd_version2, nfsd_version3,
>  				nfsd_version4;
> +extern struct workqueue_struct	*nfsd_laundry_wq;
>  extern struct mutex		nfsd_mutex;
>  extern spinlock_t		nfsd_drc_lock;
>  extern unsigned long		nfsd_drc_max_mem;
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index ad4e2377dd63..ced9944201a0 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -17,6 +17,7 @@
>  #include <linux/lockd/bind.h>
>  #include <linux/nfsacl.h>
>  #include <linux/seq_file.h>
> +#include <linux/workqueue.h>
>  #include <net/net_namespace.h>
>  #include "nfsd.h"
>  #include "cache.h"
> @@ -28,6 +29,9 @@
>  extern struct svc_program	nfsd_program;
>  static int			nfsd(void *vrqstp);
>  
> +/* A workqueue for nfsd-related cleanup tasks */
> +struct workqueue_struct		*nfsd_laundry_wq;
> +
>  /*
>   * nfsd_mutex protects nn->nfsd_serv -- both the pointer itself and the members
>   * of the svc_serv struct. In particular, ->sv_nrthreads but also to some
> @@ -224,11 +228,19 @@ static int nfsd_startup_generic(int nrservs)
>  	if (ret)
>  		goto dec_users;
>  
> +	ret = -ENOMEM;
> +	nfsd_laundry_wq = alloc_workqueue("%s", WQ_UNBOUND, 0, "nfsd-laundry");
> +	if (!nfsd_laundry_wq)
> +		goto out_racache;
> +
>  	ret = nfs4_state_start();
>  	if (ret)
> -		goto out_racache;
> +		goto out_wq;
>  	return 0;
>  
> +out_wq:
> +	destroy_workqueue(nfsd_laundry_wq);
> +	nfsd_laundry_wq = NULL;
>  out_racache:
>  	nfsd_racache_shutdown();
>  dec_users:
> -- 
> 2.4.3
