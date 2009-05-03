From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd4: set shorter timeout
Date: Sun,  3 May 2009 14:16:30 -0400
Message-ID: <1241374599-20348-5-git-send-email-bfields@fieldses.org>
References: <1241374599-20348-1-git-send-email-bfields@fieldses.org>
 <1241374599-20348-2-git-send-email-bfields@fieldses.org>
 <1241374599-20348-3-git-send-email-bfields@fieldses.org>
 <1241374599-20348-4-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:58596 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754151AbZECSQj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 May 2009 14:16:39 -0400
In-Reply-To: <1241374599-20348-4-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

We tried to do something overly complicated with the callback rpc
timeouts here.  And they're wrong--the result is that by the time a
single callback times out, it's already too late to tell the client
(using the cb_path_down return to RENEW) that the callback is down.

Use a much shorter, simpler timeout.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 290289b..049f052 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -358,6 +358,11 @@ static struct rpc_program cb_program = {
 		.pipe_dir_name  = "/nfsd4_cb",
 };
 
+static int max_cb_time(void)
+{
+	return max(NFSD_LEASE_TIME/10, (time_t)1) * HZ;
+}
+
 /* Reference counting, callback cleanup, etc., all look racy as heck.
  * And why is cb_set an atomic? */
 
@@ -366,10 +371,8 @@ static struct rpc_clnt *setup_callback_client(struct nfs4_client *clp)
 	struct sockaddr_in	addr;
 	struct nfs4_callback    *cb = &clp->cl_callback;
 	struct rpc_timeout	timeparms = {
-		.to_initval	= (NFSD_LEASE_TIME/4) * HZ,
-		.to_retries	= 5,
-		.to_maxval	= (NFSD_LEASE_TIME/2) * HZ,
-		.to_exponential	= 1,
+		.to_initval	= max_cb_time(),
+		.to_retries	= 0,
 	};
 	struct rpc_create_args args = {
 		.protocol	= IPPROTO_TCP,
-- 
1.6.0.4

