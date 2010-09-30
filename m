Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:61852 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756277Ab0I3TU7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 15:20:59 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] pnfsd: mask out unsupported pnfs attributes only when !CONFIG_PNFSD
Date: Thu, 30 Sep 2010 21:20:52 +0200
Message-Id: <1285874452-21522-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1285872478-21045-1-git-send-email-bhalevy@panasas.com>
References: <1285872478-21045-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f0dfa47..5e8e89d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1906,9 +1906,11 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		.dentry	= dentry,
 	};
 
+#if !defined(CONFIG_PNFSD)
 	/* mask out unsupported pNFS attributes */
 	bmval1 &= ~FATTR4_WORD1_FS_LAYOUT_TYPES;
 	bmval2 &= ~FATTR4_WORD2_LAYOUT_BLKSIZE;
+#endif /* !CONFIG_PNFSD */
 
 	BUG_ON(bmval1 & NFSD_WRITEONLY_ATTRS_WORD1);
 	BUG_ON(bmval0 & ~nfsd_suppattrs0(minorversion));
-- 
1.7.2.3

