From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] SUNRPC: RPC client's TCP transport ignores errors
	during connect
Date: Tue, 08 Apr 2008 14:35:43 -0400
Message-ID: <1207679743.11699.23.camel@heimdal.trondhjem.org>
References: <20080408173602.21776.60671.stgit@manray.1015granger.net>
	 <1207677612.11699.14.camel@heimdal.trondhjem.org>
	 <EXNANE01j2iihlMWBLY00000265@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34418 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753388AbYDHSnB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2008 14:43:01 -0400
In-Reply-To: <EXNANE01j2iihlMWBLY00000265-kboziUmgGqYSZCGxjG3uujkOHZLvdrmu@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-04-08 at 14:22 -0400, Talpey, Thomas wrote:
> At 02:00 PM 4/8/2008, Trond Myklebust wrote:
> >As I said, it looks to me as if a report other than ENOTCONN or
> >ETIMEDOUT will automatically result in the rpc task aborting.
> 
> FWIW, we've seen some leaks on NFS/RDMA clients that receive strange
> errors from the RDMA layer when connecting to the server. I hope to be
> able to test this soon to see if it eliminates the leak, but don't have the
> ability to do that where I am right now.
> 
> Anyway, the RDMA layer does return some very different errors from
> sockets. We attempt to "fix" them in the RPC transport before returning
> them, but it's a bit of a challenge so I would welcome error hardening in
> the layer(s) above.

The only justification for passing more errors up to the higher layers
is if they have different error handling requirements.
The reason why we currently transform more or less everything into
ENOTCONN is because the two other errors ECONNRESET and ECONNREFUSED
basically require the same kind of error handling (exit with EIO in the
"soft" case, and keep retrying in the "hard" case).

So, what kind of RDMA errors are these, and how are we failing to handle
them correctly today?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
