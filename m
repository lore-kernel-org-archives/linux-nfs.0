Return-Path: linux-nfs-owner@vger.kernel.org
Received: from minas.ics.muni.cz ([147.251.4.40]:41004 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756755Ab3CILZl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 9 Mar 2013 06:25:41 -0500
Received: from anubis.ics.muni.cz (igw1.zrnko.net [94.112.253.31])
	(authenticated user=xhejtman@META bits=0)
	by minas.ics.muni.cz (8.13.8/8.13.8/SuSE Linux 0.8) with ESMTP id r29BPaRb001683
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <linux-nfs@vger.kernel.org>; Sat, 9 Mar 2013 12:25:38 +0100
Received: from xhejtman by anubis.ics.muni.cz with local (Exim 4.80)
	(envelope-from <xhejtman@ics.muni.cz>)
	id 1UEHu7-0003Rx-5u
	for linux-nfs@vger.kernel.org; Sat, 09 Mar 2013 12:25:31 +0100
Date: Sat, 9 Mar 2013 12:25:31 +0100
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] gssd - expired credentials problem
Message-ID: <20130309112531.GA13250@ics.muni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I noticed that there is a problem with expired credentials if NFS client's
time is even few seconds behind KDC's or NFS server's time. Client's kernel
requests new GSS context but rpc.gssd is happy with existing krb cache as it
valid according to local time.

Is there any reason for gssd to check validity of existing cache when kernel
requests a new context?

However, it seems that this trivial patch solves this issue.

300 is because I believe that clock skew must be within 300sec for kerberos.

Signed-off-by: Lukas Hejtmanek <xhejtman@gmail.com>

diff -rNu nfs-utils-1.2.7.orig/utils/gssd/krb5_util.c nfs-utils-1.2.7/utils/gssd/krb5_util.c
--- nfs-utils-1.2.7.orig/utils/gssd/krb5_util.c 2012-11-12 00:01:23.000000000 +0100
+++ nfs-utils-1.2.7/utils/gssd/krb5_util.c      2013-02-15 16:35:35.652482164 +0100
@@ -343,7 +343,7 @@
        char kt_name[BUFSIZ];
        char cc_name[BUFSIZ];
        int code;
-       time_t now = time(0);
+       time_t now = time(0)+300; // workaround for clock skew among NFS server, NFS client and KDC
        char *cache_type;
        char *pname = NULL;
        char *k5err = NULL;


-- 
Luká¹ Hejtmánek
