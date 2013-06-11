Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.rfc2324.org ([31.172.8.67]:33719 "EHLO mail.rfc2324.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752447Ab3FKJeN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jun 2013 05:34:13 -0400
Received: from rfc2324.org ([31.172.8.84] helo=principal.rfc2324.org)
	by mail.rfc2324.org with esmtp rfc2324.org Mailserver
	id 1UmKxo-0005Jg-IW
	for <linux-nfs@vger.kernel.org>; Tue, 11 Jun 2013 11:34:08 +0200
Date: Tue, 11 Jun 2013 11:34:03 +0200
From: Maximilian Wilhelm <max@rfc2324.org>
To: linux-nfs@vger.kernel.org
Message-ID: <20130611093403.GB27345@principal.rfc2324.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="y0ulUmNC+osPPQO6"
Subject: [PATCH]: gssd: Fix preferred_realm option handling
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--y0ulUmNC+osPPQO6
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

--y0ulUmNC+osPPQO6
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: attachment; filename="gssd_fix_preferred_realm.patch"

commit 722bd62d1e6a9d38db57e919d914a371e67d804d
Author: Maximilian Wilhelm <max@rfc2324.org>
Date:   Fri May 24 14:46:41 2013 +0200

    Fix handling of preferred realm command line option.
    
      The current implementation ignores any preferred realm specified on the
      command line. Fix this behaviour and make sure the preferred realm is
      used as first realm when trying to acquire a keytab entry.
    
    Signed-off-by: Maximilian Wilhelm <max@rfc2324.org>
    Signed-off-by: Frederik Moellers <frederik.moellers@upb.de>

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 6275dd8..fb706a8 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -852,11 +852,18 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
 	}
 
 	/*
-	 * Try the "appropriate" realm first, and if nothing found for that
-	 * realm, try the default realm (if it hasn't already been tried).
+	 * Make sure the preferred_realm (which may have been explicitly set
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

--y0ulUmNC+osPPQO6--
