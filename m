From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/8] NFS: Fix minor mixed sign comparison in NFS client's
	write logic
Date: Thu, 20 Dec 2007 14:54:57 -0500
Message-ID: <20071220195457.3280.45475.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:46280 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753938AbXLTTzH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Dec 2007 14:55:07 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: PAGE_CACHE_SIZE is unsigned, and nfs_pageio_init() takes a size_t.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/write.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 51cc1bd..bb0347c 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -932,7 +932,7 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned i
 static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 				  struct inode *inode, int ioflags)
 {
-	int wsize = NFS_SERVER(inode)->wsize;
+	size_t wsize = NFS_SERVER(inode)->wsize;
 
 	if (wsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(pgio, inode, nfs_flush_multi, wsize, ioflags);

