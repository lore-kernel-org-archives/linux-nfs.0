From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 4/5] gfs2: stop giving out non-cluster-coherent leases
Date: Fri,  8 Jun 2007 18:14:54 -0400
Message-ID: <34327.6998763487$1181340940@news.gmane.org>
References: <20070607170557.GA14463@fieldses.org>
	<11813408953536-git-send-email-> <11813408952518-git-send-email->
	<11813408951909-git-send-email-> <11813408954053-git-send-email->
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Teigland <teigland@redhat.com>,
	Robert Rappaport <robert.rappaport@gmail.com>,
	nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: linux-fsdevel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HwmjR-0007pt-NK
	for nfs@lists.sourceforge.net; Fri, 08 Jun 2007 15:14:59 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HwmjU-0002pU-Dx
	for nfs@lists.sourceforge.net; Fri, 08 Jun 2007 15:15:00 -0700
In-Reply-To: <11813408954053-git-send-email->
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

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


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
