From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 4/4] pnfs-submit: Remove unused encode_getattr_three code
Date: Thu,  8 Jul 2010 15:25:22 -0400
Message-ID: <1278617122-24164-5-git-send-email-iisaman@netapp.com>
References: <1278617122-24164-1-git-send-email-iisaman@netapp.com>
 <1278617122-24164-2-git-send-email-iisaman@netapp.com>
 <1278617122-24164-3-git-send-email-iisaman@netapp.com>
 <1278617122-24164-4-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22871 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758512Ab0GHTZ2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jul 2010 15:25:28 -0400
Received: from localhost.localdomain (khang-lxp.hq.netapp.com [10.58.60.105] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o68JPOdO010802
	for <linux-nfs@vger.kernel.org>; Thu, 8 Jul 2010 12:25:27 -0700 (PDT)
In-Reply-To: <1278617122-24164-4-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is not used by file layout

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4xdr.c |   29 -----------------------------
 1 files changed, 0 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index befda6f..273d154 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1060,35 +1060,6 @@ static void encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm
 	hdr->replen += decode_getattr_maxsz;
 }
 
-static void
-encode_getattr_three(struct xdr_stream *xdr,
-		     uint32_t bm0, uint32_t bm1, uint32_t bm2,
-		     struct compound_hdr *hdr)
-{
-	__be32 *p;
-
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_GETATTR);
-	if (bm2) {
-		p = reserve_space(xdr, 16);
-		*p++ = cpu_to_be32(3);
-		*p++ = cpu_to_be32(bm0);
-		*p++ = cpu_to_be32(bm1);
-		*p = cpu_to_be32(bm2);
-	} else if (bm1) {
-		p = reserve_space(xdr, 12);
-		*p++ = cpu_to_be32(2);
-		*p++ = cpu_to_be32(bm0);
-		*p = cpu_to_be32(bm1);
-	} else {
-		p = reserve_space(xdr, 8);
-		*p++ = cpu_to_be32(1);
-		*p = cpu_to_be32(bm0);
-	}
-	hdr->nops++;
-	hdr->replen += decode_getattr_maxsz;
-}
-
 static void encode_getfattr(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
 {
 	encode_getattr_two(xdr, bitmask[0] & nfs4_fattr_bitmap[0],
-- 
1.6.6.1

