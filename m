Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57692 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750932Ab0JUQUg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 12:20:36 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 06/11] nfsd4: track backchannel connections
Date: Thu, 21 Oct 2010 12:20:13 -0400
Message-Id: <1287678018-9266-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1287678018-9266-1-git-send-email-bfields@redhat.com>
References: <1287678018-9266-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

We need to keep track of which connections are available for use with
the backchannel, which for the forechannel, and which for both.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7e817d1..c470cb7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -644,7 +644,7 @@ static void nfsd4_conn_lost(struct svc_xpt_user *u)
 	spin_unlock(&clp->cl_lock);
 }
 
-static struct nfsd4_conn *alloc_conn(struct svc_rqst *rqstp)
+static struct nfsd4_conn *alloc_conn(struct svc_rqst *rqstp, u32 flags)
 {
 	struct nfsd4_conn *conn;
 
@@ -653,7 +653,7 @@ static struct nfsd4_conn *alloc_conn(struct svc_rqst *rqstp)
 		return NULL;
 	svc_xprt_get(rqstp->rq_xprt);
 	conn->cn_xprt = rqstp->rq_xprt;
-	conn->cn_flags = NFS4_CDFC4_FORE;
+	conn->cn_flags = flags;
 	INIT_LIST_HEAD(&conn->cn_xpt_user.list);
 	return conn;
 }
@@ -682,8 +682,11 @@ static void nfsd4_register_conn(struct nfsd4_conn *conn)
 static __be32 nfsd4_new_conn(struct svc_rqst *rqstp, struct nfsd4_session *ses)
 {
 	struct nfsd4_conn *conn;
+	u32 flags = NFS4_CDFC4_FORE;
 
-	conn = alloc_conn(rqstp);
+	if (ses->se_flags & SESSION4_BACK_CHAN)
+		flags |= NFS4_CDFC4_BACK;
+	conn = alloc_conn(rqstp, flags);
 	if (!conn)
 		return nfserr_jukebox;
 	nfsd4_hash_conn(conn, ses);
@@ -1640,7 +1643,7 @@ static void nfsd4_sequence_check_conn(struct svc_rqst *rqstp, struct nfsd4_sessi
 	if (c)
 		return;
 
-	new = alloc_conn(rqstp);
+	new = alloc_conn(rqstp, NFS4_CDFC4_FORE);
 
 	spin_lock(&clp->cl_lock);
 	c = __nfsd4_find_conn(rqstp, ses);
-- 
1.7.1

