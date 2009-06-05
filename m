From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] libnfsidmap: debug log when local Realms are not found
Date: Fri, 05 Jun 2009 11:12:52 -0400
Message-ID: <4A2935F4.8040702@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60087 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751670AbZFEPPx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2009 11:15:53 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Kevin,

When the krb5 realm and the DNS domain name are not
the same and the 'Local-Realm' variable is not
set (or set incorrectly) in /etc/idmapd.conf, 
causes the krb5 mounted file system to be inaccessible
by any and all users, which is the right thing to do.

But, the problem is, there is no reason logged as
to why the all users are being denied assess; with
or without debug enabled. 

This patch will log, with debug enabled, when the
krb5 realm can not be used since it does not match 
the DNS domain name or the 'Local-Realm' variable 
defined in /etc/idmad.conf.

Signed-off-by: Steve Dickson <steved@redhat.com>
---------------------------------

diff -up libnfsidmap/nss.c.orig libnfsidmap/nss.c
--- libnfsidmap/nss.c.orig	2009-04-13 14:46:17.000000000 -0400
+++ libnfsidmap/nss.c	2009-06-05 10:37:46.000000000 -0400
@@ -298,9 +298,11 @@ static int nss_gss_princ_to_ids(char *se
 			break;
 		}
 	}
-	if (!found)
+	if (!found) {
+		IDMAP_LOG(1, ("nss_gss_princ_to_ids: Local-Realm '%s': NOT FOUND", 
+			princ_realm));
 		return -ENOENT;
-
+	}
 	/* XXX: this should call something like getgssauthnam instead? */
 	pw = nss_getpwnam(princ, NULL, &err);
 	if (pw == NULL) {
