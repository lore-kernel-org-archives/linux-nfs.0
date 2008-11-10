From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 77/85] nfs41: store minorversion in cb_compound_hdr_arg
Date: Mon, 10 Nov 2008 22:31:58 +0200
Message-ID: <1226349118-9802-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:53125 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702AbYKJUcE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:32:04 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.h     |    1 +
 fs/nfs/callback_xdr.c |   12 +++++++-----
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 4c69b27..e5ce040 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -26,6 +26,7 @@ enum nfs4_callback_opnum {
 struct cb_compound_hdr_arg {
 	unsigned int taglen;
 	const char *tag;
+	unsigned int minorversion;
 	unsigned int callback_ident;
 	unsigned nops;
 };
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index dd0ef34..91f6f74 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -132,7 +132,6 @@ static __be32 decode_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
 static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound_hdr_arg *hdr)
 {
 	__be32 *p;
-	unsigned int minor_version;
 	__be32 status;
 
 	status = decode_string(xdr, &hdr->taglen, &hdr->tag);
@@ -147,15 +146,18 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
 	p = read_buf(xdr, 12);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
-	minor_version = ntohl(*p++);
+	hdr->minorversion = ntohl(*p++);
 	/* Check minor version is zero. */
-	if (minor_version != 0) {
-		printk(KERN_WARNING "%s: NFSv4 server callback with illegal minor version %u!\n",
-				__func__, minor_version);
+	if (hdr->minorversion != 0) {
+		printk(KERN_WARNING "%s: NFSv4 server callback with "
+			"illegal minor version %u!\n",
+			__func__, hdr->minorversion);
 		return htonl(NFS4ERR_MINOR_VERS_MISMATCH);
 	}
 	hdr->callback_ident = ntohl(*p++);
 	hdr->nops = ntohl(*p);
+	dprintk("%s: minorversion %d nops %d\n", __func__,
+		hdr->minorversion, hdr->nops);
 	return 0;
 }
 
-- 
1.6.0.2

