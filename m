Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp20.rug.nl ([129.125.60.101]:46566 "EHLO smtp20.rug.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756603AbaHFSme (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Aug 2014 14:42:34 -0400
Received: from mail-wi0-f180.google.com ([172.23.16.207])
	by smtp20.rug.nl (8.14.7/8.14.7) with ESMTP id s76IgW94012443
	for <linux-nfs@vger.kernel.org>; Wed, 6 Aug 2014 20:42:33 +0200
Received: by mail-wi0-f180.google.com with SMTP id n3so3741575wiv.7
        for <linux-nfs@vger.kernel.org>; Wed, 06 Aug 2014 11:42:32 -0700 (PDT)
Received: from [10.0.12.202] (ip565bf259.direct-adsl.nl. [86.91.242.89])
        by mx.google.com with ESMTPSA id i8sm8647691wib.6.2014.08.06.11.42.31
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Aug 2014 11:42:31 -0700 (PDT)
Message-ID: <53E27716.9060706@rug.nl>
Date: Wed, 06 Aug 2014 20:42:30 +0200
From: Jurjen Bokma <j.bokma@rug.nl>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Patch: select non-conventional principal in gssd
Content-Type: multipart/mixed;
 boundary="------------060507090902040205090807"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060507090902040205090807
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit

HiAll,

I have patched utils/gssd/krb5_util.c to enable kerberized NFS
mounts to succeed even if the principal is not <HOSTNAME>$.

It works by reading another principal name from the [appdefaults]
section of krb5.conf:

[appdefaults]
nfs = {
    ad_principal_name = 129.125.39.115$
}

Patch is attached. Would you please incorporate it in the source if you
find it useful?
Sorry if I'm asking in the wrong place.

Best Regards
Jurjen



--------------060507090902040205090807
Content-Type: text/x-patch;
 name="krb5_util.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="krb5_util.patch"

--- utils/gssd/krb5_util.c.orig	2014-08-06 10:54:18.806414170 +0200
+++ utils/gssd/krb5_util.c	2014-08-06 11:01:21.016320365 +0200
@@ -801,7 +801,8 @@
 	char *k5err = NULL;
 	int tried_all = 0, tried_default = 0;
 	krb5_principal princ;
-
+	const char *notsetstr = "not set";
+	char *adhostoverride;
 
 	/* Get full target hostname */
 	retval = get_full_hostname(tgtname, targethostname,
@@ -818,11 +819,18 @@
 	}
 
 	/* Compute the active directory machine name HOST$ */
-	strcpy(myhostad, myhostname);
-	for (i = 0; myhostad[i] != 0; ++i)
-		myhostad[i] = toupper(myhostad[i]);
-	myhostad[i] = '$';
-	myhostad[i+1] = 0;
+	krb5_appdefault_string(context, "nfs", NULL, "ad_principal_name", notsetstr, &adhostoverride);
+	if (strcmp(adhostoverride, notsetstr) != 0) {
+	        printerr (0, "AD host string overridden with \"%s\" from appdefaults\n", adhostoverride);
+	        /* No overflow: Windows cannot handle strings longer than 19 chars */
+	        strcpy(myhostad, adhostoverride);
+	} else {
+	        strcpy(myhostad, myhostname);
+	        for (i = 0; myhostad[i] != 0; ++i)
+	          myhostad[i] = toupper(myhostad[i]);
+	        myhostad[i] = '$';
+	        myhostad[i+1] = 0;
+	}
 
 	retval = get_full_hostname(myhostname, myhostname, sizeof(myhostname));
 	if (retval)


--------------060507090902040205090807--
