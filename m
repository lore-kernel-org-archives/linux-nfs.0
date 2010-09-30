Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:42071 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755968Ab0I3Ss3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 14:48:29 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfsd41: mask out unsupported pnfs attributes
Date: Thu, 30 Sep 2010 20:47:58 +0200
Message-Id: <1285872478-21045-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These attributes are valid in NFSv4.1, the just doesn't support them yet.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f48d891..bd4ce68 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1761,6 +1761,10 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		.dentry	= dentry,
 	};
 
+	/* mask out unsupported pNFS attributes */
+	bmval1 &= ~FATTR4_WORD1_FS_LAYOUT_TYPES;
+	bmval2 &= ~FATTR4_WORD2_LAYOUT_BLKSIZE;
+
 	BUG_ON(bmval1 & NFSD_WRITEONLY_ATTRS_WORD1);
 	BUG_ON(bmval0 & ~nfsd_suppattrs0(minorversion));
 	BUG_ON(bmval1 & ~nfsd_suppattrs1(minorversion));
-- 
1.7.2.3

