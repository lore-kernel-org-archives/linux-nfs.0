From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 52/69] NFS: fix comment placement in nfs4xdr.c
Date: Tue, 23 Dec 2008 18:02:21 -0500
Message-ID: <20081223230221.13743.41565.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21081 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752762AbYLWXYl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:41 -0500
Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOclx006401
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:39 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4xdr.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)


diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 29656c5..273d001 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3790,6 +3790,10 @@ static int decode_delegreturn(struct xdr_stream *xdr)
 }
 
 /*
+ * END OF "GENERIC" DECODE ROUTINES.
+ */
+
+/*
  * Decode OPEN_DOWNGRADE response
  */
 static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp, __be32 *p, struct nfs_closeres *res)
@@ -3814,10 +3818,6 @@ out:
 }
 
 /*
- * END OF "GENERIC" DECODE ROUTINES.
- */
-
-/*
  * Decode ACCESS response
  */
 static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_accessres *res)

