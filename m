From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/9] rpc: factor out warning code from gss_pipe_destroy_msg
Date: Sun,  9 Nov 2008 16:04:36 -0500
Message-ID: <1226264683-28650-3-git-send-email-bfields@citi.umich.edu>
References: <20081109204621.GD27376@fieldses.org>
 <1226264683-28650-1-git-send-email-bfields@citi.umich.edu>
 <1226264683-28650-2-git-send-email-bfields@citi.umich.edu>
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34895 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755919AbYKIVEp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Nov 2008 16:04:45 -0500
In-Reply-To: <1226264683-28650-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We'll want to call this from elsewhere soon.  And this is a bit nicer
anyway.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/auth_gss/auth_gss.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 07bb395..1cb4bcc 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -369,6 +369,18 @@ gss_setup_upcall(struct rpc_clnt *clnt, struct gss_auth *gss_auth, struct rpc_cr
 	return gss_msg;
 }
 
+static void warn_gssd(void)
+{
+	static unsigned long ratelimit;
+	unsigned long now = jiffies;
+
+	if (time_after(now, ratelimit)) {
+		printk(KERN_WARNING "RPC: AUTH_GSS upcall timed out.\n"
+				"Please check user daemon is running.\n");
+		ratelimit = now + 15*HZ;
+	}
+}
+
 static inline int
 gss_refresh_upcall(struct rpc_task *task)
 {
@@ -568,21 +580,14 @@ static void
 gss_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 {
 	struct gss_upcall_msg *gss_msg = container_of(msg, struct gss_upcall_msg, msg);
-	static unsigned long ratelimit;
 
 	if (msg->errno < 0) {
 		dprintk("RPC:       gss_pipe_destroy_msg releasing msg %p\n",
 				gss_msg);
 		atomic_inc(&gss_msg->count);
 		gss_unhash_msg(gss_msg);
-		if (msg->errno == -ETIMEDOUT) {
-			unsigned long now = jiffies;
-			if (time_after(now, ratelimit)) {
-				printk(KERN_WARNING "RPC: AUTH_GSS upcall timed out.\n"
-						    "Please check user daemon is running!\n");
-				ratelimit = now + 15*HZ;
-			}
-		}
+		if (msg->errno == -ETIMEDOUT)
+			warn_gssd();
 		gss_release_msg(gss_msg);
 	}
 }
-- 
1.5.5.rc1

