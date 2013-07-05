Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2288 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752274Ab3GEVdV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jul 2013 17:33:21 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r65LXLej015278
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jul 2013 17:33:21 -0400
Received: from tonberry.usersys.redhat.com (dhcp145-64.rdu.redhat.com [10.13.145.64])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id r65LXKTR015022
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jul 2013 17:33:20 -0400
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.5/8.14.5) with ESMTP id r65LXKMX010159
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jul 2013 17:33:20 -0400
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.5/8.14.5/Submit) id r65LXKcR010157
	for linux-nfs@vger.kernel.org; Fri, 5 Jul 2013 17:33:20 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Allow nfs_updatepage to extend a write under additional circumstances
Date: Fri,  5 Jul 2013 17:33:19 -0400
Message-Id: <1373059999-10127-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently nfs_updatepage allows a write to be extended to cover a full
page only if we don't have a byte range lock lock on the file... but if
we have a write delegation on the file or if we have the whole file
locked for writing then we should be allowed to extend the write as
well.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/write.c | 31 +++++++++++++++++++++++--------
 1 file changed, 23 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index a2c7c28..c8a1bcc 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -888,6 +888,28 @@ out:
 	return PageUptodate(page) != 0;
 }
 
+/* If we know the page is up to date, and we're not using byte range locks (or
+ * if we have the whole file locked for writing), it may be more efficient to
+ * extend the write to cover the entire page in order to avoid fragmentation
+ * inefficiencies.
+ *
+ * If the file is opened for synchronous writes or if we have a write delegation
+ * from the server then we can just skip the rest of the checks.
+ */
+static int nfs_can_extend_write(struct file *file, struct page *page, struct inode *inode)
+{
+	if (file->f_flags & O_DSYNC)
+		return 0;
+	if (nfs_have_delegation(inode, FMODE_WRITE))
+		return 1;
+	if (nfs_write_pageuptodate(page, inode) && (inode->i_flock == NULL ||
+			(inode->i_flock->fl_start == 0 &&
+			inode->i_flock->fl_end == OFFSET_MAX &&
+			inode->i_flock->fl_type != F_RDLCK)))
+		return 1;
+	return 0;
+}
+
 /*
  * Update and possibly write a cached page of an NFS file.
  *
@@ -908,14 +930,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 		file->f_path.dentry->d_name.name, count,
 		(long long)(page_file_offset(page) + offset));
 
-	/* If we're not using byte range locks, and we know the page
-	 * is up to date, it may be more efficient to extend the write
-	 * to cover the entire page in order to avoid fragmentation
-	 * inefficiencies.
-	 */
-	if (nfs_write_pageuptodate(page, inode) &&
-			inode->i_flock == NULL &&
-			!(file->f_flags & O_DSYNC)) {
+	if (nfs_can_extend_write(file, page, inode)) {
 		count = max(count + offset, nfs_page_length(page));
 		offset = 0;
 	}
-- 
1.7.11.7

