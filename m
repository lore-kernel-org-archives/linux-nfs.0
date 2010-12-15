Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57906 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753207Ab0LOQDZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Dec 2010 11:03:25 -0500
Received: from localhost.localdomain (vpn2ntap-71744.hq.netapp.com [10.58.57.236])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBFG3Lou001580
	for <linux-nfs@vger.kernel.org>; Wed, 15 Dec 2010 08:03:24 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 05/11] wave 2: remove notify_drained
Date: Wed, 15 Dec 2010 11:03:05 -0500
Message-Id: <1292428991-30788-5-git-send-email-iisaman@netapp.com>
In-Reply-To: <1292428991-30788-1-git-send-email-iisaman@netapp.com>
References: <1292428991-30788-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Just code it inline.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback.h |    5 -----
 fs/nfs/pnfs.c     |    2 +-
 2 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 6691be1..c4d2a07 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -168,11 +168,6 @@ extern unsigned nfs4_callback_layoutrecall(
 
 extern void nfs4_check_drain_bc_complete(struct nfs4_session *ses);
 
-static inline void notify_drained(struct nfs_client *clp, int count)
-{
-	atomic_sub(count, &clp->cl_drain_notify);
-}
-
 #endif /* CONFIG_NFS_V4_1 */
 
 extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index df6561a..dadc113 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -287,7 +287,7 @@ static void free_lseg(struct pnfs_layout_segment *lseg)
 
 	BUG_ON(atomic_read(&lseg->pls_refcount) != 0);
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
-	notify_drained(NFS_SERVER(ino)->nfs_client, count);
+	atomic_sub(count, &NFS_SERVER(ino)->nfs_client->cl_drain_notify);
 	/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
 	put_layout_hdr(NFS_I(ino)->layout);
 }
-- 
1.7.2.1

