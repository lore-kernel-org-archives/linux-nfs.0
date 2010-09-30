Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49149 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932225Ab0I3QTp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 12:19:45 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 15/16] nfsd4: add new connections to session
Date: Thu, 30 Sep 2010 12:19:12 -0400
Message-Id: <1285863553-8945-16-git-send-email-bfields@redhat.com>
In-Reply-To: <1285863553-8945-1-git-send-email-bfields@redhat.com>
References: <1285863553-8945-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

As long as we're not implementing any session security, we should just
automatically add any new connections that come along to the list of
sessions associated with the session.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 47 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3b4d74c..596702e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -658,13 +658,18 @@ static struct nfsd4_conn *alloc_conn(struct svc_rqst *rqstp)
 	return conn;
 }
 
+static void __nfsd4_hash_conn(struct nfsd4_conn *conn, struct nfsd4_session *ses)
+{
+	conn->cn_session = ses;
+	list_add(&conn->cn_persession, &ses->se_conns);
+}
+
 static void nfsd4_hash_conn(struct nfsd4_conn *conn, struct nfsd4_session *ses)
 {
 	struct nfs4_client *clp = ses->se_client;
 
 	spin_lock(&clp->cl_lock);
-	conn->cn_session = ses;
-	list_add(&conn->cn_persession, &ses->se_conns);
+	__nfsd4_hash_conn(conn, ses);
 	spin_unlock(&clp->cl_lock);
 }
 
@@ -1612,6 +1617,44 @@ out:
 	return status;
 }
 
+static struct nfsd4_conn *__nfsd4_find_conn(struct svc_rqst *r, struct nfsd4_session *s)
+{
+	struct nfsd4_conn *c;
+
+	list_for_each_entry(c, &s->se_conns, cn_persession) {
+		if (c->cn_xprt == r->rq_xprt) {
+			return c;
+		}
+	}
+	return NULL;
+}
+
+static void nfsd4_sequence_check_conn(struct svc_rqst *rqstp, struct nfsd4_session *ses)
+{
+	struct nfs4_client *clp = ses->se_client;
+	struct nfsd4_conn *c, *new = NULL;
+
+	spin_lock(&clp->cl_lock);
+	c = __nfsd4_find_conn(rqstp, ses);
+	spin_unlock(&clp->cl_lock);
+	if (c)
+		return;
+
+	new = alloc_conn(rqstp);
+
+	spin_lock(&clp->cl_lock);
+	c = __nfsd4_find_conn(rqstp, ses);
+	if (c) {
+		spin_unlock(&clp->cl_lock);
+		free_conn(new);
+		return;
+	}
+	__nfsd4_hash_conn(new, ses);
+	spin_unlock(&clp->cl_lock);
+	nfsd4_register_conn(new);
+	return;
+}
+
 __be32
 nfsd4_sequence(struct svc_rqst *rqstp,
 	       struct nfsd4_compound_state *cstate,
@@ -1656,6 +1699,8 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	if (status)
 		goto out;
 
+	nfsd4_sequence_check_conn(rqstp, session);
+
 	/* Success! bump slot seqid */
 	slot->sl_inuse = true;
 	slot->sl_seqid = seq->seqid;
-- 
1.7.0.4

