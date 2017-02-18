Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35744 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753473AbdBRSSQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Feb 2017 13:18:16 -0500
Received: by mail-it0-f65.google.com with SMTP id 203so6722534ith.2
        for <linux-nfs@vger.kernel.org>; Sat, 18 Feb 2017 10:18:15 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/4] NFSv4: Remove bogus "struct nfs_client" argument from decode_ace()
Date: Sat, 18 Feb 2017 13:18:06 -0500
Message-Id: <20170218181806.25712-5-trond.myklebust@primarydata.com>
In-Reply-To: <20170218181806.25712-4-trond.myklebust@primarydata.com>
References: <20170218181806.25712-1-trond.myklebust@primarydata.com>
 <20170218181806.25712-2-trond.myklebust@primarydata.com>
 <20170218181806.25712-3-trond.myklebust@primarydata.com>
 <20170218181806.25712-4-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We shouldn't need to force callers to carry an unused argument.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4xdr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 7510a0cd93fa..dbb765fb4180 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3125,7 +3125,7 @@ static int decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
 }
 
 /* Dummy routine */
-static int decode_ace(struct xdr_stream *xdr, void *ace, struct nfs_client *clp)
+static int decode_ace(struct xdr_stream *xdr, void *ace)
 {
 	__be32 *p;
 	unsigned int strlen;
@@ -5073,7 +5073,7 @@ static int decode_rw_delegation(struct xdr_stream *xdr,
 		if (decode_space_limit(xdr, &res->pagemod_limit) < 0)
 				return -EIO;
 	}
-	return decode_ace(xdr, NULL, res->server->nfs_client);
+	return decode_ace(xdr, NULL);
 out_overflow:
 	print_overflow_msg(__func__, xdr);
 	return -EIO;
-- 
2.9.3

