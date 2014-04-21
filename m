Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59654 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373AbaDUR3R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 13:29:17 -0400
Date: Mon, 21 Apr 2014 10:29:17 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: commit layouts in fdatasync
Message-ID: <20140421172917.GA20036@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>From fdatasync(2):

 "fdatasync() is similar to fsync(), but does not flush modified metadata
  unless that metadata is needed in order  to  allow  a  subsequent  data
  retrieval to be correctly handled."

We absolutely need to commit the layouts to be able to retrieve the data
in case either the client, the server or the storage subsystem go down.

Signed-off-by: Christoph Hellwig <hch@lst.de>

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 8de3407..464db9d 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -100,8 +100,7 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 			break;
 		mutex_lock(&inode->i_mutex);
 		ret = nfs_file_fsync_commit(file, start, end, datasync);
-		if (!ret && !datasync)
-			/* application has asked for meta-data sync */
+		if (!ret)
 			ret = pnfs_layoutcommit_inode(inode, true);
 		mutex_unlock(&inode->i_mutex);
 		/*
