Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:30713 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147Ab0CRPmg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Mar 2010 11:42:36 -0400
Message-ID: <4BA249BA.7000900@oracle.com>
Date: Thu, 18 Mar 2010 11:41:46 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
CC: NFSv3 list <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
        "Batsakis, Alexandros" <Alexandros.Batsakis@netapp.com>
Subject: Re: [PATCH] NFS: add a sysctl for disable the reconnect delay
References: <4BA1FC54.9020209@cn.fujitsu.com>
In-Reply-To: <4BA1FC54.9020209@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Mi-

On 03/18/2010 06:11 AM, Mi Jinlong wrote:
> If network partition or some other reason cause a reconnect, it cannot
> succeed immediately when environment recover, but client want to connect
> timely sometimes.
>
> This patch can provide a proc file(/proc/sys/fs/nfs/nfs_disable_reconnect_delay)
> to allow client disable the reconnect delay(reestablish_timeout) when using NFS.
>
> It's only useful for NFS.

There's a good reason for the connection re-establishment delay, and 
only very few instances where you'd want to disable it.  A sysctl is the 
wrong place for this, as it would disable the reconnect delay across the 
board, instead of for just those occasions when it is actually necessary 
to connect immediately.

I assume that because the grace period has a time limit, you would want 
the client to reconnect at all costs?  I think that this is actually 
when a client should take care not to spuriously reconnect: during a 
server reboot, a server may be sluggish or not completely ready to 
accept client requests.  It's not a time when a client should be 
showering a server with connection attempts.

The reconnect delay is an exponential backoff that starts at 3 seconds, 
so if the server is really ready to accept connections, the actual 
connection delay ought to be quick.

We're already considering shortening the maximum amount of time the 
client can wait before trying a reconnect.  And, it might possibly be 
that the network layer itself is interfering with the backoff logic that 
is already built into the RPC client.  (If true, that would be the real 
bug in this case).  I'm not interested in a workaround when we really 
should fix any underlying issues to make this work correctly.

Perhaps the RPC client needs to distinguish between connection refusal 
(where a lengthening exponential backoff between connection attempts 
makes sense) and no server response (where we want the client's network 
layer to keep sending SYN requests so that it can reconnect as soon as 
possible).

The second scenario might disable the reconnect timer so that only one 
->connect() call would be outstanding until the network layer tells us 
it's given up on SYN retries.

> Signed-off-by: Mi Jinlong<mijinlong@cn.fujitsu.com>
> ---
>   fs/nfs/client.c             |    3 +++
>   fs/nfs/sysctl.c             |    8 ++++++++
>   include/linux/nfs_fs.h      |    6 ++++++
>   include/linux/sunrpc/clnt.h |    1 +
>   include/linux/sunrpc/xprt.h |    3 ++-
>   net/sunrpc/clnt.c           |    2 ++
>   net/sunrpc/xprtsock.c       |    2 +-
>   7 files changed, 23 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 8d25ccb..e878724 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -55,6 +55,8 @@ static LIST_HEAD(nfs_client_list);
>   static LIST_HEAD(nfs_volume_list);
>   static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
>
> +int nfs_disable_reconnect_delay = 0;
> +
>   /*
>    * RPC cruft for NFS
>    */
> @@ -607,6 +609,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
>   		.program	=&nfs_program,
>   		.version	= clp->rpc_ops->version,
>   		.authflavor	= flavor,
> +		.no_recon_delay	= nfs_disable_reconnect_delay,
>   	};
>
>   	if (discrtry)
> diff --git a/fs/nfs/sysctl.c b/fs/nfs/sysctl.c
> index b62481d..6c04479 100644
> --- a/fs/nfs/sysctl.c
> +++ b/fs/nfs/sysctl.c
> @@ -58,6 +58,14 @@ static ctl_table nfs_cb_sysctls[] = {
>   		.mode		= 0644,
>   		.proc_handler	=&proc_dointvec,
>   	},
> +	{
> +		.ctl_name	= CTL_UNNUMBERED,
> +		.procname	= "nfs_disable_reconnect_delay",
> +		.data		=&nfs_disable_reconnect_delay,
> +		.maxlen		= sizeof(nfs_disable_reconnect_delay),
> +		.mode		= 0644,
> +		.proc_handler	=&proc_dointvec,
> +	},
>   	{ .ctl_name = 0 }
>   };
>
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index f6b9024..e031496 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -390,6 +390,12 @@ static inline struct rpc_cred *nfs_file_cred(struct file *file)
>   }
>
>   /*
> + * linux/fs/nfs/client.c
> + */
> +
> +extern int nfs_disable_reconnect_delay;
> +
> +/*
>    * linux/fs/nfs/xattr.c
>    */
>   #ifdef CONFIG_NFS_V3_ACL
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index 5bd17f6..f73eae1 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -115,6 +115,7 @@ struct rpc_create_args {
>   	rpc_authflavor_t	authflavor;
>   	unsigned long		flags;
>   	char			*client_name;
> +	int			no_recon_delay;  /* no delay when reconnect */
>   };
>
>   /* Values for "flags" field */
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index 1175d58..a177348 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -153,7 +153,8 @@ struct rpc_xprt {
>   	unsigned int		max_reqs;	/* total slots */
>   	unsigned long		state;		/* transport state */
>   	unsigned char		shutdown   : 1,	/* being shut down */
> -				resvport   : 1; /* use a reserved port */
> +				resvport   : 1, /* use a reserved port */
> +				no_recon_delay: 1; /* no delay when reconnect */
>   	unsigned int		bind_index;	/* bind function index */
>
>   	/*
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index df1039f..7a90d1a 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -316,6 +316,8 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
>   	if (args->flags&  RPC_CLNT_CREATE_NONPRIVPORT)
>   		xprt->resvport = 0;
>
> +	xprt->no_recon_delay = !!args->no_recon_delay;
> +
>   	clnt = rpc_new_client(args, xprt);
>   	if (IS_ERR(clnt))
>   		return clnt;
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 24c9605..52f2367 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -2089,7 +2089,7 @@ static void xs_connect(struct rpc_task *task)
>   	if (xprt_test_and_set_connecting(xprt))
>   		return;
>
> -	if (transport->sock != NULL) {
> +	if (!xprt->no_recon_delay&&  transport->sock != NULL) {
>   		dprintk("RPC:       xs_connect delayed xprt %p for %lu "
>   				"seconds\n",
>   				xprt, xprt->reestablish_timeout / HZ);


-- 
chuck[dot]lever[at]oracle[dot]com
