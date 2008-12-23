From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 56/69] rpc: factor out warning code from
 gss_pipe_destroy_msg
Date: Tue, 23 Dec 2008 18:02:22 -0500
Message-ID: <20081223230222.13743.8567.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21081 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752710AbYLWXYm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:42 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOcSk021557
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:39 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: \"J. Bruce Fields\" <bfields@citi.umich.edu>

We'll want to call this from elsewhere soon.  And this is a bit nicer
anyway.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth_gss/auth_gss.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)


diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index ea4567f..0fe3566 100644
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

