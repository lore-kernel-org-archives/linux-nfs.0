Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 183.141.211.66.inaddr.G4.NET ([66.211.141.183]:45864 "EHLO
	Dobby.4dicksons.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675Ab2KQOC3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Nov 2012 09:02:29 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1TZiyY-0004zI-QU
	for linux-nfs@vger.kernel.org; Sat, 17 Nov 2012 09:02:27 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] svcgssd: Encryption types not being parsed correctly
Date: Sat, 17 Nov 2012 08:57:41 -0500
Message-Id: <1353160661-30105-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When svcgssd reads the supported encrytion types from the
kernel, they are prefixed with a 'enctypes='. That prefix
has to be ignored to correctly parse the rest of the types.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/svcgssd_krb5.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/utils/gssd/svcgssd_krb5.c b/utils/gssd/svcgssd_krb5.c
index 6c34faf..1d44d34 100644
--- a/utils/gssd/svcgssd_krb5.c
+++ b/utils/gssd/svcgssd_krb5.c
@@ -38,6 +38,7 @@
 
 #include <stdio.h>
 #include <errno.h>
+#include <ctype.h>
 #include <gssapi/gssapi.h>
 #include <krb5.h>
 
@@ -98,6 +99,12 @@ parse_enctypes(char *enctypes)
 	if (n == 0)
 		return ENOENT;
 
+	/* Skip pass any non digits */
+	while (*enctypes && isdigit(*enctypes) == 0)
+		enctypes++;
+	if (*enctypes == '\0')
+		return EINVAL;
+
 	/* Allocate space for enctypes array */
 	if ((parsed_enctypes = (int *) calloc(n, sizeof(int))) == NULL) {
 		return ENOMEM;
-- 
1.7.11.7

