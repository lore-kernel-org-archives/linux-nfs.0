Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49854 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754005Ab3HANRZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Aug 2013 09:17:25 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, stable@vger.kernel.org
Subject: [PATCH 1/4] svcrpc: fix gss_rpc_upcall create error
Date: Thu,  1 Aug 2013 09:17:19 -0400
Message-Id: <1375363042-14440-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1375363042-14440-1-git-send-email-bfields@redhat.com>
References: <1375363042-14440-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/auth_gss/gss_rpc_upcall.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
index d304f41..1e1ccf5 100644
--- a/net/sunrpc/auth_gss/gss_rpc_upcall.c
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
@@ -120,7 +120,7 @@ static int gssp_rpc_create(struct net *net, struct rpc_clnt **_clnt)
 	if (IS_ERR(clnt)) {
 		dprintk("RPC:       failed to create AF_LOCAL gssproxy "
 				"client (errno %ld).\n", PTR_ERR(clnt));
-		result = -PTR_ERR(clnt);
+		result = PTR_ERR(clnt);
 		*_clnt = NULL;
 		goto out;
 	}
-- 
1.7.9.5

