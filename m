Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37961 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752575AbaIWQVr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 12:21:47 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8NGLk8V020318
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 23 Sep 2014 12:21:47 -0400
Received: from smallhat.boston.devel.redhat.com (vpn-55-23.rdu2.redhat.com [10.10.55.23])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s8NGLhMv027727
	for <linux-nfs@vger.kernel.org>; Tue, 23 Sep 2014 12:21:46 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] nfs-service: Added gssproxy support
Date: Tue, 23 Sep 2014 12:21:41 -0400
Message-Id: <1411489301-28991-3-git-send-email-steved@redhat.com>
In-Reply-To: <1411489301-28991-1-git-send-email-steved@redhat.com>
References: <1411489301-28991-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When kernel have gssproxy support the the gssproxy
daemon should be used to manage the GSSAPI creds.
So this patch adds "calls" to the gssproxy daemon
from the NFS server systemd unit file.

When gssproxy is installed, gssproxy will be start
and rpc.svcgssd will not be. When gssproxy is not
installed the rpc.svcgssd daemon will be started.

Note, there are already existing hooks in the
rpc-svcgssd service file that will ensure the
gssproxy will be started before rpc.svcgssd
which allows the script not to start rpc.svcsdd
when gssproxy is installed and running.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/nfs-server.service | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index 2fa7387..c740fa2 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -2,12 +2,13 @@
 Description=NFS server and services
 Requires= network.target proc-fs-nfsd.mount rpcbind.target
 Requires= nfs-mountd.service
-Wants=rpc-statd.service nfs-idmapd.service rpc-gssd.service rpc-svcgssd.service
+Wants=rpc-statd.service nfs-idmapd.service 
+Wants=rpc-gssd.service gssproxy.service rpc-svcgssd.service
 Wants=rpc-statd-notify.service
 
 After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
 After= nfs-idmapd.service rpc-statd.service
-After= rpc-gssd.service rpc-svcgssd.service
+After= rpc-gssd.service gssproxy.service rpc-svcgssd.service
 Before= rpc-statd-notify.service
 
 Wants=nfs-config.service
-- 
1.9.3

