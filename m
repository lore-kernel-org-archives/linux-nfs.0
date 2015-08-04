Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:33449 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933819AbbHDLzv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 07:55:51 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: [RFC v6 37/40] nfs: Fix GETATTR bitmap verification
Date: Tue,  4 Aug 2015 13:53:35 +0200
Message-Id: <1438689218-6921-38-git-send-email-agruenba@redhat.com>
In-Reply-To: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
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
index 558cd65d..67197b8 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4346,6 +4346,11 @@ static int decode_statfs(struct xdr_stream *xdr, struct nfs_fsstat *fsstat)
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
@@ -4545,6 +4550,10 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 		goto xdr_error;
 	fattr->valid |= status;
 
+	status = -EIO;
+	if (unlikely(bitmap[0]))
+		goto xdr_error;
+
 	status = decode_attr_mode(xdr, bitmap, &fmode);
 	if (status < 0)
 		goto xdr_error;
@@ -4598,6 +4607,10 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 		goto xdr_error;
 	fattr->valid |= status;
 
+	status = -EIO;
+	if (unlikely(bitmap[1]))
+		goto xdr_error;
+
 	status = decode_attr_mdsthreshold(xdr, bitmap, fattr->mdsthreshold);
 	if (status < 0)
 		goto xdr_error;
@@ -4760,12 +4773,22 @@ static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
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

