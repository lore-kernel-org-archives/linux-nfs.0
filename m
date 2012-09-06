Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:38290 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759638Ab2IFT6A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Sep 2012 15:58:00 -0400
From: andros@netapp.com
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] GSSD: Pass GSS_context lifetime to the kernel.
Date: Thu,  6 Sep 2012 15:58:10 -0400
Message-Id: <1346961490-2624-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The kernel gss_cl_ctx stores the context lifetime in gc_expiry, set
by gssd in do_downcall() called by process_krb5_upcall(). The lifetime value is
currently not related at all to the Kerberos TGS lifetime. It is either
set to the value of gssd -t <timeout>, or to a kernel default of 3600
seconds.

Most of the time the gssd -t command line is not set, and a timeout value
of zero was sent to the kernel triggering the use of the 3600 second kernel
default timeout.

In order for the kernel to properly know when to renew a context, or to stop
buffering writes for a context about to expire, the gc_expiry value needs to
reflect the credential lifetime used to create the context.

Note that gss_inquire_cred returns the number of seconds for which the context
remains valid in the lifetime_rec parameter.

Send the actual TGS remaining lifetime to the kernel. It can still be
overwritten by the gssd -t command line option, or set to the kernel default
if the gss_inquire_cred call fails (which sets the lifetime_rec to zero).

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 utils/gssd/gssd_proc.c |   19 ++++++++++++++++---
 1 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index aa39435..c8d8142 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -640,19 +640,22 @@ parse_enctypes(char *enctypes)
 
 static int
 do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
-	    gss_buffer_desc *context_token)
+	    gss_buffer_desc *context_token, OM_uint32 lifetime_rec)
 {
 	char    *buf = NULL, *p = NULL, *end = NULL;
 	unsigned int timeout = context_timeout;
 	unsigned int buf_size = 0;
 
-	printerr(1, "doing downcall\n");
+	printerr(1, "doing downcall lifetime_rec %u\n", lifetime_rec);
 	buf_size = sizeof(uid) + sizeof(timeout) + sizeof(pd->pd_seq_win) +
 		sizeof(pd->pd_ctx_hndl.length) + pd->pd_ctx_hndl.length +
 		sizeof(context_token->length) + context_token->length;
 	p = buf = malloc(buf_size);
 	end = buf + buf_size;
 
+	/* context_timeout set by -t option overrides context lifetime */
+	if (timeout == 0)
+		timeout = lifetime_rec;
 	if (WRITE_BYTES(&p, end, uid)) goto out_err;
 	if (WRITE_BYTES(&p, end, timeout)) goto out_err;
 	if (WRITE_BYTES(&p, end, pd->pd_seq_win)) goto out_err;
@@ -952,6 +955,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 	char			**dirname, *dir, *userdir;
 	int			create_resp = -1;
 	int			err, downcall_err = -EACCES;
+	OM_uint32		maj_stat, min_stat, lifetime_rec;
 
 	printerr(1, "handling krb5 upcall (%s)\n", clp->dirname);
 
@@ -1077,6 +1081,15 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 		goto out_return_error;
 	}
 
+	/* Grab the context lifetime to pass to the kernel. lifetime_rec
+	 * is set to zero on error */
+	maj_stat = gss_inquire_context(&min_stat, pd.pd_ctx, NULL, NULL,
+				       &lifetime_rec, NULL, NULL, NULL, NULL);
+
+	if (maj_stat)
+		printerr(1, "WARNING: Failed to inquire context for lifetme "
+			    "maj_stat %u\n", maj_stat);
+
 	if (serialize_context_for_kernel(pd.pd_ctx, &token, &krb5oid, NULL)) {
 		printerr(0, "WARNING: Failed to serialize krb5 context for "
 			    "user with uid %d for server %s\n",
@@ -1084,7 +1097,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 		goto out_return_error;
 	}
 
-	do_downcall(fd, uid, &pd, &token);
+	do_downcall(fd, uid, &pd, &token, lifetime_rec);
 
 out:
 	if (token.value)
-- 
1.7.7.6

