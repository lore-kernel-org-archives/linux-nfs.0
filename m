Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36366 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727132AbeIZU4P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 26 Sep 2018 16:56:15 -0400
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 09A2F86665
        for <linux-nfs@vger.kernel.org>; Wed, 26 Sep 2018 14:42:59 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-117-50.phx2.redhat.com [10.3.117.50])
        by smtp.corp.redhat.com (Postfix) with ESMTP id B21CD5F1A6
        for <linux-nfs@vger.kernel.org>; Wed, 26 Sep 2018 14:42:58 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfs.conf: fail to disable major NFS version 4 using "vers4=n" in /etc/nfs.conf
Date: Wed, 26 Sep 2018 10:42:51 -0400
Message-Id: <20180926144251.7589-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Justin Mitchell <jumitche@redhat.com>

Setting "vers4=n/off" (disabling the major NFS version 4) in nfs.conf
doesn't work now.

Refer to rpc.nfsd(8), "vers3/vers4" in the [nfsd] section of the
/etc/nfs.conf file is to enable or disable a major NFS version 3 or 4
(which are normally enabled by default).

Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1625032

Signed-off-by: Steve Dickson <steved@redhat.com>
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
2.17.1
