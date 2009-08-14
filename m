From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC v2 07/21] nfs: nfs4xdr: encode_compound_hdr does not have to round up reserved bytes
Date: Fri, 14 Aug 2009 17:19:18 +0300
Message-ID: <1250259558-13704-1-git-send-email-bhalevy@panasas.com>
References: <4A8571E2.8020800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:30545
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756881AbZHNOT1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 10:19:27 -0400
In-Reply-To: <4A8571E2.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is already done by xdr_reserve_space and since encode_compound_hdr
is adding a byte count to "12" which is already word aligned, the xdr
level rounding will work just as well.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d460d81..7c2b162 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -740,7 +740,7 @@ static void encode_compound_hdr(struct xdr_stream *xdr,
 
 	dprintk("encode_compound: tag=%.*s\n", (int)hdr->taglen, hdr->tag);
 	BUG_ON(hdr->taglen > NFS4_MAXTAGLEN);
-	RESERVE_SPACE(12+(XDR_QUADLEN(hdr->taglen)<<2));
+	RESERVE_SPACE(12 + hdr->taglen);
 	*p++ = cpu_to_be32(hdr->taglen);
 	p = xdr_encode_opaque_fixed(p, hdr->tag, hdr->taglen);
 	*p++ = cpu_to_be32(hdr->minorversion);
-- 
1.6.4

