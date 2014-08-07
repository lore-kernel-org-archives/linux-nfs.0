Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:45769 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754037AbaHGHVe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 03:21:34 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 05/17] pnfs: add flag to force read-modify-write in ->write_begin
Date: Thu,  7 Aug 2014 09:23:37 +0200
Message-Id: <1407396229-4785-6-git-send-email-hch@lst.de>
In-Reply-To: <1407396229-4785-1-git-send-email-hch@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Like all block based filesystems, the pNFS block layout driver can't read
or write at a byte granularity and thus has to perform read-modify-write
cycles on writes smaller than this granularity.

Add a flag so that the core NFS code always reads a whole page when
starting a smaller write, so that we can do it in the place where the VFS
expects it instead of doing in very deadlock prone way in the writeback
handler.

Note that in theory we could do less than page size reads here for disks
that have a smaller sector size which are server by a server with a smaller
pnfs block size.  But so far that doesn't seem like a worthwhile
optimization.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/file.c | 9 +++++++++
 fs/nfs/pnfs.h | 1 +
 2 files changed, 10 insertions(+)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 4042ff5..718cdd6 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -36,6 +36,7 @@
 #include "internal.h"
 #include "iostat.h"
 #include "fscache.h"
+#include "pnfs.h"
 
 #include "nfstrace.h"
 
@@ -323,10 +324,18 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 static int nfs_want_read_modify_write(struct file *file, struct page *page,
 			loff_t pos, unsigned len)
 {
+	struct nfs_server *server = NFS_SERVER(file->f_mapping->host);
 	unsigned int pglen = nfs_page_length(page);
 	unsigned int offset = pos & (PAGE_CACHE_SIZE - 1);
 	unsigned int end = offset + len;
 
+	if (server->pnfs_curr_ld &&
+	    (server->pnfs_curr_ld->flags & PNFS_READ_WHOLE_PAGE)) {
+		if (!PageUptodate(page))
+			return 1;
+		return 0;
+	}
+
 	if ((file->f_mode & FMODE_READ) &&	/* open for read? */
 	    !PageUptodate(page) &&		/* Uptodate? */
 	    !PagePrivate(page) &&		/* i/o request already? */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index aca3dff..882387c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -71,6 +71,7 @@ enum layoutdriver_policy_flags {
 	/* Should the pNFS client commit and return the layout upon a setattr */
 	PNFS_LAYOUTRET_ON_SETATTR	= 1 << 0,
 	PNFS_LAYOUTRET_ON_ERROR		= 1 << 1,
+	PNFS_READ_WHOLE_PAGE		= 1 << 2,
 };
 
 struct nfs4_deviceid_node;
-- 
1.9.1

