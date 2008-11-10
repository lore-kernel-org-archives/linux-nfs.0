From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 48/51] nfsd41: nfsd DRC logic
Date: Mon, 10 Nov 2008 22:57:11 +0200
Message-ID: <1226350631-11927-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:44369 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbYKJU5Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:57:24 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Pass the current session to nfs4svc_encode_compound res via struct
nfsd4_compoundres and replay or set an NFSv4.1 DRC entry.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c |   16 ++++------------
 fs/nfsd/nfs4xdr.c  |   26 ++++++++++++++++++++++++++
 2 files changed, 30 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 4a6ec7e..5a3a08d 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1095,18 +1095,10 @@ encode_op:
 	}
 
 #if defined(CONFIG_NFSD_V4_1)
-	if (cstate->current_ses) {
-		struct nfs41_slot *cs_slot = cstate->current_ses->cs_slot;
-		if (cs_slot) {
-			if (status != nfserr_dropit) {
-				dprintk("%s: SET SLOT STATE TO AVAILABLE\n",
-					__func__);
-				nfs41_set_slot_state(cs_slot,
-						     NFS4_SLOT_AVAILABLE);
-			}
-			nfs41_put_session(cs_slot->sl_session);
-		}
-		nfsd41_current_session_free(cstate->current_ses);
+	if (resp->minorversion == 1) {
+		/* Setup the compoundres nfs4svc_encode_compoundres */
+		resp->current_ses = cstate->current_ses;
+		resp->status = status;
 	}
 #endif /* CONFIG_NFSD_V4_1 */
 	nfsd4_cstate_free(cstate, rqstp->rq_deferred);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 04a9088..4b4f5fb 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3302,6 +3302,32 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 		iov = &rqstp->rq_res.head[0];
 	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
 	BUG_ON(iov->iov_len > PAGE_SIZE);
+#ifdef CONFIG_NFSD_V4_1
+	if (resp->minorversion == 1) {
+		/*
+		* Always have a current session.
+		* The cs_slot is not set on SEQUENCE error, EXCHANGE_ID,
+		* solo CREATE_SESSION, DESTROY_SESSION compounds.
+		*/
+		if (!resp->current_ses || !resp->current_ses->cs_slot) {
+			dprintk("%s NO CS_SLOT. current_ses %p\n", __func__,
+				resp->current_ses);
+			goto free_current_ses;
+		}
+
+		if (resp->status == nfserr_replay_cache)
+			nfsd41_replay_cache_entry(resp);
+		else
+			nfsd41_set_cache_entry(resp);
+
+		dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
+		nfs41_set_slot_state(resp->current_ses->cs_slot,
+				     NFS4_SLOT_AVAILABLE);
+		nfs41_put_session(resp->current_ses->cs_slot->sl_session);
+free_current_ses:
+		nfsd41_current_session_free(resp->current_ses);
+}
+#endif /* CONFIG_NFSD_V4_1 */
 	return 1;
 }
 
-- 
1.6.0.2

