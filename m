From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 12/35] nfsd41: sequence operation
Date: Fri,  3 Apr 2009 08:28:08 +0300
Message-ID: <1238736488-17452-1-git-send-email-bhalevy@panasas.com>
References: <49D599EA.6060705@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:23380 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754755AbZDCF2N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:28:13 -0400
In-Reply-To: <49D599EA.6060705@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implement the sequence operation conforming to
http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26

Check for stale clientid (as derived from the sessionid).
Enforce slotid range and exactly-once semantics using
the slotid and seqid.

If everything went well renew the client lease and
mark the slot INPROGRESS.

Add a struct nfsd4_slot pointer to struct nfsd4_compound_state.
To be used for sessions DRC replay.

[nfsd41: rename sequence catchthis to cachethis]
Signed-off-by: Andy Adamson<andros@netapp.com>
[pulled some code to set cstate->slot from "nfsd DRC logic"]
[use sessionid_lock spin lock]
[nfsd41: use bool inuse for slot state]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd: add a struct nfsd4_slot pointer to struct nfsd4_compound_state]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: add nfsd4_session pointer to nfsd4_compound_state]
[nfsd41: set cstate session]
[nfsd41: use cstate session in nfsd4_sequence]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[simplify nfsd4_encode_sequence error handling]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c       |   73 +++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/nfs4xdr.c         |   33 ++++++++++++++++++--
 include/linux/nfsd/xdr4.h |   13 +++++++-
 3 files changed, 113 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index dfc6d94..24b6e05 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1000,6 +1000,32 @@ error:
 	return status;
 }
 
+static int
+check_slot_seqid(u32 seqid, struct nfsd4_slot *slot)
+{
+	dprintk("%s enter. seqid %d slot->sl_seqid %d\n", __func__, seqid,
+		slot->sl_seqid);
+
+	/* The slot is in use, and no response has been sent. */
+	if (slot->sl_inuse) {
+		if (seqid == slot->sl_seqid)
+			return nfserr_jukebox;
+		else
+			return nfserr_seq_misordered;
+	}
+	/* Normal */
+	if (likely(seqid == slot->sl_seqid + 1))
+		return nfs_ok;
+	/* Replay */
+	if (seqid == slot->sl_seqid)
+		return nfserr_replay_cache;
+	/* Wraparound */
+	if (seqid == 1 && (slot->sl_seqid + 1) == 0)
+		return nfs_ok;
+	/* Misordered replay or misordered new request */
+	return nfserr_seq_misordered;
+}
+
 __be32
 nfsd4_create_session(struct svc_rqst *rqstp,
 		     struct nfsd4_compound_state *cstate,
@@ -1017,11 +1043,54 @@ nfsd4_destroy_session(struct svc_rqst *r,
 }
 
 __be32
-nfsd4_sequence(struct svc_rqst *r,
+nfsd4_sequence(struct svc_rqst *rqstp,
 	       struct nfsd4_compound_state *cstate,
 	       struct nfsd4_sequence *seq)
 {
-	return -1;	/* stub */
+	struct nfsd4_session *session;
+	struct nfsd4_slot *slot;
+	int status;
+
+	spin_lock(&sessionid_lock);
+	status = nfserr_badsession;
+	session = find_in_sessionid_hashtbl(&seq->sessionid);
+	if (!session)
+		goto out;
+
+	status = nfserr_badslot;
+	if (seq->slotid >= session->se_fnumslots)
+		goto out;
+
+	slot = &session->se_slots[seq->slotid];
+	dprintk("%s: slotid %d\n", __func__, seq->slotid);
+
+	status = check_slot_seqid(seq->seqid, slot);
+	if (status == nfserr_replay_cache) {
+		cstate->slot = slot;
+		cstate->session = session;
+		goto replay_cache;
+	}
+	if (status)
+		goto out;
+
+	/* Success! bump slot seqid */
+	slot->sl_inuse = true;
+	slot->sl_seqid = seq->seqid;
+
+	cstate->slot = slot;
+	cstate->session = session;
+
+replay_cache:
+	/* Renew the clientid on success and on replay.
+	 * Hold a session reference until done processing the compound:
+	 * nfsd4_put_session called only if the cstate slot is set.
+	 */
+	renew_client(session->se_client);
+	nfsd4_get_session(session);
+out:
+	spin_unlock(&sessionid_lock);
+	dprintk("%s: return %d\n", __func__, ntohl(status));
+	return status;
 }
 
 __be32
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index bebf6d2..8556575 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1113,7 +1113,16 @@ static __be32
 nfsd4_decode_sequence(struct nfsd4_compoundargs *argp,
 		      struct nfsd4_sequence *seq)
 {
-	return nfserr_opnotsupp;	/* stub */
+	DECODE_HEAD;
+
+	READ_BUF(NFS4_MAX_SESSIONID_LEN + 16);
+	COPYMEM(seq->sessionid.data, NFS4_MAX_SESSIONID_LEN);
+	READ32(seq->seqid);
+	READ32(seq->slotid);
+	READ32(seq->maxslots);
+	READ32(seq->cachethis);
+
+	DECODE_TAIL;
 }
 
 static __be32
@@ -2828,8 +2837,26 @@ static __be32
 nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 		      struct nfsd4_sequence *seq)
 {
-	/* stub */
-	return nfserr;
+	ENCODE_HEAD;
+
+	if (nfserr)
+		return nfserr;
+
+	RESERVE_SPACE(NFS4_MAX_SESSIONID_LEN + 20);
+	WRITEMEM(seq->sessionid.data, NFS4_MAX_SESSIONID_LEN);
+	WRITE32(seq->seqid);
+	WRITE32(seq->slotid);
+	WRITE32(seq->maxslots);
+	/*
+	 * FIXME: for now:
+	 *   target_maxslots = maxslots
+	 *   status_flags = 0
+	 */
+	WRITE32(seq->maxslots);
+	WRITE32(0);
+
+	ADJUST_ARGS();
+	return 0;
 }
 
 static __be32
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 33ee71e..6e28a04 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -48,6 +48,9 @@ struct nfsd4_compound_state {
 	struct svc_fh		current_fh;
 	struct svc_fh		save_fh;
 	struct nfs4_stateowner	*replay_owner;
+	/* For sessions DRC */
+	struct nfsd4_session	*session;
+	struct nfsd4_slot	*slot;
 };
 
 struct nfsd4_change_info {
@@ -358,7 +361,15 @@ struct nfsd4_create_session {
 };
 
 struct nfsd4_sequence {
-	int	foo;	/* stub */
+	struct nfs4_sessionid	sessionid;		/* request/response */
+	u32			seqid;			/* request/response */
+	u32			slotid;			/* request/response */
+	u32			maxslots;		/* request/response */
+	u32			cachethis;		/* request */
+#if 0
+	u32			target_maxslots;	/* response */
+	u32			status_flags;		/* response */
+#endif /* not yet */
 };
 
 struct nfsd4_destroy_session {
-- 
1.6.2.1

