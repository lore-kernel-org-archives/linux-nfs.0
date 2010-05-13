Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25852 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751326Ab0EMVIX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 May 2010 17:08:23 -0400
Received: from localhost.localdomain (heimdal.trondhjem.org [10.58.49.73] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4DL8MCK021257
	for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 14:08:22 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/15] SUNRPC: Fix xs_setup_bc_tcp()
Date: Thu, 13 May 2010 17:08:07 -0400
Message-Id: <1273784901-25599-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

It is a BUG for anybody to call this function without setting
args->bc_xprt. Trying to return an error value is just wrong, since the
user cannot fix this: it is a programming error, not a user error.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/xprtsock.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3d1dcdf..beefa7a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2442,9 +2442,6 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 	struct sock_xprt *transport;
 	struct svc_sock *bc_sock;
 
-	if (!args->bc_xprt)
-		ERR_PTR(-EINVAL);
-
 	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries);
 	if (IS_ERR(xprt))
 		return xprt;
-- 
1.6.6.1

