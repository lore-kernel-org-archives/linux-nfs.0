Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39538 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495Ab0JYBGy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Oct 2010 21:06:54 -0400
Date: Sun, 24 Oct 2010 21:06:51 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: sessions patches
Message-ID: <20101025010651.GA11470@fieldses.org>
References: <1287678018-9266-1-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1287678018-9266-1-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Oct 21, 2010 at 12:20:07PM -0400, J. Bruce Fields wrote:
> The following patches fix bugs in and do some minor cleanup of the
> server 4.1 sessions code.  I'm thinking of submitting them for 2.6.37.

Also, one obvious screwup that I just noticed.

--b.

commit 3f87b9f3ea2517c79aa274fa56df7a17f8e29585
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Oct 21 17:17:31 2010 -0400

    nfsd4: fix connection allocation in sequence()
    
    We're doing an allocation under a spinlock, and ignoring the
    possibility of allocation failure.
    
    A better fix wouldn't require an unnecessary allocation in the common
    case, but we'll leave that for later.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ce0412f..d4aa1b5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1628,33 +1628,25 @@ out:
 	return status;
 }
 
-static struct nfsd4_conn *__nfsd4_find_conn(struct svc_rqst *r, struct nfsd4_session *s)
+static struct nfsd4_conn *__nfsd4_find_conn(struct svc_xprt *xpt, struct nfsd4_session *s)
 {
 	struct nfsd4_conn *c;
 
 	list_for_each_entry(c, &s->se_conns, cn_persession) {
-		if (c->cn_xprt == r->rq_xprt) {
+		if (c->cn_xprt == xpt) {
 			return c;
 		}
 	}
 	return NULL;
 }
 
-static void nfsd4_sequence_check_conn(struct svc_rqst *rqstp, struct nfsd4_session *ses)
+static void nfsd4_sequence_check_conn(struct nfsd4_conn *new, struct nfsd4_session *ses)
 {
 	struct nfs4_client *clp = ses->se_client;
-	struct nfsd4_conn *c, *new = NULL;
-
-	spin_lock(&clp->cl_lock);
-	c = __nfsd4_find_conn(rqstp, ses);
-	spin_unlock(&clp->cl_lock);
-	if (c)
-		return;
-
-	new = alloc_conn(rqstp, NFS4_CDFC4_FORE);
+	struct nfsd4_conn *c;
 
 	spin_lock(&clp->cl_lock);
-	c = __nfsd4_find_conn(rqstp, ses);
+	c = __nfsd4_find_conn(new->cn_xprt, ses);
 	if (c) {
 		spin_unlock(&clp->cl_lock);
 		free_conn(new);
@@ -1674,11 +1666,20 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfsd4_session *session;
 	struct nfsd4_slot *slot;
+	struct nfsd4_conn *conn;
 	int status;
 
 	if (resp->opcnt != 1)
 		return nfserr_sequence_pos;
 
+	/*
+	 * Will be either used or freed by nfsd4_sequence_check_conn
+	 * below.
+	 */
+	conn = alloc_conn(rqstp, NFS4_CDFC4_FORE);
+	if (!conn)
+		return nfserr_jukebox;
+
 	spin_lock(&client_lock);
 	status = nfserr_badsession;
 	session = find_in_sessionid_hashtbl(&seq->sessionid);
@@ -1710,7 +1711,8 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	if (status)
 		goto out;
 
-	nfsd4_sequence_check_conn(rqstp, session);
+	nfsd4_sequence_check_conn(conn, session);
+	conn = NULL;
 
 	/* Success! bump slot seqid */
 	slot->sl_inuse = true;
@@ -1726,6 +1728,7 @@ out:
 		nfsd4_get_session(cstate->session);
 		atomic_inc(&session->se_client->cl_refcount);
 	}
+	kfree(conn);
 	spin_unlock(&client_lock);
 	dprintk("%s: return %d\n", __func__, ntohl(status));
 	return status;
