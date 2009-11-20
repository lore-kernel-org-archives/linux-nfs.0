From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] SUNRPC: Use a cached RPC client and transport for
 rpcbind upcalls
Date: Fri, 20 Nov 2009 18:57:01 -0500
Message-ID: <1258761421.2982.7.camel@localhost>
References: <20091120224437.3504.1598.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:34349 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752962AbZKTX47 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2009 18:56:59 -0500
In-Reply-To: <20091120224437.3504.1598.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-11-20 at 17:46 -0500, Chuck Lever wrote: 
> The kernel's rpcbind client creates and deletes an rpc_clnt and its
> underlying transport socket for every upcall to the local rpcbind
> daemon.
> 
> When starting a typical NFS server on IPv4 and IPv6, the NFS service
> itself does three upcalls (one per version) times two upcalls (one
> per transport) times two upcalls (one per address family), making 12,
> plus another one for the initial call to unregister previous NFS
> services.  Starting the NLM service adds an additional 13 upcalls,
> for similar reasons.
> 
> (Currently the NFS service doesn't start IPv6 listeners, but it will
> soon enough).
> 
> Instead, let's create an rpc_clnt for rpcbind upcalls during the
> first local rpcbind query, and cache it.  This saves the overhead of
> creating and destroying an rpc_clnt and a socket for every upcall.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> Trond-
> 
> Does this refresh address your concern?

Most of them. You still need to fix cleanup_rpcb_clnt() so that it
doesn't try to call rpc_shutdown_client() with NULL arguments.

Cheers
  Trond

