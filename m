Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57684 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751048Ab0JUQUc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 12:20:32 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 02/11] nfsd4: move callback setup into session init code
Date: Thu, 21 Oct 2010 12:20:09 -0400
Message-Id: <1287678018-9266-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1287678018-9266-1-git-send-email-bfields@redhat.com>
References: <1287678018-9266-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

The backchannel should  be associated with a session, it isn't really
global to the client.

We do, however, want a pointer global to the client which tracks which
session we're currently using for client-based callbacks.

This is a first step in that direction; for now, just reshuffling of
code with no significant change in behavior.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |   29 ++++++++++++++---------------
 fs/nfsd/state.h     |    1 +
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7f12828..db5d8c8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -771,6 +771,19 @@ static __be32 alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp
 		free_session(&new->se_ref);
 		return nfserr_jukebox;
 	}
+	if (!clp->cl_cb_session && (cses->flags & SESSION4_BACK_CHAN)) {
+		struct sockaddr *sa = svc_addr(rqstp);
+
+		clp->cl_cb_session = new;
+		clp->cl_cb_conn.cb_xprt = rqstp->rq_xprt;
+		svc_xprt_get(rqstp->rq_xprt);
+		rpc_copy_addr((struct sockaddr *)&clp->cl_cb_conn.cb_addr, sa);
+		clp->cl_cb_conn.cb_addrlen = svc_addr_len(sa);
+		clp->cl_cb_conn.cb_minorversion = 1;
+		clp->cl_cb_conn.cb_prog = cses->callback_prog;
+		clp->cl_cb_seq_nr = 1;
+		nfsd4_probe_callback(clp, &clp->cl_cb_conn);
+	}
 	return nfs_ok;
 }
 
@@ -1045,7 +1058,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 	clp->cl_flavor = rqstp->rq_flavor;
 	copy_cred(&clp->cl_cred, &rqstp->rq_cred);
 	gen_confirm(clp);
-
+	clp->cl_cb_session = NULL;
 	return clp;
 }
 
@@ -1515,20 +1528,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 		cs_slot->sl_seqid++; /* from 0 to 1 */
 		move_to_confirmed(unconf);
-
-		if (cr_ses->flags & SESSION4_BACK_CHAN) {
-			unconf->cl_cb_conn.cb_xprt = rqstp->rq_xprt;
-			svc_xprt_get(rqstp->rq_xprt);
-			rpc_copy_addr(
-				(struct sockaddr *)&unconf->cl_cb_conn.cb_addr,
-				sa);
-			unconf->cl_cb_conn.cb_addrlen = svc_addr_len(sa);
-			unconf->cl_cb_conn.cb_minorversion =
-				cstate->minorversion;
-			unconf->cl_cb_conn.cb_prog = cr_ses->callback_prog;
-			unconf->cl_cb_seq_nr = 1;
-			nfsd4_probe_callback(unconf, &unconf->cl_cb_conn);
-		}
 		conf = unconf;
 	} else {
 		status = nfserr_stale_clientid;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 8d5e237..6e63c1d 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -234,6 +234,7 @@ struct nfs4_client {
 	u32			cl_cb_ident;
 	atomic_t		cl_cb_set;
 	struct nfsd4_callback	cl_cb_null;
+	struct nfsd4_session	*cl_cb_session;
 
 	/* for all client information that callback code might need: */
 	spinlock_t		cl_lock;
-- 
1.7.1

