Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:33335 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758149AbdELSYk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 14:24:40 -0400
Received: by mail-qt0-f178.google.com with SMTP id t26so48101080qtg.0
        for <linux-nfs@vger.kernel.org>; Fri, 12 May 2017 11:24:39 -0700 (PDT)
Message-ID: <1494613476.4227.3.camel@redhat.com>
Subject: Re: [PATCH 15/33] sunrpc: move p_count out of struct rpc_procinfo
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@lst.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Date: Fri, 12 May 2017 14:24:36 -0400
In-Reply-To: <20170512161701.22468-16-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
         <20170512161701.22468-16-hch@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-05-12 at 18:16 +0200, Christoph Hellwig wrote:
> p_count is the only writeable memeber of struct rpc_procinfo, which is
> a good candidate to be const-ified as it contains function pointers.
> 
> This patch moves it into out out struct rpc_procinfo, and into a
> separate writable array that is pointed to by struct rpc_version and
> indexed by p_statidx.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/lockd/clnt4xdr.c                  |  2 ++
>  fs/lockd/clntxdr.c                   |  4 ++++
>  fs/lockd/mon.c                       |  4 +++-
>  fs/nfs/mount_clnt.c                  |  5 ++++-
>  fs/nfs/nfs2xdr.c                     |  4 +++-
>  fs/nfs/nfs3xdr.c                     |  6 +++++-
>  fs/nfs/nfs4xdr.c                     |  4 +++-
>  fs/nfsd/nfs4callback.c               |  4 +++-
>  include/linux/sunrpc/clnt.h          |  2 +-
>  net/sunrpc/auth_gss/gss_rpc_upcall.c |  3 ++-
>  net/sunrpc/clnt.c                    |  6 ++++--
>  net/sunrpc/rpcb_clnt.c               | 12 +++++++++---
>  net/sunrpc/stats.c                   |  3 +--
>  13 files changed, 44 insertions(+), 15 deletions(-)
> 
> diff --git a/fs/lockd/clnt4xdr.c b/fs/lockd/clnt4xdr.c
> index f0ab7a99dd23..7c255d1d7c64 100644
> --- a/fs/lockd/clnt4xdr.c
> +++ b/fs/lockd/clnt4xdr.c
> @@ -602,8 +602,10 @@ static struct rpc_procinfo	nlm4_procedures[] = {
>  	PROC(GRANTED_RES,	res,		norep),
>  };
>  
> +static unsigned int nlm_version4_counts[ARRAY_SIZE(nlm4_procedures)];
>  const struct rpc_version nlm_version4 = {
>  	.number		= 4,
>  	.nrprocs	= ARRAY_SIZE(nlm4_procedures),
>  	.procs		= nlm4_procedures,
> +	.counts		= nlm_version4_counts,
>  };
> diff --git a/fs/lockd/clntxdr.c b/fs/lockd/clntxdr.c
> index bd8a976785ae..39500c5743a5 100644
> --- a/fs/lockd/clntxdr.c
> +++ b/fs/lockd/clntxdr.c
> @@ -600,16 +600,20 @@ static struct rpc_procinfo	nlm_procedures[] = {
>  	PROC(GRANTED_RES,	res,		norep),
>  };
>  
> +static unsigned int nlm_version1_counts[ARRAY_SIZE(nlm_procedures)];
>  static const struct rpc_version	nlm_version1 = {
>  	.number		= 1,
>  	.nrprocs	= ARRAY_SIZE(nlm_procedures),
>  	.procs		= nlm_procedures,
> +	.counts		= nlm_version1_counts,
>  };
>  
> +static unsigned int nlm_version3_counts[ARRAY_SIZE(nlm_procedures)];
>  static const struct rpc_version	nlm_version3 = {
>  	.number		= 3,
>  	.nrprocs	= ARRAY_SIZE(nlm_procedures),
>  	.procs		= nlm_procedures,
> +	.counts		= nlm_version3_counts,
>  };
>  
>  static const struct rpc_version	*nlm_versions[] = {
> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> index 62424e929a7f..fe4ec82764fe 100644
> --- a/fs/lockd/mon.c
> +++ b/fs/lockd/mon.c
> @@ -552,10 +552,12 @@ static struct rpc_procinfo	nsm_procedures[] = {
>  	},
>  };
>  
> +static unsigned int nsm_version1_counts[ARRAY_SIZE(nsm_procedures)];
>  static const struct rpc_version nsm_version1 = {
>  	.number		= 1,
>  	.nrprocs	= ARRAY_SIZE(nsm_procedures),
> -	.procs		= nsm_procedures
> +	.procs		= nsm_procedures,
> +	.counts		= nsm_version1_counts,
>  };
>  
>  static const struct rpc_version *nsm_version[] = {
> diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
> index 806657d65074..d25914aa8bf9 100644
> --- a/fs/nfs/mount_clnt.c
> +++ b/fs/nfs/mount_clnt.c
> @@ -504,17 +504,20 @@ static struct rpc_procinfo mnt3_procedures[] = {
>  	},
>  };
>  
> -
> +static unsigned int mnt_counts[ARRAY_SIZE(mnt_procedures)];
>  static const struct rpc_version mnt_version1 = {
>  	.number		= 1,
>  	.nrprocs	= ARRAY_SIZE(mnt_procedures),
>  	.procs		= mnt_procedures,
> +	.counts		= mnt_counts,
>  };
>  
> +static unsigned int mnt3_counts[ARRAY_SIZE(mnt_procedures)];
>  static const struct rpc_version mnt_version3 = {
>  	.number		= 3,
>  	.nrprocs	= ARRAY_SIZE(mnt3_procedures),
>  	.procs		= mnt3_procedures,
> +	.counts		= mnt3_counts,
>  };
>  
>  static const struct rpc_version *mnt_version[] = {
> diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
> index a299648ea321..16b4526299c1 100644
> --- a/fs/nfs/nfs2xdr.c
> +++ b/fs/nfs/nfs2xdr.c
> @@ -1170,8 +1170,10 @@ struct rpc_procinfo	nfs_procedures[] = {
>  	PROC(STATFS,	fhandle,	statfsres,	0),
>  };
>  
> +static unsigned int nfs_version2_counts[ARRAY_SIZE(nfs_procedures)];
>  const struct rpc_version nfs_version2 = {
>  	.number			= 2,
>  	.nrprocs		= ARRAY_SIZE(nfs_procedures),
> -	.procs			= nfs_procedures
> +	.procs			= nfs_procedures,
> +	.counts			= nfs_version2_counts,
>  };
> diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
> index cc272eb8be3e..a017ec5c7a9d 100644
> --- a/fs/nfs/nfs3xdr.c
> +++ b/fs/nfs/nfs3xdr.c
> @@ -2578,10 +2578,12 @@ struct rpc_procinfo	nfs3_procedures[] = {
>  	PROC(COMMIT,		commit,		commit,		5),
>  };
>  
> +static unsigned int nfs_version3_counts[ARRAY_SIZE(nfs3_procedures)];
>  const struct rpc_version nfs_version3 = {
>  	.number			= 3,
>  	.nrprocs		= ARRAY_SIZE(nfs3_procedures),
> -	.procs			= nfs3_procedures
> +	.procs			= nfs3_procedures,
> +	.counts			= nfs_version3_counts,
>  };
>  
>  #ifdef CONFIG_NFS_V3_ACL
> @@ -2606,10 +2608,12 @@ static struct rpc_procinfo	nfs3_acl_procedures[] = {
>  	},
>  };
>  
> +static unsigned int nfs3_acl_counts[ARRAY_SIZE(nfs3_acl_procedures)];
>  const struct rpc_version nfsacl_version3 = {
>  	.number			= 3,
>  	.nrprocs		= sizeof(nfs3_acl_procedures)/
>  				  sizeof(nfs3_acl_procedures[0]),
>  	.procs			= nfs3_acl_procedures,
> +	.counts			= nfs3_acl_counts,
>  };
>  #endif  /* CONFIG_NFS_V3_ACL */
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 797f3ce75286..40cf5529e65f 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -7661,10 +7661,12 @@ struct rpc_procinfo	nfs4_procedures[] = {
>  #endif /* CONFIG_NFS_V4_2 */
>  };
>  
> +static unsigned int nfs_version4_counts[ARRAY_SIZE(nfs4_procedures)];
>  const struct rpc_version nfs_version4 = {
>  	.number			= 4,
>  	.nrprocs		= ARRAY_SIZE(nfs4_procedures),
> -	.procs			= nfs4_procedures
> +	.procs			= nfs4_procedures,
> +	.counts			= nfs_version4_counts,
>  };
>  
>  /*
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index a2bedbd05b2b..afa961fe073c 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -705,6 +705,7 @@ static struct rpc_procinfo nfs4_cb_procedures[] = {
>  	PROC(CB_NOTIFY_LOCK,	COMPOUND,	cb_notify_lock,	cb_notify_lock),
>  };
>  
> +static unsigned int nfs4_cb_counts[ARRAY_SIZE(nfs4_cb_procedures)];
>  static struct rpc_version nfs_cb_version4 = {
>  /*
>   * Note on the callback rpc program version number: despite language in rfc
> @@ -715,7 +716,8 @@ static struct rpc_version nfs_cb_version4 = {
>   */
>  	.number			= 1,
>  	.nrprocs		= ARRAY_SIZE(nfs4_cb_procedures),
> -	.procs			= nfs4_cb_procedures
> +	.procs			= nfs4_cb_procedures,
> +	.counts			= nfs4_cb_counts,
>  };
>  
>  static const struct rpc_version *nfs_cb_version[] = {
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index 6095ecba0dde..c75ba37151fe 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -88,6 +88,7 @@ struct rpc_version {
>  	u32			number;		/* version number */
>  	unsigned int		nrprocs;	/* number of procs */
>  	struct rpc_procinfo *	procs;		/* procedure array */
> +	unsigned int		*counts;	/* call counts */
>  };
>  
>  /*
> @@ -99,7 +100,6 @@ struct rpc_procinfo {
>  	kxdrdproc_t		p_decode;	/* XDR decode function */
>  	unsigned int		p_arglen;	/* argument hdr length (u32) */
>  	unsigned int		p_replen;	/* reply hdr length (u32) */
> -	unsigned int		p_count;	/* call count */
>  	unsigned int		p_timer;	/* Which RTT timer to use */
>  	u32			p_statidx;	/* Which procedure to account */
>  	const char *		p_name;		/* name of procedure */
> diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
> index a80b8e607478..f8729b647605 100644
> --- a/net/sunrpc/auth_gss/gss_rpc_upcall.c
> +++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
> @@ -364,11 +364,12 @@ void gssp_free_upcall_data(struct gssp_upcall_data *data)
>  /*
>   * Initialization stuff
>   */
> -
> +static unsigned int gssp_version1_counts[ARRAY_SIZE(gssp_procedures)];
>  static const struct rpc_version gssp_version1 = {
>  	.number		= GSSPROXY_VERS_1,
>  	.nrprocs	= ARRAY_SIZE(gssp_procedures),
>  	.procs		= gssp_procedures,
> +	.counts		= gssp_version1_counts,
>  };
>  
>  static const struct rpc_version *gssp_version[] = {
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 964d5c4a1b60..f2d1f971247b 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1517,14 +1517,16 @@ static void
>  call_start(struct rpc_task *task)
>  {
>  	struct rpc_clnt	*clnt = task->tk_client;
> +	int idx = task->tk_msg.rpc_proc->p_statidx;
>  
>  	dprintk("RPC: %5u call_start %s%d proc %s (%s)\n", task->tk_pid,
>  			clnt->cl_program->name, clnt->cl_vers,
>  			rpc_proc_name(task),
>  			(RPC_IS_ASYNC(task) ? "async" : "sync"));
>  
> -	/* Increment call count */
> -	task->tk_msg.rpc_proc->p_count++;
> +	/* Increment call count (version might not be valid for ping) */
> +	if (clnt->cl_program->version[clnt->cl_vers])
> +		clnt->cl_program->version[clnt->cl_vers]->counts[idx]++;
>  	clnt->cl_stats->rpccnt++;
>  	task->tk_action = call_reserve;
>  }
>

Little bit of a behavior change here -- as you say version might not be
valid so we might lose this count in some cases? I don't think it's a
big deal, just pointing it out in case someone notices later.

> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> index f67b9e2897b4..9d47b9d3bbee 100644
> --- a/net/sunrpc/rpcb_clnt.c
> +++ b/net/sunrpc/rpcb_clnt.c
> @@ -1117,22 +1117,28 @@ static const struct rpcb_info rpcb_next_version6[] = {
>  	},
>  };
>  
> +static unsigned int rpcb_version2_counts[ARRAY_SIZE(rpcb_procedures2)];
>  static const struct rpc_version rpcb_version2 = {
>  	.number		= RPCBVERS_2,
>  	.nrprocs	= ARRAY_SIZE(rpcb_procedures2),
> -	.procs		= rpcb_procedures2
> +	.procs		= rpcb_procedures2,
> +	.counts		= rpcb_version2_counts,
>  };
>  
> +static unsigned int rpcb_version3_counts[ARRAY_SIZE(rpcb_procedures3)];
>  static const struct rpc_version rpcb_version3 = {
>  	.number		= RPCBVERS_3,
>  	.nrprocs	= ARRAY_SIZE(rpcb_procedures3),
> -	.procs		= rpcb_procedures3
> +	.procs		= rpcb_procedures3,
> +	.counts		= rpcb_version3_counts,
>  };
>  
> +static unsigned int rpcb_version4_counts[ARRAY_SIZE(rpcb_procedures4)];
>  static const struct rpc_version rpcb_version4 = {
>  	.number		= RPCBVERS_4,
>  	.nrprocs	= ARRAY_SIZE(rpcb_procedures4),
> -	.procs		= rpcb_procedures4
> +	.procs		= rpcb_procedures4,
> +	.counts		= rpcb_version4_counts,
>  };
>  
>  static const struct rpc_version *rpcb_version[] = {
> diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
> index caeb01ad2b5a..91c84d18bf9a 100644
> --- a/net/sunrpc/stats.c
> +++ b/net/sunrpc/stats.c
> @@ -55,8 +55,7 @@ static int rpc_proc_show(struct seq_file *seq, void *v) {
>  		seq_printf(seq, "proc%u %u",
>  					vers->number, vers->nrprocs);
>  		for (j = 0; j < vers->nrprocs; j++)
> -			seq_printf(seq, " %u",
> -					vers->procs[j].p_count);
> +			seq_printf(seq, " %u", vers->counts[j]);
>  		seq_putc(seq, '\n');
>  	}
>  	return 0;

Reviewed-by: Jeff Layton <jlayton@redhat.com>
