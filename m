From: andros@netapp.com
Subject: [PATCH 2/2] nfs41: fix race on session reset
Date: Wed, 28 Oct 2009 10:37:29 -0400
Message-ID: <1256740649-4899-3-git-send-email-andros@netapp.com>
References: <1256740649-4899-1-git-send-email-andros@netapp.com>
 <1256740649-4899-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47940 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754141AbZJ1PBa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Oct 2009 11:01:30 -0400
In-Reply-To: <1256740649-4899-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Do not clear the NFS4CLNT_SESSION_SETUP bit until after the session and/or the
clientid has been established.

Clear the bit in nfs4_proc_create_session on a successful CREATE_SESSION to
make the new session available for the nfs4_get_lease_time call in the
session initialization case.

In the session reset case, this prevents a race with RPC's wating on the
slot_tbl_waitq where nfs41_setup_sequence would assign a slot on a partially
reset session.

Clear the bit on session init/reset failure other than NFS4ERR_STALE_CLIENTID
in the state manager.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c  |    3 +++
 fs/nfs/nfs4state.c |   10 ++++++++--
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3ec6406..0f1afde 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4782,6 +4782,9 @@ int nfs4_proc_create_session(struct nfs_client *clp, int reset)
 	if (status)
 		goto out;
 
+	/* Signal nfs41_setup_sequence that the session is ready for use */
+	clear_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
+
 	ptr = (unsigned *)&session->sess_id.data[0];
 	dprintk("%s client>seqid %d sessionid %u:%u:%u:%u\n", __func__,
 		clp->cl_seqid, ptr[0], ptr[1], ptr[2], ptr[3]);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 2ef4fec..50a1b04 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1249,8 +1249,12 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			if (status != 0)
 				continue;
 		}
-		/* Initialize or reset the session */
-		if (test_and_clear_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state)
+		/*
+		 * Initialize or reset the session. Wait to clear the bit
+		 * (in nfs4_proc_create_session) until session and /or
+		 * clientid is established.
+		 */
+		if (test_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state)
 		   && nfs4_has_session(clp)) {
 			if (clp->cl_cons_state == NFS_CS_SESSION_INITING)
 				status = nfs4_initialize_session(clp);
@@ -1259,6 +1263,8 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			if (status) {
 				if (status == -NFS4ERR_STALE_CLIENTID)
 					continue;
+				clear_bit(NFS4CLNT_SESSION_SETUP,
+					  &clp->cl_state);
 				goto out_error;
 			}
 		}
-- 
1.6.0.6

