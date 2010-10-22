Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52149 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757157Ab0JVOOo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Oct 2010 10:14:44 -0400
Message-ID: <4CC19C53.1060407@netapp.com>
Date: Fri, 22 Oct 2010 10:14:43 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH 09/10] NFS: introduce generic decode_getattr function
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Getattr should be able to decode errors and the readdir file handle.
decode_getfattr_attrs does the actual attribute decoding, while
decode_getfattr_generic will check the opcode before decoding.  This will
let other functions call decode_getfattr_attrs to decode their attributes.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c |  118 ++++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 98 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 8346e97..26ab385 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2848,6 +2848,58 @@ out_overflow:
 	return -EIO;
 }
 
+static int decode_attr_error(struct xdr_stream *xdr, uint32_t *bitmap)
+{
+	__be32 *p;
+
+	if (unlikely(bitmap[0] & (FATTR4_WORD0_RDATTR_ERROR - 1U)))
+		return -EIO;
+	if (likely(bitmap[0] & FATTR4_WORD0_RDATTR_ERROR)) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+		bitmap[0] &= ~FATTR4_WORD0_RDATTR_ERROR;
+	}
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int decode_attr_filehandle(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs_fh *fh)
+{
+	__be32 *p;
+	int len;
+
+	if (fh == NULL) {
+		bitmap[0] &= ~FATTR4_WORD0_FILEHANDLE;
+		return 0;
+	}
+
+	memset(fh, 0, sizeof(*fh));
+
+	if (unlikely(bitmap[0] & (FATTR4_WORD0_FILEHANDLE - 1U)))
+		return -EIO;
+	if (likely(bitmap[0] & FATTR4_WORD0_FILEHANDLE)) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+		len = be32_to_cpup(p);
+		if (len > NFS4_FHSIZE)
+			return -EIO;
+		fh->size = len;
+		p = xdr_inline_decode(xdr, len);
+		if (unlikely(!p))
+			goto out_overflow;
+		memcpy(fh->data, p, len);
+		bitmap[0] &= ~FATTR4_WORD0_FILEHANDLE;
+	}
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 static int decode_attr_aclsupport(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *res)
 {
 	__be32 *p;
@@ -3744,29 +3796,14 @@ xdr_error:
 	return status;
 }
 
-static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
+static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
+		struct nfs_fattr *fattr, struct nfs_fh *fh,
 		const struct nfs_server *server, int may_sleep)
 {
-	__be32 *savep;
-	uint32_t attrlen,
-		 bitmap[2] = {0},
-		 type;
 	int status;
 	umode_t fmode = 0;
 	uint64_t fileid;
-
-	status = decode_op_hdr(xdr, OP_GETATTR);
-	if (status < 0)
-		goto xdr_error;
-
-	status = decode_attr_bitmap(xdr, bitmap);
-	if (status < 0)
-		goto xdr_error;
-
-	status = decode_attr_length(xdr, &attrlen, &savep);
-	if (status < 0)
-		goto xdr_error;
-
+	uint32_t type;
 
 	status = decode_attr_type(xdr, bitmap, &type);
 	if (status < 0)
@@ -3792,6 +3829,14 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
 		goto xdr_error;
 	fattr->valid |= status;
 
+	status = decode_attr_error(xdr, bitmap);
+	if (status < 0)
+		goto xdr_error;
+
+	status = decode_attr_filehandle(xdr, bitmap, fh);
+	if (status < 0)
+		goto xdr_error;
+
 	status = decode_attr_fileid(xdr, bitmap, &fattr->fileid);
 	if (status < 0)
 		goto xdr_error;
@@ -3857,17 +3902,50 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
 	status = decode_attr_mounted_on_fileid(xdr, bitmap, &fileid);
 	if (status < 0)
 		goto xdr_error;
-	if (status != 0 && !(fattr->valid & status)) {
+	if (status != 0) {
 		fattr->fileid = fileid;
 		fattr->valid |= status;
 	}
 
-	status = verify_attr_len(xdr, savep, attrlen);
 xdr_error:
 	dprintk("%s: xdr returned %d\n", __func__, -status);
 	return status;
 }
 
+static int decode_getfattr_generic(struct xdr_stream *xdr, struct nfs_fattr *fattr,
+		struct nfs_fh *fh, const struct nfs_server *server, int may_sleep)
+{
+	__be32 *savep;
+	uint32_t attrlen,
+		 bitmap[2] = {0};
+	int status;
+
+	status = decode_op_hdr(xdr, OP_GETATTR);
+	if (status < 0)
+		goto xdr_error;
+
+	status = decode_attr_bitmap(xdr, bitmap);
+	if (status < 0)
+		goto xdr_error;
+
+	status = decode_attr_length(xdr, &attrlen, &savep);
+	if (status < 0)
+		goto xdr_error;
+
+	status = decode_getfattr_attrs(xdr, bitmap, fattr, fh, server, may_sleep);
+	if (status < 0)
+		goto xdr_error;
+
+	status = verify_attr_len(xdr, savep, attrlen);
+xdr_error:
+	dprintk("%s: xdr returned %d\n", __func__, -status);
+	return status;
+}
+static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
+		const struct nfs_server *server, int may_sleep)
+{
+	return decode_getfattr_generic(xdr, fattr, NULL, server, may_sleep);
+}
 
 static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 {
