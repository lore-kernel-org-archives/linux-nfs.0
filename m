Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49411 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754872Ab0KUTVq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Nov 2010 14:21:46 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/8] NFS: Don't ignore errors from nfs_do_filldir()
Date: Sun, 21 Nov 2010 14:21:20 -0500
Message-Id: <1290367282-5445-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1290367282-5445-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1290367282-5445-1-git-send-email-Trond.Myklebust@netapp.com>
 <1290367282-5445-2-git-send-email-Trond.Myklebust@netapp.com>
 <1290367282-5445-3-git-send-email-Trond.Myklebust@netapp.com>
 <1290367282-5445-4-git-send-email-Trond.Myklebust@netapp.com>
 <1290367282-5445-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We should ignore the errors from the filldir callback, and just interpret
them as meaning we should exit, however we should definitely pass back
ENOMEM errors.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2492bac..ddc2e43 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -709,13 +709,15 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc, void *dirent,
 	}
 
 	for (i = desc->cache_entry_index; i < array->size; i++) {
+		struct nfs_cache_array_entry *ent;
 		d_type = DT_UNKNOWN;
 
-		res = filldir(dirent, array->array[i].string.name,
-			array->array[i].string.len, file->f_pos,
-			nfs_compat_user_ino64(array->array[i].ino), d_type);
-		if (res < 0)
+		ent = &array->array[i];
+		if (filldir(dirent, ent->string.name, ent->string.len,
+		    file->f_pos, nfs_compat_user_ino64(ent->ino), d_type) < 0) {
+			desc->eof = 1;
 			break;
+		}
 		file->f_pos++;
 		desc->cache_entry_index = i;
 		if (i < (array->size-1))
@@ -820,14 +822,14 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 		res = readdir_search_pagecache(desc);
 
 		if (res == -EBADCOOKIE) {
+			res = 0;
 			/* This means either end of directory */
 			if (*desc->dir_cookie && desc->eof == 0) {
 				/* Or that the server has 'lost' a cookie */
 				res = uncached_readdir(desc, dirent, filldir);
-				if (res >= 0)
+				if (res == 0)
 					continue;
 			}
-			res = 0;
 			break;
 		}
 		if (res == -ETOOSMALL && desc->plus) {
@@ -842,10 +844,8 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 			break;
 
 		res = nfs_do_filldir(desc, dirent, filldir);
-		if (res < 0) {
-			res = 0;
+		if (res < 0)
 			break;
-		}
 	}
 out:
 	nfs_unblock_sillyrename(dentry);
-- 
1.7.3.2

