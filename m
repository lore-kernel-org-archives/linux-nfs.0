From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 1/1] nfs41: resolve some race conditions with queued SEQUENCE operations when unmounting
Date: Wed, 14 Oct 2009 15:57:09 -0700
Message-ID: <1255561029-2925-1-git-send-email-batsakis@netapp.com>
Cc: pnfs@linux-nfs.org, Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19906 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757228AbZJNU7H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2009 16:59:07 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/nfs4_fs.h   |    1 +
 fs/nfs/nfs4proc.c  |    3 +++
 fs/nfs/nfs4state.c |   11 ++++++++---
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 6ea07a3..554af98 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -45,6 +45,7 @@ enum nfs4_client_state {
 	NFS4CLNT_RECLAIM_NOGRACE,
 	NFS4CLNT_DELEGRETURN,
 	NFS4CLNT_SESSION_SETUP,
+	NFS4CLNT_SESSION_DESTROY,
 };
 
 /*
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c321002..9eb21d2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -359,6 +359,8 @@ static void nfs41_sequence_done(struct nfs_client *clp,
 	struct nfs4_slot_table *tbl;
 	struct nfs4_slot *slot;
 
+	if (!nfs4_has_session(clp))
+		goto out;
 	/*
 	 * sr_status remains 1 if an RPC level error occurred. The server
 	 * may or may not have processed the sequence operation..
@@ -4616,6 +4618,7 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
 
 void nfs4_destroy_session(struct nfs4_session *session)
 {
+	set_bit(NFS4CLNT_SESSION_DESTROY, &session->clp->cl_state);
 	nfs4_proc_destroy_session(session);
 	dprintk("%s Destroy backchannel for xprt %p\n",
 		__func__, session->clp->cl_rpcclient->cl_xprt);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 1394dfb..a509b26 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1253,11 +1253,16 @@ static void nfs4_state_manager(struct nfs_client *clp)
 		}
 		/* Initialize or reset the session */
 		if (test_and_clear_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state)
-		   && nfs4_has_session(clp)) {
+		    && nfs4_has_session(clp)) {
 			if (clp->cl_cons_state == NFS_CS_SESSION_INITING)
 				status = nfs4_initialize_session(clp);
-			else
-				status = nfs4_reset_session(clp);
+			else {
+				if (test_bit(NFS4CLNT_SESSION_DESTROY,
+					     &clp->cl_state))
+					status = -EIO;
+				else
+					status = nfs4_reset_session(clp);
+			}
 			if (status) {
 				if (status == -NFS4ERR_STALE_CLIENTID)
 					continue;
-- 
1.6.2.5

