Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39841 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756826Ab1DFXGc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2011 19:06:32 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/7] svcrpc: note network-order types in svc_process_calldir
Date: Wed,  6 Apr 2011 19:06:22 -0400
Message-Id: <1302131186-6578-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1302131186-6578-1-git-send-email-bfields@redhat.com>
References: <1302131186-6578-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcsock.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 828fff7..2053259 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -976,9 +976,9 @@ static int svc_process_calldir(struct svc_sock *svsk, struct svc_rqst *rqstp,
 			       struct rpc_rqst **reqpp, struct kvec *vec)
 {
 	struct rpc_rqst *req = NULL;
-	u32 *p;
-	u32 xid;
-	u32 calldir;
+	__be32 *p;
+	__be32 xid;
+	__be32 calldir;
 	int len;
 
 	len = svc_recvfrom(rqstp, vec, 1, 8);
-- 
1.7.1

