From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH] nfsd: use nfs client rpc callback program
Date: Fri, 26 Sep 2008 23:34:42 -0400
Message-ID: <20080927033442.GA12765@fieldses.org>
References: <20080924172134.GI5772@fieldses.org> <1222277168.7390.19.camel@localhost> <20080924174230.GJ5772@fieldses.org> <1222281745.7390.34.camel@localhost> <20080924184934.GK5772@fieldses.org> <48DBE6D9.3010603@panasas.com> <20080925200014.GA14078@fieldses.org> <1222374421.13388.26.camel@localhost> <20080925204110.GB14349@fieldses.org> <48DCCCEA.80706@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	linux-nfs@vger.kernel.org, pnfs mailing list <pnfs@linux-nfs.org>,
	Trond Myklebust <trond@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37325 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751651AbYI0Det (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 23:34:49 -0400
In-Reply-To: <48DCCCEA.80706@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 26, 2008 at 02:52:10PM +0300, Benny Halevy wrote:
> J. Bruce Fields wrote:
> > On Thu, Sep 25, 2008 at 04:27:01PM -0400, Trond Myklebust wrote:
> >> On Thu, 2008-09-25 at 16:00 -0400, J. Bruce Fields wrote:
> >>>>>> Another fix would be to add a refcount to the rpc_program structure...
> >>>>> ... a refcount seems more straightforward.  Benny, what do you think?
> >>>> I agree.  I'll send a patch hopefully tomorrow.
> >>>> Would you like that combined with the one I sent or as a separate one?
> >>>> (I'm inclined towards the latter).
> >>> That'd be fine.
> >> So, looking at what you're trying to do, I'm still having trouble
> >> figuring out why you think you need a dynamically allocated rpc_program
> >> in the first place.
> >>
> >> If the only thing you are trying to support is dynamically allocated
> >> program numbers, then note that rpc_encode_header() doesn't use
> >> program->number at all. Instead, it uses clnt->cl_prog and
> >> clnt->cl_vers. Nothing stops you from setting those values explicitly...
> > 
> > Oh, sure, that sounds like an excellent plan--thanks!
> > 
> Yeah, much simpler.
> Though having nfs4_probe_callback directly assign to clnt->cl_prog
> would work, it seems like a layering violation.
> How about allowing this officially via struct rpc_create_args?

Looks good to me; if you could resend with the usual changelog and
signed-off-by, I'll apply it to my tree, assuming no objection from
Trond.

--b.

> 
> Benny
> 
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index e5bfe01..4ba84e8 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -104,6 +104,7 @@ struct  {
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
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 30d3130..5e95909 100644
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
