From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC 11/13] nfs: nfs4xdr: get rid of READTIME macro
Date: Wed, 12 Aug 2009 18:22:35 +0300
Message-ID: <1250090555-9863-1-git-send-email-bhalevy@panasas.com>
References: <4A82DC7B.3090600@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:10697
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752707AbZHLPWl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Aug 2009 11:22:41 -0400
In-Reply-To: <4A82DC7B.3090600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It has no users.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index db17685..2e83aef 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2448,11 +2448,6 @@ static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
  * task to translate them into Linux-specific versions which are more
  * consistent with the style used in NFSv2/v3...
  */
-#define READTIME(x)       do {			\
-	p++;					\
-	(x.tv_sec) = ntohl(*p++);		\
-	(x.tv_nsec) = ntohl(*p++);		\
-} while (0)
 #define COPYMEM(x,nbytes) do {			\
 	memcpy((x), p, nbytes);			\
 	p += XDR_QUADLEN(nbytes);		\
-- 
1.6.4

