Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 838A6C43387
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 15:42:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5D824217D8
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 15:42:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731803AbeLTPmh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Dec 2018 10:42:37 -0500
Received: from fieldses.org ([173.255.197.46]:48536 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729184AbeLTPmg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Dec 2018 10:42:36 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 54E9C1C83; Thu, 20 Dec 2018 10:42:36 -0500 (EST)
Date:   Thu, 20 Dec 2018 10:42:36 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: convert unnecessary GFP_ATOMIC to GFP_NOFS
Message-ID: <20181220154236.GC6063@fieldses.org>
References: <20181220153511.GB6063@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181220153511.GB6063@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

It's OK to sleep here, we just don't want to recurse into the filesystem
as this writeout could be waiting on this.

Future work: the documentation for GFP_NOFS says "Please try to avoid
using this flag directly and instead use memalloc_nofs_{save,restore} to
mark the whole scope which cannot/shouldn't recurse into the FS layer
with a short explanation why. All allocation requests will inherit
GFP_NOFS implicitly."

But I'm not sure where to do this.  Should the workqueue be arranging
that for us in the case of workqueues created with WQ_MEM_RECLAIM?

Reported-by: Trond Myklebust <trondmy@hammer.space>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/rpcb_clnt.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Also, I've still got this one.  (And still haven't looked into whether
it should be using a memalloc_nofs_{save,restore} elsewhere instead.)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 08b5fa4a2852..41a971ac1c63 100644
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
2.19.2

