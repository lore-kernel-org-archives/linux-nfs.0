Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60637 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755697Ab2EWVkm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 May 2012 17:40:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 03/10] nfsd4: merge last two setclientid cases
Date: Wed, 23 May 2012 17:40:33 -0400
Message-Id: <1337809240-15770-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1337809240-15770-1-git-send-email-bfields@redhat.com>
References: <1337809240-15770-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The code here is mostly the same.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4ce1045..b4e9c35 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2212,15 +2212,10 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		if (new == NULL)
 			goto out;
 		copy_clid(new, conf);
-	} else if (!unconf) {
-		/* case 2: probable client reboot: */
-		new = create_client(clname, dname, rqstp, &clverifier);
-		if (new == NULL)
-			goto out;
-		gen_clid(new);
-	} else {
-		/* case 3: probable client reboot: */
-		expire_client(unconf);
+	} else { /* conf && !same_verf(): */
+		/* cases 2, 3: probable client reboot: */
+		if (unconf)
+			expire_client(unconf);
 		new = create_client(clname, dname, rqstp, &clverifier);
 		if (new == NULL)
 			goto out;
-- 
1.7.9.5

