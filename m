Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:22186 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755339Ab2JWOxw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Oct 2012 10:53:52 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 02/25] SUNRPC: remove BUG_ON from rpc_bind_new_program
Date: Tue, 23 Oct 2012 10:43:26 -0400
Message-Id: <1351003429-18887-3-git-send-email-dros@netapp.com>
In-Reply-To: <1351003429-18887-1-git-send-email-dros@netapp.com>
References: <1351003429-18887-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of calling BUG_ON when rpc_bind_new_program gets an invalid
rpc program version, print a KERN_ERR message and return -EINVAL.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/clnt.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index abb7f5e..eacdb15 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -700,7 +700,11 @@ struct rpc_clnt *rpc_bind_new_program(struct rpc_clnt *old,
 	const struct rpc_version *version;
 	int err;
 
-	BUG_ON(vers >= program->nrvers || !program->version[vers]);
+	if (vers >= program->nrvers || !program->version[vers]) {
+		pr_err("RPC: invalid program version %u for program %s\n",
+			vers, program->name);
+		return ERR_PTR(-EINVAL);
+	}
 	version = program->version[vers];
 	clnt = rpc_clone_client(old);
 	if (IS_ERR(clnt))
-- 
1.7.9.6 (Apple Git-31.1)

