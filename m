Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:39091 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751320AbeCTVDr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 17:03:47 -0400
Received: by mail-it0-f68.google.com with SMTP id e98-v6so4162217itd.4
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 14:03:46 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 5/9] NFSv4: Clean up encode_attrs
Date: Tue, 20 Mar 2018 17:03:09 -0400
Message-Id: <20180320210313.94429-6-trond.myklebust@primarydata.com>
In-Reply-To: <20180320210313.94429-5-trond.myklebust@primarydata.com>
References: <20180320210313.94429-1-trond.myklebust@primarydata.com>
 <20180320210313.94429-2-trond.myklebust@primarydata.com>
 <20180320210313.94429-3-trond.myklebust@primarydata.com>
 <20180320210313.94429-4-trond.myklebust@primarydata.com>
 <20180320210313.94429-5-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4xdr.c | 17 ++---------------
 1 file changed, 2 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 80c5b519fd6a..3d088230c975 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1052,9 +1052,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 	int owner_namelen = 0;
 	int owner_grouplen = 0;
 	__be32 *p;
-	unsigned i;
 	uint32_t len = 0;
-	uint32_t bmval_len;
 	uint32_t bmval[3] = { 0 };
 
 	/*
@@ -1123,19 +1121,8 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 		bmval[2] |= FATTR4_WORD2_SECURITY_LABEL;
 	}
 
-	if (bmval[2] != 0)
-		bmval_len = 3;
-	else if (bmval[1] != 0)
-		bmval_len = 2;
-	else
-		bmval_len = 1;
-
-	p = reserve_space(xdr, 4 + (bmval_len << 2) + 4 + len);
-
-	*p++ = cpu_to_be32(bmval_len);
-	for (i = 0; i < bmval_len; i++)
-		*p++ = cpu_to_be32(bmval[i]);
-	*p++ = cpu_to_be32(len);
+	xdr_encode_bitmap4(xdr, bmval, ARRAY_SIZE(bmval));
+	xdr_stream_encode_opaque_inline(xdr, (void **)&p, len);
 
 	if (bmval[0] & FATTR4_WORD0_SIZE)
 		p = xdr_encode_hyper(p, iap->ia_size);
-- 
2.14.3

