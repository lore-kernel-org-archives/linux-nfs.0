Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.rfc2324.org ([31.172.8.67]:38560 "EHLO mail.rfc2324.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751406Ab3EXNtE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 May 2013 09:49:04 -0400
Date: Fri, 24 May 2013 15:48:58 +0200
From: Maximilian Wilhelm <max@rfc2324.org>
To: linux-nfs@vger.kernel.org
Cc: Frederik Moellers <frederik.moellers@upb.de>
Message-ID: <20130524134858.GS20475@principal.rfc2324.org>
References: <20130524125424.GQ20475@principal.rfc2324.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="NtwzykIc2mflq5ck"
In-Reply-To: <20130524125424.GQ20475@principal.rfc2324.org>
Subject: Re: [PATCH] Fix handling of preferred_realm command line option
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--NtwzykIc2mflq5ck
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Anno domini 2013 Maximilian Wilhelm scripsit:

Me again,

> (Please CC me in replies, I'm not on the list.)

> we found a problem in the gssd daemon when using the -R opton to
> specify a different preferred realm than the one used on the system.
> It seems the preferred_realm variable set in the gssd.c file is not
> used at all when searching for keytab entries / principal.

> The simple patch attached fixes this problem.

I felt the urge to update the comment, too :)

Best regards
Max
-- 
Friends are relatives you make for yourself.

--NtwzykIc2mflq5ck
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

--NtwzykIc2mflq5ck--
