From: andros@netapp.com
Subject: [PATCH 05/31] nfsd41: encode create_session result into cache
Date: Tue, 28 Apr 2009 12:59:39 -0400
Message-ID: <1240938005-23778-5-git-send-email-andros@netapp.com>
References: <1240938005-23778-1-git-send-email-andros@netapp.com>
 <1240938005-23778-2-git-send-email-andros@netapp.com>
 <1240938005-23778-3-git-send-email-andros@netapp.com>
 <1240938005-23778-4-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50785 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757221AbZD1RAM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:00:12 -0400
In-Reply-To: <1240938005-23778-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

CREATE_SESSION can be preceeded by a SEQUENCE operation and the
create session single slot cache must be maintained. Encode the results of
a create session call into the cache at the end of processing.

The create session result will also be encoded into the RPC response, and if
it is preceeded by a SEQUENCE operation, will also be encoded into the
session slot table cache.

Errors that do not change the create session cache:
A create session NFS4ERR_STALE_CLIENTID error means that a client record
(and associated create session slot) could not be found and therefore can't
be changed.  NFSERR_SEQ_MISORDERED errors do not change the slot cache.

All other errors get cached.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c       |    6 ++++--
 fs/nfsd/nfs4xdr.c         |   18 ++++++++++++++++++
 include/linux/nfsd/xdr4.h |    2 ++
 3 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fee6bf0..142c460 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1376,7 +1376,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
 		    (ip_addr != unconf->cl_addr)) {
 			status = nfserr_clid_inuse;
-			goto out;
+			goto out_cache;
 		}
 
 		slot = &unconf->cl_slot;
@@ -1418,7 +1418,9 @@ nfsd4_create_session(struct svc_rqst *rqstp,
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
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index b2f8d74..1dfec1d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3046,6 +3046,24 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, int nfserr,
 	return 0;
 }
 
+/*
+ * Encode the create_session result into the create session single DRC
+ * slot cache. Do this for solo or embedded create session operations.
+ */
+void
+nfsd4_cache_create_session(struct nfsd4_create_session *cr_ses,
+			   struct nfsd4_clid_slot *slot, int nfserr)
+{
+	__be32 *p = (__be32 *)slot->sl_data;
+	struct nfsd4_compoundres tmp = {
+		.p = p,
+		.end = p + XDR_QUADLEN(CS_MAX_ENC_SZ),
+	}, *resp = &tmp;
+
+	slot->sl_status = nfsd4_encode_create_session(resp, nfserr, cr_ses);
+	slot->sl_datalen = (char *)resp->p - (char *)p;
+}
+
 static __be32
 nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, int nfserr,
 			     struct nfsd4_destroy_session *destroy_session)
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index afd4464..21e0b73 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -517,6 +517,8 @@ extern __be32 nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 extern void nfsd4_store_cache_entry(struct nfsd4_compoundres *resp);
 extern __be32 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 		struct nfsd4_sequence *seq);
+extern void nfsd4_cache_create_session(struct nfsd4_create_session *cr_ses,
+		struct nfsd4_clid_slot *slot, int nfserr);
 extern __be32 nfsd4_exchange_id(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 struct nfsd4_exchange_id *);
-- 
1.5.4.3

