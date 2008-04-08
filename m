From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH] SUNRPC: RPC client's TCP transport ignores errors
  during connect
Date: Tue, 08 Apr 2008 14:22:39 -0400
Message-ID: <EXNANE01j2iihlMWBLY00000265@exnane01.hq.netapp.com>
References: <20080408173602.21776.60671.stgit@manray.1015granger.net>
 <1207677612.11699.14.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60366 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753421AbYDHSXV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2008 14:23:21 -0400
In-Reply-To: <1207677612.11699.14.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
References: <20080408173602.21776.60671.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
 <1207677612.11699.14.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 02:00 PM 4/8/2008, Trond Myklebust wrote:
>As I said, it looks to me as if a report other than ENOTCONN or
>ETIMEDOUT will automatically result in the rpc task aborting.

FWIW, we've seen some leaks on NFS/RDMA clients that receive strange
errors from the RDMA layer when connecting to the server. I hope to be
able to test this soon to see if it eliminates the leak, but don't have the
ability to do that where I am right now.

Anyway, the RDMA layer does return some very different errors from
sockets. We attempt to "fix" them in the RPC transport before returning
them, but it's a bit of a challenge so I would welcome error hardening in
the layer(s) above.

Tom.

