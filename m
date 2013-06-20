Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.rfc2324.org ([31.172.8.67]:50102 "EHLO mail.rfc2324.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161110Ab3FTT4J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Jun 2013 15:56:09 -0400
Date: Thu, 20 Jun 2013 21:56:03 +0200
From: Maximilian Wilhelm <max@rfc2324.org>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Message-ID: <20130620195603.GE16125@principal.rfc2324.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="A6N2fC+uXW/VQSAv"
Subject: [PATCH]: gssd: Fix preferred_realm option handling
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--A6N2fC+uXW/VQSAv
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline


Hi,

the gssd currently ignores any preferred realm given via the -R
command line option.

The attached patch fixes that behaviour and makes sure the
preferrred_realm is used first when searching for a valid principal
for mount authentication.

I would be happy if you would apply this. This would close bug #235 in
bugzilla.

Thanks
Max

--A6N2fC+uXW/VQSAv
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: attachment; filename="gssd_fix_preferred_realm.patch"

commit 36784e52650fb08d9012a243365693f2a0eb1f93
Author: Maximilian Wilhelm <max@rfc2324.org>
Date:   Thu Jun 20 21:30:17 2013 +0200

    Fix handling of preferred realm command line option.

      The current implementation ignores any preferred realm specified on the
      command line. Fix this behaviour and make sure the preferred realm is
      used as first realm when trying to acquire a keytab entry.

    Signed-off-by: Maximilian Wilhelm <max@rfc2324.org>
    Signed-off-by: Frederik Moellers <frederik.moellers@upb.de>

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 6275dd8..d6bf8cc 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -852,11 +852,18 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
 	}
 
 	/*
-	 * Try the "appropriate" realm first, and if nothing found for that
-	 * realm, try the default realm (if it hasn't already been tried).
+	 * Make sure the preferred_realm, which may have been explicitly set
+	 * on the command line, is tried first. If nothing is found go on with
+	 * the host and local default realm (if that hasn't already been tried).
 	 */
 	i = 0;
 	realm = realmnames[i];
+
+	if (strcmp (realm, preferred_realm) != 0) {
+		realm = preferred_realm;
+		i = -1;
+	}
+
 	while (1) {
 		if (realm == NULL) {
 			tried_all = 1;

--A6N2fC+uXW/VQSAv--
