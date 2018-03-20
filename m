Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:39095 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751468AbeCTVDt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 17:03:49 -0400
Received: by mail-it0-f67.google.com with SMTP id e98-v6so4162364itd.4
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 14:03:49 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 8/9] NFSv4: Clean up CB_GETATTR encoding
Date: Tue, 20 Mar 2018 17:03:12 -0400
Message-Id: <20180320210313.94429-9-trond.myklebust@primarydata.com>
In-Reply-To: <20180320210313.94429-8-trond.myklebust@primarydata.com>
References: <20180320210313.94429-1-trond.myklebust@primarydata.com>
 <20180320210313.94429-2-trond.myklebust@primarydata.com>
 <20180320210313.94429-3-trond.myklebust@primarydata.com>
 <20180320210313.94429-4-trond.myklebust@primarydata.com>
 <20180320210313.94429-5-trond.myklebust@primarydata.com>
 <20180320210313.94429-6-trond.myklebust@primarydata.com>
 <20180320210313.94429-7-trond.myklebust@primarydata.com>
 <20180320210313.94429-8-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace the open coded bitmap implementation with a generic one.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_xdr.c | 37 ++++++++-----------------------------
 1 file changed, 8 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 123c069429a7..a813979b5be0 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -535,35 +535,10 @@ static __be32 encode_string(struct xdr_stream *xdr, unsigned int len, const char
 	return 0;
 }
 
-#define CB_SUPPORTED_ATTR0 (FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE)
-#define CB_SUPPORTED_ATTR1 (FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY)
-static __be32 encode_attr_bitmap(struct xdr_stream *xdr, const uint32_t *bitmap, __be32 **savep)
+static __be32 encode_attr_bitmap(struct xdr_stream *xdr, const uint32_t *bitmap, size_t sz)
 {
-	__be32 bm[2];
-	__be32 *p;
-
-	bm[0] = htonl(bitmap[0] & CB_SUPPORTED_ATTR0);
-	bm[1] = htonl(bitmap[1] & CB_SUPPORTED_ATTR1);
-	if (bm[1] != 0) {
-		p = xdr_reserve_space(xdr, 16);
-		if (unlikely(p == NULL))
-			return htonl(NFS4ERR_RESOURCE);
-		*p++ = htonl(2);
-		*p++ = bm[0];
-		*p++ = bm[1];
-	} else if (bm[0] != 0) {
-		p = xdr_reserve_space(xdr, 12);
-		if (unlikely(p == NULL))
-			return htonl(NFS4ERR_RESOURCE);
-		*p++ = htonl(1);
-		*p++ = bm[0];
-	} else {
-		p = xdr_reserve_space(xdr, 8);
-		if (unlikely(p == NULL))
-			return htonl(NFS4ERR_RESOURCE);
-		*p++ = htonl(0);
-	}
-	*savep = p;
+	if (xdr_stream_encode_uint32_array(xdr, bitmap, sz) < 0)
+		return cpu_to_be32(NFS4ERR_RESOURCE);
 	return 0;
 }
 
@@ -656,9 +631,13 @@ static __be32 encode_getattr_res(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	
 	if (unlikely(status != 0))
 		goto out;
-	status = encode_attr_bitmap(xdr, res->bitmap, &savep);
+	status = encode_attr_bitmap(xdr, res->bitmap, ARRAY_SIZE(res->bitmap));
 	if (unlikely(status != 0))
 		goto out;
+	status = cpu_to_be32(NFS4ERR_RESOURCE);
+	savep = xdr_reserve_space(xdr, sizeof(*savep));
+	if (unlikely(!savep))
+		goto out;
 	status = encode_attr_change(xdr, res->bitmap, res->change_attr);
 	if (unlikely(status != 0))
 		goto out;
-- 
2.14.3

