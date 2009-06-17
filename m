From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/3] SQUASHME: nfs41: no need to break read_buf in decode_compound_hdr_arg
Date: Wed, 17 Jun 2009 20:22:02 +0300
Message-ID: <1245259322-9339-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:14480
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754477AbZFQRWB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jun 2009 13:22:01 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixes Trond's review comment from 2009-06-15
Re: [pnfs] [RFC 25/39] nfs41: decode minorversion 1 cb_compound header

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_xdr.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 27ac457..654a6a2 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -153,15 +153,12 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
 				__func__, hdr->taglen);
 		return htonl(NFS4ERR_RESOURCE);
 	}
-	p = read_buf(xdr, 4);
+	p = read_buf(xdr, 12);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
 	hdr->minorversion = ntohl(*p++);
 	/* Check minor version is zero or one. */
 	if (hdr->minorversion <= 1) {
-		p = read_buf(xdr, 8);
-		if (unlikely(p == NULL))
-			return htonl(NFS4ERR_RESOURCE);
 		p++;	/* skip callback_ident */
 	} else {
 		printk(KERN_WARNING "%s: NFSv4 server callback with "
-- 
1.6.3.1

