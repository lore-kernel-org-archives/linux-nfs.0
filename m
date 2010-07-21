From: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 7/7] nfsd: minor nfsd_svc() cleanup
Date: Wed, 21 Jul 2010 19:26:51 -0400
Message-ID: <1279754811-8328-7-git-send-email-bfields@redhat.com>
References: <20100721232432.GA6689@fieldses.org>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46654 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754916Ab0GUX2A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Jul 2010 19:28:00 -0400
In-Reply-To: <20100721232432.GA6689@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

More idiomatic to put the error case in the if clause.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfssvc.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 62a6c44..92173bd 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -443,12 +443,13 @@ nfsd_svc(unsigned short port, int nrservs)
 	if (error)
 		goto out_shutdown;
 	error = svc_set_num_threads(nfsd_serv, NULL, nrservs);
-	if (error == 0)
-		/* We are holding a reference to nfsd_serv which
-		 * we don't want to count in the return value,
-		 * so subtract 1
-		 */
-		error = nfsd_serv->sv_nrthreads - 1;
+	if (error)
+		goto out_destroy;
+	/* We are holding a reference to nfsd_serv which
+	 * we don't want to count in the return value,
+	 * so subtract 1
+	 */
+	error = nfsd_serv->sv_nrthreads - 1;
 out_destroy:
 	svc_destroy(nfsd_serv);		/* Release server */
 out_shutdown:
-- 
1.7.0.4

