From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 03/33] SUNRPC: Don't attempt to destroy expired
	RPCSEC_GSS credentials..
Date: Tue, 22 Apr 2008 11:06:40 -0400
Message-ID: <1208876800.11982.6.camel@heimdal.trondhjem.org>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <20080419204047.14124.64969.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <FB8780E7-FE92-40D6-8DFE-0663DF1B0162@oracle.com>
	 <1208822443.7767.23.camel@heimdal.trondhjem.org>
	 <86898638-C54D-44F7-917E-1EDF6795B56C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34394 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933707AbYDVPLB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Apr 2008 11:11:01 -0400
In-Reply-To: <86898638-C54D-44F7-917E-1EDF6795B56C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-04-22 at 09:38 -0400, Chuck Lever wrote:
> > RFC-2203 states that servers are supposed to silently discard requests
> > that they don't recognise (see section 5.3.3.1 - Context  
> > Management), so
> > it is correct server behaviour.
> 
> 
> Dropping the request to destroy a context is fine.  Temporarily  
> fencing the client is what I was concerned about.

I'd agree that is somewhat drastic, and have passed the information on
to the server vendor, however that doesn't change the fact that we have
a client bug too: we should not be using expired creds.

The client side performance problem was compounded by the fact that the
RPCSEC_GSS destruction call was sent as a hard RPC call, and the fact
that we impose the NFSv4 rule that we need to drop the connection before
resending a request.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
