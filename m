Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59383 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753240Ab0LQTB4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Dec 2010 14:01:56 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/3] nfsd4: move guts of nfsd4_lookupp into helper
Date: Fri, 17 Dec 2010 14:01:50 -0500
Message-Id: <1292612511-14203-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1292612511-14203-1-git-send-email-bfields@redhat.com>
References: <1292612511-14203-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We'll reuse this code in secinfo_no_name.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index bad4bf8..095431a 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -604,9 +604,7 @@ nfsd4_link(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status;
 }
 
-static __be32
-nfsd4_lookupp(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	      void *arg)
+static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 {
 	struct svc_fh tmp_fh;
 	__be32 ret;
@@ -615,13 +613,19 @@ nfsd4_lookupp(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	ret = exp_pseudoroot(rqstp, &tmp_fh);
 	if (ret)
 		return ret;
-	if (tmp_fh.fh_dentry == cstate->current_fh.fh_dentry) {
+	if (tmp_fh.fh_dentry == fh->fh_dentry) {
 		fh_put(&tmp_fh);
 		return nfserr_noent;
 	}
 	fh_put(&tmp_fh);
-	return nfsd_lookup(rqstp, &cstate->current_fh,
-			   "..", 2, &cstate->current_fh);
+	return nfsd_lookup(rqstp, fh, "..", 2, fh);
+}
+
+static __be32
+nfsd4_lookupp(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+	      void *arg)
+{
+	return nfsd4_do_lookupp(rqstp, &cstate->current_fh);
 }
 
 static __be32
-- 
1.7.1

