Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f42.google.com ([209.85.128.42]:64153 "EHLO
	mail-qe0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258Ab3KGPrj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Nov 2013 10:47:39 -0500
Received: by mail-qe0-f42.google.com with SMTP id gc15so629948qeb.1
        for <linux-nfs@vger.kernel.org>; Thu, 07 Nov 2013 07:47:38 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] gssd: cut down log chatter in gssd_search_krb5_keytab
Date: Thu,  7 Nov 2013 10:47:33 -0500
Message-Id: <1383839253-8223-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Because the kernel now looks for krb5 creds by default when mounting, we
need to always have clients run rpc.gssd to avoid the 15s hang on the
first mount attempt.

In situations however where people don't have krb5 set up, this leads to
a lot of log spamming on mount attempts. Try to cut down on some of the
log chatter by lowering the priority of the log messages in
gssd_search_krb5_keytab().

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/krb5_util.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 697d1d2..2ca3adc 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -711,13 +711,13 @@ gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
 	 */
 	if ((code = krb5_kt_get_name(context, kt, kt_name, BUFSIZ))) {
 		k5err = gssd_k5_err_msg(context, code);
-		printerr(0, "ERROR: %s attempting to get keytab name\n", k5err);
+		printerr(1, "ERROR: %s attempting to get keytab name\n", k5err);
 		retval = code;
 		goto out;
 	}
 	if ((code = krb5_kt_start_seq_get(context, kt, &cursor))) {
 		k5err = gssd_k5_err_msg(context, code);
-		printerr(0, "ERROR: %s while beginning keytab scan "
+		printerr(1, "ERROR: %s while beginning keytab scan "
 			    "for keytab '%s'\n", k5err, kt_name);
 		retval = code;
 		goto out;
@@ -727,7 +727,7 @@ gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
 		if ((code = krb5_unparse_name(context, kte->principal,
 					      &pname))) {
 			k5err = gssd_k5_err_msg(context, code);
-			printerr(0, "WARNING: Skipping keytab entry because "
+			printerr(1, "WARNING: Skipping keytab entry because "
 				 "we failed to unparse principal name: %s\n",
 				 k5err);
 			k5_free_kt_entry(context, kte);
@@ -768,7 +768,7 @@ gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
 
 	if ((code = krb5_kt_end_seq_get(context, kt, &cursor))) {
 		k5err = gssd_k5_err_msg(context, code);
-		printerr(0, "WARNING: %s while ending keytab scan for "
+		printerr(1, "WARNING: %s while ending keytab scan for "
 			    "keytab '%s'\n", k5err, kt_name);
 	}
 
-- 
1.8.3.1

