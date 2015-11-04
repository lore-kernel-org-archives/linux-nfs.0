Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56453 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030368AbbKDPUh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Nov 2015 10:20:37 -0500
Subject: [PATCH 3/4] cachefiles: perform test on s_blocksize when opening
 cache file.
From: David Howells <dhowells@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-cachefs@redhat.com, linux-fsdevel@vger.kernel.org
Date: Wed, 04 Nov 2015 15:20:34 +0000
Message-ID: <20151104152034.2987.22424.stgit@warthog.procyon.org.uk>
In-Reply-To: <20151104152005.2987.46683.stgit@warthog.procyon.org.uk>
References: <20151104152005.2987.46683.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: NeilBrown <neilb@suse.de>

cachefiles requires that s_blocksize in the cache is not greater than
PAGE_SIZE, and performs the check every time a block is accessed.

Move the test to the place where the file is "opened", where other
file-validity tests are performed.

Signed-off-by: NeilBrown <neilb@suse.de>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/cachefiles/namei.c |    2 ++
 fs/cachefiles/rdwr.c  |    6 ------
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/cachefiles/namei.c b/fs/cachefiles/namei.c
index fc1056f5c96a..c4b893453e0e 100644
--- a/fs/cachefiles/namei.c
+++ b/fs/cachefiles/namei.c
@@ -655,6 +655,8 @@ lookup_again:
 			aops = d_backing_inode(object->dentry)->i_mapping->a_ops;
 			if (!aops->bmap)
 				goto check_error;
+			if (object->dentry->d_sb->s_blocksize > PAGE_SIZE)
+				goto check_error;
 
 			object->backer = object->dentry;
 		} else {
diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index 3cbb0e834694..e76c2452ac40 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -414,9 +414,6 @@ int cachefiles_read_or_alloc_page(struct fscache_retrieval *op,
 	ASSERT(inode->i_mapping->a_ops->readpages);
 
 	/* calculate the shift required to use bmap */
-	if (inode->i_sb->s_blocksize > PAGE_SIZE)
-		goto enobufs;
-
 	shift = PAGE_SHIFT - inode->i_sb->s_blocksize_bits;
 
 	op->op.flags &= FSCACHE_OP_KEEP_FLAGS;
@@ -711,9 +708,6 @@ int cachefiles_read_or_alloc_pages(struct fscache_retrieval *op,
 	ASSERT(inode->i_mapping->a_ops->readpages);
 
 	/* calculate the shift required to use bmap */
-	if (inode->i_sb->s_blocksize > PAGE_SIZE)
-		goto all_enobufs;
-
 	shift = PAGE_SHIFT - inode->i_sb->s_blocksize_bits;
 
 	pagevec_init(&pagevec, 0);

