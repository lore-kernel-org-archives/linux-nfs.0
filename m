Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57694 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751048Ab0JUQUk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 12:20:40 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 07/11] nfsd4: callback program number is per-session
Date: Thu, 21 Oct 2010 12:20:14 -0400
Message-Id: <1287678018-9266-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1287678018-9266-1-git-send-email-bfields@redhat.com>
References: <1287678018-9266-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The callback program is allowed to depend on the session which the
callback is going over.

No change in behavior yet, while we still only do callbacks over a
single session for the lifetime of the client.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4callback.c |    1 +
 fs/nfsd/nfs4state.c    |    2 +-
 fs/nfsd/state.h        |    4 +++-
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 5df9dda..140bb36 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -498,6 +498,7 @@ int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *conn)
 		return -EINVAL;
 	if (conn->cb_minorversion) {
 		args.bc_xprt = conn->cb_xprt;
+		args.prognumber = clp->cl_cb_session->se_cb_prog;
 		args.protocol = XPRT_TRANSPORT_BC_TCP;
 	}
 	/* Create RPC client */
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c470cb7..59bc001 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -760,6 +760,7 @@ static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct n
 
 	new->se_cb_seq_nr = 1;
 	new->se_flags = cses->flags;
+	new->se_cb_prog = cses->callback_prog;
 	kref_init(&new->se_ref);
 	idx = hash_sessionid(&new->se_sessionid);
 	spin_lock(&client_lock);
@@ -782,7 +783,6 @@ static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct n
 		rpc_copy_addr((struct sockaddr *)&clp->cl_cb_conn.cb_addr, sa);
 		clp->cl_cb_conn.cb_addrlen = svc_addr_len(sa);
 		clp->cl_cb_conn.cb_minorversion = 1;
-		clp->cl_cb_conn.cb_prog = cses->callback_prog;
 		nfsd4_probe_callback(clp, &clp->cl_cb_conn);
 	}
 	return new;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 7f5b267..b3bed36 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -96,7 +96,8 @@ struct nfs4_cb_conn {
 	/* SETCLIENTID info */
 	struct sockaddr_storage	cb_addr;
 	size_t			cb_addrlen;
-	u32                     cb_prog;
+	u32                     cb_prog; /* used only in 4.0 case;
+					    per-session otherwise */
 	u32			cb_minorversion;
 	u32                     cb_ident;	/* minorversion 0 only */
 	struct svc_xprt		*cb_xprt;	/* minorversion 1 only */
@@ -172,6 +173,7 @@ struct nfsd4_session {
 	struct nfsd4_channel_attrs se_fchannel;
 	struct nfsd4_channel_attrs se_bchannel;
 	struct list_head	se_conns;
+	u32			se_cb_prog;
 	u32			se_cb_seq_nr;
 	struct nfsd4_slot	*se_slots[];	/* forward channel slots */
 };
-- 
1.7.1

