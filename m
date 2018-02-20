Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:37682 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751902AbeBTSug (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Feb 2018 13:50:36 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.rdu2.redhat.com [10.11.54.3])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 4364E4023150
        for <linux-nfs@vger.kernel.org>; Tue, 20 Feb 2018 18:50:36 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 2ABDF10A9DE7
        for <linux-nfs@vger.kernel.org>; Tue, 20 Feb 2018 18:50:36 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 5/7] Removed undef warnings
Date: Tue, 20 Feb 2018 13:50:32 -0500
Message-Id: <20180220185034.26301-6-steved@redhat.com>
In-Reply-To: <20180220185034.26301-1-steved@redhat.com>
References: <20180220185034.26301-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Added the -Werror=undef warning flag and
then fixed a few #ifdefs

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac           | 1 +
 utils/gssd/krb5_util.c | 6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/configure.ac b/configure.ac
index 11b994b..2364275 100644
--- a/configure.ac
+++ b/configure.ac
@@ -552,6 +552,7 @@ my_am_cflags="\
  -Werror=missing-declarations \
  -Werror=format-overflow=2 \
  -Werror=format=2 \
+ -Werror=undef \
 "
 
 AC_SUBST([AM_CFLAGS], ["$my_am_cflags"])
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index b64818a..6e61da2 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -333,7 +333,7 @@ gssd_get_single_krb5_cred(krb5_context context,
 			  struct gssd_k5_kt_princ *ple,
 			  int nocache)
 {
-#if HAVE_KRB5_GET_INIT_CREDS_OPT_SET_ADDRESSLESS
+#ifdef HAVE_KRB5_GET_INIT_CREDS_OPT_SET_ADDRESSLESS
 	krb5_get_init_creds_opt *init_opts = NULL;
 #else
 	krb5_get_init_creds_opt options;
@@ -372,7 +372,7 @@ gssd_get_single_krb5_cred(krb5_context context,
 	if ((krb5_unparse_name(context, ple->princ, &pname)))
 		pname = NULL;
 
-#if HAVE_KRB5_GET_INIT_CREDS_OPT_SET_ADDRESSLESS
+#ifdef HAVE_KRB5_GET_INIT_CREDS_OPT_SET_ADDRESSLESS
 	code = krb5_get_init_creds_opt_alloc(context, &init_opts);
 	if (code) {
 		k5err = gssd_k5_err_msg(context, code);
@@ -454,7 +454,7 @@ gssd_get_single_krb5_cred(krb5_context context,
 	code = 0;
 	printerr(2, "%s: principal '%s' ccache:'%s'\n", __func__, pname, cc_name);
   out:
-#if HAVE_KRB5_GET_INIT_CREDS_OPT_SET_ADDRESSLESS
+#ifdef HAVE_KRB5_GET_INIT_CREDS_OPT_SET_ADDRESSLESS
 	if (init_opts)
 		krb5_get_init_creds_opt_free(context, init_opts);
 #endif
-- 
2.14.3

