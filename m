Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3665 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751577AbaDAP5d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Apr 2014 11:57:33 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s31FvWt8025563
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 1 Apr 2014 11:57:32 -0400
Received: from spanjikk.pnq.redhat.com (spanjikk.pnq.redhat.com [10.65.222.100])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s31FvV30004106
	for <linux-nfs@vger.kernel.org>; Tue, 1 Apr 2014 11:57:32 -0400
Message-ID: <533AE1EA.4030103@redhat.com>
Date: Tue, 01 Apr 2014 21:27:30 +0530
From: Shijoe George <spanjikk@redhat.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: [libnfsidmapd PATCH] nss: use strrchr() instead of strchr() to get
 the last occurrence of "@"
Content-Type: multipart/mixed;
 boundary="------------020604080701000608020301"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020604080701000608020301
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Issues with AD/IPA Trust works & how SSSD deals with AD users.

Lets say we have a IPA domain linux.example.com & AD domain 
win.example.com, We setup IPA/AD trust so that Windows domain users can 
login into Linux, When we setup AD Trust with IPA, AD users login as 
username@AD_REALM, With our example above, username will be 
"user@win.example.com" Without @win.example.com that user will be 
searched only in IPA domain not in AD domain. That is the reason @DOMAIN 
part is important in SSSD when dealing with IPA-AD trust.

With current behaviour the client-side code is stripping the domain off 
based on the location of the first "@" character in the value returned 
by the server. This results in UID/GID mappings failing and resulting in 
ownership on the clients as "nobody".

With the provided patch, we can accept fully qualified usernames.

--------------020604080701000608020301
Content-Type: text/x-patch;
 name="nss.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="nss.patch"

commit 7ff76ddf2e37d595732d9c8e534de8aa530eb57a
Author: Shijoe Panjikkaran <spanjikk@redhat.com>
Date:   Tue Apr 1 20:53:54 2014 +0530

    nss: strrchr() instead of strchr() to get the last occurrence of "@"
    
    Signed-off-by: Shijoe Panjikkaran <spanjikk@redhat.com>

diff --git a/nss.c b/nss.c
index b2b1227..f8129fe 100644
--- a/nss.c
+++ b/nss.c
@@ -135,7 +135,7 @@ static char *strip_domain(const char *name, const char *domain)
 	char *l = NULL;
 	int len;
 
-	c = strchr(name, '@');
+	c = strrchr(name, '@');
 	if (c == NULL && domain != NULL)
 		goto out;
 	if (c == NULL && domain == NULL) {

--------------020604080701000608020301--
