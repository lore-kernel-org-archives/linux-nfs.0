Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:42604 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756017Ab1FENCI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Jun 2011 09:02:08 -0400
Date: Sun, 5 Jun 2011 14:02:07 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-kernel@vger.kernel.org
Subject: [PATCH] fix return values of rpcb_create_local()
Message-ID: <20110605130207.GE11521@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

	commit 7402ab19cdd5943c7dd4f3399afe3abda8077ef5 (SUNRPC: Use AF_LOCAL
for rpcbind upcalls) broke rpcb_create_local() error reporting in several
cases.  Callers expect negative return value on error and until that commit
they used to get it in all failure exits.  Now if rpc_create() fails we get
-PTR_ERR(clnt), i.e. *positive* value.  Restore original behaviour...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 9a80a92..5efaf5f 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -193,7 +193,7 @@ static int rpcb_create_local_unix(void)
 	if (IS_ERR(clnt)) {
 		dprintk("RPC:       failed to create AF_LOCAL rpcbind "
 				"client (errno %ld).\n", PTR_ERR(clnt));
-		result = -PTR_ERR(clnt);
+		result = PTR_ERR(clnt);
 		goto out;
 	}
 
@@ -242,7 +242,7 @@ static int rpcb_create_local_net(void)
 	if (IS_ERR(clnt)) {
 		dprintk("RPC:       failed to create local rpcbind "
 				"client (errno %ld).\n", PTR_ERR(clnt));
-		result = -PTR_ERR(clnt);
+		result = PTR_ERR(clnt);
 		goto out;
 	}
 
