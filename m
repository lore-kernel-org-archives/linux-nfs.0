From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 20/24] Removed warnings from svcgssd_proc.c
Date: Tue, 20 Jul 2010 19:37:33 -0400
Message-ID: <1279669057-17509-21-git-send-email-steved@redhat.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:60381 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932569Ab0GUAnP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 20:43:15 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1ObMNZ-0004K5-7y
	for linux-nfs@vger.kernel.org; Tue, 20 Jul 2010 19:37:41 -0400
In-Reply-To: <1279669057-17509-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

svcgssd_proc.c: In function 'send_response':
svcgssd_proc.c:135: warning: unused parameter 'f'
svcgssd_proc.c: In function 'handle_nullreq':
svcgssd_proc.c:434: warning: comparison of unsigned expression < 0 is always false

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/svcgssd_proc.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index f1bfbef..28336c2 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -132,7 +132,7 @@ struct gss_verifier {
 #define RPCSEC_GSS_SEQ_WIN	5
 
 static int
-send_response(FILE *f, gss_buffer_desc *in_handle, gss_buffer_desc *in_token,
+send_response(gss_buffer_desc *in_handle, gss_buffer_desc *in_token,
 	      u_int32_t maj_stat, u_int32_t min_stat,
 	      gss_buffer_desc *out_handle, gss_buffer_desc *out_token)
 {
@@ -431,7 +431,7 @@ handle_nullreq(FILE *f) {
 	print_hexl("in_tok", in_tok.value, in_tok.length);
 #endif
 
-	if (in_tok.length < 0) {
+	if (in_tok.length == 0) {
 		printerr(0, "WARNING: handle_nullreq: "
 			    "failed parsing request\n");
 		goto out_err;
@@ -498,7 +498,7 @@ handle_nullreq(FILE *f) {
 	do_svc_downcall(&out_handle, &cred, mech, &ctx_token, ctx_endtime,
 			hostbased_name);
 continue_needed:
-	send_response(f, &in_handle, &in_tok, maj_stat, min_stat,
+	send_response(&in_handle, &in_tok, maj_stat, min_stat,
 			&out_handle, &out_tok);
 out:
 	if (ctx_token.value != NULL)
@@ -514,7 +514,7 @@ out:
 out_err:
 	if (ctx != GSS_C_NO_CONTEXT)
 		gss_delete_sec_context(&ignore_min_stat, &ctx, &ignore_out_tok);
-	send_response(f, &in_handle, &in_tok, maj_stat, min_stat,
+	send_response(&in_handle, &in_tok, maj_stat, min_stat,
 			&null_token, &null_token);
 	goto out;
 }
-- 
1.7.0.1

