From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 15/15] rpc: add service field to new upcall
Date: Fri, 12 Dec 2008 13:20:35 -0500
Message-ID: <1229106035-16102-16-git-send-email-bfields@citi.umich.edu>
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
 <1229106035-16102-15-git-send-email-bfields@citi.umich.edu>
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34017 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758672AbYLLSUp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Dec 2008 13:20:45 -0500
In-Reply-To: <1229106035-16102-15-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <aglo@citi.umich.edu>

This patch extends the new upcall with a "service" field that currently
can have 2 values: "*" or "nfs". These values specify matching rules for
principals in the keytab file. The "*" means that gssd is allowed to use
"root", "nfs", or "host" keytab entries while the other option requires
"nfs".

Restricting gssd to use the "nfs" principal is needed for when the
server performs a callback to the client.  The server in this case has
to authenticate itself as an "nfs" principal.

We also need "service" field to distiguish between two client-side cases
both currently using a uid of 0: the case of regular file access by the
root user, and the case of state-management calls (such as setclientid)
which should use a keytab for authentication.  (And the upcall should
fail if an appropriate principal can't be found.)

Signed-off: Olga Kornievskaia <aglo@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/auth_gss/auth_gss.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 9c929af..95ca99d 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -369,7 +369,7 @@ static void gss_encode_v0_msg(struct gss_upcall_msg *gss_msg)
 }
 
 static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
-				struct rpc_clnt *clnt)
+				struct rpc_clnt *clnt, int machine_cred)
 {
 	char *p = gss_msg->databuf;
 	int len = 0;
@@ -383,6 +383,15 @@ static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 		p += len;
 		gss_msg->msg.len += len;
 	}
+	if (machine_cred) {
+		len = sprintf(p, "service=* ");
+		p += len;
+		gss_msg->msg.len += len;
+	} else if (!strcmp(clnt->cl_program->name, "nfs4_cb")) {
+		len = sprintf(p, "service=nfs ");
+		p += len;
+		gss_msg->msg.len += len;
+	}
 	len = sprintf(p, "\n");
 	gss_msg->msg.len += len;
 
@@ -391,16 +400,17 @@ static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 }
 
 static void gss_encode_msg(struct gss_upcall_msg *gss_msg,
-				struct rpc_clnt *clnt)
+				struct rpc_clnt *clnt, int machine_cred)
 {
 	if (pipe_version == 0)
 		gss_encode_v0_msg(gss_msg);
 	else /* pipe_version == 1 */
-		gss_encode_v1_msg(gss_msg, clnt);
+		gss_encode_v1_msg(gss_msg, clnt, machine_cred);
 }
 
 static inline struct gss_upcall_msg *
-gss_alloc_msg(struct gss_auth *gss_auth, uid_t uid, struct rpc_clnt *clnt)
+gss_alloc_msg(struct gss_auth *gss_auth, uid_t uid, struct rpc_clnt *clnt,
+		int machine_cred)
 {
 	struct gss_upcall_msg *gss_msg;
 	int vers;
@@ -420,7 +430,7 @@ gss_alloc_msg(struct gss_auth *gss_auth, uid_t uid, struct rpc_clnt *clnt)
 	atomic_set(&gss_msg->count, 1);
 	gss_msg->uid = uid;
 	gss_msg->auth = gss_auth;
-	gss_encode_msg(gss_msg, clnt);
+	gss_encode_msg(gss_msg, clnt, machine_cred);
 	return gss_msg;
 }
 
@@ -432,11 +442,7 @@ gss_setup_upcall(struct rpc_clnt *clnt, struct gss_auth *gss_auth, struct rpc_cr
 	struct gss_upcall_msg *gss_new, *gss_msg;
 	uid_t uid = cred->cr_uid;
 
-	/* Special case: rpc.gssd assumes that uid == 0 implies machine creds */
-	if (gss_cred->gc_machine_cred != 0)
-		uid = 0;
-
-	gss_new = gss_alloc_msg(gss_auth, uid, clnt);
+	gss_new = gss_alloc_msg(gss_auth, uid, clnt, gss_cred->gc_machine_cred);
 	if (IS_ERR(gss_new))
 		return gss_new;
 	gss_msg = gss_add_msg(gss_auth, gss_new);
-- 
1.5.5.rc1

