Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:35343 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933795Ab0KQSBR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 13:01:17 -0500
Received: by pxi15 with SMTP id 15so578254pxi.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 10:01:17 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/12] NFS: Avoid return code checking in mount XDR encoder
	functions
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 17 Nov 2010 13:01:14 -0500
Message-ID: <20101117180114.29429.39517.stgit@matisse.1015granger.net>
In-Reply-To: <20101117175317.29429.90956.stgit@matisse.1015granger.net>
References: <20101117175317.29429.90956.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

The trend in the other XDR encoder functions is to BUG() when encoding
problems occur, since a problem is always due to a local coding error.

Then, instead of a status, zero is unconditionally returned.

Update the mount client XDR encoders to behave this way.

To finish the update, use the new-style ntohl() and htonl() macros,
and compute the buffer sizes using raw integers instead of sizeof().
This matches the conventions used in other XDR functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/nfs/mount_clnt.c |   35 +++++++++++++++--------------------
 1 files changed, 15 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index eceafe7..2e238f3 100644
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

