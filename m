Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:49289 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189Ab1J0QHI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Oct 2011 12:07:08 -0400
Received: by iaby12 with SMTP id y12so3056485iab.19
        for <linux-nfs@vger.kernel.org>; Thu, 27 Oct 2011 09:07:08 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Alexandros Batsakis <batsakis@netapp.com>,
        Peng Tao <peng_tao@emc.com>
Subject: [PATCH] NFS4: fix cb_recallany decode error
Date: Sun, 23 Oct 2011 20:22:38 -0700
Message-Id: <1319426558-2145-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

craa_type_mask is bitmap4 per RFC5661. We need to expect a length before
extracting bitmap value.

Cc: Alexandros Batsakis <batsakis@netapp.com>
Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/callback_xdr.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 918ad64..ee1a5b3 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -488,17 +488,18 @@ static __be32 decode_recallany_args(struct svc_rqst *rqstp,
 				      struct xdr_stream *xdr,
 				      struct cb_recallanyargs *args)
 {
-	__be32 *p;
+	uint32_t bitmap[2];
+	__be32 *p, status;
 
 	args->craa_addr = svc_addr(rqstp);
 	p = read_buf(xdr, 4);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_BADXDR);
 	args->craa_objs_to_keep = ntohl(*p++);
-	p = read_buf(xdr, 4);
-	if (unlikely(p == NULL))
-		return htonl(NFS4ERR_BADXDR);
-	args->craa_type_mask = ntohl(*p);
+	status = decode_bitmap(xdr, bitmap);
+	if (unlikely(status))
+		return status;
+	args->craa_type_mask = bitmap[0];
 
 	return 0;
 }
-- 
1.7.1.262.g5ef3d

