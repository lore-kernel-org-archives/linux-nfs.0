From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 02/12] lockd: kill redundant host->h_server check
Date: Wed,  5 Nov 2008 15:06:41 -0500
Message-ID: <1225915611-2401-2-git-send-email-bfields@citi.umich.edu>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
 <1225915611-2401-1-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39485 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757493AbYKEUGy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2008 15:06:54 -0500
In-Reply-To: <1225915611-2401-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Note that the first argument to nlmsvc_is_client always has h_server
set, since it is the host associated with a lock, block, or share held
by the server.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svcsubs.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index 34c2766..9c186f0 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -335,16 +335,15 @@ nlmsvc_is_client(void *data, struct nlm_host *dummy)
 {
 	struct nlm_host *host = data;
 
-	if (host->h_server) {
-		/* we are destroying locks even though the client
-		 * hasn't asked us too, so don't unmonitor the
-		 * client
-		 */
-		if (host->h_nsmhandle)
-			host->h_nsmhandle->sm_sticky = 1;
-		return 1;
-	} else
-		return 0;
+	BUG_ON(!host->h_server);
+	/* we are destroying locks even though the client
+	 * hasn't asked us too, so don't unmonitor the
+	 * client
+	 */
+	if (host->h_nsmhandle)
+		host->h_nsmhandle->sm_sticky = 1;
+	return 1;
+
 }
 
 /*
-- 
1.5.5.rc1

