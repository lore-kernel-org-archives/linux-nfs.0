From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 02/33] SUNRPC: Fix up xprt_write_space()
Date: Mon, 21 Apr 2008 19:51:57 -0400
Message-ID: <1208821917.7767.13.camel@heimdal.trondhjem.org>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <20080419204047.14124.5947.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <31D9D5A4-237E-4B4D-85B4-43E212D72A1F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54324 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752874AbYDUXwM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Apr 2008 19:52:12 -0400
In-Reply-To: <31D9D5A4-237E-4B4D-85B4-43E212D72A1F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-04-21 at 13:31 -0400, Chuck Lever wrote:
> Hi Trond-
> 
> On Apr 19, 2008, at 4:40 PM, Trond Myklebust wrote:
> > The rest of the networking layer uses SOCK_ASYNC_NOSPACE to signal  
> > whether
> > or not we have someone waiting for buffer memory. Convert the SUNRPC  
> > layer
> > to use the same idiom.
> 
> As near as I can tell, SOCK_NOSPACE is used for this purpose.  It  
> really isn't clear what SOCK_ASYNC_NOSPACE is used for.

See sock_wake_async(): The SOCK_ASYNC_NOSPACE flag basically turns on
and off the mechanism for notifying userland that the socket send
congestion is over.

> In fact I found at least one comment that suggested these flags  
> currently may be used inconsistently in the network layer.  Did you  
> happen to find any unambiguous documentation explaining how the  
> network layer uses these flags?  (I for one would like to understand  
> this better).
> 
> I'm a little concerned about this patch overall because the  
> SOCK_NOSPACE flags interface is well understood by only a handful of  
> people in the universe, so it's difficult for us networking outsiders  
> to evaluate this patch.

See net/ipv4/tcp_input.c:tcp_cwnd_application_limited(). The
SOCK_NOSPACE flag is used to notify the code that regulates the TCP
congestion window that the application hit the sndbuf limit. It is
normally supposed to be cleared in sk_stream_write_space() if and only
if we're below the low waterline for the sndbuf.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
