Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.rfc2324.org ([31.172.8.67]:38501 "EHLO mail.rfc2324.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751114Ab3EXN0X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 May 2013 09:26:23 -0400
Date: Fri, 24 May 2013 14:54:24 +0200
From: Maximilian Wilhelm <max@rfc2324.org>
To: linux-nfs@vger.kernel.org
Cc: Frederik Moellers <frederik.moellers@upb.de>
Message-ID: <20130524125424.GQ20475@principal.rfc2324.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="tqI+Z3u+9OQ7kwn0"
Subject: [PATCH] Fix handling of preferred_realm command line option
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--tqI+Z3u+9OQ7kwn0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

(Please CC me in replies, I'm not on the list.)

Hi,

we found a problem in the gssd daemon when using the -R opton to
specify a different preferred realm than the one used on the system.
It seems the preferred_realm variable set in the gssd.c file is not
used at all when searching for keytab entries / principal.

The simple patch attached fixes this problem.

Thanks
Max

--tqI+Z3u+9OQ7kwn0
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: attachment; filename="gssd_fix_preferred_realm.patch"

commit aa28b92860357f3d445836205f7851c75566da35
Author: Maximilian Wilhelm <max@rfc2324.org>
Date:   Fri May 24 14:46:41 2013 +0200

    Fix handling of preferred realm command line option.
    
      The current implementation ignores any preferred realm specified on the
      command line. Fix this behaviour and make sure the preferred realm is
      used as first realm when trying to acquire a keytab entry.
    
    Signed-off-by: Maximilian Wilhelm <max@rfc2324.org>
    Signed-off-by: Frederik Moellers <frederik.moellers@upb.de>

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 6275dd8..9f5e634 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -857,6 +857,12 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
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

--tqI+Z3u+9OQ7kwn0--
