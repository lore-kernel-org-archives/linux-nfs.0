Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f171.google.com ([209.85.192.171]:41894 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753398AbaIALcp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Sep 2014 07:32:45 -0400
From: Shakil A Khan <shakilk1729@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, peterz@infradead.org,
        paulmck@linux.vnet.ibm.com, andros@netapp.com, jlayton@primarydata.com,
        davem@davemloft.net, bfields@fieldses.org,
        trond.myklebust@primarydata.com, Shakil A Khan <shakilk1729@gmail.com>
Subject: [PATCH] Next branch: authgss: authgss.c: Fix warnings for uninitizlized variable expire
Date: Mon,  1 Sep 2014 07:32:34 -0400
Message-Id: <1409571154-50408-1-git-send-email-shakilk1729@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by : Shakil A Khan <shakilk1729@gmail.com>
---
 net/sunrpc/auth_gss/auth_gss.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index afb292c..bea0951 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1387,7 +1387,7 @@ gss_key_timeout(struct rpc_cred *rc)
 	struct gss_cred *gss_cred = container_of(rc, struct gss_cred, gc_base);
 	struct gss_cl_ctx *ctx;
 	unsigned long now = jiffies;
-	unsigned long expire;
+	unsigned long expire = 0;
 
 	rcu_read_lock();
 	ctx = rcu_dereference(gss_cred->gc_ctx);
-- 
1.7.1

