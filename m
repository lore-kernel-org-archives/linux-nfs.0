Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:51838 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757539Ab3J1W5M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 18:57:12 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>, Bruce Fields <bfields@fieldses.org>
Subject: [PATCH 2/2] SUNRPC: Fix buffer overflow checking in gss_encode_v0_msg/gss_encode_v1_msg
Date: Mon, 28 Oct 2013 18:57:07 -0400
Message-ID: <1383001027-62282-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1383001027-62282-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1383001027-62282-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In gss_encode_v1_msg, it is pointless to BUG() after the overflow has
happened. Replace the existing sprintf()-based code with scnprintf(),
and warn if an overflow is ever triggered.

In gss_encode_v0_msg, replace the runtime BUG_ON() with an appropriate
compile-time BUILD_BUG_ON.

Reported-by: Bruce Fields <bfields@fieldses.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 56 ++++++++++++++++++++++++++++--------------
 1 file changed, 37 insertions(+), 19 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index cc24323d3045..97912b40c254 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -420,41 +420,53 @@ static void gss_encode_v0_msg(struct gss_upcall_msg *gss_msg)
 	memcpy(gss_msg->databuf, &uid, sizeof(uid));
 	gss_msg->msg.data = gss_msg->databuf;
 	gss_msg->msg.len = sizeof(uid);
-	BUG_ON(sizeof(uid) > UPCALL_BUF_LEN);
+
+	BUILD_BUG_ON(sizeof(uid) > sizeof(gss_msg->databuf));
 }
 
-static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
+static int gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 				const char *service_name,
 				const char *target_name)
 {
 	struct gss_api_mech *mech = gss_msg->auth->mech;
 	char *p = gss_msg->databuf;
-	int len = 0;
-
-	gss_msg->msg.len = sprintf(gss_msg->databuf, "mech=%s uid=%d ",
-				   mech->gm_name,
-				   from_kuid(&init_user_ns, gss_msg->uid));
-	p += gss_msg->msg.len;
+	size_t buflen = sizeof(gss_msg->databuf);
+	int len;
+
+	len = scnprintf(p, buflen, "mech=%s uid=%d ", mech->gm_name,
+			from_kuid(&init_user_ns, gss_msg->uid));
+	buflen -= len;
+	p += len;
+	gss_msg->msg.len = len;
 	if (target_name) {
-		len = sprintf(p, "target=%s ", target_name);
+		len = scnprintf(p, buflen, "target=%s ", target_name);
+		buflen -= len;
 		p += len;
 		gss_msg->msg.len += len;
 	}
 	if (service_name != NULL) {
-		len = sprintf(p, "service=%s ", service_name);
+		len = scnprintf(p, buflen, "service=%s ", service_name);
+		buflen -= len;
 		p += len;
 		gss_msg->msg.len += len;
 	}
 	if (mech->gm_upcall_enctypes) {
-		len = sprintf(p, "enctypes=%s ", mech->gm_upcall_enctypes);
+		len = scnprintf(p, buflen, "enctypes=%s ",
+				mech->gm_upcall_enctypes);
+		buflen -= len;
 		p += len;
 		gss_msg->msg.len += len;
 	}
-	len = sprintf(p, "\n");
+	len = scnprintf(p, buflen, "\n");
+	if (len == 0)
+		goto out_overflow;
 	gss_msg->msg.len += len;
 
 	gss_msg->msg.data = gss_msg->databuf;
-	BUG_ON(gss_msg->msg.len > UPCALL_BUF_LEN);
+	return 0;
+out_overflow:
+	WARN_ON_ONCE(1);
+	return -ENOMEM;
 }
 
 static struct gss_upcall_msg *
@@ -463,15 +475,15 @@ gss_alloc_msg(struct gss_auth *gss_auth,
 {
 	struct gss_upcall_msg *gss_msg;
 	int vers;
+	int err = -ENOMEM;
 
 	gss_msg = kzalloc(sizeof(*gss_msg), GFP_NOFS);
 	if (gss_msg == NULL)
-		return ERR_PTR(-ENOMEM);
+		goto err;
 	vers = get_pipe_version(gss_auth->net);
-	if (vers < 0) {
-		kfree(gss_msg);
-		return ERR_PTR(vers);
-	}
+	err = vers;
+	if (err < 0)
+		goto err_free_msg;
 	gss_msg->pipe = gss_auth->gss_pipe[vers]->pipe;
 	INIT_LIST_HEAD(&gss_msg->list);
 	rpc_init_wait_queue(&gss_msg->rpc_waitqueue, "RPCSEC_GSS upcall waitq");
@@ -484,9 +496,15 @@ gss_alloc_msg(struct gss_auth *gss_auth,
 		gss_encode_v0_msg(gss_msg);
 		break;
 	default:
-		gss_encode_v1_msg(gss_msg, service_name, gss_auth->target_name);
+		err = gss_encode_v1_msg(gss_msg, service_name, gss_auth->target_name);
+		if (err)
+			goto err_free_msg;
 	};
 	return gss_msg;
+err_free_msg:
+	kfree(gss_msg);
+err:
+	return ERR_PTR(err);
 }
 
 static struct gss_upcall_msg *
-- 
1.8.3.1

