From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 2/2] pnfs-post-submit: Revert "pnfs-submit: Remove unused encode_getattr_three code"
Date: Wed, 16 Jun 2010 21:06:49 -0400
Message-ID: <1276736809-9423-2-git-send-email-iisaman@netapp.com>
References: <1276736809-9423-1-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:50221 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751660Ab0FRTIJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jun 2010 15:08:09 -0400
Received: from localhost.localdomain (netapp-61.citi.umich.edu [141.212.112.250])
	by citi.umich.edu (Postfix) with ESMTP id C2F7C180A8
	for <linux-nfs@vger.kernel.org>; Fri, 18 Jun 2010 15:08:07 -0400 (EDT)
In-Reply-To: <1276736809-9423-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

---
 fs/nfs/nfs4xdr.c |   29 +++++++++++++++++++++++++++++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 9ef0f0a..c0bdb60 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1060,6 +1060,35 @@ static void encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm
 	hdr->replen += decode_getattr_maxsz;
 }
 
+static void
+encode_getattr_three(struct xdr_stream *xdr,
+		     uint32_t bm0, uint32_t bm1, uint32_t bm2,
+		     struct compound_hdr *hdr)
+{
+	__be32 *p;
+
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(OP_GETATTR);
+	if (bm2) {
+		p = reserve_space(xdr, 16);
+		*p++ = cpu_to_be32(3);
+		*p++ = cpu_to_be32(bm0);
+		*p++ = cpu_to_be32(bm1);
+		*p = cpu_to_be32(bm2);
+	} else if (bm1) {
+		p = reserve_space(xdr, 12);
+		*p++ = cpu_to_be32(2);
+		*p++ = cpu_to_be32(bm0);
+		*p = cpu_to_be32(bm1);
+	} else {
+		p = reserve_space(xdr, 8);
+		*p++ = cpu_to_be32(1);
+		*p = cpu_to_be32(bm0);
+	}
+	hdr->nops++;
+	hdr->replen += decode_getattr_maxsz;
+}
+
 static void encode_getfattr(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
 {
 	encode_getattr_two(xdr, bitmask[0] & nfs4_fattr_bitmap[0],
-- 
1.6.6.1

