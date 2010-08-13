Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48989 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754132Ab0HMVc1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:27 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 27/50] pnfs_submit: layoutreturn helper functions
Date: Fri, 13 Aug 2010 17:31:39 -0400
Message-Id: <1281735122-1496-28-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-27-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
 <1281735122-1496-21-git-send-email-andros@netapp.com>
 <1281735122-1496-22-git-send-email-andros@netapp.com>
 <1281735122-1496-23-git-send-email-andros@netapp.com>
 <1281735122-1496-24-git-send-email-andros@netapp.com>
 <1281735122-1496-25-git-send-email-andros@netapp.com>
 <1281735122-1496-26-git-send-email-andros@netapp.com>
 <1281735122-1496-27-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c        |  124 ++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4.h |    7 +++
 2 files changed, 131 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d0a6320..2ea3cbd 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -581,6 +581,25 @@ should_free_lseg(struct pnfs_layout_segment *lseg,
 		lseg->range.iomode == range->iomode);
 }
 
+static struct pnfs_layout_segment *
+has_layout_to_return(struct pnfs_layout_type *lo,
+		     struct nfs4_pnfs_layout_segment *range)
+{
+	struct pnfs_layout_segment *out = NULL, *lseg;
+	dprintk("%s:Begin lo %p offset %llu length %llu iomode %d\n",
+		__func__, lo, range->offset, range->length, range->iomode);
+
+	BUG_ON_UNLOCKED_LO(lo);
+	list_for_each_entry (lseg, &lo->segs, fi_list)
+		if (should_free_lseg(lseg, range)) {
+			out = lseg;
+			break;
+		}
+
+	dprintk("%s:Return lseg=%p\n", __func__, out);
+	return out;
+}
+
 static inline bool
 _pnfs_can_return_lseg(struct pnfs_layout_segment *lseg)
 {
@@ -621,6 +640,111 @@ pnfs_free_layout(struct pnfs_layout_type *lo,
 	dprintk("%s:Return\n", __func__);
 }
 
+static bool
+pnfs_return_layout_barrier(struct nfs_inode *nfsi,
+			   struct nfs4_pnfs_layout_segment *range)
+{
+	struct pnfs_layout_segment *lseg;
+	bool ret = false;
+
+	spin_lock(&nfsi->vfs_inode.i_lock);
+	list_for_each_entry(lseg, &nfsi->layout->segs, fi_list) {
+		if (!should_free_lseg(lseg, range))
+			continue;
+		lseg->valid = false;
+		if (!_pnfs_can_return_lseg(lseg)) {
+			dprintk("%s: wait on lseg %p refcount %d\n",
+				__func__, lseg,
+				atomic_read(&lseg->kref.refcount));
+			ret = true;
+		}
+	}
+	spin_unlock(&nfsi->vfs_inode.i_lock);
+	dprintk("%s:Return %d\n", __func__, ret);
+	return ret;
+}
+
+static int
+return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
+	      enum pnfs_layoutreturn_type type, struct pnfs_layout_type *lo,
+	      bool wait)
+{
+	return 0;
+}
+
+int
+_pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
+		    const nfs4_stateid *stateid, /* optional */
+		    enum pnfs_layoutreturn_type type,
+		    bool wait)
+{
+	struct pnfs_layout_type *lo = NULL;
+	struct nfs_inode *nfsi = NFS_I(ino);
+	struct nfs4_pnfs_layout_segment arg;
+	int status = 0;
+
+	dprintk("--> %s type %d\n", __func__, type);
+
+
+	arg.iomode = range ? range->iomode : IOMODE_ANY;
+	arg.offset = 0;
+	arg.length = NFS4_MAX_UINT64;
+
+	if (type == RETURN_FILE) {
+		spin_lock(&ino->i_lock);
+		lo = nfsi->layout;
+		if (lo && !has_layout_to_return(lo, &arg)) {
+			lo = NULL;
+		}
+		if (!lo) {
+			spin_unlock(&ino->i_lock);
+			dprintk("%s: no layout segments to return\n", __func__);
+			goto out;
+		}
+
+		/* Reference for layoutreturn matched in pnfs_layout_release */
+		get_layout(lo);
+
+		spin_unlock(&ino->i_lock);
+
+		if (pnfs_return_layout_barrier(nfsi, &arg)) {
+			if (stateid) { /* callback */
+				status = -EAGAIN;
+				goto out_put;
+			}
+			dprintk("%s: waiting\n", __func__);
+			wait_event(nfsi->lo_waitq,
+				   !pnfs_return_layout_barrier(nfsi, &arg));
+		}
+
+		if (layoutcommit_needed(nfsi)) {
+			if (stateid && !wait) { /* callback */
+				dprintk("%s: layoutcommit pending\n", __func__);
+				status = -EAGAIN;
+				goto out_put;
+			}
+			status = pnfs_layoutcommit_inode(ino, wait);
+			if (status) {
+				/* Return layout even if layoutcommit fails */
+				dprintk("%s: layoutcommit failed, status=%d. "
+					"Returning layout anyway\n",
+					__func__, status);
+			}
+		}
+
+		if (!stateid)
+			status = return_layout(ino, &arg, type, lo, wait);
+		else
+			pnfs_layout_release(lo, &arg);
+	}
+out:
+	dprintk("<-- %s status: %d\n", __func__, status);
+	return status;
+out_put:
+	put_layout(ino);
+	goto out;
+}
+
 /*
  * cmp two layout segments for sorting into layout cache
  */
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 4c4c4cc..f0cf013 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -571,6 +571,13 @@ enum pnfs_layouttype {
 	LAYOUT_NFSV4_1_FILES  = 1,
 };
 
+/* used for both layout return and recall */
+enum pnfs_layoutreturn_type {
+	RETURN_FILE = 1,
+	RETURN_FSID = 2,
+	RETURN_ALL  = 3
+};
+
 enum pnfs_iomode {
 	IOMODE_READ = 1,
 	IOMODE_RW = 2,
-- 
1.6.2.5

