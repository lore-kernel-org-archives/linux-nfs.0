From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC v2 13/21] nfs: nfs4xdr: get rid of READTIME
Date: Fri, 14 Aug 2009 17:19:44 +0300
Message-ID: <1250259584-13897-1-git-send-email-bhalevy@panasas.com>
References: <4A8571E2.8020800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:26161
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932095AbZHNOTv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 10:19:51 -0400
In-Reply-To: <4A8571E2.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It has no users.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 238189c..0c26bb2 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2433,11 +2433,6 @@ static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
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

