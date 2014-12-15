Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f171.google.com ([209.85.192.171]:44905 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbaLOF10 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Dec 2014 00:27:26 -0500
Received: by mail-pd0-f171.google.com with SMTP id y13so10996837pdi.2
        for <linux-nfs@vger.kernel.org>; Sun, 14 Dec 2014 21:27:25 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH 1/8] nfs: follow direct I/O write locking convention
Date: Sun, 14 Dec 2014 21:26:55 -0800
Message-Id: <7561c096c7de603ac39fcfcff7bd2ec80589cae1.1418618044.git.osandov@osandov.com>
In-Reply-To: <cover.1418618044.git.osandov@osandov.com>
References: <cover.1418618044.git.osandov@osandov.com>
In-Reply-To: <cover.1418618044.git.osandov@osandov.com>
References: <cover.1418618044.git.osandov@osandov.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The generic callers of direct_IO lock i_mutex before doing a write. NFS
doesn't use the generic write code, so it doesn't follow this
convention. This is now a problem because the interface introduced for
swap-over-NFS calls direct_IO for a write without holding i_mutex, but
other implementations of direct_IO will expect to have it locked.

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 fs/nfs/direct.c | 12 +++++-------
 fs/nfs/file.c   |  8 ++++++--
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 10bf072..9402b96 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -906,17 +906,15 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
 	if (!count)
 		goto out;
 
-	mutex_lock(&inode->i_mutex);
-
 	result = nfs_sync_mapping(mapping);
 	if (result)
-		goto out_unlock;
+		goto out;
 
 	if (mapping->nrpages) {
 		result = invalidate_inode_pages2_range(mapping,
 					pos >> PAGE_CACHE_SHIFT, end);
 		if (result)
-			goto out_unlock;
+			goto out;
 	}
 
 	task_io_account_write(count);
@@ -924,7 +922,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
 	result = -ENOMEM;
 	dreq = nfs_direct_req_alloc();
 	if (!dreq)
-		goto out_unlock;
+		goto out;
 
 	dreq->inode = inode;
 	dreq->bytes_left = count;
@@ -960,12 +958,12 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
 		}
 	}
 	nfs_direct_req_release(dreq);
+
+	mutex_lock(&inode->i_mutex);
 	return result;
 
 out_release:
 	nfs_direct_req_release(dreq);
-out_unlock:
-	mutex_unlock(&inode->i_mutex);
 out:
 	return result;
 }
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 2ab6f00..8b80276 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -675,8 +675,12 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 	if (result)
 		return result;
 
-	if (file->f_flags & O_DIRECT)
-		return nfs_file_direct_write(iocb, from, pos);
+	if (file->f_flags & O_DIRECT) {
+		mutex_lock(&inode->i_mutex);
+		result = nfs_file_direct_write(iocb, from, pos);
+		mutex_unlock(&inode->i_mutex);
+		return result;
+	}
 
 	dprintk("NFS: write(%pD2, %zu@%Ld)\n",
 		file, count, (long long) pos);
-- 
2.1.3

