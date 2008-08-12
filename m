From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/7] nfsd: properly xdr-encode deleg stateid returned from open
Date: Tue, 12 Aug 2008 20:43:37 +0300
Message-ID: <1218563017-25336-1-git-send-email-bhalevy@panasas.com>
References: <48A1CB0C.4090906@panasas.com>
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Chuck Lever <chucklever@gmail.com>,
	Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:42161 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751763AbYHLRnx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2008 13:43:53 -0400
In-Reply-To: <48A1CB0C.4090906@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index e1a1a5e..cfe9d5c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2158,7 +2158,9 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 		break;
 	case NFS4_OPEN_DELEGATE_READ:
 		RESERVE_SPACE(20 + sizeof(stateid_t));
-		WRITEMEM(&open->op_delegate_stateid, sizeof(stateid_t));
+		WRITE32(open->op_delegate_stateid.si_generation);
+		WRITEMEM(&open->op_delegate_stateid.si_opaque,
+			 sizeof(stateid_opaque_t));
 		WRITE32(open->op_recall);
 
 		/*
@@ -2172,7 +2174,9 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 		break;
 	case NFS4_OPEN_DELEGATE_WRITE:
 		RESERVE_SPACE(32 + sizeof(stateid_t));
-		WRITEMEM(&open->op_delegate_stateid, sizeof(stateid_t));
+		WRITE32(open->op_delegate_stateid.si_generation);
+		WRITEMEM(&open->op_delegate_stateid.si_opaque,
+			 sizeof(stateid_opaque_t));
 		WRITE32(0);
 
 		/*
-- 
1.5.6.5

