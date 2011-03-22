Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay03.bluemeaney.com ([205.234.16.187]:47196 "EHLO
	relay03.bluemeaney.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755324Ab1CVVwP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2011 17:52:15 -0400
From: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Subject: [PATCH] nfs4: Fix memory corruption due to not expected FS_LOCATIONS v3
Date: Wed, 23 Mar 2011 00:36:35 +0300
Message-Id: <1300829795-17054-1-git-send-email-gusev.vitaliy@nexenta.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Changes with v2 version: when unexpected fs_locations occurs:

1. Throw print message "unexpected fs_locations"
2. Stop parsing xdr and return EIO error

----

There is a remote vulnerability for nfs4-client. That allows
a remote NFSv4 server or attacker in middle rewrite memory on
NFSv4 client.
Of course if encryption is used then only server can do corruption.

1. Client send GETATTR request to server, but there are not
   checks for bitmask in reply from server. Therefore server may return
   more attributes than were asked.

2. Pointer to struct nfs_fattr is passed to decode_getfattr(), but
   that parameter is considered as pointer to struct nfs4_fs_locations
   in case set FATTR4_WORD0_FS_LOCATIONS in reply from server.

   But there is no check for pointer type that was passed!

3. Remote side can set FATTR4_WORD0_FS_LOCATIONS and fill
   datas fsattr4_fs_locations in reply to client.

4. sizeof(nfs4_fs_locations) is about 92080 bytes in kernel 2.6.38

   So ~ 90 Kbytes can be overwritten in memory of NFSv4 client.

   Fortunately, nfs_fattr is allocated via kmalloc and
   is not stored on stack. So generally kmalloc-192 is corrupted.

   Affected kernels: all from v2.6.18
   Commit 683b57b435326eb512c7305892683b6205669448
   "NFSv4: Implement the fs_locations function call"
---
 fs/nfs/nfs4xdr.c |   39 +++++++++++++++++++++++++++++----------
 1 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c87e543..6fea9c9 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3451,7 +3451,8 @@ out_overflow:
 	return -EIO;
 }
 
-static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs4_fs_locations *res)
+static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs4_fs_locations *res,
+				    uint32_t *deny_bitmap)
 {
 	int n;
 	__be32 *p;
@@ -3462,6 +3463,13 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 	status = 0;
 	if (unlikely(!(bitmap[0] & FATTR4_WORD0_FS_LOCATIONS)))
 		goto out;
+
+	if (unlikely(deny_bitmap[0] & FATTR4_WORD0_FS_LOCATIONS)) {
+		status = -EIO;
+		printk(KERN_WARNING "%s: Unexpected fs_locations\n", __func__);
+		goto out;
+	}
+
 	dprintk("%s: fsroot ", __func__);
 	status = decode_pathname(xdr, &res->fs_path);
 	if (unlikely(status != 0))
@@ -4186,7 +4194,8 @@ xdr_error:
 
 static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 		struct nfs_fattr *fattr, struct nfs_fh *fh,
-		const struct nfs_server *server, int may_sleep)
+		const struct nfs_server *server, int may_sleep,
+		uint32_t *deny_bitmap)
 {
 	int status;
 	umode_t fmode = 0;
@@ -4232,7 +4241,7 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 
 	status = decode_attr_fs_locations(xdr, bitmap, container_of(fattr,
 						struct nfs4_fs_locations,
-						fattr));
+						fattr), deny_bitmap);
 	if (status < 0)
 		goto xdr_error;
 	fattr->valid |= status;
@@ -4301,11 +4310,13 @@ xdr_error:
 }
 
 static int decode_getfattr_generic(struct xdr_stream *xdr, struct nfs_fattr *fattr,
-		struct nfs_fh *fh, const struct nfs_server *server, int may_sleep)
+		struct nfs_fh *fh, const struct nfs_server *server, int may_sleep,
+		int expect_fsloc)
 {
 	__be32 *savep;
 	uint32_t attrlen,
 		 bitmap[3] = {0};
+	uint32_t deny_bitmap[3] = {0};
 	int status;
 
 	status = decode_op_hdr(xdr, OP_GETATTR);
@@ -4316,11 +4327,15 @@ static int decode_getfattr_generic(struct xdr_stream *xdr, struct nfs_fattr *fat
 	if (status < 0)
 		goto xdr_error;
 
+	if (!expect_fsloc)
+		deny_bitmap[0] |= FATTR4_WORD0_FS_LOCATIONS;
+
 	status = decode_attr_length(xdr, &attrlen, &savep);
 	if (status < 0)
 		goto xdr_error;
 
-	status = decode_getfattr_attrs(xdr, bitmap, fattr, fh, server, may_sleep);
+	status = decode_getfattr_attrs(xdr, bitmap, fattr, fh, server, may_sleep,
+				       deny_bitmap);
 	if (status < 0)
 		goto xdr_error;
 
@@ -4333,7 +4348,7 @@ xdr_error:
 static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
 		const struct nfs_server *server, int may_sleep)
 {
-	return decode_getfattr_generic(xdr, fattr, NULL, server, may_sleep);
+	return decode_getfattr_generic(xdr, fattr, NULL, server, may_sleep, 0);
 }
 
 /*
@@ -6338,9 +6353,11 @@ static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req,
 	if (status)
 		goto out;
 	xdr_enter_page(xdr, PAGE_SIZE);
-	status = decode_getfattr(xdr, &res->fs_locations->fattr,
+	status = decode_getfattr_generic(xdr, &res->fs_locations->fattr,
+				 NULL,
 				 res->fs_locations->server,
-				 !RPC_IS_ASYNC(req->rq_task));
+				 !RPC_IS_ASYNC(req->rq_task),
+				 1);
 out:
 	return status;
 }
@@ -6639,7 +6656,7 @@ out:
 int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 		       int plus)
 {
-	uint32_t bitmap[3] = {0};
+	uint32_t bitmap[3] = {0}, deny_bitmap[3] = {0};
 	uint32_t len;
 	__be32 *p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
@@ -6680,8 +6697,10 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	if (decode_attr_length(xdr, &len, &p) < 0)
 		goto out_overflow;
 
+	deny_bitmap[0] |= FATTR4_WORD0_FS_LOCATIONS;
+
 	if (decode_getfattr_attrs(xdr, bitmap, entry->fattr, entry->fh,
-					entry->server, 1) < 0)
+				  entry->server, 1, deny_bitmap) < 0)
 		goto out_overflow;
 	if (entry->fattr->valid & NFS_ATTR_FATTR_FILEID)
 		entry->ino = entry->fattr->fileid;
-- 
1.7.1

