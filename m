From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/1 v2] nfs41: pass state recovery error back to caller
Date: Wed,  2 Sep 2009 10:48:45 +0300
Message-ID: <1251877725-12113-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-67.z220-152-67.customer.algx.net ([67.152.220.67]:52020
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751774AbZIBHsp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 03:48:45 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently the error returned from create_session
is ignored by nfs4_check_client_ready and mis-translated to
-EPROTONOSUPPORT if the client has a session.
Record the error returned from create_session to the state manager
in cl_cons_state via nfs_mark_client_ready and pass it upstream
in nfs4_recover_expired_lease.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---

This version of the patch is based on top of
commit a78cb57a106fceeba26da2907db9d8886700e1dc
NFSv4: Don't loop forever on state recovery failure...
that's queued for 2.6.32

Benny

 fs/nfs/client.c    |   10 +++-------
 fs/nfs/nfs4proc.c  |    6 ++++++
 fs/nfs/nfs4state.c |    2 ++
 3 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d36925f..79c3ee3 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -149,6 +149,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	clp->cl_boot_time = CURRENT_TIME;
 	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
 	clp->cl_minorversion = cl_init->minorversion;
+	clp->cl_lease_time = 0;
 #endif
 	cred = rpc_lookup_machine_cred();
 	if (!IS_ERR(cred))
@@ -535,16 +536,11 @@ void nfs_mark_client_ready(struct nfs_client *clp, int state)
 /*
  * With sessions, the client is not marked ready until after a
  * successful EXCHANGE_ID and CREATE_SESSION.
- *
- * Map errors cl_cons_state errors to EPROTONOSUPPORT to indicate
- * other versions of NFS can be tried.
  */
 int nfs4_check_client_ready(struct nfs_client *clp)
 {
-	if (!nfs4_has_session(clp))
-		return 0;
-	if (clp->cl_cons_state < NFS_CS_READY)
-		return -EPROTONOSUPPORT;
+	if (clp->cl_cons_state < 0)
+		return clp->cl_cons_state;
 	return 0;
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index be6544a..09f709a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1458,6 +1458,12 @@ static int nfs4_recover_expired_lease(struct nfs_server *server)
 		if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) &&
 		    !test_bit(NFS4CLNT_CHECK_LEASE,&clp->cl_state))
 			break;
+		if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) &&
+		    clp->cl_lease_time) {
+			/* fetch the lease reclaim error */
+			ret = (int)clp->cl_lease_time;
+			break;
+		}
 		nfs4_schedule_state_recovery(clp);
 		ret = -EIO;
 	}
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 65ca8c1..b5c71dc 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1220,6 +1220,7 @@ static void nfs4_set_lease_expired(struct nfs_client *clp, int status)
 			return;
 		}
 	}
+	clp->cl_lease_time = status;
 	set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 }
 
@@ -1231,6 +1232,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 	for(;;) {
 		if (test_and_clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state)) {
 			/* We're going to have to re-establish a clientid */
+			clp->cl_lease_time = 0;
 			status = nfs4_reclaim_lease(clp);
 			if (status) {
 				nfs4_set_lease_expired(clp, status);
-- 
1.6.4

