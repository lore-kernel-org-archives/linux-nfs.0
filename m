Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10285 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755677Ab2KZUQz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:16:55 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 01/28] NFSv4.1: Handle session reset and bind_conn_to_session before lease check
Date: Mon, 26 Nov 2012 15:16:18 -0500
Message-Id: <1353961005-63874-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353961005-63874-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1353961005-63874-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We can't send a SEQUENCE op unless the session is OK, so it is pointless
to handle the CHECK_LEASE state before we've dealt with SESSION_RESET
and BIND_CONN_TO_SESSION.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4state.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e0a28df..f3d1bc4 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2114,15 +2114,6 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			continue;
 		}
 
-		if (test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
-			section = "check lease";
-			status = nfs4_check_lease(clp);
-			if (status < 0)
-				goto out_error;
-			if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
-				continue;
-		}
-
 		/* Initialize or reset the session */
 		if (test_and_clear_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state)) {
 			section = "reset session";
@@ -2143,6 +2134,14 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			continue;
 		}
 
+		if (test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
+			section = "check lease";
+			status = nfs4_check_lease(clp);
+			if (status < 0)
+				goto out_error;
+			continue;
+		}
+
 		/* Recall session slots */
 		if (test_and_clear_bit(NFS4CLNT_RECALL_SLOT, &clp->cl_state)) {
 			section = "recall slot";
-- 
1.7.11.7

