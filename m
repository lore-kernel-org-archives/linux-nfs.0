Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61090 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756002AbaISRK0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Sep 2014 13:10:26 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8JHAQaw025896
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Fri, 19 Sep 2014 13:10:26 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Simo Sorce <simo@redhat.com>
Subject: [PATCH 1/2] nfs-server: Replace rpc.svcgssd with gssproxy in systemd script
Date: Fri, 19 Sep 2014 13:10:20 -0400
Message-Id: <1411146621-18797-2-git-send-email-steved@redhat.com>
In-Reply-To: <1411146621-18797-1-git-send-email-steved@redhat.com>
References: <1411146621-18797-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have the nfs-server depend/start on the gssproxy daemon
instead of rpc.svcgssd to manage GSSAPI credentials

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/nfs-server.service | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index 2fa7387..3b04f84 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -2,12 +2,12 @@
 Description=NFS server and services
 Requires= network.target proc-fs-nfsd.mount rpcbind.target
 Requires= nfs-mountd.service
-Wants=rpc-statd.service nfs-idmapd.service rpc-gssd.service rpc-svcgssd.service
+Wants=rpc-statd.service nfs-idmapd.service rpc-gssd.service gssproxy.service
 Wants=rpc-statd-notify.service
 
 After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
 After= nfs-idmapd.service rpc-statd.service
-After= rpc-gssd.service rpc-svcgssd.service
+After= rpc-gssd.service gssproxy.service
 Before= rpc-statd-notify.service
 
 Wants=nfs-config.service
-- 
1.9.3

