Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:51186 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694AbaHUQHc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 12:07:32 -0400
Received: from ip-64-134-168-64.public.wayport.net ([64.134.168.64] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XKUtf-00009z-0N
	for linux-nfs@vger.kernel.org; Thu, 21 Aug 2014 16:07:31 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 07/19] pnfs: add flag to force read-modify-write in ->write_begin
Date: Thu, 21 Aug 2014 11:09:23 -0500
Message-Id: <1408637375-11343-8-git-send-email-hch@lst.de>
In-Reply-To: <1408637375-11343-1-git-send-email-hch@lst.de>
References: <pnfs block layout driver fixes V2>
 <1408637375-11343-1-git-send-email-hch@lst.de>
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
index 524dd80..58566e9 100644
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
index 16cd14f..302b279 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -72,6 +72,7 @@ enum layoutdriver_policy_flags {
 	/* Should the pNFS client commit and return the layout upon a setattr */
 	PNFS_LAYOUTRET_ON_SETATTR	= 1 << 0,
 	PNFS_LAYOUTRET_ON_ERROR		= 1 << 1,
+	PNFS_READ_WHOLE_PAGE		= 1 << 2,
 };
 
 struct nfs4_deviceid_node;
-- 
1.9.1

