From: andros@netapp.com
Subject: [PATCH 2/2] nfs41: fix race on session reset
Date: Wed, 21 Oct 2009 14:24:52 -0400
Message-ID: <1256149492-25481-3-git-send-email-andros@netapp.com>
References: <1256149492-25481-1-git-send-email-andros@netapp.com>
 <1256149492-25481-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6584 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754353AbZJUSYu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Oct 2009 14:24:50 -0400
In-Reply-To: <1256149492-25481-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Do not clear the NFS4CLNT_SESSION_SETUP bit until after the session has been
reset (a possible EXCHANGE_ID, a DESTROY_SESSION, and a CREATE_SESSION) to
prevent a race with nfs41_setup_sequence assigning a slot on a
partially reset session.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c  |    3 +++
 fs/nfs/nfs4state.c |   15 +++++++++------
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index eb245a1..80764e2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4788,6 +4788,9 @@ int nfs4_proc_create_session(struct nfs_client *clp, int reset)
 	if (status)
 		goto out;
 
+	/* Signal nfs41_setup_sequence that the session is ready for use */
+	clear_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
+
 	ptr = (unsigned *)&session->sess_id.data[0];
 	dprintk("%s client>seqid %d sessionid %u:%u:%u:%u\n", __func__,
 		clp->cl_seqid, ptr[0], ptr[1], ptr[2], ptr[3]);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 1394dfb..09ca30b 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1252,17 +1252,20 @@ static void nfs4_state_manager(struct nfs_client *clp)
 				continue;
 		}
 		/* Initialize or reset the session */
-		if (test_and_clear_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state)
-		   && nfs4_has_session(clp)) {
+		if (test_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state)
+		    && nfs4_has_session(clp)) {
 			if (clp->cl_cons_state == NFS_CS_SESSION_INITING)
 				status = nfs4_initialize_session(clp);
 			else
 				status = nfs4_reset_session(clp);
-			if (status) {
-				if (status == -NFS4ERR_STALE_CLIENTID)
-					continue;
+			if (status == -NFS4ERR_STALE_CLIENTID)
+				continue;
+			/* For error case. On success the bit is cleared in
+			 * nfs4_proc_create_session */
+			clear_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
+
+			if (status)
 				goto out_error;
-			}
 		}
 		/* First recover reboot state... */
 		if (test_and_clear_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)) {
-- 
1.6.2.5

