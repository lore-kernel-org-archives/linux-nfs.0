Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:46730 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751137AbdAQUcx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Jan 2017 15:32:53 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 10/10] NFS: Return the comparison result directly in nfs41_match_stateid()
Date: Tue, 17 Jan 2017 15:32:05 -0500
Message-ID: <20170117203205.29033-11-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
References: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8395432c6fb1..06190beb2c52 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9107,10 +9107,8 @@ static bool nfs41_match_stateid(const nfs4_stateid *s1,
 
 	if (s1->seqid == s2->seqid)
 		return true;
-	if (s1->seqid == 0 || s2->seqid == 0)
-		return true;
 
-	return false;
+	return s1->seqid == 0 || s2->seqid == 0;
 }
 
 #endif /* CONFIG_NFS_V4_1 */
-- 
2.11.0

