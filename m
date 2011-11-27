Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39105 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754215Ab1K0FgQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Nov 2011 00:36:16 -0500
From: Cong Wang <amwang@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, Cong Wang <amwang@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 41/62] nfs: remove the second argument of k[un]map_atomic()
Date: Sun, 27 Nov 2011 13:27:21 +0800
Message-Id: <1322371662-26166-42-git-send-email-amwang@redhat.com>
In-Reply-To: <1322371662-26166-1-git-send-email-amwang@redhat.com>
References: <1322371662-26166-1-git-send-email-amwang@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Cong Wang <amwang@redhat.com>
---
 fs/nfs/dir.c      |    8 ++++----
 fs/nfs/nfs4proc.c |    4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ac28990..ce07968 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -260,10 +260,10 @@ void nfs_readdir_clear_array(struct page *page)
 	struct nfs_cache_array *array;
 	int i;
 
-	array = kmap_atomic(page, KM_USER0);
+	array = kmap_atomic(page);
 	for (i = 0; i < array->size; i++)
 		kfree(array->array[i].string.name);
-	kunmap_atomic(array, KM_USER0);
+	kunmap_atomic(array);
 }
 
 /*
@@ -1881,11 +1881,11 @@ static int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *sym
 	if (!page)
 		return -ENOMEM;
 
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	memcpy(kaddr, symname, pathlen);
 	if (pathlen < PAGE_SIZE)
 		memset(kaddr + pathlen, 0, PAGE_SIZE - pathlen);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	error = NFS_PROTO(dir)->symlink(dir, dentry, page, pathlen, &attr);
 	if (error != 0) {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index be2bbac..ebc122b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -189,7 +189,7 @@ static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dent
 	 * when talking to the server, we always send cookie 0
 	 * instead of 1 or 2.
 	 */
-	start = p = kmap_atomic(*readdir->pages, KM_USER0);
+	start = p = kmap_atomic(*readdir->pages);
 	
 	if (cookie == 0) {
 		*p++ = xdr_one;                                  /* next */
@@ -217,7 +217,7 @@ static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dent
 
 	readdir->pgbase = (char *)p - (char *)start;
 	readdir->count -= readdir->pgbase;
-	kunmap_atomic(start, KM_USER0);
+	kunmap_atomic(start);
 }
 
 static int nfs4_wait_clnt_recover(struct nfs_client *clp)
-- 
1.7.4.4

