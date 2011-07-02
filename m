Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52790 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752661Ab1GBI7m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 2 Jul 2011 04:59:42 -0400
Message-ID: <4E0EDEBE.8040902@cn.fujitsu.com>
Date: Sat, 02 Jul 2011 17:02:54 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2 v2] nfsd41: check the size of request
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This patch just check request's size when it consists SEQUENCE.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4state.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e98f3c2..17e30bf 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1736,6 +1736,21 @@ static bool nfsd4_session_too_many_ops(struct svc_rqst *rqstp, struct nfsd4_sess
 	return args->opcnt > session->se_fchannel.maxops;
 }
 
+static int nfsd4_check_request_size(struct nfsd4_compoundargs *args,
+				    struct nfsd4_session *session)
+{
+	struct xdr_buf *xb = &args->rqstp->rq_arg;
+
+	/* Only SEQUENCE operation */
+	if (args->opcnt == 1)
+		return 0;
+
+	if (xb->len > session->se_fchannel.maxreq_sz)
+		return nfserr_req_too_big;
+
+	return 0;
+}
+
 __be32
 nfsd4_sequence(struct svc_rqst *rqstp,
 	       struct nfsd4_compound_state *cstate,
@@ -1804,6 +1819,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	cstate->slot = slot;
 	cstate->session = session;
 
+	status = nfsd4_check_request_size(rqstp->rq_argp, session);
 out:
 	/* Hold a session reference until done processing the compound. */
 	if (cstate->session) {
-- 
1.7.5.4



