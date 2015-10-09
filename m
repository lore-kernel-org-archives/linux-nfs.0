Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:43022 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411AbbJINHP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Oct 2015 09:07:15 -0400
From: Christoph Hellwig <hch@lst.de>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: [PATCH] nfsd/blocklayout: accept any minlength
Date: Fri,  9 Oct 2015 15:03:26 +0200
Message-Id: <1444395806-32111-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recent Linux clients have started to send less than blocksize minglength
requests.  Given that minlength is just a hint except for the magic value
of zero just don't check for it except for same zero value.  Without
this we'll hang forever during fsx runs.

Cc: stable@vger.kernel.org
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/blocklayout.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
index cdefaa3..c29d942 100644
--- a/fs/nfsd/blocklayout.c
+++ b/fs/nfsd/blocklayout.c
@@ -56,14 +56,6 @@ nfsd4_block_proc_layoutget(struct inode *inode, const struct svc_fh *fhp,
 	u32 device_generation = 0;
 	int error;
 
-	/*
-	 * We do not attempt to support I/O smaller than the fs block size,
-	 * or not aligned to it.
-	 */
-	if (args->lg_minlength < block_size) {
-		dprintk("pnfsd: I/O too small\n");
-		goto out_layoutunavailable;
-	}
 	if (seg->offset & (block_size - 1)) {
 		dprintk("pnfsd: I/O misaligned\n");
 		goto out_layoutunavailable;
-- 
1.9.1

