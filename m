Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56731 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752796Ab0LAPgw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Dec 2010 10:36:52 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Nick Bowler <nbowler@elliptictech.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] NFS: lock the readdir page while it is in use
Date: Wed,  1 Dec 2010 10:36:43 -0500
Message-Id: <1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com>
 <1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <20101201150428.GA2879@elliptictech.com>
References: <20101201150428.GA2879@elliptictech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Before we can fix the memory leak due to not freeing up the contents
of the nfs_cache_array when clearing the page cache, we need to
ensure that shrink_page_list can't just lock the page and
call try_to_release_page() while we're accessing the array.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e03537f..3ec3f1c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -639,6 +639,7 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page* page)
 static
 void cache_page_release(nfs_readdir_descriptor_t *desc)
 {
+	unlock_page(desc->page);
 	page_cache_release(desc->page);
 	desc->page = NULL;
 }
@@ -646,8 +647,20 @@ void cache_page_release(nfs_readdir_descriptor_t *desc)
 static
 struct page *get_cache_page(nfs_readdir_descriptor_t *desc)
 {
-	return read_cache_page(desc->file->f_path.dentry->d_inode->i_mapping,
+	struct page *page;
+
+	for (;;) {
+		page = read_cache_page(desc->file->f_path.dentry->d_inode->i_mapping,
 			desc->page_index, (filler_t *)nfs_readdir_filler, desc);
+		if (IS_ERR(page))
+			break;
+		lock_page(page);
+		if (page->mapping != NULL && PageUptodate(page))
+			break;
+		unlock_page(page);
+		page_cache_release(page);
+	}
+	return page;
 }
 
 /*
@@ -771,6 +784,7 @@ int uncached_readdir(nfs_readdir_descriptor_t *desc, void *dirent,
 	desc->page_index = 0;
 	desc->last_cookie = *desc->dir_cookie;
 	desc->page = page;
+	lock_page(page);
 
 	status = nfs_readdir_xdr_to_array(desc, page, inode);
 	if (status < 0)
-- 
1.7.3.2

