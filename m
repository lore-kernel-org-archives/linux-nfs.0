From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] NFS: Stop sillyname renames and unmounts from racing
Date: Wed, 31 Oct 2007 12:40:29 -0400
Message-ID: <4728AFFD.1090001@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1InGcN-0004MJ-2H
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 09:40:35 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1InGcS-0006uK-2Y
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 09:40:40 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id l9VGeVUJ009940
	for <nfs@lists.sourceforge.net>; Wed, 31 Oct 2007 12:40:31 -0400
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l9VGeUIS000719
	for <nfs@lists.sourceforge.net>; Wed, 31 Oct 2007 12:40:30 -0400
Received: from [10.12.32.32] (dickson.boston.devel.redhat.com [10.12.32.32])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	l9VGeUhN013580
	for <nfs@lists.sourceforge.net>; Wed, 31 Oct 2007 12:40:30 -0400
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

The following patch stops sillyname renames and umounts from racing.
I have a test script does the following:
     1) start nfs server
      2) mount loopback
      3) open file in background
      4) remove file
      5) stop nfs server
      6) kill -9 process which has file open
      7) restart nfs server
      8) umount looback mount.

After umount I got the "VFS: Busy inodes after unmount" message
because the processing of the rename has not finished.

Below is a patch that the uses the new silly_count mechanism to 
synchronize sillyname processing and umounts. The patch introduces a
nfs_put_super() routine that waits until the nfsi->silly_count count
is zero.

Comments?

steved.


Author: Steve Dickson <steved@redhat.com>
Date:   Wed Oct 31 12:19:26 2007 -0400

     Close a unlink/sillyname rename and umount race by added a
     nfs_put_super routine that will run through all the inode
     currently on the super block, waiting for those that are
     in the middle of a sillyname rename or removal.

     This patch stop the infamous "VFS: Busy inodes after unmount... "
     warning during umounts.

     Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/fs/inode.c b/fs/inode.c
index ed35383..da9034a 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -81,6 +81,7 @@ static struct hlist_head *inode_hashtable __read_mostly;
   * the i_state of an inode while it is in use..
   */
  DEFINE_SPINLOCK(inode_lock);
+EXPORT_SYMBOL_GPL(inode_lock);

  /*
   * iprune_mutex provides exclusion between the kswapd or try_to_free_pages
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index fa517ae..2ac3c34 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -48,6 +48,7 @@
  #include <linux/nfs_xdr.h>
  #include <linux/magic.h>
  #include <linux/parser.h>
+#include <linux/writeback.h>

  #include <asm/system.h>
  #include <asm/uaccess.h>
@@ -202,6 +203,7 @@ static int nfs_get_sb(struct file_system_type *, 
int, const char *, void *, stru
  static int nfs_xdev_get_sb(struct file_system_type *fs_type,
  		int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
  static void nfs_kill_super(struct super_block *);
+static void nfs_put_super(struct super_block *);

  static struct file_system_type nfs_fs_type = {
  	.owner		= THIS_MODULE,
@@ -223,6 +225,7 @@ static const struct super_operations nfs_sops = {
  	.alloc_inode	= nfs_alloc_inode,
  	.destroy_inode	= nfs_destroy_inode,
  	.write_inode	= nfs_write_inode,
+	.put_super		= nfs_put_super,
  	.statfs		= nfs_statfs,
  	.clear_inode	= nfs_clear_inode,
  	.umount_begin	= nfs_umount_begin,
@@ -1767,6 +1770,30 @@ static void nfs4_kill_super(struct super_block *sb)
  	nfs_free_server(server);
  }

+void nfs_put_super(struct super_block *sb)
+{
+	struct inode *inode;
+	struct nfs_inode *nfsi;
+	/*
+	 * Make sure there are no outstanding renames
+	 */
+relock:
+	spin_lock(&inode_lock);
+	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
+		nfsi = NFS_I(inode);
+		if (atomic_read(&nfsi->silly_count) > 0) {
+			/* Keep this inode around  during the wait */
+			atomic_inc(&inode->i_count);
+			spin_unlock(&inode_lock);
+			wait_event(nfsi->waitqueue,
+				atomic_read(&nfsi->silly_count) == 1);
+			iput(inode);
+			goto relock;
+		}
+	}
+	spin_unlock(&inode_lock);
+}
+
  /*
   * Clone an NFS4 server record on xdev traversal (FSID-change)
   */

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
