Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52929 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754799Ab1LFVtc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Dec 2011 16:49:32 -0500
Date: Tue, 6 Dec 2011 16:49:28 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org, xemul@parallels.com,
        neilb@suse.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, davem@davemloft.net, devel@openvz.org
Subject: Re: [PATCH 2/2] SUNRPC: register service stats /proc entries in
 passed network namespace context
Message-ID: <20111206214928.GF12640@fieldses.org>
References: <20111206123748.15702.93290.stgit@localhost6.localdomain6>
 <20111206124249.15702.211.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111206124249.15702.211.stgit@localhost6.localdomain6>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 06, 2011 at 04:42:49PM +0300, Stanislav Kinsbursky wrote:
> This patch makes it possible to create NFSd program entry ("/proc/net/rpc/nfsd")
> in passed network namespace context instead of hard-coded "init_net".

	Acked-by: J. Bruce Fields <bfields@redhat.com>

Or I can just apply it.  I'll assume it's going through Trond's tree
unless I hear otherwise.

--b.

> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> 
> ---
>  fs/nfsd/stats.c              |    5 +++--
>  include/linux/sunrpc/stats.h |    8 ++++----
>  net/sunrpc/stats.c           |    8 ++++----
>  3 files changed, 11 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfsd/stats.c b/fs/nfsd/stats.c
> index a2e2402..6d4521f 100644
> --- a/fs/nfsd/stats.c
> +++ b/fs/nfsd/stats.c
> @@ -25,6 +25,7 @@
>  #include <linux/module.h>
>  #include <linux/sunrpc/stats.h>
>  #include <linux/nfsd/stats.h>
> +#include <net/net_namespace.h>
>  
>  #include "nfsd.h"
>  
> @@ -94,11 +95,11 @@ static const struct file_operations nfsd_proc_fops = {
>  void
>  nfsd_stat_init(void)
>  {
> -	svc_proc_register(&nfsd_svcstats, &nfsd_proc_fops);
> +	svc_proc_register(&init_net, &nfsd_svcstats, &nfsd_proc_fops);
>  }
>  
>  void
>  nfsd_stat_shutdown(void)
>  {
> -	svc_proc_unregister("nfsd");
> +	svc_proc_unregister(&init_net, "nfsd");
>  }
> diff --git a/include/linux/sunrpc/stats.h b/include/linux/sunrpc/stats.h
> index f625b57..4720b12 100644
> --- a/include/linux/sunrpc/stats.h
> +++ b/include/linux/sunrpc/stats.h
> @@ -61,9 +61,9 @@ void			rpc_modcount(struct inode *, int);
>  struct proc_dir_entry *	rpc_proc_register(struct net *,struct rpc_stat *);
>  void			rpc_proc_unregister(struct net *,const char *);
>  void			rpc_proc_zero(struct rpc_program *);
> -struct proc_dir_entry *	svc_proc_register(struct svc_stat *,
> +struct proc_dir_entry *	svc_proc_register(struct net *, struct svc_stat *,
>  					  const struct file_operations *);
> -void			svc_proc_unregister(const char *);
> +void			svc_proc_unregister(struct net *, const char *);
>  
>  void			svc_seq_show(struct seq_file *,
>  				     const struct svc_stat *);
> @@ -73,9 +73,9 @@ static inline struct proc_dir_entry *rpc_proc_register(struct net *, struct rpc_
>  static inline void rpc_proc_unregisterstruct net *, (const char *p) {}
>  static inline void rpc_proc_zero(struct rpc_program *p) {}
>  
> -static inline struct proc_dir_entry *svc_proc_register(struct svc_stat *s,
> +static inline struct proc_dir_entry *svc_proc_register(struct net *net, struct svc_stat *s,
>  						       const struct file_operations *f) { return NULL; }
> -static inline void svc_proc_unregister(const char *p) {}
> +static inline void svc_proc_unregister(struct net *net, const char *p) {}
>  
>  static inline void svc_seq_show(struct seq_file *seq,
>  				const struct svc_stat *st) {}
> diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
> index f0f6e7c..3c4f688 100644
> --- a/net/sunrpc/stats.c
> +++ b/net/sunrpc/stats.c
> @@ -241,18 +241,18 @@ rpc_proc_unregister(struct net *net, const char *name)
>  EXPORT_SYMBOL_GPL(rpc_proc_unregister);
>  
>  struct proc_dir_entry *
> -svc_proc_register(struct svc_stat *statp, const struct file_operations *fops)
> +svc_proc_register(struct net *net, struct svc_stat *statp, const struct file_operations *fops)
>  {
> -	return do_register(&init_net, statp->program->pg_name, statp, fops);
> +	return do_register(net, statp->program->pg_name, statp, fops);
>  }
>  EXPORT_SYMBOL_GPL(svc_proc_register);
>  
>  void
> -svc_proc_unregister(const char *name)
> +svc_proc_unregister(struct net *net, const char *name)
>  {
>  	struct sunrpc_net *sn;
>  
> -	sn = net_generic(&init_net, sunrpc_net_id);
> +	sn = net_generic(net, sunrpc_net_id);
>  	remove_proc_entry(name, sn->proc_net_rpc);
>  }
>  EXPORT_SYMBOL_GPL(svc_proc_unregister);
> 
