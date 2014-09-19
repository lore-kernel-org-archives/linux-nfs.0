Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30350 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755831AbaISMvs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Sep 2014 08:51:48 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8JCpmnq024190
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Fri, 19 Sep 2014 08:51:48 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Simo Sorce <simo@redhat.com>
Subject: [PATCH 1/2] nfs-server: Replace rpc.svcgssd with gssproxy
Date: Fri, 19 Sep 2014 08:51:42 -0400
Message-Id: <1411131103-17254-2-git-send-email-steved@redhat.com>
In-Reply-To: <1411131103-17254-1-git-send-email-steved@redhat.com>
References: <1411131103-17254-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make the nfs-server depend on the gssproxy
daemon running instead of svcgssd to manage
GSSAPI credentials

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/nfs-server.service  |  4 ++--
 systemd/rpc-svcgssd.service | 19 -------------------
 2 files changed, 2 insertions(+), 21 deletions(-)
 delete mode 100644 systemd/rpc-svcgssd.service

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
diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
deleted file mode 100644
index f7424b0..0000000
--- a/systemd/rpc-svcgssd.service
+++ /dev/null
@@ -1,19 +0,0 @@
-[Unit]
-Description=RPC security service for NFS server
-Requires=var-lib-nfs-rpc_pipefs.mount
-After=var-lib-nfs-rpc_pipefs.mount
-PartOf=nfs-server.service
-PartOf=nfs-utils.service
-
-After=gssproxy.service
-ConditionPathExists=|!/run/gssproxy.pid
-ConditionPathExists=|!/proc/net/rpc/use-gss-proxy
-ConditionPathExists=/etc/krb5.keytab
-
-Wants=nfs-config.service
-After=nfs-config.service
-
-[Service]
-EnvironmentFile=-/run/sysconfig/nfs-utils
-Type=forking
-ExecStart=/usr/sbin/rpc.svcgssd $SVCGSSDARGS
-- 
1.9.3

