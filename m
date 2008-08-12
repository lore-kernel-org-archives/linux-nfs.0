From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/7] nfsd: fix nfsd4_encode_open buffer space reservation
Date: Tue, 12 Aug 2008 20:44:41 +0300
Message-ID: <1218563081-25364-1-git-send-email-bhalevy@panasas.com>
References: <48A1CB0C.4090906@panasas.com>
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Chuck Lever <chucklever@gmail.com>,
	Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:42170 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071AbYHLRo6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2008 13:44:58 -0400
In-Reply-To: <48A1CB0C.4090906@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd4_encode_open first reservation is currently for 36 + sizeof(stateid_t)
while it writes after the stateid a cinfo (20 bytes) and 5 more 4-bytes
words, for a total of 40 + sizeof(stateid_t).

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index cfe9d5c..4ec52f9 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2142,7 +2142,7 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 	if (nfserr)
 		goto out;
 
-	RESERVE_SPACE(36 + sizeof(stateid_t));
+	RESERVE_SPACE(40 + sizeof(stateid_t));
 	WRITE32(open->op_stateid.si_generation);
 	WRITEMEM(&open->op_stateid.si_opaque, sizeof(stateid_opaque_t));
 	WRITECINFO(open->op_cinfo);
-- 
1.5.6.5

