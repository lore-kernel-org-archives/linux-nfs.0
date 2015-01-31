Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hygieia.santi-shop.eu ([78.46.175.2]:55052 "EHLO
	hygieia.santi-shop.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088AbbAaJDK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 31 Jan 2015 04:03:10 -0500
Date: Sat, 31 Jan 2015 10:02:56 +0100
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Nix <nix@esperi.org.uk>, "J. Bruce Fields" <bfields@fieldses.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [Patch] sunrpc: NULL utsname dereference on NFS umount during
 namespace cleanup
Message-ID: <20150131100256.39a6da0b@uranus>
In-Reply-To: <1422661761.21259.5.camel@primarydata.com>
References: <20150125220604.090121ae@neptune.home>
	<CAHQdGtSNmera4P6ocFGbLhjmESB8oV9zKE_x_zTm=5qUg7e7Ug@mail.gmail.com>
	<1422661761.21259.5.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 30 Jan 2015 18:49:21 Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> On Sun, 2015-01-25 at 16:55 -0500, Trond Myklebust wrote:
> > On Sun, Jan 25, 2015 at 4:06 PM, Bruno Prémont
> > <bonbons@linux-vserver.org> wrote:
> > > On a system running home-brown container (mntns, utsns, pidns,
> > > netns) with NFS mount-point bind-mounted into the container I hit
> > > the following trace if nfs filesystem is first umount()ed in init
> > > ns and then later umounted from container when the container
> > > exists.
> > >
> >
> > We should rather change rpcb_create() to pass the nodename from the
> > parent. The point is that the rpc_clnt->cl_nodename is used in
> > various different contexts (for instance in the AUTH_SYS
> > credential) where it isn't always appropriate to have it set to an
> > empty string.
> 
> I was rather hoping that Bruno would fix up his patch and resend, but
> since other reports of the same bug are now surfacing... Please could
> you all check if something like the following patch fixes it.

With FOSDEM this weekend I've had no time to look into it.

Will test when home on Wednesday.

Thanks,
Bruno


> Thanks
>   Trond
> 
> 8<---------------------------------------------------------------------
> From 87557df0ca2241da0edac558286650fdb081152c Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Fri, 30 Jan 2015 18:12:28 -0500
> Subject: [PATCH] SUNRPC: NULL utsname dereference on NFS umount during
>  namespace cleanup
> MIME-Version: 1.0
> Content-Type: text/plain; charset=UTF-8
> Content-Transfer-Encoding: 8bit
> 
> Fix an Oopsable condition when nsm_mon_unmon is called as part of the
> namespace cleanup, which now apparently happens after the utsname
> has been freed.
> 
> Link: http://lkml.kernel.org/r/20150125220604.090121ae@neptune.home
> Reported-by: Bruno Prémont <bonbons@linux-vserver.org>
> Cc: stable@vger.kernel.org # 3.18
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/lockd/mon.c              | 13 +++++++++----
>  include/linux/sunrpc/clnt.h |  3 ++-
>  net/sunrpc/clnt.c           | 12 +++++++-----
>  net/sunrpc/rpcb_clnt.c      |  8 ++++++--
>  4 files changed, 24 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> index 1cc6ec51e6b1..47a32b6d9b90 100644
> --- a/fs/lockd/mon.c
> +++ b/fs/lockd/mon.c
> @@ -65,7 +65,7 @@ static inline struct sockaddr *nsm_addr(const
> struct nsm_handle *nsm) return (struct sockaddr *)&nsm->sm_addr;
>  }
>  
> -static struct rpc_clnt *nsm_create(struct net *net)
> +static struct rpc_clnt *nsm_create(struct net *net, const char
> *nodename) {
>  	struct sockaddr_in sin = {
>  		.sin_family		= AF_INET,
> @@ -77,6 +77,7 @@ static struct rpc_clnt *nsm_create(struct net *net)
>  		.address		= (struct sockaddr *)&sin,
>  		.addrsize		= sizeof(sin),
>  		.servername		= "rpc.statd",
> +		.nodename		= nodename,
>  		.program		= &nsm_program,
>  		.version		= NSM_VERSION,
>  		.authflavor		= RPC_AUTH_NULL,
> @@ -102,7 +103,7 @@ out:
>  	return clnt;
>  }
>  
> -static struct rpc_clnt *nsm_client_get(struct net *net)
> +static struct rpc_clnt *nsm_client_get(struct net *net, const char
> *nodename) {
>  	struct rpc_clnt	*clnt, *new;
>  	struct lockd_net *ln = net_generic(net, lockd_net_id);
> @@ -111,7 +112,7 @@ static struct rpc_clnt *nsm_client_get(struct net
> *net) if (clnt != NULL)
>  		goto out;
>  
> -	clnt = new = nsm_create(net);
> +	clnt = new = nsm_create(net, nodename);
>  	if (IS_ERR(clnt))
>  		goto out;
>  
> @@ -190,19 +191,23 @@ int nsm_monitor(const struct nlm_host *host)
>  	struct nsm_res	res;
>  	int		status;
>  	struct rpc_clnt *clnt;
> +	const char *nodename = NULL;
>  
>  	dprintk("lockd: nsm_monitor(%s)\n", nsm->sm_name);
>  
>  	if (nsm->sm_monitored)
>  		return 0;
>  
> +	if (host->h_rpcclnt)
> +		nodename = host->h_rpcclnt->cl_nodename;
> +
>  	/*
>  	 * Choose whether to record the caller_name or IP address of
>  	 * this peer in the local rpc.statd's database.
>  	 */
>  	nsm->sm_mon_name = nsm_use_hostnames ? nsm->sm_name :
> nsm->sm_addrbuf; 
> -	clnt = nsm_client_get(host->net);
> +	clnt = nsm_client_get(host->net, nodename);
>  	if (IS_ERR(clnt)) {
>  		status = PTR_ERR(clnt);
>  		dprintk("lockd: failed to create NSM upcall
> transport, " diff --git a/include/linux/sunrpc/clnt.h
> b/include/linux/sunrpc/clnt.h index d86acc63b25f..598ba80ec30c 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -57,7 +57,7 @@ struct rpc_clnt {
>  	const struct rpc_timeout *cl_timeout;	/* Timeout
> strategy */ 
>  	int			cl_nodelen;	/* nodename
> length */
> -	char 			cl_nodename[UNX_MAXNODENAME];
> +	char 			cl_nodename[UNX_MAXNODENAME+1];
>  	struct rpc_pipe_dir_head cl_pipedir_objects;
>  	struct rpc_clnt *	cl_parent;	/* Points to
> parent of clones */ struct rpc_rtt		cl_rtt_default;
> @@ -112,6 +112,7 @@ struct rpc_create_args {
>  	struct sockaddr		*saddress;
>  	const struct rpc_timeout *timeout;
>  	const char		*servername;
> +	const char		*nodename;
>  	const struct rpc_program *program;
>  	u32			prognumber;	/* overrides
> program->number */ u32			version;
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 05da12a33945..3f5d4d48f0cb 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -286,10 +286,8 @@ static struct rpc_xprt
> *rpc_clnt_set_transport(struct rpc_clnt *clnt, 
>  static void rpc_clnt_set_nodename(struct rpc_clnt *clnt, const char
> *nodename) {
> -	clnt->cl_nodelen = strlen(nodename);
> -	if (clnt->cl_nodelen > UNX_MAXNODENAME)
> -		clnt->cl_nodelen = UNX_MAXNODENAME;
> -	memcpy(clnt->cl_nodename, nodename, clnt->cl_nodelen);
> +	clnt->cl_nodelen = strlcpy(clnt->cl_nodename,
> +			nodename, sizeof(clnt->cl_nodename));
>  }
>  
>  static int rpc_client_register(struct rpc_clnt *clnt,
> @@ -365,6 +363,7 @@ static struct rpc_clnt * rpc_new_client(const
> struct rpc_create_args *args, const struct rpc_version *version;
>  	struct rpc_clnt *clnt = NULL;
>  	const struct rpc_timeout *timeout;
> +	const char *nodename = args->nodename;
>  	int err;
>  
>  	/* sanity check the name before trying to print it */
> @@ -420,8 +419,10 @@ static struct rpc_clnt * rpc_new_client(const
> struct rpc_create_args *args, 
>  	atomic_set(&clnt->cl_count, 1);
>  
> +	if (nodename == NULL)
> +		nodename = utsname()->nodename;
>  	/* save the nodename */
> -	rpc_clnt_set_nodename(clnt, utsname()->nodename);
> +	rpc_clnt_set_nodename(clnt, nodename);
>  
>  	err = rpc_client_register(clnt, args->authflavor,
> args->client_name); if (err)
> @@ -576,6 +577,7 @@ static struct rpc_clnt *__rpc_clone_client(struct
> rpc_create_args *args, if (xprt == NULL)
>  		goto out_err;
>  	args->servername = xprt->servername;
> +	args->nodename = clnt->cl_nodename;
>  
>  	new = rpc_new_client(args, xprt, clnt);
>  	if (IS_ERR(new)) {
> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> index 05202012bcfc..cf5770d8f49a 100644
> --- a/net/sunrpc/rpcb_clnt.c
> +++ b/net/sunrpc/rpcb_clnt.c
> @@ -355,7 +355,8 @@ out:
>  	return result;
>  }
>  
> -static struct rpc_clnt *rpcb_create(struct net *net, const char
> *hostname, +static struct rpc_clnt *rpcb_create(struct net *net,
> const char *nodename,
> +				    const char *hostname,
>  				    struct sockaddr *srvaddr, size_t
> salen, int proto, u32 version)
>  {
> @@ -365,6 +366,7 @@ static struct rpc_clnt *rpcb_create(struct net
> *net, const char *hostname, .address	= srvaddr,
>  		.addrsize	= salen,
>  		.servername	= hostname,
> +		.nodename	= nodename,
>  		.program	= &rpcb_program,
>  		.version	= version,
>  		.authflavor	= RPC_AUTH_UNIX,
> @@ -740,7 +742,9 @@ void rpcb_getport_async(struct rpc_task *task)
>  	dprintk("RPC: %5u %s: trying rpcbind version %u\n",
>  		task->tk_pid, __func__, bind_version);
>  
> -	rpcb_clnt = rpcb_create(xprt->xprt_net, xprt->servername,
> sap, salen,
> +	rpcb_clnt = rpcb_create(xprt->xprt_net,
> +				clnt->cl_nodename,
> +				xprt->servername, sap, salen,
>  				xprt->prot, bind_version);
>  	if (IS_ERR(rpcb_clnt)) {
>  		status = PTR_ERR(rpcb_clnt);

