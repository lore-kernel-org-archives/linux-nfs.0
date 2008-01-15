From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NFS: remove error field from nfs_readdir_descriptor_t
Date: Tue, 15 Jan 2008 13:06:59 -0500
Message-ID: <1200420419-4208-1-git-send-email-jlayton@redhat.com>
Cc: staubach@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51271 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755448AbYAOSHC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2008 13:07:02 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m0FI71Kr019172
	for <linux-nfs@vger.kernel.org>; Tue, 15 Jan 2008 13:07:01 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The error field in nfs_readdir_descriptor_t is never used outside of
the function in which it is set. Remove the field and change the
place that does use it to use an existing local variable.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/dir.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 410449d..ad3b359 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -154,7 +154,6 @@ typedef struct {
 	struct nfs_entry *entry;
 	decode_dirent_t	decode;
 	int		plus;
-	int		error;
 	unsigned long	timestamp;
 	int		timestamp_valid;
 } nfs_readdir_descriptor_t;
@@ -213,7 +212,6 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page *page)
 	return 0;
  error:
 	unlock_page(page);
-	desc->error = error;
 	return -EIO;
 }
 
@@ -483,13 +481,13 @@ int uncached_readdir(nfs_readdir_descriptor_t *desc, void *dirent,
 		goto out;
 	}
 	timestamp = jiffies;
-	desc->error = NFS_PROTO(inode)->readdir(file->f_path.dentry, cred, *desc->dir_cookie,
-						page,
+	status = NFS_PROTO(inode)->readdir(file->f_path.dentry, cred,
+						*desc->dir_cookie, page,
 						NFS_SERVER(inode)->dtsize,
 						desc->plus);
 	desc->page = page;
 	desc->ptr = kmap(page);		/* matching kunmap in nfs_do_filldir */
-	if (desc->error >= 0) {
+	if (status >= 0) {
 		desc->timestamp = timestamp;
 		desc->timestamp_valid = 1;
 		if ((status = dir_decode(desc)) == 0)
-- 
1.5.3.7

