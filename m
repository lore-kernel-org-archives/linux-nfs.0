Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49602 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751084Ab1GNGxl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jul 2011 02:53:41 -0400
Message-ID: <4E1E9302.4080504@cn.fujitsu.com>
Date: Thu, 14 Jul 2011 14:56:02 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2 v4] nfsd41: check the size of request
References: <4E0EDEBE.8040902@cn.fujitsu.com> <20110706164306.GC30349@fieldses.org> <4E16CA48.3030308@cn.fujitsu.com> <20110708200319.GC13886@fieldses.org> <4E17BACC.8030901@cn.fujitsu.com> <20110713002522.GJ2162@fieldses.org>
In-Reply-To: <20110713002522.GJ2162@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This patch checks request's size when it consists SEQUENCE.

v4:
   delete format fixing which length exceed 80

v3:
   remove the check about only SEQUENCE operation.
   check the size immediately after find session.
   modify some function's format which length exceed 80.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4state.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 72899ec..cc20587 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1763,6 +1763,14 @@ static bool nfsd4_session_too_many_ops(struct svc_rqst *rqstp, struct nfsd4_sess
 	return args->opcnt > session->se_fchannel.maxops;
 }
 
+static bool nfsd4_request_too_big(struct svc_rqst *rqstp,
+				  struct nfsd4_session *session)
+{
+	struct xdr_buf *xb = &rqstp->rq_arg;
+
+	return xb->len > session->se_fchannel.maxreq_sz;
+}
+
 __be32
 nfsd4_sequence(struct svc_rqst *rqstp,
 	       struct nfsd4_compound_state *cstate,
@@ -1795,6 +1803,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	if (nfsd4_session_too_many_ops(rqstp, session))
 		goto out;
 
+	status = nfserr_req_too_big;
+	if (nfsd4_request_too_big(rqstp, session))
+		goto out;
+
 	status = nfserr_badslot;
 	if (seq->slotid >= session->se_fchannel.maxreqs)
 		goto out;
-- 
1.7.5.4



