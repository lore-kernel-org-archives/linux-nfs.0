From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/7] nfsd: properly xdr-encode stateid4.seqid as uint32_t for cb_recall
Date: Tue, 12 Aug 2008 20:42:51 +0300
Message-ID: <1218562971-25307-1-git-send-email-bhalevy@panasas.com>
References: <48A1CB0C.4090906@panasas.com>
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Chuck Lever <chucklever@gmail.com>,
	Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:42132 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbYHLRnQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2008 13:43:16 -0400
In-Reply-To: <48A1CB0C.4090906@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index ecae593..30d3130 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -222,7 +222,8 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_cb_recall *cb_rec)
 
 	RESERVE_SPACE(12+sizeof(cb_rec->cbr_stateid) + len);
 	WRITE32(OP_CB_RECALL);
-	WRITEMEM(&cb_rec->cbr_stateid, sizeof(stateid_t));
+	WRITE32(cb_rec->cbr_stateid.si_generation);
+	WRITEMEM(&cb_rec->cbr_stateid.si_opaque, sizeof(stateid_opaque_t));
 	WRITE32(cb_rec->cbr_trunc);
 	WRITE32(len);
 	WRITEMEM(cb_rec->cbr_fhval, len);
-- 
1.5.6.5

