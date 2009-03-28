From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 21/47] nfsd41: nfsd DRC logic
Date: Sat, 28 Mar 2009 11:32:44 +0300
Message-ID: <1238229164-10922-1-git-send-email-bhalevy@panasas.com>
References: <49CDDFC2.4070402@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:19614 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755432AbZC1Icx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 04:32:53 -0400
In-Reply-To: <49CDDFC2.4070402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replay a request in nfsd4_sequence.
Add a minorversion to struct nfsd4_compound_state.

Pass the current slot to nfs4svc_encode_compound res via struct
nfsd4_compoundres to set an NFSv4.1 DRC entry.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: use bool inuse for slot state]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c        |    7 +++++++
 fs/nfsd/nfs4state.c       |    6 ++++++
 fs/nfsd/nfs4xdr.c         |   13 +++++++++++++
 include/linux/nfsd/xdr4.h |    1 +
 4 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e703ac2..bdbeb87 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -920,6 +920,12 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 			BUG_ON(op->status == nfs_ok);
 
 encode_op:
+		/* Only from SEQUENCE or CREATE_SESSION */
+		if (resp->cstate.status == nfserr_replay_cache) {
+			dprintk("%s NFS4.1 replay from cache\n", __func__);
+			status = op->status;
+			goto out;
+		}
 		if (op->status == nfserr_replay_me) {
 			op->replay = &cstate->replay_owner->so_replay;
 			nfsd4_encode_replay(resp, op);
@@ -948,6 +954,7 @@ encode_op:
 		status = nfserr_jukebox;
 	}
 
+	resp->cstate.status = status;
 	fh_put(&resp->cstate.current_fh);
 	fh_put(&resp->cstate.save_fh);
 	BUG_ON(resp->cstate.replay_owner);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f0ce639..07c869d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -997,6 +997,8 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp)
 	}
 
 	resp->rqstp->rq_resused = entry->ce_resused;
+	resp->opcnt = entry->ce_opcnt;
+	resp->cstate.iovlen = entry->ce_datav.iov_len + entry->ce_rpchdrlen;
 	status = entry->ce_status;
 
 	return status;
@@ -1217,6 +1219,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	status = check_slot_seqid(seq->seqid, slot);
 	if (status == nfserr_replay_cache) {
 		cstate->slot = slot;
+		/* Return the cached reply status and set cstate->status
+		 * for nfsd4_svc_encode_compoundres processing*/
+		status = nfsd4_replay_cache_entry(resp);
+		cstate->status = nfserr_replay_cache;
 		goto replay_cache;
 	}
 	if (status)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c6b490e..57afb33 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3059,6 +3059,19 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 		iov = &rqstp->rq_res.head[0];
 	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
 	BUG_ON(iov->iov_len > PAGE_SIZE);
+#ifdef CONFIG_NFSD_V4_1
+	if (resp->cstate.slot != NULL) {
+		if (resp->cstate.status == nfserr_replay_cache) {
+			iov->iov_len = resp->cstate.iovlen;
+		} else {
+			nfsd4_set_cache_entry(resp);
+			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
+			resp->cstate.slot->sl_inuse = 0;
+		}
+		if (resp->cstate.slot->sl_session)
+			nfsd4_put_session(resp->cstate.slot->sl_session);
+	}
+#endif /* CONFIG_NFSD_V4_1 */
 	return 1;
 }
 
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index cde8947..5c0d376 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -51,6 +51,7 @@ struct nfsd4_compound_state {
 	/* For sessions DRC */
 	struct nfsd4_slot	*slot;
 	__be32			*statp;
+	size_t			iovlen;
 	u32			status;
 };
 
-- 
1.6.2.1

