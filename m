From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 07/10] pnfs-submit: avoid race handling return on close
Date: Mon, 14 Jun 2010 21:46:12 -0400
Message-ID: <1276566375-24566-8-git-send-email-iisaman@netapp.com>
References: <1276566375-24566-1-git-send-email-iisaman@netapp.com>
 <1276566375-24566-2-git-send-email-iisaman@netapp.com>
 <1276566375-24566-3-git-send-email-iisaman@netapp.com>
 <1276566375-24566-4-git-send-email-iisaman@netapp.com>
 <1276566375-24566-5-git-send-email-iisaman@netapp.com>
 <1276566375-24566-6-git-send-email-iisaman@netapp.com>
 <1276566375-24566-7-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:52271 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932220Ab0FOO3G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jun 2010 10:29:06 -0400
Received: from localhost.localdomain (netapp-61.citi.umich.edu [141.212.112.250])
	by citi.umich.edu (Postfix) with ESMTP id 5E20D18168
	for <linux-nfs@vger.kernel.org>; Tue, 15 Jun 2010 10:20:11 -0400 (EDT)
In-Reply-To: <1276566375-24566-7-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This prepares for the next patch.

NOTE this doesn't really fix any current race, since
layout going to NULL is OK.  But layout changing from NULL to nonNULL
is a real race that is not fixed

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4state.c        |    5 +++--
 fs/nfs/pnfs.c             |   11 +++++++++++
 include/linux/nfs4_pnfs.h |    2 ++
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index d5144bd..8a7a64c 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -594,11 +594,12 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state,
 	} else {
 #ifdef CONFIG_NFS_V4_1
 		struct nfs_inode *nfsi = NFS_I(state->inode);
+		int roc = nfs4_roc_iomode(nfsi);
 
-		if (has_layout(nfsi) && nfsi->layout.roc_iomode) {
+		if (roc) {
 			struct nfs4_pnfs_layout_segment range;
 
-			range.iomode = nfsi->layout.roc_iomode;
+			range.iomode = roc;
 			range.offset = 0;
 			range.length = NFS4_MAX_UINT64;
 			pnfs_return_layout(state->inode, &range, NULL,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6def09c..bd11ec7 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -321,6 +321,17 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
 #define BUG_ON_UNLOCKED_LO(lo) do {} while (0)
 #endif /* CONFIG_SMP */
 
+int nfs4_roc_iomode(struct nfs_inode *nfsi)
+{
+	int rv = 0;
+
+	spin_lock(&pnfs_spinlock);
+	if (has_layout(nfsi))
+		rv = nfsi->layout.roc_iomode;
+	spin_unlock(&pnfs_spinlock);
+	return rv;
+}
+
 static inline void
 get_layout(struct pnfs_layout_type *lo)
 {
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 0eb9b16..2ea131f 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -86,6 +86,8 @@ layoutcommit_needed(struct nfs_inode *nfsi)
 	return test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->pnfs_layout_state);
 }
 
+int nfs4_roc_iomode(struct nfs_inode *nfs);
+
 #else /* CONFIG_NFS_V4_1 */
 
 static inline bool
-- 
1.6.6.1

