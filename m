Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:46740 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751186AbdAQUcw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Jan 2017 15:32:52 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 08/10] NFS: No need to set and return status in nfs41_lock_expired()
Date: Tue, 17 Jan 2017 15:32:03 -0500
Message-ID: <20170117203205.29033-9-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
References: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 67aa9cf5f569..c6d0a93ca652 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6274,8 +6274,7 @@ static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *reques
 	if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) ||
 	    test_bit(NFS_LOCK_LOST, &lsp->ls_flags))
 		return 0;
-	status = nfs4_lock_expired(state, request);
-	return status;
+	return nfs4_lock_expired(state, request);
 }
 #endif
 
-- 
2.11.0

