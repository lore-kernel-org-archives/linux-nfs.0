Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45201 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752519AbaGOPJq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 11:09:46 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 03/15] gss_log: Removed DEBUG defines
Date: Tue, 15 Jul 2014 11:09:22 -0400
Message-Id: <1405436974-4161-4-git-send-email-steved@redhat.com>
In-Reply-To: <1405436974-4161-1-git-send-email-steved@redhat.com>
References: <1405436974-4161-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Enable the gss_log_XXX routines by removing the
ifdef DEBUGs that surround them.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/auth_gss.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/src/auth_gss.c b/src/auth_gss.c
index fd6191b..e36f5d9 100644
--- a/src/auth_gss.c
+++ b/src/auth_gss.c
@@ -78,7 +78,6 @@ static struct auth_ops authgss_ops = {
 	authgss_unwrap
 };
 
-#ifdef DEBUG
 
 /* useful as i add more mechanisms */
 void
@@ -126,7 +125,6 @@ char *p;
 	fprintf(stderr, "     service: %d\n", ptr->svc);
 	fprintf(stderr, "     cred: %p\n", ptr->cred);
 }
-#endif /*DEBUG*/
 
 struct rpc_gss_data {
 	bool_t			 established;	/* context established */
@@ -406,6 +404,7 @@ authgss_validate(AUTH *auth, struct opaque_auth *verf)
 
 	maj_stat = gss_verify_mic(&min_stat, gd->ctx, &signbuf,
 				  &checksum, &qop_state);
+
 	if (maj_stat != GSS_S_COMPLETE || qop_state != gd->sec.qop) {
 		gss_log_status("gss_verify_mic", maj_stat, min_stat);
 		if (maj_stat == GSS_S_CONTEXT_EXPIRED) {
@@ -436,19 +435,15 @@ authgss_refresh(AUTH *auth, void *dummy)
 	memset(&gr, 0, sizeof(gr));
 	recv_tokenp = GSS_C_NO_BUFFER;
 
-#ifdef DEBUG
 	print_rpc_gss_sec(&gd->sec);
-#endif /*DEBUG*/
 
 	for (;;) {
-#ifdef DEBUG
 		/* print the token we just received */
 		if (recv_tokenp != GSS_C_NO_BUFFER) {
 			gss_log_debug("The token we just received (length %d):",
 				  recv_tokenp->length);
 			gss_log_hexdump(recv_tokenp->value, recv_tokenp->length, 0);
 		}
-#endif
 		maj_stat = gss_init_sec_context(&min_stat,
 						gd->sec.cred,
 						&gd->ctx,
@@ -475,12 +470,10 @@ authgss_refresh(AUTH *auth, void *dummy)
 		if (send_token.length != 0) {
 			memset(&gr, 0, sizeof(gr));
 
-#ifdef DEBUG
 			/* print the token we are about to send */
 			gss_log_debug("The token being sent (length %d):",
 				  send_token.length);
 			gss_log_hexdump(send_token.value, send_token.length, 0);
-#endif
 
 			call_stat = clnt_call(gd->clnt, NULLPROC,
 					      (xdrproc_t)xdr_rpc_gss_init_args,
-- 
1.9.3

