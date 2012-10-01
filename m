Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43337 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751667Ab2JARq4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 13:46:56 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 8/8] nfsd4: remove redundant callback probe
Date: Mon,  1 Oct 2012 13:46:52 -0400
Message-Id: <1349113612-30374-9-git-send-email-bfields@redhat.com>
In-Reply-To: <1349113612-30374-1-git-send-email-bfields@redhat.com>
References: <1349113612-30374-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Both nfsd4_init_conn and alloc_init_session are probing the callback
channel, harmless but pointless.

Also, nfsd4_init_conn should probably be probing in the "unknown" case
as well.  In fact I don't see any harm to just doing it unconditionally
when we get a new backchannel connection.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 592cd7f..773b903 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -861,8 +861,7 @@ static void nfsd4_init_conn(struct svc_rqst *rqstp, struct nfsd4_conn *conn, str
 	if (ret)
 		/* oops; xprt is already down: */
 		nfsd4_conn_lost(&conn->cn_xpt_user);
-	if (ses->se_client->cl_cb_state == NFSD4_CB_DOWN &&
-			conn->cn_flags & NFS4_CDFC4_BACK) {
+	if (conn->cn_flags & NFS4_CDFC4_BACK) {
 		/* callback channel may be back up */
 		nfsd4_probe_callback(ses->se_client);
 	}
@@ -979,7 +978,6 @@ static struct nfsd4_session *init_session(struct svc_rqst *rqstp, struct nfsd4_s
 		rpc_copy_addr((struct sockaddr *)&clp->cl_cb_conn.cb_addr, sa);
 		clp->cl_cb_conn.cb_addrlen = svc_addr_len(sa);
 	}
-	nfsd4_probe_callback(clp);
 	return new;
 }
 
-- 
1.7.9.5

