From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 02/32] NFSv4: Don't loop forever on state recovery
 failure...
Date: Wed, 19 Aug 2009 19:38:25 -0400
Message-ID: <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32245 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754132AbZHSXlB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:41:01 -0400
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNe90T028534
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:49 -0700 (PDT)
In-Reply-To: <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server is broken, then retrying forever won't fix it. We
should just give up after a while, and return an error to the user.
We set the number of retries to 10 for now...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6917311..d95f7f9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -61,6 +61,8 @@
 #define NFS4_POLL_RETRY_MIN	(HZ/10)
 #define NFS4_POLL_RETRY_MAX	(15*HZ)
 
+#define NFS4_MAX_LOOP_ON_RECOVER (10)
+
 struct nfs4_opendata;
 static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
@@ -426,17 +428,19 @@ out:
 static int nfs4_recover_session(struct nfs4_session *session)
 {
 	struct nfs_client *clp = session->clp;
+	unsigned int loop;
 	int ret;
 
-	for (;;) {
+	for (loop = NFS4_MAX_LOOP_ON_RECOVER; loop != 0; loop--) {
 		ret = nfs4_wait_clnt_recover(clp);
 		if (ret != 0)
-				return ret;
+			break;
 		if (!test_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state))
 			break;
 		nfs4_schedule_state_manager(clp);
+		ret = -EIO;
 	}
-	return 0;
+	return ret;
 }
 
 static int nfs41_setup_sequence(struct nfs4_session *session,
@@ -1444,18 +1448,20 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 static int nfs4_recover_expired_lease(struct nfs_server *server)
 {
 	struct nfs_client *clp = server->nfs_client;
+	unsigned int loop;
 	int ret;
 
-	for (;;) {
+	for (loop = NFS4_MAX_LOOP_ON_RECOVER; loop != 0; loop--) {
 		ret = nfs4_wait_clnt_recover(clp);
 		if (ret != 0)
-			return ret;
+			break;
 		if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) &&
 		    !test_bit(NFS4CLNT_CHECK_LEASE,&clp->cl_state))
 			break;
 		nfs4_schedule_state_recovery(clp);
+		ret = -EIO;
 	}
-	return 0;
+	return ret;
 }
 
 /*
-- 
1.6.0.4
