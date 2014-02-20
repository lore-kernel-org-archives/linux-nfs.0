Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26337 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752700AbaBTOa6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Feb 2014 09:30:58 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s1KEUpZR002104
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 20 Feb 2014 09:30:56 -0500
Subject: [PATCH] Fix windows hostname calculation
From: Simo Sorce <simo@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 20 Feb 2014 09:30:48 -0500
Message-ID: <1392906648.22754.213.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>From 026c489ac7019a91951b37240f438329de1d615c Mon Sep 17 00:00:00 2001
From: Simo Sorce <simo@redhat.com>
Date: Thu, 20 Feb 2014 09:25:06 -0500
Subject: [PATCH] Drop full domain when constructing the Ad hostname.

When trying to use the special MS Windows hostanme we need to stop
at the first '.' if we got a FQDN from gethostname()
Tee HOST$@REALM form in fact uses the AD samAccountName attribute to
represent 'HOST', and that attribute is always the host's shortname.
Characters like '.' are actually illegal for a shortname in AD.

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 utils/gssd/krb5_util.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index
208c72bc072bceecc81f591887603e274dc35d9b..4b57141b4e17643ef9b56aa13639354860009db6 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -819,8 +819,10 @@ find_keytab_entry(krb5_context context, krb5_keytab
kt, const char *tgtname,
 
 	/* Compute the active directory machine name HOST$ */
 	strcpy(myhostad, myhostname);
-	for (i = 0; myhostad[i] != 0; ++i)
+	for (i = 0; myhostad[i] != 0; ++i) {
+		if (myhostad[i] == '.') break;
 		myhostad[i] = toupper(myhostad[i]);
+	}
 	myhostad[i] = '$';
 	myhostad[i+1] = 0;
 
-- 
1.8.5.3


-- 
Simo Sorce * Red Hat, Inc * New York

