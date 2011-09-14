Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60182 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932133Ab1INLp2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 17/25] nfsd4: rename init_stateid
Date: Wed, 14 Sep 2011 07:45:13 -0400
Message-Id: <1316000721-3289-18-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Note this is actually open-stateid specific.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4813463..73b5e1e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2314,7 +2314,7 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 }
 
 static inline void
-init_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
+init_open_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
 	struct nfs4_openowner *oo = open->op_openowner;
 	unsigned int hashval = stateid_hashval(oo->oo_owner.so_id, fp->fi_id);
 
@@ -2934,7 +2934,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		status = nfs4_new_open(rqstp, &stp, fp, current_fh, open);
 		if (status)
 			goto out;
-		init_stateid(stp, fp, open);
+		init_open_stateid(stp, fp, open);
 		status = nfsd4_truncate(rqstp, current_fh, open);
 		if (status) {
 			release_open_stateid(stp);
-- 
1.7.4.1

