Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qy0-f181.google.com ([209.85.216.181]:39022 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933253Ab1JaPQh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 11:16:37 -0400
Received: by qyk27 with SMTP id 27so6351146qyk.19
        for <linux-nfs@vger.kernel.org>; Mon, 31 Oct 2011 08:16:36 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, bhalevy@tonian.com,
        Peng Tao <peng_tao@emc.com>
Subject: [PATCH 1/2 RESEND] NFS4: fix cb_recallany decode error
Date: Mon, 31 Oct 2011 08:15:35 -0700
Message-Id: <1320074136-3087-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

craa_type_mask is bitmap4 according to RFC5661. We need to expect a length before
extracting its value.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
Resend this one as it is a dependency for "[PATCH 2/2] nfs41: handle BLK_LAYOUT CB_RECALL_ANY".

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

