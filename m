Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:53523 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752947AbdG1Uu1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Jul 2017 16:50:27 -0400
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <anna.schumaker@netapp.com>, <olga.kornievskaia@netapp.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 1/2] GSSD: Add RPCSEC_GSS version to downcall
Date: Fri, 28 Jul 2017 16:50:21 -0400
Message-ID: <1501275022-24313-2-git-send-email-andros@netapp.com>
In-Reply-To: <1501275022-24313-1-git-send-email-andros@netapp.com>
References: <1501275022-24313-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

retry without gss_vers on downcall failure

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 configure.ac           |  1 +
 utils/gssd/gssd_proc.c | 17 +++++++++++++++--
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/configure.ac b/configure.ac
index 1ca1603..77827c7 100644
--- a/configure.ac
+++ b/configure.ac
@@ -9,6 +9,7 @@ AC_PREREQ(2.59)
 AC_PREFIX_DEFAULT(/usr)
 AM_MAINTAINER_MODE
 AC_USE_SYSTEM_EXTENSIONS
+AC_PROG_RANLIB
 
 dnl *************************************************************
 dnl * Define the set of applicable options
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index d74d372..689d916 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -149,13 +149,19 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
 	char    *buf = NULL, *p = NULL, *end = NULL;
 	unsigned int timeout = context_timeout;
 	unsigned int buf_size = 0;
+	bool use_gss_vers = true;
 
-	printerr(2, "doing downcall: lifetime_rec=%u acceptor=%.*s\n",
-		lifetime_rec, acceptor->length, acceptor->value);
+retry:
+	printerr(2, "doing downcall: lifetime_rec=%u acceptor=%.*s"
+		"gss vers %d\n", lifetime_rec, acceptor->length,
+		acceptor->value, use_gss_vers ? pd->pd_gss_vers : 1);
 	buf_size = sizeof(uid) + sizeof(timeout) + sizeof(pd->pd_seq_win) +
 		sizeof(pd->pd_ctx_hndl.length) + pd->pd_ctx_hndl.length +
 		sizeof(context_token->length) + context_token->length +
 		sizeof(acceptor->length) + acceptor->length;
+	if (use_gss_vers)
+		buf_size += sizeof(pd->pd_gss_vers);
+
 	p = buf = malloc(buf_size);
 	if (!buf)
 		goto out_err;
@@ -171,6 +177,8 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
 	if (write_buffer(&p, end, &pd->pd_ctx_hndl)) goto out_err;
 	if (write_buffer(&p, end, context_token)) goto out_err;
 	if (write_buffer(&p, end, acceptor)) goto out_err;
+	if (use_gss_vers)
+		if (WRITE_BYTES(&p, end, pd->pd_gss_vers)) goto out_err;
 
 	if (write(k5_fd, buf, p - buf) < p - buf) goto out_err;
 	free(buf);
@@ -178,6 +186,11 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
 out_err:
 	free(buf);
 	printerr(1, "Failed to write downcall!\n");
+	if (use_gss_vers) {
+		printerr(1, "Retry downcall without gss_vers\n");
+		use_gss_vers = false;
+		goto retry;
+	}
 	return;
 }
 
-- 
1.8.3.1

