Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37207 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229AbbKCRZk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Nov 2015 12:25:40 -0500
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Cc: Andreas Gruenbacher <agruenba@redhat.com>
Subject: [PATCH 1/2] nfs: Fix GETATTR bitmap verification
Date: Tue,  3 Nov 2015 18:25:33 +0100
Message-Id: <1446571534-16286-2-git-send-email-agruenba@redhat.com>
In-Reply-To: <1446571534-16286-1-git-send-email-agruenba@redhat.com>
References: <1446571534-16286-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When decoding GETATTR replies, the client checks the attribute bitmap
for which attributes the server has sent.  It misses bits at the word
boundaries, though; fix that.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/nfs/nfs4xdr.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 788adf3..6f6d921 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4375,6 +4375,11 @@ static int decode_statfs(struct xdr_stream *xdr, struct nfs_fsstat *fsstat)
 		goto xdr_error;
 	if ((status = decode_attr_files_total(xdr, bitmap, &fsstat->tfiles)) != 0)
 		goto xdr_error;
+
+	status = -EIO;
+	if (unlikely(bitmap[0]))
+		goto xdr_error;
+
 	if ((status = decode_attr_space_avail(xdr, bitmap, &fsstat->abytes)) != 0)
 		goto xdr_error;
 	if ((status = decode_attr_space_free(xdr, bitmap, &fsstat->fbytes)) != 0)
@@ -4574,6 +4579,10 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 		goto xdr_error;
 	fattr->valid |= status;
 
+	status = -EIO;
+	if (unlikely(bitmap[0]))
+		goto xdr_error;
+
 	status = decode_attr_mode(xdr, bitmap, &fmode);
 	if (status < 0)
 		goto xdr_error;
@@ -4627,6 +4636,10 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 		goto xdr_error;
 	fattr->valid |= status;
 
+	status = -EIO;
+	if (unlikely(bitmap[1]))
+		goto xdr_error;
+
 	status = decode_attr_mdsthreshold(xdr, bitmap, fattr->mdsthreshold);
 	if (status < 0)
 		goto xdr_error;
@@ -4789,12 +4802,22 @@ static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 	if ((status = decode_attr_maxwrite(xdr, bitmap, &fsinfo->wtmax)) != 0)
 		goto xdr_error;
 	fsinfo->wtpref = fsinfo->wtmax;
+
+	status = -EIO;
+	if (unlikely(bitmap[0]))
+		goto xdr_error;
+
 	status = decode_attr_time_delta(xdr, bitmap, &fsinfo->time_delta);
 	if (status != 0)
 		goto xdr_error;
 	status = decode_attr_pnfstype(xdr, bitmap, &fsinfo->layouttype);
 	if (status != 0)
 		goto xdr_error;
+
+	status = -EIO;
+	if (unlikely(bitmap[1]))
+		goto xdr_error;
+
 	status = decode_attr_layout_blksize(xdr, bitmap, &fsinfo->blksize);
 	if (status)
 		goto xdr_error;
-- 
2.5.0

