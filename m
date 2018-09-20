Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34170 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726128AbeIUCaN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Sep 2018 22:30:13 -0400
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A9E12C049E3A
        for <linux-nfs@vger.kernel.org>; Thu, 20 Sep 2018 20:44:55 +0000 (UTC)
Received: from wlan-196-148.bos.redhat.com (wlan-196-148.bos.redhat.com [10.16.196.148])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 624153DB8
        for <linux-nfs@vger.kernel.org>; Thu, 20 Sep 2018 20:44:55 +0000 (UTC)
Message-ID: <1537476294.8924.12.camel@redhat.com>
Subject: [PATCH] nfs-utils: Fix version setting by config for vers4
From: Justin Mitchell <jumitche@redhat.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 20 Sep 2018 16:44:54 -0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The code path for setting major versions via nfs.conf was not
the same as setting it by cli option, resulting in vers4=n not
working unless vers4.0=n was also set

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 utils/nfsd/nfsd.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 6b57e2b..b256bd9 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -83,6 +83,9 @@ main(int argc, char **argv)
 
 	conf_init_file(NFS_CONFFILE); 
 	xlog_from_conffile("nfsd");
+
+	nfssvc_get_minormask(&minormask);
+
 	count = conf_get_num("nfsd", "threads", count);
 	grace = conf_get_num("nfsd", "grace-time", grace);
 	lease = conf_get_num("nfsd", "lease-time", lease);
@@ -101,13 +104,19 @@ main(int argc, char **argv)
 	for (i = 2; i <= 4; i++) {
 		char tag[20];
 		sprintf(tag, "vers%d", i);
-		if (conf_get_bool("nfsd", tag, NFSCTL_VERISSET(versbits, i)))
+		if (conf_get_bool("nfsd", tag, NFSCTL_VERISSET(versbits, i))) {
 			NFSCTL_VERSET(versbits, i);
-		else
+			if (i == 4)
+				minorvers = minorversset = minormask;
+		} else {
 			NFSCTL_VERUNSET(versbits, i);
+			if (i == 4) {
+				minorvers = 0;
+				minorversset = minormask;
+			}
+		}
 	}
 
-	nfssvc_get_minormask(&minormask);
 	/* We assume the kernel will default all minor versions to 'on',
 	 * and allow the config file to disable some.
 	 */
-- 
1.8.3.1
