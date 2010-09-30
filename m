Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49147 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932222Ab0I3QTp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 12:19:45 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 16/16] nfsd4: enforce DESTROY_SESSION connection requirement
Date: Thu, 30 Sep 2010 12:19:13 -0400
Message-Id: <1285863553-8945-17-git-send-email-bfields@redhat.com>
In-Reply-To: <1285863553-8945-1-git-send-email-bfields@redhat.com>
References: <1285863553-8945-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

This is the first MUST of the second paragraph of 18.37.3: a
destroy_session should arrive over a connection associated with the
session being destroyed.

XXX: The motivation for that must is somewhat unclear.  We may relax
this check eventually.  For now it at least gives a simple way to test
whether the connection list implementation is correct.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |   41 +++++++++++++++++++++++++++++------------
 1 files changed, 29 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 596702e..01fd1b7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1573,6 +1573,29 @@ static bool nfsd4_compound_in_session(struct nfsd4_session *session, struct nfs4
 	return !memcmp(sid, &session->se_sessionid, sizeof(*sid));
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
+static bool nfsd4_associated_connection(struct svc_rqst *r, struct nfsd4_session *s)
+{
+	struct nfs4_client *clp = s->se_client;
+	struct nfsd4_conn *c;
+
+	spin_lock(&clp->cl_lock);
+	c = __nfsd4_find_conn(r, s);
+	spin_unlock(&clp->cl_lock);
+	return c;
+}
+
 __be32
 nfsd4_destroy_session(struct svc_rqst *r,
 		      struct nfsd4_compound_state *cstate,
@@ -1600,6 +1623,12 @@ nfsd4_destroy_session(struct svc_rqst *r,
 		goto out;
 	}
 
+	if (!nfsd4_associated_connection(r, ses)) {
+		spin_unlock(&client_lock);
+		status = nfserr_conn_not_bound_to_session;
+		goto out;
+	}
+
 	unhash_session(ses);
 	spin_unlock(&client_lock);
 
@@ -1617,18 +1646,6 @@ out:
 	return status;
 }
 
-static struct nfsd4_conn *__nfsd4_find_conn(struct svc_rqst *r, struct nfsd4_session *s)
-{
-	struct nfsd4_conn *c;
-
-	list_for_each_entry(c, &s->se_conns, cn_persession) {
-		if (c->cn_xprt == r->rq_xprt) {
-			return c;
-		}
-	}
-	return NULL;
-}
-
 static void nfsd4_sequence_check_conn(struct svc_rqst *rqstp, struct nfsd4_session *ses)
 {
 	struct nfs4_client *clp = ses->se_client;
-- 
1.7.0.4

