Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62805 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932703Ab1ERCN0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 May 2011 22:13:26 -0400
Message-ID: <4DD32BCF.8020905@cn.fujitsu.com>
Date: Wed, 18 May 2011 10:15:43 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsd41: check the size of request
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This patch just check request's size when it consists SEQUENCE.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4state.c |   33 +++++++++++++++++++++++++++++++++
 1 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4cf04e1..de4e6d4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1725,6 +1725,38 @@ static void nfsd4_sequence_check_conn(struct nfsd4_conn *new, struct nfsd4_sessi
 	return;
 }
 
+static int nfsd4_check_request_size(struct nfsd4_compoundargs *args,
+				    struct nfsd4_compound_state *cstate)
+{
+	int status = 0;
+	struct xdr_buf *xb = &args->rqstp->rq_arg;
+	struct nfsd4_session *session = NULL;
+	u32 length, tlen = 0, pad = 8;
+
+	if (!nfsd4_has_session(cstate))
+		return status;
+
+	session = cstate->session;
+	if (session == NULL)
+		return status;
+
+	if (xb->page_len == 0) {
+		length = (char *)args->p - (char *)xb->head[0].iov_base + pad;
+	} else {
+		if (xb->tail[0].iov_base && xb->tail[0].iov_len > 0)
+			tlen = (char *)args->p - (char *)xb->tail[0].iov_base;
+
+		 length = xb->head[0].iov_len + xb->page_len + tlen + pad;
+	}
+	dprintk("%s length %u, xb->page_len %u tlen %u pad %u\n", __func__,
+		length, xb->page_len, tlen, pad);
+
+	if (length > session->se_fchannel.maxreq_sz)
+		return nfserr_req_too_big;
+
+	return status;
+}
+
 __be32
 nfsd4_sequence(struct svc_rqst *rqstp,
 	       struct nfsd4_compound_state *cstate,
@@ -1789,6 +1821,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	cstate->slot = slot;
 	cstate->session = session;
 
+	status = nfsd4_check_request_size(rqstp->rq_argp, cstate);
 out:
 	/* Hold a session reference until done processing the compound. */
 	if (cstate->session) {
-- 
1.7.4.5


