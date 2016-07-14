Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34219 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbcGNECF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jul 2016 00:02:05 -0400
Received: by mail-pa0-f67.google.com with SMTP id hh10so3981295pac.1
        for <linux-nfs@vger.kernel.org>; Wed, 13 Jul 2016 21:02:05 -0700 (PDT)
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] nfs/blocklayout: Check max uuids and devices before decoding
Message-ID: <87b2740f-d38b-b5f6-be85-cf2279c62496@gmail.com>
Date: Thu, 14 Jul 2016 12:02:01 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid nfs return uuids/devices larger than maximum.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/blocklayout/dev.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index 3021015..6d71b67 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -65,8 +65,8 @@ nfs4_block_decode_volume(struct xdr_stream *xdr, struct pnfs_block_volume *b)
 		if (!p)
 			return -EIO;
 		b->simple.nr_sigs = be32_to_cpup(p++);
-		if (!b->simple.nr_sigs) {
-			dprintk("no signature\n");
+		if (!b->simple.nr_sigs || b->simple.nr_sigs > PNFS_BLOCK_MAX_UUIDS) {
+			dprintk("Bad signature count: %d\n", b->simple.nr_sigs);
 			return -EIO;
 		}
 
@@ -105,7 +105,12 @@ nfs4_block_decode_volume(struct xdr_stream *xdr, struct pnfs_block_volume *b)
 		p = xdr_inline_decode(xdr, 4);
 		if (!p)
 			return -EIO;
+
 		b->concat.volumes_count = be32_to_cpup(p++);
+		if (b->concat.volumes_count > PNFS_BLOCK_MAX_DEVICES) {
+			dprintk("Too many volumes: %d\n", b->concat.volumes_count);
+			return -EIO;
+		}
 
 		p = xdr_inline_decode(xdr, b->concat.volumes_count * 4);
 		if (!p)
@@ -117,8 +122,13 @@ nfs4_block_decode_volume(struct xdr_stream *xdr, struct pnfs_block_volume *b)
 		p = xdr_inline_decode(xdr, 8 + 4);
 		if (!p)
 			return -EIO;
+
 		p = xdr_decode_hyper(p, &b->stripe.chunk_size);
 		b->stripe.volumes_count = be32_to_cpup(p++);
+		if (b->stripe.volumes_count > PNFS_BLOCK_MAX_DEVICES) {
+			dprintk("Too many volumes: %d\n", b->stripe.volumes_count);
+			return -EIO;
+		}
 
 		p = xdr_inline_decode(xdr, b->stripe.volumes_count * 4);
 		if (!p)
-- 
2.7.4

