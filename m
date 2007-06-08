From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 4/5] gfs2: stop giving out non-cluster-coherent leases
Date: Fri,  8 Jun 2007 18:14:54 -0400
Message-ID: <1434.42228804833$1181340908@news.gmane.org>
References: <20070607170557.GA14463@fieldses.org>
 <11813408953536-git-send-email->
 <11813408952518-git-send-email->
 <11813408951909-git-send-email->
 <11813408954053-git-send-email->
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	David Teigland <teigland@redhat.com>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Robert Rappaport <robert.rappaport@gmail.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <11813408954053-git-send-email->
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Marc Eshel <eshel@almaden.ibm.com>

Since gfs2 can't prevent conflicting opens or leases on other nodes, we
probably shouldn't allow it to give out leases at all.

Put the newly defined lease operation into use in gfs2 by turning off
lease, unless we're using the "nolock' locking module (in which case all
locking is local anyway).

Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
---
 fs/gfs2/ops_file.c |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/fs/gfs2/ops_file.c b/fs/gfs2/ops_file.c
index 064df88..654000b 100644
--- a/fs/gfs2/ops_file.c
+++ b/fs/gfs2/ops_file.c
@@ -489,6 +489,31 @@ static int gfs2_fsync(struct file *file, struct dentry *dentry, int datasync)
 }
 
 /**
+ * gfs2_setlease - acquire/release a file lease
+ * @file: the file pointer
+ * @arg: lease type
+ * @fl: file lock
+ *
+ * Returns: errno
+ */
+
+static int gfs2_setlease(struct file *file, long arg, struct file_lock **fl)
+{
+	struct gfs2_sbd *sdp = GFS2_SB(file->f_mapping->host);
+	int ret = EAGAIN;
+
+	if (sdp->sd_args.ar_localflocks) {
+		return setlease(file, arg, fl);
+	}
+
+	/* For now fail the delegation request. Cluster file system can not
+	   allow any node in the cluster to get a local lease until it can
+	   be managed centrally by the cluster file system.
+	*/
+	return ret;
+}
+
+/**
  * gfs2_lock - acquire/release a posix lock on a file
  * @file: the file pointer
  * @cmd: either modify or retrieve lock state, possibly wait
@@ -639,6 +664,7 @@ const struct file_operations gfs2_file_fops = {
 	.flock		= gfs2_flock,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,
+	.setlease	= gfs2_setlease,
 };
 
 const struct file_operations gfs2_dir_fops = {
-- 
1.5.2

