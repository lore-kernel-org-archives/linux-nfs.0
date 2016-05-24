Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59268 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752168AbcEXVQU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 May 2016 17:16:20 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/3] SUNRPC: fix xprt leak on xps allocation failure
Date: Tue, 24 May 2016 17:16:14 -0400
Message-Id: <1464124576-27467-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1464124576-27467-1-git-send-email-bfields@redhat.com>
References: <1464124576-27467-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Callers of rpc_create_xprt expect it to put the xprt on success and
failure.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/clnt.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Alternatively, maybe we should just change that convention and leave it
to callers to put the xprt on failure?

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 7e0c9bf22df8..a87e29ac993e 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -453,9 +453,10 @@ struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
 	struct rpc_xprt_switch *xps;
 
 	xps = xprt_switch_alloc(xprt, GFP_KERNEL);
-	if (xps == NULL)
+	if (xps == NULL) {
+		xprt_put(xprt);
 		return ERR_PTR(-ENOMEM);
-
+	}
 	clnt = rpc_new_client(args, xps, xprt, NULL);
 	if (IS_ERR(clnt))
 		return clnt;
-- 
2.5.5

