Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:34886 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbaHUAdF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2014 20:33:05 -0400
Received: by mail-ie0-f170.google.com with SMTP id rl12so3866407iec.1
        for <linux-nfs@vger.kernel.org>; Wed, 20 Aug 2014 17:33:03 -0700 (PDT)
Message-ID: <1408581184.4029.5.camel@leira.trondhjem.org>
Subject: Re: [PATCH 1/2] SUNRPC: track when a client connection is routed to
 the local host.
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 20 Aug 2014 20:33:04 -0400
In-Reply-To: <20140818062254.1449.26590.stgit@notabene.brown>
References: <20140818061727.1449.89101.stgit@notabene.brown>
	 <20140818062254.1449.26590.stgit@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2014-08-18 at 16:22 +1000, NeilBrown wrote:
> If requests are being sent to the local host, then NFS will
> need to take care to avoid deadlocks.
> 
> So keep track when accepting a connection or sending a UDP request
> and set a flag in the svc_xprt when the peer connected to is local.
> 
> The interface rpc_is_foreign() is provided to check is a given client
> is connected to a foreign server.  When it returns zero it is either
> not connected or connected to a local server and in either case
> greater care is needed.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  include/linux/sunrpc/clnt.h |    1 +
>  include/linux/sunrpc/xprt.h |    1 +
>  net/sunrpc/clnt.c           |   25 +++++++++++++++++++++++++
>  net/sunrpc/xprtsock.c       |    9 +++++++++
>  4 files changed, 36 insertions(+)
> 
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index 70736b98c721..cd79b2a28ceb 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -175,6 +175,7 @@ void		rpc_force_rebind(struct rpc_clnt *);
>  size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
>  const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
>  int		rpc_localaddr(struct rpc_clnt *, struct sockaddr *, size_t);
> +int		rpc_is_foreign(struct rpc_clnt *);
>  
>  #endif /* __KERNEL__ */
>  #endif /* _LINUX_SUNRPC_CLNT_H */
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index fcbfe8783243..6a9dffcb9d3f 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -357,6 +357,7 @@ int			xs_swapper(struct rpc_xprt *xprt, int enable);
>  #define XPRT_CONNECTION_ABORT	(7)
>  #define XPRT_CONNECTION_CLOSE	(8)
>  #define XPRT_CONGESTED		(9)
> +#define XPRT_LOCAL		(10)
>  

Can we please rename that to XPRT_LOOPBACK or something along those
lines? To me XPRT_LOCAL looks a little too close for comfort to
AF_LOCAL, which is also a supported transport.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


