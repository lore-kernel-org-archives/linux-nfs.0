From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/3] SQUASHME: nfs41: get rid of READ64 in callback_xdr.c
Date: Wed, 17 Jun 2009 20:22:07 +0300
Message-ID: <1245259327-9403-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:14445
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754106AbZFQRWG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jun 2009 13:22:06 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This was only used later on by the pnfs code.

Fixes Trond's review comment from 2009-06-15:
Re: [pnfs] [RFC 31/39] nfs41: cb_sequence xdr implementation
http://linux-nfs.org/pipermail/pnfs/2009-June/007846.html

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_xdr.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 28242a0..e5a2dac 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -27,11 +27,6 @@
 
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
 
-#define READ64(x)         do {			\
-	(x) = (u64)ntohl(*p++) << 32;		\
-	(x) |= ntohl(*p++);			\
-} while (0)
-
 typedef __be32 (*callback_process_op_t)(void *, void *);
 typedef __be32 (*callback_decode_arg_t)(struct svc_rqst *, struct xdr_stream *, void *);
 typedef __be32 (*callback_encode_res_t)(struct svc_rqst *, struct xdr_stream *, void *);
-- 
1.6.3.1

