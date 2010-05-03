From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 1/3] nfsd4: use local variable in nfs4svc_encode_compoundres
Date: Mon,  3 May 2010 19:31:33 +0300
Message-ID: <1272904293-27080-1-git-send-email-bhalevy@panasas.com>
References: <4BDEF641.4020507@panasas.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:21271 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758542Ab0ECQbh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 May 2010 12:31:37 -0400
In-Reply-To: <4BDEF641.4020507@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

'cs' is already computed, re-use it.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index b04583c..19ff5a3 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3311,9 +3311,9 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 		if (cs->status != nfserr_replay_cache) {
 			nfsd4_store_cache_entry(resp);
 			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
-			resp->cstate.slot->sl_inuse = false;
+			cs->slot->sl_inuse = false;
 		}
-		nfsd4_put_session(resp->cstate.session);
+		nfsd4_put_session(cs->session);
 	}
 	return 1;
 }
-- 
1.6.3.3

