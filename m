From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH] nfsd: use nfs client rpc callback program
Date: Wed, 24 Sep 2008 12:35:28 -0400
Message-ID: <20080924163528.GB5772@fieldses.org>
References: <48D15DF0.4000406@panasas.com> <20080917231018.GA5723@fieldses.org> <48D193EE.2020805@panasas.com> <48D19C74.8000303@panasas.com> <48D2AAF7.6060808@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, linux-nfs@vger.kernel.org,
	pnfs mailing list <pnfs@linux-nfs.org>,
	Trond Myklebust <trond@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:35753 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751996AbYIXQfc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2008 12:35:32 -0400
In-Reply-To: <48D2AAF7.6060808@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 18, 2008 at 02:24:39PM -0500, Benny Halevy wrote:
> From: Benny Halevy <bhalevy@panasas.com>
> 
> since commit ff7d9756b501744540be65e172d27ee321d86103
> "nfsd: use static memory for callback program and stats"
> do_probe_callback uses a static callback program
> (NFS4_CALLBACK) rather than the one set in clp->cl_callback.cb_prog
> as passed in by the client in setclientid (4.0)
> or create_session (4.1).
> 
> This patches allows allocating cb_program (and cb_stats) dynamically
> and setting a free_rpc_program function pointer to be
> called when the rpc_clnt structure is destroyed.

So that means we handle two cases:

	- free_rpc_program = NULL: We assume the program and stats are
	  in static memory (or module memory--which might be a problem
	  if we shut down the server and remove the nfsd module in quick
	  succession.  I assume there's a similar (probably very
	  hard-to-hit) bug on the client too, but haven't looked
	  carefully.).
	- free_rpc_program != NULL: We assume this rpc_client is the
	  last user of the program.

It seems a little ad hoc, but I can't see why it wouldn't solve the
problem.

I'd want Trond's ack.

--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
> 
> Bruce, how about the following patch instead.
> It should solve the callback program number as well as Olga
> gss_auth issue.
> 
> I'm still not sure about the gss_auth reference accounting
> for the rpc_clnt it references, but that's somewhat orthogonal
> to the solution in this patch.
> 
> Benny
> 
>  fs/nfsd/nfs4callback.c      |   47 ++++++++++++++++++++++++++++--------------
>  include/linux/sunrpc/clnt.h |    1 +
>  net/sunrpc/clnt.c           |    2 +
>  3 files changed, 34 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 30d3130..6599b1e 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -342,20 +342,11 @@ static struct rpc_version *	nfs_cb_version[] = {
>  	&nfs_cb_version4,
>  };
>  
> -static struct rpc_program cb_program;
> -
> -static struct rpc_stat cb_stats = {
> -		.program	= &cb_program
> -};
> -
> -#define NFS4_CALLBACK 0x40000000
> -static struct rpc_program cb_program = {
> -		.name 		= "nfs4_cb",
> -		.number		= NFS4_CALLBACK,
> -		.nrvers		= ARRAY_SIZE(nfs_cb_version),
> -		.version	= nfs_cb_version,
> -		.stats		= &cb_stats,
> -};
> +static void free_rpc_program(struct rpc_program *cb_program)
> +{
> +	dprintk("%s: freeing callback program 0x%p\n", __func__, cb_program);
> +	kfree(cb_program);
> +}
>  
>  /* Reference counting, callback cleanup, etc., all look racy as heck.
>   * And why is cb_set an atomic? */
> @@ -371,12 +362,13 @@ static int do_probe_callback(void *data)
>  		.to_maxval	= (NFSD_LEASE_TIME/2) * HZ,
>  		.to_exponential	= 1,
>  	};
> +	struct rpc_stat		*cb_stats;
> +	struct rpc_program	*cb_program;
>  	struct rpc_create_args args = {
>  		.protocol	= IPPROTO_TCP,
>  		.address	= (struct sockaddr *)&addr,
>  		.addrsize	= sizeof(addr),
>  		.timeout	= &timeparms,
> -		.program	= &cb_program,
>  		.version	= nfs_cb_version[1]->number,
>  		.authflavor	= RPC_AUTH_UNIX, /* XXX: need AUTH_GSS... */
>  		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
> @@ -394,8 +386,31 @@ static int do_probe_callback(void *data)
>  	addr.sin_port = htons(cb->cb_port);
>  	addr.sin_addr.s_addr = htonl(cb->cb_addr);
>  
> +	/* Initialize rpc_program */
> +	cb_program = kzalloc(sizeof(struct rpc_program) +
> +			     sizeof(struct rpc_stat), GFP_KERNEL);
> +	if (!cb_program) {
> +		dprintk("NFSD: %s: couldn't allocate callback program\n",
> +			__func__);
> +		status = -ENOMEM;
> +		goto out_err;
> +	}
> +
> +	cb_program->name = "nfs4_cb";
> +	cb_program->number = clp->cl_callback.cb_prog;
> +	cb_program->nrvers = ARRAY_SIZE(nfs_cb_version);
> +	cb_program->version = nfs_cb_version;
> +	cb_program->free_rpc_program = free_rpc_program;
> +	args.program = cb_program;
> +
> +	dprintk("%s: program %s 0x%x nrvers %u version %u\n",
> +		__func__, args.program->name, args.program->number,
> +		args.program->nrvers, args.version);
> +
>  	/* Initialize rpc_stat */
> -	memset(args.program->stats, 0, sizeof(struct rpc_stat));
> +	cb_stats = (struct rpc_stat *)(cb_program + 1);
> +	cb_stats->program = cb_program;
> +	cb_program->stats = cb_stats;
>  
>  	/* Create RPC client */
>  	client = rpc_create(&args);
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index e5bfe01..d342374 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -71,6 +71,7 @@ struct rpc_program {
>  	struct rpc_version **	version;	/* version array */
>  	struct rpc_stat *	stats;		/* statistics */
>  	char *			pipe_dir_name;	/* path to rpc_pipefs dir */
> +	void			(*free_rpc_program)(struct rpc_program *);
>  };
>  
>  struct rpc_version {
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 76739e9..cfb21c0 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -415,6 +415,8 @@ rpc_free_client(struct kref *kref)
>  	if (clnt->cl_server != clnt->cl_inline_name)
>  		kfree(clnt->cl_server);
>  out_free:
> +	if (clnt->cl_program && clnt->cl_program->free_rpc_program)
> +		clnt->cl_program->free_rpc_program(clnt->cl_program);
>  	rpc_unregister_client(clnt);
>  	rpc_free_iostats(clnt->cl_metrics);
>  	clnt->cl_metrics = NULL;
> -- 
> 1.6.0.1
> 
