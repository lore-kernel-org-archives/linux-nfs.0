From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 78/85] nfs41: decode minorversion 1 cb_compound header
Date: Mon, 10 Nov 2008 22:32:08 +0200
Message-ID: <1226349128-9837-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:53132 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752713AbYKJUcO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:32:14 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

decode cb_compound header conforming to
http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26

Get rid of cb_compound_hdr_arg.callback_ident

callback_ident is not used anywhere so we shouldn't waste any memory to
store it.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.h     |    1 -
 fs/nfs/callback_xdr.c |   12 ++++++++----
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index e5ce040..f8325da 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -27,7 +27,6 @@ struct cb_compound_hdr_arg {
 	unsigned int taglen;
 	const char *tag;
 	unsigned int minorversion;
-	unsigned int callback_ident;
 	unsigned nops;
 };
 
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 91f6f74..e141a7e 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -143,18 +143,22 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
 				__func__, hdr->taglen);
 		return htonl(NFS4ERR_RESOURCE);
 	}
-	p = read_buf(xdr, 12);
+	p = read_buf(xdr, 4);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
 	hdr->minorversion = ntohl(*p++);
-	/* Check minor version is zero. */
-	if (hdr->minorversion != 0) {
+	/* Check minor version is zero or one. */
+	if (hdr->minorversion <= 1) {
+		p = read_buf(xdr, 8);
+		if (unlikely(p == NULL))
+			return htonl(NFS4ERR_RESOURCE);
+		p++;	/* skip callback_ident */
+	} else {
 		printk(KERN_WARNING "%s: NFSv4 server callback with "
 			"illegal minor version %u!\n",
 			__func__, hdr->minorversion);
 		return htonl(NFS4ERR_MINOR_VERS_MISMATCH);
 	}
-	hdr->callback_ident = ntohl(*p++);
 	hdr->nops = ntohl(*p);
 	dprintk("%s: minorversion %d nops %d\n", __func__,
 		hdr->minorversion, hdr->nops);
-- 
1.6.0.2

