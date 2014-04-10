Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:37356 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965191AbaDJUbQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Apr 2014 16:31:16 -0400
Received: by mail-qa0-f51.google.com with SMTP id j7so4373201qaq.24
        for <linux-nfs@vger.kernel.org>; Thu, 10 Apr 2014 13:31:15 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] gssd: scrape the acceptor name out of the context
Date: Thu, 10 Apr 2014 16:31:03 -0400
Message-Id: <1397161863-29266-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1397161863-29266-1-git-send-email-jlayton@redhat.com>
References: <1397161863-29266-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and pass it to the kernel in the downcall. Legacy kernels will just
ignore the extra data, but with a proposed kernel patch the kernel will
grab this info and use it to verify requests on the v4.0 callback
channel.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c | 39 ++++++++++++++++++++++++++++-----------
 1 file changed, 28 insertions(+), 11 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 7387cce010cf..d95e39416c28 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -77,6 +77,7 @@
 #include "context.h"
 #include "nfsrpc.h"
 #include "nfslib.h"
+#include "gss_names.h"
 
 /*
  * pollarray:
@@ -683,16 +684,19 @@ parse_enctypes(char *enctypes)
 
 static void
 do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
-	    gss_buffer_desc *context_token, OM_uint32 lifetime_rec)
+	    gss_buffer_desc *context_token, OM_uint32 lifetime_rec,
+	    gss_buffer_desc *acceptor)
 {
 	char    *buf = NULL, *p = NULL, *end = NULL;
 	unsigned int timeout = context_timeout;
 	unsigned int buf_size = 0;
 
-	printerr(1, "doing downcall lifetime_rec %u\n", lifetime_rec);
+	printerr(1, "doing downcall: lifetime_rec=%u acceptor=%.*s\n",
+		lifetime_rec, acceptor->length, acceptor->value);
 	buf_size = sizeof(uid) + sizeof(timeout) + sizeof(pd->pd_seq_win) +
 		sizeof(pd->pd_ctx_hndl.length) + pd->pd_ctx_hndl.length +
-		sizeof(context_token->length) + context_token->length;
+		sizeof(context_token->length) + context_token->length +
+		acceptor->length;
 	p = buf = malloc(buf_size);
 	if (!buf)
 		goto out_err;
@@ -707,6 +711,8 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
 	if (WRITE_BYTES(&p, end, pd->pd_seq_win)) goto out_err;
 	if (write_buffer(&p, end, &pd->pd_ctx_hndl)) goto out_err;
 	if (write_buffer(&p, end, context_token)) goto out_err;
+	if (acceptor->length > 0 &&
+	    write_buffer(&p, end, acceptor)) goto out_err;
 
 	if (write(k5_fd, buf, p - buf) < p - buf) goto out_err;
 	free(buf);
@@ -1034,6 +1040,9 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 	gss_cred_id_t		gss_cred;
 	OM_uint32		maj_stat, min_stat, lifetime_rec;
 	pid_t			pid;
+	gss_name_t		gacceptor;
+	gss_OID			mech;
+	gss_buffer_desc		acceptor  = {0};
 
 	pid = fork();
 	switch(pid) {
@@ -1174,15 +1183,22 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 		goto out_return_error;
 	}
 
-	/* Grab the context lifetime to pass to the kernel. lifetime_rec
-	 * is set to zero on error */
-	maj_stat = gss_inquire_context(&min_stat, pd.pd_ctx, NULL, NULL,
-				       &lifetime_rec, NULL, NULL, NULL, NULL);
+	maj_stat = gss_inquire_context(&min_stat, pd.pd_ctx, NULL, &gacceptor,
+				       &lifetime_rec, &mech, NULL, NULL, NULL);
 
-	if (maj_stat)
-		printerr(1, "WARNING: Failed to inquire context for lifetme "
-			    "maj_stat %u\n", maj_stat);
+	if (maj_stat != GSS_S_COMPLETE) {
+		printerr(1, "WARNING: Failed to inquire context "
+			    "maj_stat (0x%x)\n", maj_stat);
+	} else {
+		get_hostbased_client_buffer(gacceptor, mech, &acceptor);
+		gss_release_name(&min_stat, &gacceptor);
+	}
 
+	/*
+	 * The serialization can mean turning the ctx into a lucid context. If
+	 * that happens then the original ctx is no longer valid, so we mustn't
+	 * try to use if after this point.
+	 */
 	if (serialize_context_for_kernel(&pd.pd_ctx, &token, &krb5oid, NULL)) {
 		printerr(0, "WARNING: Failed to serialize krb5 context for "
 			    "user with uid %d for server %s\n",
@@ -1190,9 +1206,10 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 		goto out_return_error;
 	}
 
-	do_downcall(fd, uid, &pd, &token, lifetime_rec);
+	do_downcall(fd, uid, &pd, &token, lifetime_rec, &acceptor);
 
 out:
+	gss_release_buffer(&min_stat, &acceptor);
 	if (token.value)
 		free(token.value);
 #ifdef HAVE_AUTHGSS_FREE_PRIVATE_DATA
-- 
1.9.0

