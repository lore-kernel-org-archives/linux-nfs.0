Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59339 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755472Ab3JJPPI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Oct 2013 11:15:08 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/4] svcrpc: handle some gssproxy encoding errors
Date: Thu, 10 Oct 2013 11:15:02 -0400
Message-Id: <1381418103-3852-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1381418103-3852-1-git-send-email-bfields@redhat.com>
References: <1381418103-3852-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Reported-by: Andi Kleen <andi@firstfloor.org>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/auth_gss/gss_rpc_xdr.c |   29 ++++++++++++++---------------
 1 file changed, 14 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_rpc_xdr.c
index f0f78c5..1ec19f6 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
@@ -559,6 +559,8 @@ static int gssx_enc_cred(struct xdr_stream *xdr,
 
 	/* cred->elements */
 	err = dummy_enc_credel_array(xdr, &cred->elements);
+	if (err)
+		return err;
 
 	/* cred->cred_handle_reference */
 	err = gssx_enc_buffer(xdr, &cred->cred_handle_reference);
@@ -740,22 +742,20 @@ void gssx_enc_accept_sec_context(struct rpc_rqst *req,
 		goto done;
 
 	/* arg->context_handle */
-	if (arg->context_handle) {
+	if (arg->context_handle)
 		err = gssx_enc_ctx(xdr, arg->context_handle);
-		if (err)
-			goto done;
-	} else {
+	else
 		err = gssx_enc_bool(xdr, 0);
-	}
+	if (err)
+		goto done;
 
 	/* arg->cred_handle */
-	if (arg->cred_handle) {
+	if (arg->cred_handle)
 		err = gssx_enc_cred(xdr, arg->cred_handle);
-		if (err)
-			goto done;
-	} else {
+	else
 		err = gssx_enc_bool(xdr, 0);
-	}
+	if (err)
+		goto done;
 
 	/* arg->input_token */
 	err = gssx_enc_in_token(xdr, &arg->input_token);
@@ -763,13 +763,12 @@ void gssx_enc_accept_sec_context(struct rpc_rqst *req,
 		goto done;
 
 	/* arg->input_cb */
-	if (arg->input_cb) {
+	if (arg->input_cb)
 		err = gssx_enc_cb(xdr, arg->input_cb);
-		if (err)
-			goto done;
-	} else {
+	else
 		err = gssx_enc_bool(xdr, 0);
-	}
+	if (err)
+		goto done;
 
 	err = gssx_enc_bool(xdr, arg->ret_deleg_cred);
 	if (err)
-- 
1.7.9.5

