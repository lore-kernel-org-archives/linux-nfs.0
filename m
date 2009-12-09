From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/3] SQUASHME: pnfsd: define a is_ds_only_session helper
Date: Wed,  9 Dec 2009 12:27:34 +0200
Message-ID: <1260354454-12109-1-git-send-email-bhalevy@panasas.com>
References: <4B1F7AF6.2080305@panasas.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:9388 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754484AbZLIK13 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Dec 2009 05:27:29 -0500
In-Reply-To: <4B1F7AF6.2080305@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c  |    3 +--
 include/linux/nfs4.h |    7 +++++++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index aa2e9c2..019b936 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1342,8 +1342,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		cr_ses->flags &= ~SESSION4_PERSIST;
 		cr_ses->flags &= ~SESSION4_RDMA;
 
-		if (!(unconf->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS) &&
-		    (unconf->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS))
+		if (is_ds_only_session(unconf->cl_exchange_flags))
 			cr_ses->flags &= ~SESSION4_BACK_CHAN;
 
 		if (cr_ses->flags & SESSION4_BACK_CHAN) {
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 8a53213..e84b442 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -119,6 +119,13 @@
 #define EXCHGID4_FLAG_MASK_A			0x40070003
 #define EXCHGID4_FLAG_MASK_R			0x80070003
 
+static inline bool
+is_ds_only_session(u32 exchange_flags)
+{
+	u32 mask = EXCHGID4_FLAG_USE_PNFS_DS | EXCHGID4_FLAG_USE_PNFS_MDS;
+	return (exchange_flags & mask) == EXCHGID4_FLAG_USE_PNFS_DS;
+}
+
 #define SEQ4_STATUS_CB_PATH_DOWN		0x00000001
 #define SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRING	0x00000002
 #define SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRED	0x00000004
-- 
1.6.5.1

