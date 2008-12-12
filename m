From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 14/15] rpc: add target field to new upcall
Date: Fri, 12 Dec 2008 13:20:34 -0500
Message-ID: <1229106035-16102-15-git-send-email-bfields@citi.umich.edu>
References: <1229106035-16102-1-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-2-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-3-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-4-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-5-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-6-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-7-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-8-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-9-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-10-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-11-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-12-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-13-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-14-git-send-email-bfields@citi.umich.edu>
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34015 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758561AbYLLSUp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Dec 2008 13:20:45 -0500
In-Reply-To: <1229106035-16102-14-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <aglo@citi.umich.edu>

This patch extends the new upcall by adding a "target" field
communicating who we want to authenticate to (equivalently, the service
principal that we want to acquire a ticket for).

Signed-off: Olga Kornievskaia <aglo@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/auth_gss/auth_gss.c |   28 +++++++++++++++++++++-------
 1 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 55f922f..9c929af 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -368,25 +368,39 @@ static void gss_encode_v0_msg(struct gss_upcall_msg *gss_msg)
 	gss_msg->msg.len = sizeof(gss_msg->uid);
 }
 
-static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg)
+static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
+				struct rpc_clnt *clnt)
 {
-	gss_msg->msg.len = sprintf(gss_msg->databuf, "mech=%s uid=%d\n",
+	char *p = gss_msg->databuf;
+	int len = 0;
+
+	gss_msg->msg.len = sprintf(gss_msg->databuf, "mech=%s uid=%d ",
 				   gss_msg->auth->mech->gm_name,
 				   gss_msg->uid);
+	p += gss_msg->msg.len;
+	if (clnt->cl_principal) {
+		len = sprintf(p, "target=%s ", clnt->cl_principal);
+		p += len;
+		gss_msg->msg.len += len;
+	}
+	len = sprintf(p, "\n");
+	gss_msg->msg.len += len;
+
 	gss_msg->msg.data = gss_msg->databuf;
 	BUG_ON(gss_msg->msg.len > UPCALL_BUF_LEN);
 }
 
-static void gss_encode_msg(struct gss_upcall_msg *gss_msg)
+static void gss_encode_msg(struct gss_upcall_msg *gss_msg,
+				struct rpc_clnt *clnt)
 {
 	if (pipe_version == 0)
 		gss_encode_v0_msg(gss_msg);
 	else /* pipe_version == 1 */
-		gss_encode_v1_msg(gss_msg);
+		gss_encode_v1_msg(gss_msg, clnt);
 }
 
 static inline struct gss_upcall_msg *
-gss_alloc_msg(struct gss_auth *gss_auth, uid_t uid)
+gss_alloc_msg(struct gss_auth *gss_auth, uid_t uid, struct rpc_clnt *clnt)
 {
 	struct gss_upcall_msg *gss_msg;
 	int vers;
@@ -406,7 +420,7 @@ gss_alloc_msg(struct gss_auth *gss_auth, uid_t uid)
 	atomic_set(&gss_msg->count, 1);
 	gss_msg->uid = uid;
 	gss_msg->auth = gss_auth;
-	gss_encode_msg(gss_msg);
+	gss_encode_msg(gss_msg, clnt);
 	return gss_msg;
 }
 
@@ -422,7 +436,7 @@ gss_setup_upcall(struct rpc_clnt *clnt, struct gss_auth *gss_auth, struct rpc_cr
 	if (gss_cred->gc_machine_cred != 0)
 		uid = 0;
 
-	gss_new = gss_alloc_msg(gss_auth, uid);
+	gss_new = gss_alloc_msg(gss_auth, uid, clnt);
 	if (IS_ERR(gss_new))
 		return gss_new;
 	gss_msg = gss_add_msg(gss_auth, gss_new);
-- 
1.5.5.rc1

