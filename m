From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 2/3] nfsd4: hold a reference on nfs4_client when it is used by a session
Date: Mon,  3 May 2010 19:31:48 +0300
Message-ID: <1272904308-27113-1-git-send-email-bhalevy@panasas.com>
References: <4BDEF641.4020507@panasas.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:58932 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758812Ab0ECQbv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 May 2010 12:31:51 -0400
In-Reply-To: <4BDEF641.4020507@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Although expire_client unhashes the session form the session table
so no new compounds can find it, there's no refcount to keep the
nfs4_client structure around while it's in use and referenced
in the compound state via the session structure.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |    2 +-
 fs/nfsd/nfs4state.c    |    4 +++-
 fs/nfsd/nfs4xdr.c      |    1 +
 fs/nfsd/state.h        |    6 ++++++
 4 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 7e32bd3..fef1dbe 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -571,7 +571,7 @@ nfsd4_probe_callback(struct nfs4_client *clp)
 	}
 
 	/* the task holds a reference to the nfs4_client struct */
-	atomic_inc(&clp->cl_count);
+	get_nfs4_client(clp);
 
 	do_probe_callback(clp);
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6dbcaf1..50b75af 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1458,8 +1458,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 
 out:
 	/* Hold a session reference until done processing the compound. */
-	if (cstate->session)
+	if (cstate->session) {
 		nfsd4_get_session(cstate->session);
+		get_nfs4_client(cstate->session->se_client);
+	}
 	spin_unlock(&sessionid_lock);
 	/* Renew the clientid on success and on replay */
 	if (cstate->session) {
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 19ff5a3..aed733c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3313,6 +3313,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
 			cs->slot->sl_inuse = false;
 		}
+		put_nfs4_client(cs->session->se_client);
 		nfsd4_put_session(cs->session);
 	}
 	return 1;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index fefeae2..e3c002e 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -231,6 +231,12 @@ struct nfs4_client {
 						/* wait here for slots */
 };
 
+static inline void
+get_nfs4_client(struct nfs4_client *clp)
+{
+	atomic_inc(&clp->cl_count);
+}
+
 /* struct nfs4_client_reset
  * one per old client. Populates reset_str_hashtbl. Filled from conf_id_hashtbl
  * upon lease reset, or from upcall to state_daemon (to read in state
-- 
1.6.3.3

