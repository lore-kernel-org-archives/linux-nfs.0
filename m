Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10285 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755445Ab2KZUQ4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:16:56 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 03/28] NFSv4.1: Adjust CREATE_SESSION arguments when mounting a new filesystem
Date: Mon, 26 Nov 2012 15:16:20 -0500
Message-Id: <1353961005-63874-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353961005-63874-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1353961005-63874-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're mounting a new filesystem, ensure that the session has negotiated
large enough request and reply sizes to match the wsize and rsize mount
arguments.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3e572dc..ee82cdd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6037,9 +6037,22 @@ int nfs4_init_session(struct nfs_server *server)
 		session->fc_attrs.max_rqst_sz = target_max_rqst_sz;
 		session->fc_target_max_resp_sz = target_max_resp_sz;
 		session->fc_attrs.max_resp_sz = target_max_resp_sz;
+	} else {
+		/* Just adjust the targets */
+		if (target_max_rqst_sz > session->fc_target_max_rqst_sz) {
+			session->fc_target_max_rqst_sz = target_max_rqst_sz;
+			set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
+		}
+		if (target_max_resp_sz > session->fc_target_max_resp_sz) {
+			session->fc_target_max_resp_sz = target_max_resp_sz;
+			set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
+		}
 	}
 	spin_unlock(&clp->cl_lock);
 
+	if (test_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state))
+		nfs4_schedule_lease_recovery(clp);
+
 	return nfs41_check_session_ready(clp);
 }
 
-- 
1.7.11.7

