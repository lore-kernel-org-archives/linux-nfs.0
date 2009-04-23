From: andros@netapp.com
Subject: [PATCH 05/29] nfsd41: create_session cache hold client reference
Date: Thu, 23 Apr 2009 12:42:44 -0400
Message-ID: <1240504988-9572-6-git-send-email-andros@netapp.com>
References: <>
 <1240504988-9572-1-git-send-email-andros@netapp.com>
 <1240504988-9572-2-git-send-email-andros@netapp.com>
 <1240504988-9572-3-git-send-email-andros@netapp.com>
 <1240504988-9572-4-git-send-email-andros@netapp.com>
 <1240504988-9572-5-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51648 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754678AbZDWQnQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 12:43:16 -0400
In-Reply-To: <1240504988-9572-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

expire_client can be called on a confirmed or unconfirmed client while
processing the create session operation and accessing the clientid slot.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a585a58..accad58 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1355,6 +1355,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	conf = find_confirmed_client(&cr_ses->clientid);
 
 	if (conf) {
+		atomic_inc(&conf->cl_count);
 		slot = &conf->cl_slot;
 		status = check_slot_seqid(cr_ses->seqid, slot);
 		if (status == nfserr_replay_cache) {
@@ -1363,27 +1364,30 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			cstate->status = nfserr_replay_clientid_cache;
 			/* Return the cached reply status */
 			status = nfsd4_replay_create_session(resp, slot);
-			goto out;
+			goto out_put;
 		} else if (cr_ses->seqid != conf->cl_slot.sl_seqid + 1) {
 			status = nfserr_seq_misordered;
 			dprintk("Sequence misordered!\n");
 			dprintk("Expected seqid= %d but got seqid= %d\n",
 				slot->sl_seqid, cr_ses->seqid);
-			goto out;
+			goto out_put;
 		}
 		conf->cl_slot.sl_seqid++;
 	} else if (unconf) {
+		atomic_inc(&unconf->cl_count);
 		slot = &unconf->cl_slot;
 		status = check_slot_seqid(cr_ses->seqid, slot);
 		if (status) {
 			/* an unconfirmed replay returns misordered */
 			status = nfserr_seq_misordered;
-			goto out;
+			conf = unconf; /* for put_nfs4_client */
+			goto out_put;
 		}
 
 		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
 		    (ip_addr != unconf->cl_addr)) {
 			status = nfserr_clid_inuse;
+			conf = unconf; /* for put_nfs4_client */
 			goto out_cache;
 		}
 
@@ -1413,7 +1417,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 	status = alloc_init_session(rqstp, conf, cr_ses);
 	if (status)
-		goto out;
+		goto out_put;
 
 	memcpy(cr_ses->sessionid.data, conf->cl_sessionid.data,
 	       NFS4_MAX_SESSIONID_LEN);
@@ -1423,6 +1427,8 @@ out_cache:
 	/* cache solo and embedded create sessions under the state lock */
 	nfsd4_cache_create_session(cr_ses, slot, status);
 
+out_put:
+	put_nfs4_client(conf);
 out:
 	nfs4_unlock_state();
 	dprintk("%s returns %d\n", __func__, ntohl(status));
-- 
1.5.4.3

