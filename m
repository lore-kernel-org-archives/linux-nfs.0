Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hygieia.santi-shop.eu ([78.46.175.2]:54093 "EHLO
	hygieia.santi-shop.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161356AbbBDRIj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2015 12:08:39 -0500
Date: Wed, 4 Feb 2015 18:08:33 +0100
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Nix <nix@esperi.org.uk>, "J. Bruce Fields" <bfields@fieldses.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [Patch] sunrpc: NULL utsname dereference on NFS umount during
 namespace cleanup
Message-ID: <20150204180833.4d4a22cf@neptune.home>
In-Reply-To: <1422661761.21259.5.camel@primarydata.com>
References: <20150125220604.090121ae@neptune.home>
	<CAHQdGtSNmera4P6ocFGbLhjmESB8oV9zKE_x_zTm=5qUg7e7Ug@mail.gmail.com>
	<1422661761.21259.5.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 30 January 2015 Trond Myklebust wrote:
> On Sun, 2015-01-25 at 16:55 -0500, Trond Myklebust wrote:
> > On Sun, Jan 25, 2015 at 4:06 PM, Bruno Prémont wrote:
> > > On a system running home-brown container (mntns, utsns, pidns, netns)
> > > with NFS mount-point bind-mounted into the container I hit the following
> > > trace if nfs filesystem is first umount()ed in init ns and then later
> > > umounted from container when the container exists.
> > >
> > > [51397.767310] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> > > [51397.770671] IP: [<ffffffff81828173>] rpc_new_client+0x193/0x2b0
> > > [51397.773967] PGD 0
> > > [51397.777218] Oops: 0000 [#1] SMP
> > > [51397.780490] Modules linked in:
> > > [51397.783751] CPU: 0 PID: 1711 Comm: image-starter Not tainted 3.19.0-rc2-kvm+ #7
> > > [51397.787123] Hardware name: Gigabyte Technology Co., Ltd. GA-A75M-UD2H/GA-A75M-UD2H, BIOS F6 09/28/2012
> > > [51397.790606] task: ffff8800c9fcbac0 ti: ffff8801fe754000 task.ti: ffff8801fe754000
> > > [51397.794149] RIP: 0010:[<ffffffff81828173>]  [<ffffffff81828173>] rpc_new_client+0x193/0x2b0
> > > [51397.797798] RSP: 0018:ffff8801fe757908  EFLAGS: 00010246
> > > [51397.801444] RAX: 0000000000000000 RBX: ffff88009dafb240 RCX: 0000000000000180
> > > [51397.805174] RDX: 000000000000bae0 RSI: 0000000000001770 RDI: ffff88009dafb308
> > > [51397.808913] RBP: ffff8801fe757948 R08: ffff88009daf92d8 R09: ffff88009dafb458
> > > [51397.812673] R10: ffff88009dafb458 R11: ffff88020ec15bc0 R12: ffff8801fe757a40
> > > [51397.816456] R13: ffffffff81b9d800 R14: ffff8800c6e31030 R15: 0000000000000000
> > > [51397.820270] FS:  00007f335a3a1700(0000) GS:ffff88020ec00000(0000) knlGS:00000000f7287700
> > > [51397.824168] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > > [51397.828066] CR2: 0000000000000008 CR3: 00000001fc54d000 CR4: 00000000000007f0
> > > [51397.832017] Stack:
> > > [51397.835924]  000000000000000a ffffffff81b9d770 ffffffff81826450 ffff8801fe757a40
> > > [51397.840023]  ffff8801fe757a40 ffff8800cf08d500 ffffffff81826450 ffffffff820f4728
> > > [51397.844130]  ffff8801fe757978 ffffffff81828815 ffff8801fe757978 ffffffff8182aad8
> > > [51397.848224] Call Trace:
> > > [51397.852221]  [<ffffffff81826450>] ? call_start+0x20/0x20
> > > [51397.856273]  [<ffffffff81826450>] ? call_start+0x20/0x20
> > > [51397.860295]  [<ffffffff81828815>] rpc_create_xprt+0x15/0xb0
> > > [51397.864324]  [<ffffffff8182aad8>] ? xprt_create_transport+0x108/0x1b0
> > > [51397.868428]  [<ffffffff81828971>] rpc_create+0xc1/0x190
> > > [51397.872574]  [<ffffffff81111c86>] ? internal_add_timer+0x66/0x80
> > > [51397.876733]  [<ffffffff81113a99>] ? mod_timer+0x109/0x1e0
> > > [51397.880877]  [<ffffffff8183a19e>] rpcb_create+0x6e/0x90
> > > [51397.884999]  [<ffffffff8183a71a>] rpcb_getport_async+0x15a/0x330
> > > [51397.889118]  [<ffffffff8182f1da>] ? rpc_malloc+0x3a/0x70
> > > [51397.893240]  [<ffffffff811af8d2>] ? __kmalloc+0xc2/0x170
> > > [51397.897354]  [<ffffffff81826830>] ? call_reserveresult+0x110/0x110
> > > [51397.901490]  [<ffffffff81826450>] ? call_start+0x20/0x20
> > > [51397.905606]  [<ffffffff81826450>] ? call_start+0x20/0x20
> > > [51397.909662]  [<ffffffff8182648e>] call_bind+0x3e/0x40
> > > [51397.913709]  [<ffffffff8182fa99>] __rpc_execute+0x79/0x330
> > > [51397.917778]  [<ffffffff818327bd>] rpc_execute+0x5d/0xa0
> > > [51397.921871]  [<ffffffff818286cb>] rpc_run_task+0x6b/0x90
> > > [51397.925989]  [<ffffffff8182872e>] rpc_call_sync+0x3e/0xa0
> > > [51397.930108]  [<ffffffff8127fe29>] nsm_mon_unmon+0xb9/0xd0
> > > [51397.934191]  [<ffffffff8110e2a0>] ? call_rcu_bh+0x20/0x20
> > > [51397.938235]  [<ffffffff8128018c>] nsm_unmonitor+0x8c/0x140
> > > [51397.942309]  [<ffffffff8127bc43>] nlm_destroy_host_locked+0x63/0xa0
> > > [51397.946442]  [<ffffffff8127c03c>] nlmclnt_release_host+0x7c/0x130
> > > [51397.950591]  [<ffffffff81279645>] nlmclnt_done+0x15/0x30
> > > [51397.954773]  [<ffffffff81241862>] nfs_destroy_server+0x12/0x20
> > > [51397.958934]  [<ffffffff81242372>] nfs_free_server+0x22/0xa0
> > > [51397.963053]  [<ffffffff8124cadd>] nfs_kill_super+0x1d/0x30
> > > [51397.967158]  [<ffffffff811c2e2c>] deactivate_locked_super+0x4c/0x70
> > > [51397.971286]  [<ffffffff811c33f9>] deactivate_super+0x49/0x70
> > > [51397.975398]  [<ffffffff811ddafe>] cleanup_mnt+0x3e/0x90
> > > [51397.979499]  [<ffffffff811ddb9d>] __cleanup_mnt+0xd/0x10
> > > [51397.983598]  [<ffffffff810e04cc>] task_work_run+0xbc/0xe0
> > > [51397.987697]  [<ffffffff810c8f95>] do_exit+0x295/0xaf0
> > > [51397.991812]  [<ffffffff811c2239>] ? ____fput+0x9/0x10
> > > [51397.995937]  [<ffffffff810e04b4>] ? task_work_run+0xa4/0xe0
> > > [51398.000070]  [<ffffffff810c986a>] do_group_exit+0x3a/0xa0
> > > [51398.004201]  [<ffffffff810c98df>] SyS_exit_group+0xf/0x10
> > > [51398.008315]  [<ffffffff8185e8d2>] system_call_fastpath+0x12/0x17
> > > [51398.012438] Code: 43 78 48 8d bb c8 00 00 00 48 89 7b 70 48 8b 30 e8 63 2d 01 00 c7 03 01 00 00 00 65 48 8b 04 25 00 aa 00 00 48 8b 80 c0 09 00 00 <4c> 8b 68 08 49 83 c5 45 4
> > > [51398.022378] RIP  [<ffffffff81828173>] rpc_new_client+0x193/0x2b0
> > > [51398.026732]  RSP <ffff8801fe757908>
> > > [51398.031025] CR2: 0000000000000008
> > > [51398.035326] ---[ end trace b701b037bc457620 ]---
> > > [51398.058223] Fixing recursive fault but reboot is needed!
> >
> > We should rather change rpcb_create() to pass the nodename from the
> > parent. The point is that the rpc_clnt->cl_nodename is used in various
> > different contexts (for instance in the AUTH_SYS credential) where it
> > isn't always appropriate to have it set to an empty string.
> 
> I was rather hoping that Bruno would fix up his patch and resend, but
> since other reports of the same bug are now surfacing... Please could
> you all check if something like the following patch fixes it.

This patch works for me, so
  Tested-by: Bruno Prémont <bonbons@linux-vserver.org>

Now I get just the following complaint in dmesg on shutdown:
  [ 1940.173201] lockd: cannot unmonitor nfs.home
                                         ^^^^^^^^  name of NFS server

This complaint did not happen with my "empty string" name
patch.

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
> @@ -65,7 +65,7 @@ static inline struct sockaddr *nsm_addr(const struct nsm_handle *nsm)
>  	return (struct sockaddr *)&nsm->sm_addr;
>  }
>  
> -static struct rpc_clnt *nsm_create(struct net *net)
> +static struct rpc_clnt *nsm_create(struct net *net, const char *nodename)
>  {
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
> +static struct rpc_clnt *nsm_client_get(struct net *net, const char *nodename)
>  {
>  	struct rpc_clnt	*clnt, *new;
>  	struct lockd_net *ln = net_generic(net, lockd_net_id);
> @@ -111,7 +112,7 @@ static struct rpc_clnt *nsm_client_get(struct net *net)
>  	if (clnt != NULL)
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
>  	nsm->sm_mon_name = nsm_use_hostnames ? nsm->sm_name : nsm->sm_addrbuf;
>  
> -	clnt = nsm_client_get(host->net);
> +	clnt = nsm_client_get(host->net, nodename);
>  	if (IS_ERR(clnt)) {
>  		status = PTR_ERR(clnt);
>  		dprintk("lockd: failed to create NSM upcall transport, "
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index d86acc63b25f..598ba80ec30c 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -57,7 +57,7 @@ struct rpc_clnt {
>  	const struct rpc_timeout *cl_timeout;	/* Timeout strategy */
>  
>  	int			cl_nodelen;	/* nodename length */
> -	char 			cl_nodename[UNX_MAXNODENAME];
> +	char 			cl_nodename[UNX_MAXNODENAME+1];
>  	struct rpc_pipe_dir_head cl_pipedir_objects;
>  	struct rpc_clnt *	cl_parent;	/* Points to parent of clones */
>  	struct rpc_rtt		cl_rtt_default;
> @@ -112,6 +112,7 @@ struct rpc_create_args {
>  	struct sockaddr		*saddress;
>  	const struct rpc_timeout *timeout;
>  	const char		*servername;
> +	const char		*nodename;
>  	const struct rpc_program *program;
>  	u32			prognumber;	/* overrides program->number */
>  	u32			version;
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 05da12a33945..3f5d4d48f0cb 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -286,10 +286,8 @@ static struct rpc_xprt *rpc_clnt_set_transport(struct rpc_clnt *clnt,
>  
>  static void rpc_clnt_set_nodename(struct rpc_clnt *clnt, const char *nodename)
>  {
> -	clnt->cl_nodelen = strlen(nodename);
> -	if (clnt->cl_nodelen > UNX_MAXNODENAME)
> -		clnt->cl_nodelen = UNX_MAXNODENAME;
> -	memcpy(clnt->cl_nodename, nodename, clnt->cl_nodelen);
> +	clnt->cl_nodelen = strlcpy(clnt->cl_nodename,
> +			nodename, sizeof(clnt->cl_nodename));
>  }
>  
>  static int rpc_client_register(struct rpc_clnt *clnt,
> @@ -365,6 +363,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
>  	const struct rpc_version *version;
>  	struct rpc_clnt *clnt = NULL;
>  	const struct rpc_timeout *timeout;
> +	const char *nodename = args->nodename;
>  	int err;
>  
>  	/* sanity check the name before trying to print it */
> @@ -420,8 +419,10 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
>  
>  	atomic_set(&clnt->cl_count, 1);
>  
> +	if (nodename == NULL)
> +		nodename = utsname()->nodename;
>  	/* save the nodename */
> -	rpc_clnt_set_nodename(clnt, utsname()->nodename);
> +	rpc_clnt_set_nodename(clnt, nodename);
>  
>  	err = rpc_client_register(clnt, args->authflavor, args->client_name);
>  	if (err)
> @@ -576,6 +577,7 @@ static struct rpc_clnt *__rpc_clone_client(struct rpc_create_args *args,
>  	if (xprt == NULL)
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
> -static struct rpc_clnt *rpcb_create(struct net *net, const char *hostname,
> +static struct rpc_clnt *rpcb_create(struct net *net, const char *nodename,
> +				    const char *hostname,
>  				    struct sockaddr *srvaddr, size_t salen,
>  				    int proto, u32 version)
>  {
> @@ -365,6 +366,7 @@ static struct rpc_clnt *rpcb_create(struct net *net, const char *hostname,
>  		.address	= srvaddr,
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
> -	rpcb_clnt = rpcb_create(xprt->xprt_net, xprt->servername, sap, salen,
> +	rpcb_clnt = rpcb_create(xprt->xprt_net,
> +				clnt->cl_nodename,
> +				xprt->servername, sap, salen,
>  				xprt->prot, bind_version);
>  	if (IS_ERR(rpcb_clnt)) {
>  		status = PTR_ERR(rpcb_clnt);
