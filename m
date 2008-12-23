From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 33/69] NFSv4: Don't exit the state management if there are
 still tasks to do
Date: Tue, 23 Dec 2008 18:02:15 -0500
Message-ID: <20081223230215.13743.48055.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45954 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752278AbYLWXXq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:46 -0500
Received: from svlrsexc1-prd.hq.netapp.com ([10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNbse006182
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:41 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix up a potential race...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4state.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)


diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 83f3dd3..9e76712 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1112,7 +1112,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 	int status = 0;
 
 	/* Ensure exclusive access to NFSv4 state */
-	while (!list_empty(&clp->cl_superblocks)) {
+	for(;;) {
 		if (test_and_clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state)) {
 			/* We're going to have to re-establish a clientid */
 			status = nfs4_reclaim_lease(clp);
@@ -1161,7 +1161,11 @@ static void nfs4_state_manager(struct nfs_client *clp)
 		}
 
 		nfs4_clear_state_manager_bit(clp);
-		break;
+		/* Did we race with an attempt to give us more work? */
+		if (clp->cl_state == 0)
+			break;
+		if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) != 0)
+			break;
 	}
 	return;
 out_error:

