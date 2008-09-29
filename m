From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v4] nfsd: use nfs client rpc callback program
Date: Mon, 29 Sep 2008 15:21:34 -0400
Message-ID: <20080929192134.GA23736@fieldses.org>
References: <20080924174230.GJ5772@fieldses.org> <1222281745.7390.34.camel@localhost> <20080924184934.GK5772@fieldses.org> <48DBE6D9.3010603@panasas.com> <20080925200014.GA14078@fieldses.org> <1222374421.13388.26.camel@localhost> <20080925204110.GB14349@fieldses.org> <48DCCCEA.80706@panasas.com> <20080927033442.GA12765@fieldses.org> <48DF2266.809@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	linux-nfs@vger.kernel.org, pnfs mailing list <pnfs@linux-nfs.org>,
	Trond Myklebust <trond@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:54924 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751603AbYI2TVo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2008 15:21:44 -0400
In-Reply-To: <48DF2266.809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Sep 28, 2008 at 09:21:26AM +0300, Benny Halevy wrote:
> From: Benny Halevy <bhalevy@panasas.com>
> 
> since commit ff7d9756b501744540be65e172d27ee321d86103
> "nfsd: use static memory for callback program and stats"
> do_probe_callback uses a static callback program
> (NFS4_CALLBACK) rather than the one set in clp->cl_callback.cb_prog
> as passed in by the client in setclientid (4.0)
> or create_session (4.1).
> 
> This patches introduces rpc_create_args.prognumber that allows
> overriding program->number when creating rpc_clnt.

Applied--thanks!--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4callback.c      |    1 +
>  include/linux/sunrpc/clnt.h |    1 +
>  net/sunrpc/clnt.c           |    2 +-
>  3 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 3073ccb..e198ead 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -377,6 +377,7 @@ static int do_probe_callback(void *data)
>  		.addrsize	= sizeof(addr),
>  		.timeout	= &timeparms,
>  		.program	= &cb_program,
> +		.prognumber	= cb->cb_prog,
>  		.version	= nfs_cb_version[1]->number,
>  		.authflavor	= RPC_AUTH_UNIX, /* XXX: need AUTH_GSS... */
>  		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index e5bfe01..4ba84e8 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -104,6 +104,7 @@ struct rpc_create_args {
>  	const struct rpc_timeout *timeout;
>  	char			*servername;
>  	struct rpc_program	*program;
> +	u32			prognumber;	/* overrides program->number */
>  	u32			version;
>  	rpc_authflavor_t	authflavor;
>  	unsigned long		flags;
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 76739e9..da0789f 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -174,7 +174,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
>  	clnt->cl_procinfo = version->procs;
>  	clnt->cl_maxproc  = version->nrprocs;
>  	clnt->cl_protname = program->name;
> -	clnt->cl_prog     = program->number;
> +	clnt->cl_prog     = args->prognumber ? : program->number;
>  	clnt->cl_vers     = version->number;
>  	clnt->cl_stats    = program->stats;
>  	clnt->cl_metrics  = rpc_alloc_iostats(clnt);
> -- 
> 1.6.0.2
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
