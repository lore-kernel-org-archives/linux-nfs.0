From: andros@netapp.com
Subject: [PATCH 04/30] nfsd41: encode create_session result into clid cache
Date: Mon,  8 Jun 2009 14:20:45 -0400
Message-ID: <1244485271-7461-5-git-send-email-andros@netapp.com>
References: <>
 <1244485271-7461-1-git-send-email-andros@netapp.com>
 <1244485271-7461-2-git-send-email-andros@netapp.com>
 <1244485271-7461-3-git-send-email-andros@netapp.com>
 <1244485271-7461-4-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39968 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752867AbZFHSVX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:21:23 -0400
In-Reply-To: <1244485271-7461-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

CREATE_SESSION can be preceeded by a SEQUENCE operation and the
create session single slot cache must be maintained. Save the results of
a create session call (struct nfsd4_create_session) into the cache at the end
of processing while still under the state lock.

If the CREATE_SESSION operation it is preceeded by a SEQUENCE operation it
will also be encoded into the session slot table cache.

Errors that do not change the create session cache:
A create session NFS4ERR_STALE_CLIENTID error means that a client record
(and associated create session slot) could not be found and therefore can't
be changed.  NFSERR_SEQ_MISORDERED errors do not change the slot cache.

All other errors get cached.

The old method of using nfsd4_store_cache_entry() for create sessions operations
will be removed in a following patch.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   22 +++++++++++++++++++++-
 1 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8bf1cfa..265379e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1334,6 +1334,20 @@ check_slot_seqid(u32 seqid, u32 slot_seqid, int slot_inuse)
 	return nfserr_seq_misordered;
 }
 
+/*
+ * Cache the create session result into the create session single DRC
+ * slot cache by saving the xdr structure. sl_seqid has been set.
+ * Do this for solo or embedded create session operations.
+ */
+static void
+nfsd4_cache_create_session(struct nfsd4_create_session *cr_ses,
+			   struct nfsd4_clid_slot *slot, int nfserr)
+{
+	slot->sl_status = nfserr;
+	memcpy(&slot->sl_cr_ses, cr_ses, sizeof(*cr_ses));
+}
+
+
 __be32
 nfsd4_create_session(struct svc_rqst *rqstp,
 		     struct nfsd4_compound_state *cstate,
@@ -1343,6 +1357,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfs4_client *conf, *unconf;
 	struct nfsd4_slot *slot = NULL;
+	struct nfsd4_clid_slot *cs_slot = NULL;
 	int status = 0;
 
 	nfs4_lock_state();
@@ -1371,6 +1386,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		conf->cl_slot.sl_seqid++;
 	} else if (unconf) {
 		slot = &unconf->cl_slot;
+		cs_slot = &unconf->cl_cs_slot;
 		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid,
 					  slot->sl_inuse);
 		if (status) {
@@ -1382,7 +1398,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
 		    (ip_addr != unconf->cl_addr)) {
 			status = nfserr_clid_inuse;
-			goto out;
+			goto out_cache;
 		}
 
 		slot->sl_seqid++; /* from 0 to 1 */
@@ -1412,6 +1428,10 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	cstate->slot = slot;
 	/* Ensure a page is used for the cache */
 	slot->sl_cache_entry.ce_cachethis = 1;
+
+out_cache:
+	/* cache solo and embedded create sessions under the state lock */
+	nfsd4_cache_create_session(cr_ses, cs_slot, status);
 out:
 	nfs4_unlock_state();
 	dprintk("%s returns %d\n", __func__, ntohl(status));
-- 
1.5.4.3

