From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/7] SUNRPC: Allow RPCs to fail quickly if the server
 is unreachable
Date: Wed, 07 Oct 2009 18:47:38 -0400
Message-ID: <1254955658.7045.46.camel@heimdal.trondhjem.org>
References: <20091007215019.1844.17414.stgit@matisse.1015granger.net>
	 <20091007220232.1844.62559.stgit@matisse.1015granger.net>
	 <1254954039.7045.31.camel@heimdal.trondhjem.org>
	 <680A4087-D9CB-40D6-8C7E-239E7EB8CC21@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59741 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754516AbZJGWsQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Oct 2009 18:48:16 -0400
In-Reply-To: <680A4087-D9CB-40D6-8C7E-239E7EB8CC21@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-10-07 at 18:34 -0400, Chuck Lever wrote:
> On Oct 7, 2009, at 6:20 PM, Trond Myklebust wrote:
> > On Wed, 2009-10-07 at 18:02 -0400, Chuck Lever wrote:
> >> 		 * Special cases: if we've been waiting on the
> >> 		 * socket's write_space() callback, or if the
> >> @@ -1198,6 +1200,11 @@ call_transmit_status(struct rpc_task *task)
> >> 	case -EHOSTUNREACH:
> >> 	case -ENETUNREACH:
> >> 	case -EPIPE:
> >> +		if (RPC_IS_SOFTCONN(task)) {
> >> +			xprt_end_transmit(task);
> >> +			rpc_exit(task, task->tk_status);
> >> +			break;
> >> +		}
> >
> > This doesn't look robust. The EPIPE error may mean that the socket got
> > closed as a result of server action, or a previous RPC call. Don't
> > forget that we might want to reuse SOFTCONN for NFSv4.1 session  
> > binding
> > semantics.
> 
> EPIPE can easily be handled in a separate case that doesn't have soft  
> connect.

It directly affects rpcbind when you cache the rpc client, as you do in
later patches. If one RPC call fails with EPIPE, then so will all the
subsequent ones...

IOW: I'd suggest moving EPIPE _below_ your above SOFTCONN special case.
You might want to do the same for ENOTCONN...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
