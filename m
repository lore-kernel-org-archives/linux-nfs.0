From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/6] rpc: timeout patch
Date: Mon,  9 Jun 2008 16:51:32 -0400
Message-ID: <1213044696-32741-3-git-send-email-bfields@citi.umich.edu>
References: <1213044696-32741-1-git-send-email-bfields@citi.umich.edu>
 <1213044696-32741-2-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org, Olga Kornievskaia <aglo@citi.umich.edu>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:48629 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751780AbYFIUvi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2008 16:51:38 -0400
In-Reply-To: <1213044696-32741-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <aglo@citi.umich.edu>

When a client gss upcall times out, we currently give a mesage reminding
the user to check whether gssd is running.

Currently gssd only listens on pipes under nfs/.  We expect to modify it
so it treats all clients the same regardless of protocol (as it probably
should have before), and new functionality may depend on that.  So
people may need to upgrade gssd to get such new functionality.

So it would be helpful if the error message specified which pipe exactly
the upcall was failing on, and suggested that the problem could be due
to an outdated gssd (not just a non-existant gssd).

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/auth_gss/auth_gss.c |   42 +++++++++++++++++++++++++--------------
 1 files changed, 27 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index cc12d5f..c3ca6f0 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -584,22 +584,34 @@ gss_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 {
 	struct gss_upcall_msg *gss_msg = container_of(msg, struct gss_upcall_msg, msg);
 	static unsigned long ratelimit;
+	unsigned long now = jiffies;
+	struct path path = {
+		.dentry = gss_msg->auth->dentry,
+		.mnt = gss_msg->auth->client->cl_vfsmnt,
+	};
+	char name[128], *p;
 
-	if (msg->errno < 0) {
-		dprintk("RPC:       gss_pipe_destroy_msg releasing msg %p\n",
-				gss_msg);
-		atomic_inc(&gss_msg->count);
-		gss_unhash_msg(gss_msg);
-		if (msg->errno == -ETIMEDOUT) {
-			unsigned long now = jiffies;
-			if (time_after(now, ratelimit)) {
-				printk(KERN_WARNING "RPC: AUTH_GSS upcall timed out.\n"
-						    "Please check user daemon is running!\n");
-				ratelimit = now + 15*HZ;
-			}
-		}
-		gss_release_msg(gss_msg);
-	}
+	if (msg->errno >= 0)
+		return;
+
+	dprintk("RPC:       gss_pipe_destroy_msg releasing msg %p\n", gss_msg);
+	atomic_inc(&gss_msg->count);
+	gss_unhash_msg(gss_msg);
+
+	if (msg->errno != -ETIMEDOUT)
+		goto out;
+
+	if (!time_after(now, ratelimit))
+		goto out;
+
+	p = d_path(&path, name, 128);
+	printk(KERN_WARNING "RPC: AUTH_GSS upcall to <rpc_pipefs_dir>%s "
+			    "timed out.\n Please check user daemon is "
+			    "up-to-date and running!\n", p ? p : "<null>");
+	ratelimit = now + 15*HZ;
+
+out:
+	gss_release_msg(gss_msg);
 }
 
 /*
-- 
1.5.5.rc1

