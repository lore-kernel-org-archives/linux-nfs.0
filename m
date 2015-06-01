Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55824 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751797AbbFAUYA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jun 2015 16:24:00 -0400
Date: Mon, 1 Jun 2015 16:24:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 10/10] rpcrdma: Merge svcrdma and xprtrdma modules
 into one
Message-ID: <20150601202400.GB26972@fieldses.org>
References: <20150526174401.7061.43137.stgit@klimt.1015granger.net>
 <20150526175004.7061.83923.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150526175004.7061.83923.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 26, 2015 at 01:50:04PM -0400, Chuck Lever wrote:
> Bi-directional RPC support means code in svcrdma.ko invokes a bit of
> code in xprtrdma.ko, and vice versa. To avoid loader/linker loops,
> merge the server and client side modules together into a single
> module.
> 
> When backchannel capabilities are added, the combined module will
> register all needed transport capabilities so that Upper Layer
> consumers automatically have everything needed to create a
> bi-directional transport connection.
> 
> Module aliases are added for backwards compatibility with user
> space, which still may expect svcrdma.ko or xprtrdma.ko to be
> present.
> 
> This commit reverts commit 2e8c12e1b765 ("xprtrdma: add separate
> Kconfig options for NFSoRDMA client and server support") and
> provides a single CONFIG option for enabling the new module.

The motivation for adding this was basically that in RHEL we wanted to
support client-side but not server-side NFS/RDMA.

I guess bidirectional RPC blurs the client/server distinction, so if we
wanted to preserve the ability to turn off server-side NFS/RDMA at
compiple time then that should go in nfsd.

Maybe it's less important now....

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/Kconfig              |   28 +++++++-----------------
>  net/sunrpc/Makefile             |    3 +--
>  net/sunrpc/xprtrdma/Makefile    |   14 +++++-------
>  net/sunrpc/xprtrdma/module.c    |   46 +++++++++++++++++++++++++++++++++++++++
>  net/sunrpc/xprtrdma/svc_rdma.c  |    8 +------
>  net/sunrpc/xprtrdma/transport.c |   13 ++---------
>  net/sunrpc/xprtrdma/xprt_rdma.h |    5 ++++
>  7 files changed, 69 insertions(+), 48 deletions(-)
>  create mode 100644 net/sunrpc/xprtrdma/module.c
> 
> diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
> index 9068e72..04ce2c0 100644
> --- a/net/sunrpc/Kconfig
> +++ b/net/sunrpc/Kconfig
> @@ -48,28 +48,16 @@ config SUNRPC_DEBUG
>  
>  	  If unsure, say Y.
>  
> -config SUNRPC_XPRT_RDMA_CLIENT
> -	tristate "RPC over RDMA Client Support"
> +config SUNRPC_XPRT_RDMA
> +	tristate "RPC-over-RDMA transport"
>  	depends on SUNRPC && INFINIBAND && INFINIBAND_ADDR_TRANS
>  	default SUNRPC && INFINIBAND
>  	help
> -	  This option allows the NFS client to support an RDMA-enabled
> -	  transport.
> +	  This option allows the NFS client and server to use RDMA
> +	  transports (InfiniBand, iWARP, or RoCE).
>  
> -	  To compile RPC client RDMA transport support as a module,
> -	  choose M here: the module will be called xprtrdma.
> +	  To compile this support as a module, choose M. The module
> +	  will be called rpcrdma.ko.
>  
> -	  If unsure, say N.
> -
> -config SUNRPC_XPRT_RDMA_SERVER
> -	tristate "RPC over RDMA Server Support"
> -	depends on SUNRPC && INFINIBAND && INFINIBAND_ADDR_TRANS
> -	default SUNRPC && INFINIBAND
> -	help
> -	  This option allows the NFS server to support an RDMA-enabled
> -	  transport.
> -
> -	  To compile RPC server RDMA transport support as a module,
> -	  choose M here: the module will be called svcrdma.
> -
> -	  If unsure, say N.
> +	  If unsure, or you know there is no RDMA capability on your
> +	  hardware platform, say N.
> diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
> index 1b8e68d..b512fbd 100644
> --- a/net/sunrpc/Makefile
> +++ b/net/sunrpc/Makefile
> @@ -5,8 +5,7 @@
>  
>  obj-$(CONFIG_SUNRPC) += sunrpc.o
>  obj-$(CONFIG_SUNRPC_GSS) += auth_gss/
> -
> -obj-y += xprtrdma/
> +obj-$(CONFIG_SUNRPC_XPRT_RDMA) += xprtrdma/
>  
>  sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
>  	    auth.o auth_null.o auth_unix.o auth_generic.o \
> diff --git a/net/sunrpc/xprtrdma/Makefile b/net/sunrpc/xprtrdma/Makefile
> index 579f72b..48913de 100644
> --- a/net/sunrpc/xprtrdma/Makefile
> +++ b/net/sunrpc/xprtrdma/Makefile
> @@ -1,9 +1,7 @@
> -obj-$(CONFIG_SUNRPC_XPRT_RDMA_CLIENT) += xprtrdma.o
> +obj-$(CONFIG_SUNRPC_XPRT_RDMA) += rpcrdma.o
>  
> -xprtrdma-y := transport.o rpc_rdma.o verbs.o \
> -	fmr_ops.o frwr_ops.o physical_ops.o
> -
> -obj-$(CONFIG_SUNRPC_XPRT_RDMA_SERVER) += svcrdma.o
> -
> -svcrdma-y := svc_rdma.o svc_rdma_transport.o \
> -	svc_rdma_marshal.o svc_rdma_sendto.o svc_rdma_recvfrom.o
> +rpcrdma-y := transport.o rpc_rdma.o verbs.o \
> +	fmr_ops.o frwr_ops.o physical_ops.o \
> +	svc_rdma.o svc_rdma_transport.o \
> +	svc_rdma_marshal.o svc_rdma_sendto.o svc_rdma_recvfrom.o \
> +	module.o
> diff --git a/net/sunrpc/xprtrdma/module.c b/net/sunrpc/xprtrdma/module.c
> new file mode 100644
> index 0000000..560712b
> --- /dev/null
> +++ b/net/sunrpc/xprtrdma/module.c
> @@ -0,0 +1,46 @@
> +/*
> + * Copyright (c) 2015 Oracle.  All rights reserved.
> + */
> +
> +/* rpcrdma.ko module initialization
> + */
> +
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/sunrpc/svc_rdma.h>
> +#include "xprt_rdma.h"
> +
> +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> +# define RPCDBG_FACILITY	RPCDBG_TRANS
> +#endif
> +
> +MODULE_AUTHOR("Open Grid Computing and Network Appliance, Inc.");
> +MODULE_DESCRIPTION("RPC/RDMA Transport");
> +MODULE_LICENSE("Dual BSD/GPL");
> +MODULE_ALIAS("svcrdma");
> +MODULE_ALIAS("xprtrdma");
> +
> +static void __exit rpc_rdma_cleanup(void)
> +{
> +	xprt_rdma_cleanup();
> +	svc_rdma_cleanup();
> +}
> +
> +static int __init rpc_rdma_init(void)
> +{
> +	int rc;
> +
> +	rc = svc_rdma_init();
> +	if (rc)
> +		goto out;
> +
> +	rc = xprt_rdma_init();
> +	if (rc)
> +		svc_rdma_cleanup();
> +
> +out:
> +	return rc;
> +}
> +
> +module_init(rpc_rdma_init);
> +module_exit(rpc_rdma_cleanup);
> diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
> index 7a18ae4..dc7d7a5 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma.c
> @@ -38,8 +38,7 @@
>   *
>   * Author: Tom Tucker <tom@opengridcomputing.com>
>   */
> -#include <linux/module.h>
> -#include <linux/init.h>
> +
>  #include <linux/slab.h>
>  #include <linux/fs.h>
>  #include <linux/sysctl.h>
> @@ -305,8 +304,3 @@ int svc_rdma_init(void)
>  	destroy_workqueue(svc_rdma_wq);
>  	return -ENOMEM;
>  }
> -MODULE_AUTHOR("Tom Tucker <tom@opengridcomputing.com>");
> -MODULE_DESCRIPTION("SVC RDMA Transport");
> -MODULE_LICENSE("Dual BSD/GPL");
> -module_init(svc_rdma_init);
> -module_exit(svc_rdma_cleanup);
> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> index 54f23b1..436da2c 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -48,7 +48,6 @@
>   */
>  
>  #include <linux/module.h>
> -#include <linux/init.h>
>  #include <linux/slab.h>
>  #include <linux/seq_file.h>
>  #include <linux/sunrpc/addr.h>
> @@ -59,11 +58,6 @@
>  # define RPCDBG_FACILITY	RPCDBG_TRANS
>  #endif
>  
> -MODULE_LICENSE("Dual BSD/GPL");
> -
> -MODULE_DESCRIPTION("RPC/RDMA Transport for Linux kernel NFS");
> -MODULE_AUTHOR("Network Appliance, Inc.");
> -
>  /*
>   * tunables
>   */
> @@ -711,7 +705,7 @@ static struct xprt_class xprt_rdma = {
>  	.setup			= xprt_setup_rdma,
>  };
>  
> -static void __exit xprt_rdma_cleanup(void)
> +void xprt_rdma_cleanup(void)
>  {
>  	int rc;
>  
> @@ -728,7 +722,7 @@ static void __exit xprt_rdma_cleanup(void)
>  			__func__, rc);
>  }
>  
> -static int __init xprt_rdma_init(void)
> +int xprt_rdma_init(void)
>  {
>  	int rc;
>  
> @@ -753,6 +747,3 @@ static int __init xprt_rdma_init(void)
>  #endif
>  	return 0;
>  }
> -
> -module_init(xprt_rdma_init);
> -module_exit(xprt_rdma_cleanup);
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index e60907b..58163b8 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -480,6 +480,11 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *);
>   */
>  int rpcrdma_marshal_req(struct rpc_rqst *);
>  
> +/* RPC/RDMA module init - xprtrdma/transport.c
> + */
> +int xprt_rdma_init(void);
> +void xprt_rdma_cleanup(void);
> +
>  /* Temporary NFS request map cache. Created in svc_rdma.c  */
>  extern struct kmem_cache *svc_rdma_map_cachep;
>  /* WR context cache. Created in svc_rdma.c  */
