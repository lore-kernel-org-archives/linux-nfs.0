Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41910 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753524AbcBAUs0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Feb 2016 15:48:26 -0500
Date: Mon, 1 Feb 2016 15:48:25 -0500
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH v3 00/13] Basic multipathing support and demonstrator
Message-ID: <20160201204825.GD5499@fieldses.org>
References: <1454347277-10997-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1454347277-10997-1-git-send-email-trond.myklebust@primarydata.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 01, 2016 at 12:21:04PM -0500, Trond Myklebust wrote:
> The following patchset is intended as an RFC to demonstrate how we could
> implement multipathing in NFS.
> It adds basic support for attaching multiple RPC transports to a client,
> an embryonic policy mechanism for switching tasks across those transports
> (with a round-robin policy implementation), as well as helpers to allow
> iteration of tasks across all tranports (for instance in order to
> support NFSv4.1's BIND_CONN_TO_SESSION).
> 
> A lot of polish and finishing touches are missing. For instance, I have yet
> to add support in debugfs for these transports, and there is no support
> for mounting with NFSv4.1 session trunking. However there is a demonstrator
> that implements pNFS multipathing over NFSv3. Adding support for NFSv4.1
> requires that you call EXCHANGE_ID to allow verification of the
> major/minor server and scopeid fields, which should not be too hard.
> 
> More to come, but in the meantime, comments are welcome...

Since your prototype is doing round-robin per task, I assume the
motivating problem is that you don't want to waste bandwidth when
there's multiple links available.  Is that right, or is there some other
goal you have in mind?

--b.

> 
> Cheers
>   Trond
> 
> --------------
> v2 & v3: Fix up kbuild warnings
> 
> Trond Myklebust (13):
>   SUNRPC: Remove unused function rpc_task_reset_client
>   SUNRPC: Reorder rpc_task to put waitqueue related info in same
>     cachelines
>   SUNRPC: Uninline xprt_get(); It isn't performance critical.
>   SUNRPC: Make freeing of struct xprt rcu-safe
>   SUNRPC: Add a structure to track multiple transports
>   SUNRPC: Make rpc_clnt store the multipath iterators
>   SUNRPC: Use the multipath iterator to assign a transport to each task
>   SUNRPC: Allow caller to specify the transport to use
>   SUNRPC: Add a helper to apply a function to all the rpc_clnt's
>     transports
>   SUNRPC: Make NFS swap work with multipath
>   NFSv4.1: nfs4_proc_bind_conn_to_session must iterate over all
>     connections
>   SUNRPC: Allow addition of new transports to a struct rpc_clnt
>   pnfs/NFSv4.1: Add multipath capabilities to pNFS flexfiles servers
>     over NFSv3
> 
>  fs/nfs/nfs4proc.c                    |  51 +++-
>  fs/nfs/pnfs_nfs.c                    |  16 +-
>  include/linux/sunrpc/clnt.h          |  18 +-
>  include/linux/sunrpc/sched.h         |  32 +--
>  include/linux/sunrpc/xprt.h          |  22 +-
>  include/linux/sunrpc/xprtmultipath.h |  69 +++++
>  net/sunrpc/Makefile                  |   3 +-
>  net/sunrpc/auth_gss/auth_gss.c       |   4 +-
>  net/sunrpc/clnt.c                    | 326 ++++++++++++++++++------
>  net/sunrpc/rpcb_clnt.c               |  10 +-
>  net/sunrpc/sched.c                   |   2 +
>  net/sunrpc/xprt.c                    |  42 ++--
>  net/sunrpc/xprtmultipath.c           | 473 +++++++++++++++++++++++++++++++++++
>  net/sunrpc/xprtsock.c                |   4 +-
>  14 files changed, 938 insertions(+), 134 deletions(-)
>  create mode 100644 include/linux/sunrpc/xprtmultipath.h
>  create mode 100644 net/sunrpc/xprtmultipath.c
> 
> -- 
> 2.5.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
