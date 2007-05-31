From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] gfs2: stop giving out non-cluster-coherent leases
Date: Thu, 31 May 2007 17:40:24 -0400
Message-ID: <1180647626378-git-send-email-bfields@fieldses.org>
References: <1180647624483-git-send-email-bfields@fieldses.org>
	<11806476252240-git-send-email-bfields@fieldses.org>
	<11806476252913-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Teigland <teigland@redhat.com>, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HtsOo-0000b9-F5
	for nfs@lists.sourceforge.net; Thu, 31 May 2007 14:41:38 -0700
Received: from pear.citi.umich.edu ([141.211.133.128])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HtsOr-00030c-A5
	for nfs@lists.sourceforge.net; Thu, 31 May 2007 14:41:41 -0700
In-Reply-To: <11806476252913-git-send-email-bfields@fieldses.org>
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
index 064df88..78ac4ac 100644
--- a/fs/gfs2/ops_file.c
+++ b/fs/gfs2/ops_file.c
@@ -489,6 +489,31 @@ static int gfs2_fsync(struct file *file, struct dentry *dentry, int datasync)
 }
 
 /**
+ * gfs2_set_lease - acquire/release a file lease
+ * @file: the file pointer
+ * @arg: lease type
+ * @fl: file lock
+ *
+ * Returns: errno
+ */
+
+static int gfs2_set_lease(struct file *file, long arg, struct file_lock **fl)
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
+	.set_lease	= gfs2_set_lease,
 };
 
 const struct file_operations gfs2_dir_fops = {
-- 
1.5.2.rc3


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
