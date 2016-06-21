Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60616 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752020AbcFUPD1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jun 2016 11:03:27 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 78594C05681D
	for <linux-nfs@vger.kernel.org>; Tue, 21 Jun 2016 14:53:29 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u5LErSth006809
	for <linux-nfs@vger.kernel.org>; Tue, 21 Jun 2016 10:53:29 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1 v2] systemd: Only start the gssd daemons when they are enabled
Date: Tue, 21 Jun 2016 10:53:27 -0400
Message-Id: <1466520807-4340-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When Kerberos is enabled, the /etc/krb5.keytab exists
which causes the both gssd daemons to start, automatically.

With rpc.gssd running, on all NFS mounts, an upcall
is done to get GSS security context for SETCLIENTID procedure.

When Kerberos is not configured for NFS, meaning
there is no host/hostname@REALM principal in
the key tab, those upcalls always fall causing
the mount to hang for several seconds.

This patch added an [Install] section to both
services so the services can be enable and disable.
The README was also updated.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/README              | 14 +++++---------
 systemd/rpc-gssd.service    |  6 ++++++
 systemd/rpc-svcgssd.service |  7 +++++++
 3 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/systemd/README b/systemd/README
index 7c43df8..58dae42 100644
--- a/systemd/README
+++ b/systemd/README
@@ -59,13 +59,9 @@ information such as in /etc/sysconfig/nfs or /etc/defaults/nfs.
 It is run once by nfs-config.service.
 
 rpc.gssd and rpc.svcgssd are assumed to be needed if /etc/krb5.keytab
-is present.
-If a site needs this file present but does not want the gss daemons
-running, it should create
-   /etc/systemd/system/rpc-gssd.service.d/01-disable.conf
-and
-   /etc/systemd/system/rpc-svcgssd.service.d/01-disable.conf
+is present.  If a site needs this file present but does not want 
+the gss daemons running, they can be disabled by doing
+   
+   systemctl disable rpc-gssd
+   systemctl disable rpc-svcgssd
 
-containing
-   [Unit]
-   ConditionNull=false
diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
index d4a3819..681f26a 100644
--- a/systemd/rpc-gssd.service
+++ b/systemd/rpc-gssd.service
@@ -17,3 +17,9 @@ EnvironmentFile=-/run/sysconfig/nfs-utils
 
 Type=forking
 ExecStart=/usr/sbin/rpc.gssd $GSSDARGS
+
+# Only start if the service is enabled 
+# and /etc/krb5.keytab exists 
+[Install]
+WantedBy=multi-user.target
+
diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
index 41177b6..4433ed7 100644
--- a/systemd/rpc-svcgssd.service
+++ b/systemd/rpc-svcgssd.service
@@ -18,3 +18,10 @@ After=nfs-config.service
 EnvironmentFile=-/run/sysconfig/nfs-utils
 Type=forking
 ExecStart=/usr/sbin/rpc.svcgssd $SVCGSSDARGS
+
+# Only start if the service is enabled 
+# and /etc/krb5.keytab exists 
+# and when gss-proxy is not runing
+[Install]
+WantedBy=multi-user.target
+
-- 
2.5.5

