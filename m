Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:18539 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751193AbdAQUcw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Jan 2017 15:32:52 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 09/10] NFS: Clean up nfs41_same_server_scope()
Date: Tue, 17 Jan 2017 15:32:04 -0500
Message-ID: <20170117203205.29033-10-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
References: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

The function is cleaner this way, since we can use the result of
memcmp() directly

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c6d0a93ca652..8395432c6fb1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7112,11 +7112,9 @@ static bool
 nfs41_same_server_scope(struct nfs41_server_scope *a,
 			struct nfs41_server_scope *b)
 {
-	if (a->server_scope_sz == b->server_scope_sz &&
-	    memcmp(a->server_scope, b->server_scope, a->server_scope_sz) == 0)
-		return true;
-
-	return false;
+	if (a->server_scope_sz != b->server_scope_sz)
+		return false;
+	return memcmp(a->server_scope, b->server_scope, a->server_scope_sz) == 0;
 }
 
 static void
-- 
2.11.0

