Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55052 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932337AbbBZWxF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Feb 2015 17:53:05 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1QMr5s3031779
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Thu, 26 Feb 2015 17:53:05 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-63-188.rdu2.redhat.com [10.10.63.188])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1QMr458030920
	for <linux-nfs@vger.kernel.org>; Thu, 26 Feb 2015 17:53:04 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] rpc-statd-notify: Added Requires=network.target to service file.
Date: Thu, 26 Feb 2015 17:53:00 -0500
Message-Id: <1424991180-14604-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/rpc-statd-notify.service | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service
index a655445..b608a14 100644
--- a/systemd/rpc-statd-notify.service
+++ b/systemd/rpc-statd-notify.service
@@ -1,6 +1,6 @@
 [Unit]
 Description=Notify NFS peers of a restart
-Requires=network-online.target
+Requires=network.target
 After=network.target nss-lookup.target
 
 # if we run an nfs server, it needs to be running before we
-- 
2.1.0

