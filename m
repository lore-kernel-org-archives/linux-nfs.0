Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:60756 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753161Ab3HVA0b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Aug 2013 20:26:31 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: Andy Adamson <andros@netapp.com>
Subject: [PATCH 5/6] NFSv4: Fix an incorrect pointer declaration in decode_first_pnfs_layout_type
Date: Wed, 21 Aug 2013 20:26:25 -0400
Message-ID: <1377131186-40249-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377131186-40249-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1377131186-40249-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377131186-40249-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377131186-40249-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377131186-40249-4-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We always encode to __be32 format in XDR: silences a sparse warning.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 1336263..4593728 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4630,7 +4630,7 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
 static int decode_first_pnfs_layout_type(struct xdr_stream *xdr,
 					 uint32_t *layouttype)
 {
-	uint32_t *p;
+	__be32 *p;
 	int num;
 
 	p = xdr_inline_decode(xdr, 4);
-- 
1.8.3.1

