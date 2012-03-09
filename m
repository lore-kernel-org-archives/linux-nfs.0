Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36575 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755107Ab2CIWOJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 17:14:09 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/3] nfsd4: delay setting current filehandle till success
Date: Fri,  9 Mar 2012 17:14:05 -0500
Message-Id: <1331331247-22343-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1331331247-22343-1-git-send-email-bfields@redhat.com>
References: <1331331247-22343-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Compound processing stops on error, so the current filehandle won't be
used on error.  Thus the order here doesn't really matter.  It'll be
more convenient to do it later, though.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index cdb7ca3..bdb71a5 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -247,16 +247,14 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
 	if (is_create_with_attrs(open) && open->op_acl != NULL)
 		do_set_nfs4_acl(rqstp, &resfh, open->op_acl, open->op_bmval);
 
-	set_change_info(&open->op_cinfo, current_fh);
-	fh_dup2(current_fh, &resfh);
-
 	/* set reply cache */
 	fh_copy_shallow(&open->op_openowner->oo_owner.so_replay.rp_openfh,
 			&resfh.fh_handle);
 	if (!open->op_created)
-		status = do_open_permission(rqstp, current_fh, open,
+		status = do_open_permission(rqstp, &resfh, open,
 					    NFSD_MAY_NOP);
-
+	set_change_info(&open->op_cinfo, current_fh);
+	fh_dup2(current_fh, &resfh);
 out:
 	fh_put(&resfh);
 	return status;
-- 
1.7.5.4

