From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] SUNRPC: RPC client's TCP transport ignores errors
	during connect
Date: Tue, 08 Apr 2008 16:21:13 -0400
Message-ID: <1207686073.11699.32.camel@heimdal.trondhjem.org>
References: <20080408173602.21776.60671.stgit@manray.1015granger.net>
	 <1207677350.11699.9.camel@heimdal.trondhjem.org>
	 <E12D75B9-D74B-45F0-97A3-5209F7C3539F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36283 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753179AbYDHUVm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2008 16:21:42 -0400
In-Reply-To: <E12D75B9-D74B-45F0-97A3-5209F7C3539F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-04-08 at 15:35 -0400, Chuck Lever wrote:

> Last week, you claimed:
> 
>  > The client currently doesn't retry in the case of a connection
>  > failing for a soft RPC request.
> 
> In fact, it does retry a connection attempt on soft RPC requests  
> until a *major* timeout occurs.

You're right. I forgot that we changed that.

> So is the actual bug in call_timeout?

I'm confused. What should call_timeout be doing differently?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
