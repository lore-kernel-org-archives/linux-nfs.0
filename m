Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39506 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752790Ab0KUTVq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Nov 2010 14:21:46 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/8] NFS: Fix a page leak in nfs_do_filldir()
Date: Sun, 21 Nov 2010 14:21:17 -0500
Message-Id: <1290367282-5445-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1290367282-5445-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1290367282-5445-1-git-send-email-Trond.Myklebust@netapp.com>
 <1290367282-5445-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

nfs_do_filldir() must always free desc->page when it is done, otherwise
we end up leaking the page.

Also remove unused variable 'dentry'.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2789cb3..42e66e9 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -701,11 +701,12 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc, void *dirent,
 	int res = 0;
 	struct nfs_cache_array *array = NULL;
 	unsigned int d_type = DT_UNKNOWN;
-	struct dentry *dentry = NULL;
 
 	array = nfs_readdir_get_array(desc->page);
-	if (IS_ERR(array))
-		return PTR_ERR(array);
+	if (IS_ERR(array)) {
+		res = PTR_ERR(array);
+		goto out;
+	}
 
 	for (i = desc->cache_entry_index; i < array->size; i++) {
 		d_type = DT_UNKNOWN;
@@ -726,9 +727,8 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc, void *dirent,
 		desc->eof = 1;
 
 	nfs_readdir_release_array(desc->page);
+out:
 	cache_page_release(desc);
-	if (dentry != NULL)
-		dput(dentry);
 	dfprintk(DIRCACHE, "NFS: nfs_do_filldir() filling ended @ cookie %Lu; returning = %d\n",
 			(unsigned long long)*desc->dir_cookie, res);
 	return res;
-- 
1.7.3.2

