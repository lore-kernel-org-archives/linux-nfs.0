Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:52669 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753331Ab3KNNuL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Nov 2013 08:50:11 -0500
Date: Thu, 14 Nov 2013 05:50:10 -0800
From: Christoph Hellwig <hch@infradead.org>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: export proper maximum file size to the client
Message-ID: <20131114135010.GA2869@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I noticed that we export a way to high value for the maxfilesize
attribute when debugging a client issue.  The issue didn't turn
out to be related to it, but I think we should export it, so that
clients can limit what write sizes they accept before hitting
the server.
    
Signed-off-by: Christoph Hellwig <hch@lst.de>

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 9423522..a3c9347 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2488,7 +2488,7 @@ out_acl:
 	if (bmval0 & FATTR4_WORD0_MAXFILESIZE) {
 		if ((buflen -= 8) < 0)
 			goto out_resource;
-		WRITE64(~(u64)0);
+		WRITE64(exp->ex_path.mnt->mnt_sb->s_maxbytes);
 	}
 	if (bmval0 & FATTR4_WORD0_MAXLINK) {
 		if ((buflen -= 4) < 0)
