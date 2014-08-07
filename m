Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp24.rug.nl ([129.125.60.105]:43803 "EHLO smtp24.rug.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932071AbaHGPUR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Aug 2014 11:20:17 -0400
From: Jurjen Bokma <j.bokma@rug.nl>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Jurjen Bokma <j.bokma@rug.nl>
Subject: [PATCH] AD principal configurable
Date: Thu,  7 Aug 2014 16:19:00 +0200
Message-Id: <1407421140-16566-1-git-send-email-j.bokma@rug.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jurjen Bokma <j.bokma@rug.nl>
---
 utils/gssd/krb5_util.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 4b57141..8f492a6 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -801,6 +801,8 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
 	char *k5err = NULL;
 	int tried_all = 0, tried_default = 0;
 	krb5_principal princ;
+	const char *notsetstr = "not set";
+	char *adhostoverride;
 
 
 	/* Get full target hostname */
@@ -818,13 +820,21 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
 	}
 
 	/* Compute the active directory machine name HOST$ */
-	strcpy(myhostad, myhostname);
-	for (i = 0; myhostad[i] != 0; ++i) {
-		if (myhostad[i] == '.') break;
-		myhostad[i] = toupper(myhostad[i]);
+	krb5_appdefault_string(context, "nfs", NULL, "ad_principal_name", notsetstr, &adhostoverride);
+	if (strcmp(adhostoverride, notsetstr) != 0) {
+	        printerr (0, "AD host string overridden with \"%s\" from appdefaults\n", adhostoverride);
+	        /* No overflow: Windows cannot handle strings longer than 19 chars */
+	        strcpy(myhostad, adhostoverride);
+		free(adhostoverride);
+	} else {
+	        strcpy(myhostad, myhostname);
+	        for (i = 0; myhostad[i] != 0; ++i) {
+	          if (myhostad[i] == '.') break;
+	          myhostad[i] = toupper(myhostad[i]);
+	        }
+	        myhostad[i] = '$';
+	        myhostad[i+1] = 0;
 	}
-	myhostad[i] = '$';
-	myhostad[i+1] = 0;
 
 	retval = get_full_hostname(myhostname, myhostname, sizeof(myhostname));
 	if (retval) {
-- 
1.9.1

