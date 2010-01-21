From: andros@netapp.com
Subject: [PATCH 2/2] nfs41: clear NFS4CLNT_RECALL_SLOT bit on session reset
Date: Thu, 21 Jan 2010 14:19:17 -0500
Message-ID: <1264101557-6619-2-git-send-email-andros@netapp.com>
References: <1264101557-6619-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14143 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754815Ab0AUTTY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jan 2010 14:19:24 -0500
In-Reply-To: <1264101557-6619-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4state.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 069dcb3..c7f2944 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1291,9 +1291,12 @@ static int nfs4_reset_session(struct nfs_client *clp)
 
 	memset(clp->cl_session->sess_id.data, 0, NFS4_MAX_SESSIONID_LEN);
 	status = nfs4_proc_create_session(clp);
-	if (status)
+	if (status) {
 		status = nfs4_recovery_handle_error(clp, status);
-
+		goto out;
+	}
+	/* create_session negotiated new slot table */
+	clear_bit(NFS4CLNT_RECALL_SLOT, &clp->cl_state);
 out:
 	/*
 	 * Let the state manager reestablish state
-- 
1.6.6

