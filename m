Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:41416 "EHLO verein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753641Ab0FAT7Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Jun 2010 15:59:24 -0400
Date: Tue, 1 Jun 2010 21:59:18 +0200
From: Christoph Hellwig <hch@lst.de>
To: bfields@fieldses.org
Cc: bpm@sgi.com, linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: nfsd_setattr needs to call commit_metadata
Message-ID: <20100601195917.GA25910@lst.de>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The conversion of write_inode_now calls to commit_metadata in commit
f501912a35c02eadc55ca9396ece55fe36f785d0 missed out the call in nfsd_setattr.

But without this conversion we can't guarantee that a SETATTR request
has actually been commited to disk with XFS, which causes a regression
from 2.6.32 (only for NFSv2, but anyway).

Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/nfsd/vfs.c
===================================================================
--- linux-2.6.orig/fs/nfsd/vfs.c	2010-06-01 21:24:34.945004695 +0200
+++ linux-2.6/fs/nfsd/vfs.c	2010-06-01 21:25:48.299003856 +0200
@@ -443,8 +443,7 @@ nfsd_setattr(struct svc_rqst *rqstp, str
 	if (size_change)
 		put_write_access(inode);
 	if (!err)
-		if (EX_ISSYNC(fhp->fh_export))
-			write_inode_now(inode, 1);
+		commit_metadata(fhp);
 out:
 	return err;
 
