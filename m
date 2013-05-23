Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29702 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759629Ab3EWVxm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 May 2013 17:53:42 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r4NLrg1r009222
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 23 May 2013 17:53:42 -0400
Received: from tonberry.usersys.redhat.com (dhcp145-64.rdu.redhat.com [10.13.145.64])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r4NLrgqD020753
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 23 May 2013 17:53:42 -0400
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.5/8.14.5) with ESMTP id r4NLrfYp020076
	for <linux-nfs@vger.kernel.org>; Thu, 23 May 2013 17:53:41 -0400
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.5/8.14.5/Submit) id r4NLrflZ020075
	for linux-nfs@vger.kernel.org; Thu, 23 May 2013 17:53:41 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH RFC 1/1] NFS: Allow nfs_updatepage to extend a write to cover a full page when we have a lock that covers the entire file
Date: Thu, 23 May 2013 17:53:41 -0400
Message-Id: <1369346021-20041-2-git-send-email-smayhew@redhat.com>
In-Reply-To: <1369346021-20041-1-git-send-email-smayhew@redhat.com>
References: <1369346021-20041-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently nfs_updatepage allows a write to be extended to cover a full
page only if we don't have a byte range lock on the file... but if we've
got the whole file locked, then we should be allowed to extend the
write.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/write.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index a2c7c28..f35fb4f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -908,13 +908,16 @@ int nfs_updatepage(struct file *file, struct page *page,
 		file->f_path.dentry->d_name.name, count,
 		(long long)(page_file_offset(page) + offset));
 
-	/* If we're not using byte range locks, and we know the page
+	/* If we're not using byte range locks (or if the range of the
+	 * lock covers the entire file), and we know the page
 	 * is up to date, it may be more efficient to extend the write
 	 * to cover the entire page in order to avoid fragmentation
 	 * inefficiencies.
 	 */
 	if (nfs_write_pageuptodate(page, inode) &&
-			inode->i_flock == NULL &&
+			(inode->i_flock == NULL ||
+			(inode->i_flock->fl_start == 0 &&
+			inode->i_flock->fl_end == OFFSET_MAX)) &&
 			!(file->f_flags & O_DSYNC)) {
 		count = max(count + offset, nfs_page_length(page));
 		offset = 0;
-- 
1.7.11.7

