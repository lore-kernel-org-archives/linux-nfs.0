Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39506 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754883Ab0KUTVq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Nov 2010 14:21:46 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 7/8] NFS: Correct the array bound calculation in nfs_readdir_add_to_array
Date: Sun, 21 Nov 2010 14:21:21 -0500
Message-Id: <1290367282-5445-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1290367282-5445-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1290367282-5445-1-git-send-email-Trond.Myklebust@netapp.com>
 <1290367282-5445-2-git-send-email-Trond.Myklebust@netapp.com>
 <1290367282-5445-3-git-send-email-Trond.Myklebust@netapp.com>
 <1290367282-5445-4-git-send-email-Trond.Myklebust@netapp.com>
 <1290367282-5445-5-git-send-email-Trond.Myklebust@netapp.com>
 <1290367282-5445-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

It looks as if the array size calculation in MAX_READDIR_ARRAY does not
take the alignment of struct nfs_cache_array_entry into account.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ddc2e43..ced7291 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -171,8 +171,6 @@ struct nfs_cache_array {
 	struct nfs_cache_array_entry array[0];
 };
 
-#define MAX_READDIR_ARRAY ((PAGE_SIZE - sizeof(struct nfs_cache_array)) / sizeof(struct nfs_cache_array_entry))
-
 typedef __be32 * (*decode_dirent_t)(struct xdr_stream *, struct nfs_entry *, struct nfs_server *, int);
 typedef struct {
 	struct file	*file;
@@ -257,11 +255,14 @@ int nfs_readdir_add_to_array(struct nfs_entry *entry, struct page *page)
 
 	if (IS_ERR(array))
 		return PTR_ERR(array);
+
+	cache_entry = &array->array[array->size];
+
+	/* Check that this entry lies within the page bounds */
 	ret = -ENOSPC;
-	if (array->size >= MAX_READDIR_ARRAY)
+	if ((char *)&cache_entry[1] - (char *)page_address(page) > PAGE_SIZE)
 		goto out;
 
-	cache_entry = &array->array[array->size];
 	cache_entry->cookie = entry->prev_cookie;
 	cache_entry->ino = entry->ino;
 	ret = nfs_readdir_make_qstr(&cache_entry->string, entry->name, entry->len);
-- 
1.7.3.2

