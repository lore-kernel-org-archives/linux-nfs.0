Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60635 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760873Ab2EWVkm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 May 2012 17:40:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 05/10] nfsd4: merge 3 setclientid cases to 2
Date: Wed, 23 May 2012 17:40:35 -0400
Message-Id: <1337809240-15770-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1337809240-15770-1-git-send-email-bfields@redhat.com>
References: <1337809240-15770-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Boy, is this simpler.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index af916a7..2d28abf 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2195,16 +2195,11 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	new = create_client(clname, dname, rqstp, &clverifier);
 	if (new == NULL)
 		goto out;
-	if (!conf) {
-		/* case 4: placed first, because it's the normal case */
-		gen_clid(new);
-	} else if (same_verf(&conf->cl_verifier, &clverifier)) {
+	if (conf && same_verf(&conf->cl_verifier, &clverifier))
 		/* case 1: probable callback update */
 		copy_clid(new, conf);
-	} else { /* conf && !same_verf(): */
-		/* cases 2, 3: probable client reboot: */
+	else /* case 4 (new client) or cases 2, 3 (client reboot): */
 		gen_clid(new);
-	}
 	/*
 	 * XXX: we should probably set this at creation time, and check
 	 * for consistent minorversion use throughout:
-- 
1.7.9.5

