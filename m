Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33687 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbbC1Ptx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2015 11:49:53 -0400
Received: by pabxg6 with SMTP id xg6so124268317pab.0
        for <linux-nfs@vger.kernel.org>; Sat, 28 Mar 2015 08:49:53 -0700 (PDT)
Message-ID: <5516CD98.70706@gmail.com>
Date: Sat, 28 Mar 2015 23:49:44 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 2/4] nfs: use NFS4_MAXTAGLEN for cb_taglen checking
References: <5516CCDB.4020509@gmail.com>
In-Reply-To: <5516CCDB.4020509@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/callback_xdr.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 1737c2e..ea6d4de 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -18,8 +18,7 @@
 #include "internal.h"
 #include "nfs4session.h"
 
-#define CB_OP_TAGLEN_MAXSZ	(512)
-#define CB_OP_HDR_RES_MAXSZ	(2 + CB_OP_TAGLEN_MAXSZ)
+#define CB_OP_HDR_RES_MAXSZ	(2 + NFS4_MAXTAGLEN)
 #define CB_OP_GETATTR_BITMAP_MAXSZ	(4)
 #define CB_OP_GETATTR_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ + \
 				CB_OP_GETATTR_BITMAP_MAXSZ + \
@@ -157,7 +156,7 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
 	if (unlikely(status != 0))
 		return status;
 	/* We do not like overly long tags! */
-	if (hdr->taglen > CB_OP_TAGLEN_MAXSZ) {
+	if (hdr->taglen > NFS4_MAXTAGLEN) {
 		printk("NFS: NFSv4 CALLBACK %s: server sents tag of length %u\n",
 				__func__, hdr->taglen);
 		return htonl(NFS4ERR_RESOURCE);
-- 
2.3.4

