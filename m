Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16492 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754757AbaIVTUN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 15:20:13 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8MJKDXo024760
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 22 Sep 2014 15:20:13 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Simo Sorce <simo@redhat.com>
Subject: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Date: Mon, 22 Sep 2014 15:20:07 -0400
Message-Id: <1411413608-16462-2-git-send-email-steved@redhat.com>
In-Reply-To: <1411413608-16462-1-git-send-email-steved@redhat.com>
References: <1411413608-16462-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Added the gssproxy.service to both the Wants= and
Atfers= lines, before the rpc-svcgssd.service. There
are  ConditionPathExists= lines in the rpc-svcgssd.service
unit which will stop the rpc.svcgssd daemon from
starting when the gssproxy daemon is already running.

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

