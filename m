Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57690 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750932Ab0JUQUf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 12:20:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 05/11] nfsd4: confirm only on succesful create_session
Date: Thu, 21 Oct 2010 12:20:12 -0400
Message-Id: <1287678018-9266-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1287678018-9266-1-git-send-email-bfields@redhat.com>
References: <1287678018-9266-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Following rfc 5661, section 18.36.4: "If the session is not successfully
created, then no changes are made to any client records on the server."
We shouldn't be confirming or incrementing the sequence id in this case.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6367c44..7e817d1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1487,6 +1487,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	struct nfs4_client *conf, *unconf;
 	struct nfsd4_session *new;
 	struct nfsd4_clid_slot *cs_slot = NULL;
+	bool confirm_me = false;
 	int status = 0;
 
 	nfs4_lock_state();
@@ -1509,7 +1510,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 				cs_slot->sl_seqid, cr_ses->seqid);
 			goto out;
 		}
-		cs_slot->sl_seqid++;
 	} else if (unconf) {
 		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
 		    !rpc_cmp_addr(sa, (struct sockaddr *) &unconf->cl_addr)) {
@@ -1525,8 +1525,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			goto out;
 		}
 
-		cs_slot->sl_seqid++; /* from 0 to 1 */
-		move_to_confirmed(unconf);
+		confirm_me = true;
 		conf = unconf;
 	} else {
 		status = nfserr_stale_clientid;
@@ -1546,10 +1545,13 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	status = nfs_ok;
 	memcpy(cr_ses->sessionid.data, new->se_sessionid.data,
 	       NFS4_MAX_SESSIONID_LEN);
+	cs_slot->sl_seqid++;
 	cr_ses->seqid = cs_slot->sl_seqid;
 
 	/* cache solo and embedded create sessions under the state lock */
 	nfsd4_cache_create_session(cr_ses, cs_slot, status);
+	if (confirm_me)
+		move_to_confirmed(conf);
 out:
 	nfs4_unlock_state();
 	dprintk("%s returns %d\n", __func__, ntohl(status));
-- 
1.7.1

