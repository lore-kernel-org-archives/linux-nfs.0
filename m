Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37924 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753117AbcFOQe6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jun 2016 12:34:58 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D0A01C01AC56
	for <linux-nfs@vger.kernel.org>; Wed, 15 Jun 2016 16:34:57 +0000 (UTC)
Received: from steved.boston.devel.redhat.com.redhat.com (vpn-63-66.rdu2.redhat.com [10.10.63.66])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u5FGYv0r016718
	for <linux-nfs@vger.kernel.org>; Wed, 15 Jun 2016 12:34:57 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] systemd: Only start the rpc-gssd service when its enabled
Date: Wed, 15 Jun 2016 12:34:56 -0400
Message-Id: <1466008496-9932-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When Kerberos is enabled, the /etc/krb5.keytab exists
which causes the rpc-gssd to start, automatically.

With rpc.gssd running, on all NFS mounts, an
upcall is done to get GSS security context for
SETCLIENTID procedure.

When Kerberos is not configured for NFS, meaning
there is no host/hostname@REALM principal in
the key tab, those upcalls always fall causing
the mount to hang for several seconds.

This patch adds an [Install] section so the service
can be enable and disable, so those errant upcalls
can be stopped which eliminating the delay.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/rpc-gssd.service | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
index d4a3819..df9f090 100644
--- a/systemd/rpc-gssd.service
+++ b/systemd/rpc-gssd.service
@@ -17,3 +17,9 @@ EnvironmentFile=-/run/sysconfig/nfs-utils
 
 Type=forking
 ExecStart=/usr/sbin/rpc.gssd $GSSDARGS
+
+# Only start if service is enabled 
+# and /etc/krb5.keytab exists 
+[Install]
+WantedBy=multi-user.target
+
-- 
2.5.5

