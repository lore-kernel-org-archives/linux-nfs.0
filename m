Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60630 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760861Ab2EWVkl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 May 2012 17:40:41 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 04/10] nfsd4: pull out common code from setclientid cases
Date: Wed, 23 May 2012 17:40:34 -0400
Message-Id: <1337809240-15770-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1337809240-15770-1-git-send-email-bfields@redhat.com>
References: <1337809240-15770-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   26 +++++---------------------
 1 file changed, 5 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b4e9c35..af916a7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2189,36 +2189,20 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		}
 	}
 	unconf = find_unconfirmed_client_by_str(dname, strhashval);
+	if (unconf)
+		expire_client(unconf);
 	status = nfserr_jukebox;
+	new = create_client(clname, dname, rqstp, &clverifier);
+	if (new == NULL)
+		goto out;
 	if (!conf) {
 		/* case 4: placed first, because it's the normal case */
-		if (unconf)
-			expire_client(unconf);
-		new = create_client(clname, dname, rqstp, &clverifier);
-		if (new == NULL)
-			goto out;
 		gen_clid(new);
 	} else if (same_verf(&conf->cl_verifier, &clverifier)) {
 		/* case 1: probable callback update */
-		if (unconf) {
-			/* Note this is removing unconfirmed {*x***},
-			 * which is stronger than RFC recommended {vxc**}.
-			 * This has the advantage that there is at most
-			 * one {*x***} in either list at any time.
-			 */
-			expire_client(unconf);
-		}
-		new = create_client(clname, dname, rqstp, &clverifier);
-		if (new == NULL)
-			goto out;
 		copy_clid(new, conf);
 	} else { /* conf && !same_verf(): */
 		/* cases 2, 3: probable client reboot: */
-		if (unconf)
-			expire_client(unconf);
-		new = create_client(clname, dname, rqstp, &clverifier);
-		if (new == NULL)
-			goto out;
 		gen_clid(new);
 	}
 	/*
-- 
1.7.9.5

