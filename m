Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:35654 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354AbaIGTNd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Sep 2014 15:13:33 -0400
Received: from ip-64-134-224-54.public.wayport.net ([64.134.224.54] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XQhty-0008Ni-RL
	for linux-nfs@vger.kernel.org; Sun, 07 Sep 2014 19:13:31 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: update mtime on truncate
Date: Sun,  7 Sep 2014 12:15:52 -0700
Message-Id: <1410117352-28443-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes a failure in xfstests generic/313 because nfs doesn't update
mtime on a truncate.  The protocol requires this to be done implicity
for a size changing setattr.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/vfs.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f501a9b..60ed117 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -445,6 +445,16 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 		if (err)
 			goto out;
 		size_change = 1;
+
+		/*
+		 * RFC5661, Section 18.30.4:
+		 *   Changing the size of a file with SETATTR indirectly
+		 *   changes the time_modify and change attributes.
+		 *
+		 * (and similar for the older RFCs)
+		 */
+		if (iap->ia_size != i_size_read(inode))
+			iap->ia_valid |= ATTR_MTIME;
 	}
 
 	iap->ia_valid |= ATTR_CTIME;
-- 
1.9.1

