Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp20.rug.nl ([129.125.60.101]:35907 "EHLO smtp20.rug.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753280AbaHFPNQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Aug 2014 11:13:16 -0400
Received: from mail-wi0-f174.google.com ([172.23.16.207])
	by smtp20.rug.nl (8.14.7/8.14.7) with ESMTP id s76ExuDY016729
	for <linux-nfs@vger.kernel.org>; Wed, 6 Aug 2014 16:59:56 +0200
Received: by mail-wi0-f174.google.com with SMTP id d1so9134393wiv.1
        for <linux-nfs@vger.kernel.org>; Wed, 06 Aug 2014 07:59:56 -0700 (PDT)
Received: from [129.125.249.214] (bwp-249-214.rcuwp.rug.nl. [129.125.249.214])
        by mx.google.com with ESMTPSA id co6sm3033173wjb.31.2014.08.06.07.59.54
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 Aug 2014 07:59:54 -0700 (PDT)
Message-ID: <53E242E9.1050106@rug.nl>
Date: Wed, 06 Aug 2014 16:59:53 +0200
From: Jurjen Bokma <j.bokma@rug.nl>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Patch: select non-conventional principal in gssd
Content-Type: multipart/mixed;
 boundary="------------070304030107000803010009"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070304030107000803010009
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

HiAll,

I have a patch to utils/gssd/krb5_util.c that enables kerberized NFS
mounts to succeed even if the principal is not <HOSTNAME>$.

It works by reading another principal name from the [appdefaults]
section of krb5.conf:

[appdefaults]
nfs =3D {
    ad_principal_name =3D 129.125.39.115$
}

Patch is attached. Would you please incorporate it in the source if you
find it useful?
Sorry if I'm asking in the wrong place.

Best Regards
Jurjen


--------------070304030107000803010009
Content-Type: text/x-patch;
 name="krb5_util.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="krb5_util.patch"

--- utils/gssd/krb5_util.c.orig	2014-08-06 10:54:18.806414170 +0200
+++ utils/gssd/krb5_util.c	2014-08-06 11:01:21.016320365 +0200
@@ -801,7 +801,8 @@
 	char *k5err =3D NULL;
 	int tried_all =3D 0, tried_default =3D 0;
 	krb5_principal princ;
-
+	const char *notsetstr =3D "not set";
+	char *adhostoverride;
=20
 	/* Get full target hostname */
 	retval =3D get_full_hostname(tgtname, targethostname,
@@ -818,11 +819,18 @@
 	}
=20
 	/* Compute the active directory machine name HOST$ */
-	strcpy(myhostad, myhostname);
-	for (i =3D 0; myhostad[i] !=3D 0; ++i)
-		myhostad[i] =3D toupper(myhostad[i]);
-	myhostad[i] =3D '$';
-	myhostad[i+1] =3D 0;
+	krb5_appdefault_string(context, "nfs", NULL, "ad_principal_name", notse=
tstr, &adhostoverride);
+	if (strcmp(adhostoverride, notsetstr) !=3D 0) {
+	        printerr (0, "AD host string overridden with \"%s\" from appdef=
aults\n", adhostoverride);
+	        /* No overflow: Windows cannot handle strings longer than 19 ch=
ars */
+	        strcpy(myhostad, adhostoverride);
+	} else {
+	        strcpy(myhostad, myhostname);
+	        for (i =3D 0; myhostad[i] !=3D 0; ++i)
+	          myhostad[i] =3D toupper(myhostad[i]);
+	        myhostad[i] =3D '$';
+	        myhostad[i+1] =3D 0;
+	}
=20
 	retval =3D get_full_hostname(myhostname, myhostname, sizeof(myhostname)=
);
 	if (retval)

--------------070304030107000803010009--
