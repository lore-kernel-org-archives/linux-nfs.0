From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 06/44] nfsd41: encode create_session result into cache
Date: Tue, 16 Jun 2009 04:19:29 +0300
Message-ID: <1245115169-6997-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2642
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753146AbZFPBT3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:19:29 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

CREATE_SESSION can be preceeded by a SEQUENCE operation and the
create session single slot cache must be maintained. Cache the create session
xdr struct at the end of processing.

The create session result will also be encoded into the RPC response, and if
it is preceeded by a SEQUENCE operation, will also be encoded into the
session slot table cache.

Errors that do not change the create session cache:
A create session NFS4ERR_STALE_CLIENTID error means that a client record
(and associated create session slot) could not be found and therefore can't
be changed.  NFSERR_SEQ_MISORDERED errors do not change the slot cache.

All other errors get cached.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: cache-struct-nfsd4_create_session]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f589952..bfc808b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1335,6 +1335,20 @@ check_slot_seqid(u32 seqid, u32 slot_seqid, int slot_inuse)
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
@@ -1367,7 +1381,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
 		    (ip_addr != unconf->cl_addr)) {
 			status = nfserr_clid_inuse;
-			goto out;
+			goto out_cache;
 		}
 
 		slot = &unconf->cl_slot;
@@ -1400,7 +1414,9 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	memcpy(cr_ses->sessionid.data, conf->cl_sessionid.data,
 	       NFS4_MAX_SESSIONID_LEN);
 	cr_ses->seqid = slot->sl_seqid;
-
+out_cache:
+	/* cache solo and embedded create sessions under the state lock */
+	nfsd4_cache_create_session(cr_ses, slot, status);
 out:
 	nfs4_unlock_state();
 	dprintk("%s returns %d\n", __func__, ntohl(status));
-- 
1.6.3

