Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50808 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932127AbeEHQLa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 8 May 2018 12:11:30 -0400
Date: Tue, 8 May 2018 12:11:30 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@hammer.space>
Cc: "syzbot+4b98281f2401ab849f4b@syzkaller.appspotmail.com"
        <syzbot+4b98281f2401ab849f4b@syzkaller.appspotmail.com>,
        "syzkaller-bugs@googlegroups.com" <syzkaller-bugs@googlegroups.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: Re: general protection fault in encode_rpcb_string
Message-ID: <20180508161130.GC6151@fieldses.org>
References: <f4f5e80803d08f47b9056a0366dd@google.com>
 <20180417213308.GC18217@fieldses.org>
 <1524002074.63751.5.camel@hammer.space>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1524002074.63751.5.camel@hammer.space>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>
Date: Tue, 8 May 2018 11:47:03 -0400
Subject: [PATCH 2/2] sunrpc: convert unnecessary GFP_ATOMIC to GFP_NOFS

It's OK to sleep here, we just don't want to recurse into the filesystem
as this writeout could be waiting on this.

As a next step: the documentation for GFP_NOFS says "Please try to avoid
using this flag directly and instead use memalloc_nofs_{save,restore} to
mark the whole scope which cannot/shouldn't recurse into the FS layer
with a short explanation why. All allocation requests will inherit
GFP_NOFS implicitly."

But I'm not sure where to do this.  Should the workqueue could be
arranging that for us in the case of workqueues created with
WQ_MEM_RECLAIM?

Reported-by: Trond Myklebust <trondmy@hammer.space>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/rpcb_clnt.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

On Tue, Apr 17, 2018 at 09:54:36PM +0000, Trond Myklebust wrote:
> Yes, and we can probably convert it, and the other GFP_ATOMIC
> allocations in the rpcbind client to use GFP_NOFS in order to improve
> reliability.

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 82c120e51d64..576e84a1adee 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -752,7 +752,7 @@ void rpcb_getport_async(struct rpc_task *task)
 		goto bailout_nofree;
 	}
 
-	map = kzalloc(sizeof(struct rpcbind_args), GFP_ATOMIC);
+	map = kzalloc(sizeof(struct rpcbind_args), GFP_NOFS);
 	if (!map) {
 		status = -ENOMEM;
 		dprintk("RPC: %5u %s: no memory available\n",
@@ -770,7 +770,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	case RPCBVERS_4:
 	case RPCBVERS_3:
 		map->r_netid = xprt->address_strings[RPC_DISPLAY_NETID];
-		map->r_addr = rpc_sockaddr2uaddr(sap, GFP_ATOMIC);
+		map->r_addr = rpc_sockaddr2uaddr(sap, GFP_NOFS);
 		if (!map->r_addr) {
 			status = -ENOMEM;
 			dprintk("RPC: %5u %s: no memory available\n",
-- 
2.17.0

