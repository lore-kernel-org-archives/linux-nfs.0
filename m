Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34077 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbcHHJNx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Aug 2016 05:13:53 -0400
Date: Mon, 8 Aug 2016 14:43:49 +0530
From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
To: bfields@fieldses.org, jlayton@poochiereds.net,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        davem@davemloft.net, linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc: julia.lawall@lip6.fr
Subject: [PATCH] sunrpc: Remove unnecessary variable
Message-ID: <20160808091349.GA20849@amitoj-Inspiron-3542>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The variable `err` is not used anywhere and just returns the
predefined value `0` at the end of the function. Hence, remove the
variable and return 0 explicitly.

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 net/sunrpc/clnt.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index b7f2104..0a775fa 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -184,7 +184,6 @@ static int __rpc_clnt_handle_event(struct rpc_clnt *clnt, unsigned long event,
 				   struct super_block *sb)
 {
 	struct dentry *dentry;
-	int err = 0;
 
 	switch (event) {
 	case RPC_PIPEFS_MOUNT:
@@ -201,7 +200,7 @@ static int __rpc_clnt_handle_event(struct rpc_clnt *clnt, unsigned long event,
 		printk(KERN_ERR "%s: unknown event: %ld\n", __func__, event);
 		return -ENOTSUPP;
 	}
-	return err;
+	return 0;
 }
 
 static int __rpc_pipefs_event(struct rpc_clnt *clnt, unsigned long event,
-- 
1.9.1

