From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v3 03/12] nfsd41: sunrpc: add new xprt class for
	nfsv4.1 backchannel
Date: Fri, 11 Sep 2009 16:58:21 -0400
Message-ID: <20090911205821.GE5701@fieldses.org>
References: <4AA8C597.8080809@panasas.com> <1252574732-30108-1-git-send-email-bhalevy@panasas.com> <4AA90E3A.80400@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Alexandros Batsakis <batsakis@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57119 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751925AbZIKU6U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2009 16:58:20 -0400
In-Reply-To: <4AA90E3A.80400@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 10, 2009 at 05:33:30PM +0300, Benny Halevy wrote:
> diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
> index 54a379c..c2f04e1 100644
> --- a/include/linux/sunrpc/xprtrdma.h
> +++ b/include/linux/sunrpc/xprtrdma.h
> @@ -41,11 +41,6 @@
>  #define _LINUX_SUNRPC_XPRTRDMA_H
>  
>  /*
> - * RPC transport identifier for RDMA
> - */
> -#define XPRT_TRANSPORT_RDMA	256
> -
> -/*
>   * rpcbind (v3+) RDMA netid.
>   */
>  #define RPCBIND_NETID_RDMA	"rdma"
> diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
> index c2a46c4..d7c98d1 100644
> --- a/include/linux/sunrpc/xprtsock.h
> +++ b/include/linux/sunrpc/xprtsock.h
> @@ -20,8 +20,13 @@ void		cleanup_socket_xprt(void);
>   * values. No such restriction exists for new transports, except that
>   * they may not collide with these values (17 and 6, respectively).
>   */
> -#define XPRT_TRANSPORT_UDP	IPPROTO_UDP
> -#define XPRT_TRANSPORT_TCP	IPPROTO_TCP
> +#define XPRT_TRANSPORT_BC	(1 << 31)
> +enum xprt_transports {
> +	XPRT_TRANSPORT_UDP 	= IPPROTO_UDP,
> +	XPRT_TRANSPORT_TCP 	= IPPROTO_TCP,
> +	XPRT_TRANSPORT_BC_TCP 	= IPPROTO_TCP | XPRT_TRANSPORT_BC,
> +	XPRT_TRANSPORT_RDMA	= 256
> +};

This fails to compile when CONFIG_SUNRPC_XPRT_RDMA is set.

A minimal fix might be:

	--- a/net/sunrpc/xprtrdma/transport.c
	+++ b/net/sunrpc/xprtrdma/transport.c
	@@ -50,6 +50,8 @@
	 #include <linux/module.h>
	 #include <linux/init.h>
	 #include <linux/seq_file.h>
	+#include <linux/in.h>
	+#include <linux/sunrpc/xprtsock.h>
 
	 #include "xprt_rdma.h"
 
Or maybe just ditch the enum and leave these as they were before.

--b.
