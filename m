From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 01/10] SUNRPC: Clean up RPCBIND_MAXUADDRLEN definitions
Date: Thu, 16 Jul 2009 14:56:30 -0400
Message-ID: <1247770590.12292.79.camel@heimdal.trondhjem.org>
References: <20090715212628.7582.98251.stgit@matisse.1015granger.net>
	 <20090715213654.7582.2418.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:53948 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932941AbZGPS4d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jul 2009 14:56:33 -0400
In-Reply-To: <20090715213654.7582.2418.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-07-15 at 17:36 -0400, Chuck Lever wrote:
> Clean up: Replace the single-integer definition of RPCBIND_MAXUADDRLEN
> with a definition that is based on previously defined address string
> sizes, and document the way this maximum is calculated.  Also provide
> a separate macro for the size of the port number extension.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  include/linux/sunrpc/msg_prot.h |   18 +++++++++++++++++-
>  1 files changed, 17 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/sunrpc/msg_prot.h b/include/linux/sunrpc/msg_prot.h
> index 70df4f1..063e806 100644
> --- a/include/linux/sunrpc/msg_prot.h
> +++ b/include/linux/sunrpc/msg_prot.h
> @@ -189,7 +189,23 @@ typedef __be32	rpc_fraghdr;
>   * Additionally, the two alternative forms specified in Section 2.2 of
>   * [RFC2373] are also acceptable.
>   */
> -#define RPCBIND_MAXUADDRLEN	(56u)
> +
> +#include <linux/inet.h>
> +
> +/* Maximum size of the port number part of a universal address */
> +#define RPCBIND_MAXUADDRPLEN	sizeof(".255.255")
> +
> +/* Maximum size of an IPv4 universal address */
> +#define RPCBIND_MAXUADDR4LEN	\
> +		(INET_ADDRSTRLEN + RPCBIND_MAXUADDRPLEN)
> +
> +/* Maximum size of an IPv6 universal address */
> +#define RPCBIND_MAXUADDR6LEN	\
> +		(INET6_ADDRSTRLEN + RPCBIND_MAXUADDRPLEN)
> +
> +#define __RPCB_MAXLEN(x, y) (x > y ? x : y)
> +#define RPCBIND_MAXUADDRLEN	\
> +		__RPCB_MAXLEN(RPCBIND_MAXUADDR4LEN, RPCBIND_MAXUADDR6LEN)

Ewww... We _know_ that this will always evaluate to
RPCBIND_MAXUADDR6LEN, so why pretend that we need the above
"calculation"?

>  #endif /* __KERNEL__ */
>  #endif /* _LINUX_SUNRPC_MSGPROT_H_ */
> 


