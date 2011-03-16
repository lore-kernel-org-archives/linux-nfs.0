Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:42140 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754425Ab1CPAMQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2011 20:12:16 -0400
Date: Tue, 15 Mar 2011 17:11:59 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        Neil Brown <neilb@suse.de>, bfields@fieldses.org
Subject: [PATCH -next] sunrpc: fix printk format warning
Message-Id: <20110315171159.b0e1fab1.randy.dunlap@oracle.com>
In-Reply-To: <20110315194543.a5d56c0c.sfr@canb.auug.org.au>
References: <20110315194543.a5d56c0c.sfr@canb.auug.org.au>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix printk format build warning:

net/sunrpc/xprtrdma/verbs.c:1463: warning: format '%llx' expects type 'long long unsigned int', but argument 3 has type 'dma_addr_t'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux-next-20110315.orig/net/sunrpc/xprtrdma/verbs.c
+++ linux-next-20110315/net/sunrpc/xprtrdma/verbs.c
@@ -1462,7 +1462,8 @@ rpcrdma_map_one(struct rpcrdma_ia *ia, s
 	if (ib_dma_mapping_error(ia->ri_id->device, seg->mr_dma)) {
 		dprintk("RPC:       %s: mr_dma %llx mr_offset %p mr_dma_len %zu\n",
 			__func__,
-			seg->mr_dma, seg->mr_offset, seg->mr_dmalen);
+			(unsigned long long)seg->mr_dma,
+			seg->mr_offset, seg->mr_dmalen);
 	}
 }
 
