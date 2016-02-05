Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:13990 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751364AbcBEVIr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2016 16:08:47 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH RFC Version 1 1/6] SUNRPC fix rpc_clnt_add_xprt setup return
Date: Fri, 5 Feb 2016 16:08:33 -0500
Message-ID: <1454706518-4641-2-git-send-email-andros@netapp.com>
In-Reply-To: <1454706518-4641-1-git-send-email-andros@netapp.com>
References: <1454706518-4641-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Caller rpc_clnt_add_xprt() expects zero on success.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/clnt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index efd6ffc..c0469d1 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2573,7 +2573,7 @@ int rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	rpc_put_task(task);
-	return 1;
+	return 0;
 }
 EXPORT_SYMBOL_GPL(rpc_clnt_test_and_add_xprt);
 
-- 
1.8.3.1

