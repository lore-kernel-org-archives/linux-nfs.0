From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 07/30] NFS: Fix the NFS attribute update
Date: Tue, 07 Oct 2008 18:19:53 -0400
Message-ID: <20081007221953.20945.88069.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52974 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756206AbYJGWcw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:52 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m97MWi0f025764
	for <linux-nfs@vger.kernel.org>; Tue, 7 Oct 2008 15:32:48 -0700 (PDT)
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently nfs_refresh_inode() will only update the inode metadata if it
sees that the RPC call that returned the nfs_fattr was started
after the last update of the inode. This means that if we have parallel
RPC calls to the same inode (when sending WRITE calls, for instance), we
may often miss updates.

This patch attempts to recover those missed updates by also accepting
them if the ctime in the nfs_fattr is more recent than the inode's
cached ctime.
It also recovers the case where the file size has increased, but the
ctime has not been updated due to limited ctime resolution.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c |   44 +++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 41 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index f189169..8c514a1 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -948,11 +948,49 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 	return 0;
 }
 
-static int nfs_refresh_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
+static int nfs_ctime_need_update(const struct inode *inode, const struct nfs_fattr *fattr)
 {
-	struct nfs_inode *nfsi = NFS_I(inode);
+	return timespec_compare(&fattr->ctime, &inode->i_ctime) > 0;
+}
+
+static int nfs_size_need_update(const struct inode *inode, const struct nfs_fattr *fattr)
+{
+	return nfs_size_to_loff_t(fattr->size) > i_size_read(inode);
+}
 
-	if (time_after(fattr->time_start, nfsi->last_updated))
+/**
+ * nfs_inode_attrs_need_update - check if the inode attributes need updating
+ * @inode - pointer to inode
+ * @fattr - attributes
+ *
+ * Attempt to divine whether or not an RPC call reply carrying stale
+ * attributes got scheduled after another call carrying updated ones.
+ *
+ * To do so, the function first assumes that a more recent ctime means
+ * that the attributes in fattr are newer, however it also attempt to
+ * catch the case where ctime either didn't change, or went backwards
+ * (if someone reset the clock on the server) by looking at whether
+ * or not this RPC call was started after the inode was last updated.
+ * Note also the check for jiffy wraparound if the last_updated timestamp
+ * is later than 'jiffies'.
+ *
+ * The function returns 'true' if it thinks the attributes in 'fattr' are
+ * more recent than the ones cached in the inode.
+ *
+ */
+static int nfs_inode_attrs_need_update(const struct inode *inode, const struct nfs_fattr *fattr)
+{
+	const struct nfs_inode *nfsi = NFS_I(inode);
+
+	return nfs_ctime_need_update(inode, fattr) ||
+			nfs_size_need_update(inode, fattr) ||
+			time_after(fattr->time_start, nfsi->last_updated) ||
+			time_after(nfsi->last_updated, jiffies);
+}
+
+static int nfs_refresh_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
+{
+	if (nfs_inode_attrs_need_update(inode, fattr))
 		return nfs_update_inode(inode, fattr);
 	return nfs_check_inode_attributes(inode, fattr);
 }

