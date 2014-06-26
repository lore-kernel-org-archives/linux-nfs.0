Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f51.google.com ([209.85.160.51]:55671 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844AbaFZSjR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 14:39:17 -0400
Received: by mail-pb0-f51.google.com with SMTP id rp16so3517096pbb.10
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 11:39:16 -0700 (PDT)
Date: Fri, 27 Jun 2014 00:09:09 +0530
From: Himangi Saraogi <himangi774@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel
Cc: julia.lawall@lip6.fr
Subject: [PATCH] NFSv4: Drop cast
Message-ID: <20140626183908.GA4242@himangi-Dell>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch does away with the cast on void * as it is unnecessary.

The following Coccinelle semantic patch was used for making the change:

@r@
expression x;
void* e;
type T;
identifier f;
@@

(
  *((T *)e)
|
  ((T *)x)[...]
|
  ((T *)x)->f
|
- (T *)
  e
)

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
---
 fs/nfs/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 939ae60..e13b59d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7092,7 +7092,7 @@ static int nfs4_xdr_dec_reclaim_complete(struct rpc_rqst *rqstp,
 	if (!status)
 		status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (!status)
-		status = decode_reclaim_complete(xdr, (void *)NULL);
+		status = decode_reclaim_complete(xdr, NULL);
 	return status;
 }
 
-- 
1.9.1

