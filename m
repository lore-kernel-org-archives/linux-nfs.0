Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:60246 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756678Ab0LNO6n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 09:58:43 -0500
Received: by gxk19 with SMTP id 19so474921gxk.11
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 06:58:43 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 26/31] NFS: Avoid return code checking in mount XDR encoder
	functions
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 09:58:40 -0500
Message-ID: <20101214145840.2293.20221.stgit@matisse.1015granger.net>
In-Reply-To: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

The trend in the other XDR encoder functions is to BUG() when encoding
problems occur, since a problem here is always due to a local coding
error.  Then, instead of a status, zero is unconditionally returned.

Update the mount client XDR encoders to behave this way.

To finish the update, use the new-style be32_to_cpup() and
cpu_to_be32() macros, and compute the buffer sizes using raw integers
instead of sizeof().  This matches the conventions used in other XDR
functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/nfs/mount_clnt.c |   35 +++++++++++++++--------------------
 1 files changed, 15 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 4f981f1..c82547e 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -280,20 +280,14 @@ out_call_err:
  * XDR encode/decode functions for MOUNT
  */
 
-static int encode_mntdirpath(struct xdr_stream *xdr, const char *pathname)
+static void encode_mntdirpath(struct xdr_stream *xdr, const char *pathname)
 {
 	const u32 pathname_len = strlen(pathname);
 	__be32 *p;
 
-	if (unlikely(pathname_len > MNTPATHLEN))
-		return -EIO;
-
-	p = xdr_reserve_space(xdr, sizeof(u32) + pathname_len);
-	if (unlikely(p == NULL))
-		return -EIO;
+	BUG_ON(pathname_len > MNTPATHLEN);
+	p = xdr_reserve_space(xdr, 4 + pathname_len);
 	xdr_encode_opaque(p, pathname, pathname_len);
-
-	return 0;
 }
 
 static int mnt_enc_dirpath(struct rpc_rqst *req, __be32 *p,
@@ -302,7 +296,8 @@ static int mnt_enc_dirpath(struct rpc_rqst *req, __be32 *p,
 	struct xdr_stream xdr;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	return encode_mntdirpath(&xdr, dirpath);
+	encode_mntdirpath(&xdr, dirpath);
+	return 0;
 }
 
 /*
@@ -320,10 +315,10 @@ static int decode_status(struct xdr_stream *xdr, struct mountres *res)
 	u32 status;
 	__be32 *p;
 
-	p = xdr_inline_decode(xdr, sizeof(status));
+	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
 		return -EIO;
-	status = ntohl(*p);
+	status = be32_to_cpup(p);
 
 	for (i = 0; i < ARRAY_SIZE(mnt_errtbl); i++) {
 		if (mnt_errtbl[i].status == status) {
@@ -371,10 +366,10 @@ static int decode_fhs_status(struct xdr_stream *xdr, struct mountres *res)
 	u32 status;
 	__be32 *p;
 
-	p = xdr_inline_decode(xdr, sizeof(status));
+	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
 		return -EIO;
-	status = ntohl(*p);
+	status = be32_to_cpup(p);
 
 	for (i = 0; i < ARRAY_SIZE(mnt3_errtbl); i++) {
 		if (mnt3_errtbl[i].status == status) {
@@ -394,11 +389,11 @@ static int decode_fhandle3(struct xdr_stream *xdr, struct mountres *res)
 	u32 size;
 	__be32 *p;
 
-	p = xdr_inline_decode(xdr, sizeof(size));
+	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
 		return -EIO;
 
-	size = ntohl(*p++);
+	size = be32_to_cpup(p);
 	if (size > NFS3_FHSIZE || size == 0)
 		return -EIO;
 
@@ -421,15 +416,15 @@ static int decode_auth_flavors(struct xdr_stream *xdr, struct mountres *res)
 	if (*count == 0)
 		return 0;
 
-	p = xdr_inline_decode(xdr, sizeof(entries));
+	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
 		return -EIO;
-	entries = ntohl(*p);
+	entries = be32_to_cpup(p);
 	dprintk("NFS: received %u auth flavors\n", entries);
 	if (entries > NFS_MAX_SECFLAVORS)
 		entries = NFS_MAX_SECFLAVORS;
 
-	p = xdr_inline_decode(xdr, sizeof(u32) * entries);
+	p = xdr_inline_decode(xdr, 4 * entries);
 	if (unlikely(p == NULL))
 		return -EIO;
 
@@ -437,7 +432,7 @@ static int decode_auth_flavors(struct xdr_stream *xdr, struct mountres *res)
 		entries = *count;
 
 	for (i = 0; i < entries; i++) {
-		flavors[i] = ntohl(*p++);
+		flavors[i] = be32_to_cpup(p++);
 		dprintk("NFS:   auth flavor[%u]: %d\n", i, flavors[i]);
 	}
 	*count = i;

