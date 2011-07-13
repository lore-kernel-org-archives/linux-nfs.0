Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:56148 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756388Ab1GMQy0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jul 2011 12:54:26 -0400
From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH] svcgssd: use correct defaults in call to
 gss_set_allowable_enctypes
To: steved@redhat.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Date: Wed, 13 Jul 2011 12:54:26 -0400
Message-ID: <20110713165425.7469.23269.stgit@jazz.citi.umich.edu>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

For the window of kernels between 2.6.35 (when the support
for newer encryption was added) and 2.6.39 (when the ability
to read the supported enctypes from the kernel was added),
use a default of all enctypes when the kernel supported
enctypes file cannot be read.

For kernels before 2.6.35, continue to use a default of
only DES enctypes.

Note that the version of Kerberos must also support the use of
gss_set_allowable_enctypes for service-side negotiations.

See also: http://bugzilla.redhat.com/show_bug.cgi?id=719776

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/svcgssd_krb5.c |   37 ++++++++++++++++++++++++++++++-------
 1 files changed, 30 insertions(+), 7 deletions(-)

diff --git a/utils/gssd/svcgssd_krb5.c b/utils/gssd/svcgssd_krb5.c
index fc67a6f..6c34faf 100644
--- a/utils/gssd/svcgssd_krb5.c
+++ b/utils/gssd/svcgssd_krb5.c
@@ -45,6 +45,7 @@
 #include "gss_oids.h"
 #include "err_util.h"
 #include "svcgssd_krb5.h"
+#include "../mount/version.h"
 
 #define MYBUFLEN 1024
 
@@ -169,22 +170,44 @@ svcgssd_limit_krb5_enctypes(void)
 {
 #ifdef HAVE_SET_ALLOWABLE_ENCTYPES
 	u_int maj_stat, min_stat;
-	krb5_enctype default_enctypes[] = { ENCTYPE_DES_CBC_CRC,
-					    ENCTYPE_DES_CBC_MD5,
-					    ENCTYPE_DES_CBC_MD4 };
-	int default_num_enctypes =
-		sizeof(default_enctypes) / sizeof(default_enctypes[0]);
-	krb5_enctype *enctypes;
-	int num_enctypes;
+	krb5_enctype old_kernel_enctypes[] = {
+		ENCTYPE_DES_CBC_CRC,
+		ENCTYPE_DES_CBC_MD5,
+		ENCTYPE_DES_CBC_MD4 };
+	krb5_enctype new_kernel_enctypes[] = {
+		ENCTYPE_AES256_CTS_HMAC_SHA1_96,
+		ENCTYPE_AES128_CTS_HMAC_SHA1_96,
+		ENCTYPE_DES3_CBC_SHA1,
+		ENCTYPE_ARCFOUR_HMAC,
+		ENCTYPE_DES_CBC_CRC,
+		ENCTYPE_DES_CBC_MD5,
+		ENCTYPE_DES_CBC_MD4 };
+	krb5_enctype *default_enctypes, *enctypes;
+	int default_num_enctypes, num_enctypes;
+
+
+	if (linux_version_code() < MAKE_VERSION(2, 6, 35)) {
+		default_enctypes = old_kernel_enctypes;
+		default_num_enctypes =
+			sizeof(old_kernel_enctypes) / sizeof(old_kernel_enctypes[0]);
+	} else {
+		default_enctypes = new_kernel_enctypes;
+		default_num_enctypes =
+			sizeof(new_kernel_enctypes) / sizeof(new_kernel_enctypes[0]);
+	}
 
 	get_kernel_supported_enctypes();
 
 	if (parsed_enctypes != NULL) {
 		enctypes = parsed_enctypes;
 		num_enctypes = parsed_num_enctypes;
+		printerr(2, "%s: Calling gss_set_allowable_enctypes with %d "
+			"enctypes from the kernel\n", __func__, num_enctypes);
 	} else {
 		enctypes = default_enctypes;
 		num_enctypes = default_num_enctypes;
+		printerr(2, "%s: Calling gss_set_allowable_enctypes with %d "
+			"enctypes from defaults\n", __func__, num_enctypes);
 	}
 
 	maj_stat = gss_set_allowable_enctypes(&min_stat, gssd_creds,

