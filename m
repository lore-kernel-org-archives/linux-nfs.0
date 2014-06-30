Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:45843 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754328AbaF3PwS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:52:18 -0400
Received: by mail-qa0-f44.google.com with SMTP id hw13so6567223qab.17
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:52:17 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 074/114] nfsd: close potential race in nfsd4_free_stateid
Date: Mon, 30 Jun 2014 11:49:43 -0400
Message-Id: <1404143423-24381-75-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Once we remove the client_mutex, it'll be possible for the sc_type of a
lock stateid to change after it's found and checked, but before we can
go to destroy it. If that happens, we can end up putting the persistent
reference to the stateid more than once, and unhash it more than once.

Fix this by unhashing the lock stateid prior to dropping the cl_lock but
after finding it.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 24 +++++++++---------------
 1 file changed, 9 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e840d41fe2c9..0f56fb179e8a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4357,17 +4357,6 @@ unlock_state:
 	return status;
 }
 
-static __be32
-nfsd4_free_lock_stateid(struct nfs4_ol_stateid *stp)
-{
-	struct nfs4_lockowner *lo = lockowner(stp->st_stateowner);
-
-	if (check_for_locks(stp->st_stid.sc_file, lo))
-		return nfserr_locks_held;
-	release_lock_stateid(stp);
-	return nfs_ok;
-}
-
 /*
  * Test if the stateid is valid
  */
@@ -4394,6 +4383,7 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	stateid_t *stateid = &free_stateid->fr_stateid;
 	struct nfs4_stid *s;
 	struct nfs4_delegation *dp;
+	struct nfs4_ol_stateid *stp;
 	struct nfs4_client *cl = cstate->session->se_client;
 	__be32 ret = nfserr_bad_stateid;
 
@@ -4411,12 +4401,16 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		ret = check_stateid_generation(stateid, &s->sc_stateid, 1);
 		if (ret)
 			break;
-		if (s->sc_type != NFS4_LOCK_STID) {
-			ret = nfserr_locks_held;
+		stp = openlockstateid(s);
+		ret = nfserr_locks_held;
+		if (s->sc_type == NFS4_OPEN_STID ||
+		    check_for_locks(s->sc_file,
+				    lockowner(stp->st_stateowner)))
 			break;
-		}
+		unhash_lock_stateid(stp);
 		spin_unlock(&cl->cl_lock);
-		ret = nfsd4_free_lock_stateid(openlockstateid(s));
+		put_generic_stateid(stp);
+		ret = nfs_ok;
 		goto out;
 	case NFS4_REVOKED_DELEG_STID:
 		spin_unlock(&cl->cl_lock);
-- 
1.9.3

