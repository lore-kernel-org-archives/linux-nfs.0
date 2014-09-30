Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25075 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751005AbaI3Pow (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Sep 2014 11:44:52 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8UFip4m027882
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 30 Sep 2014 11:44:51 -0400
From: Simo Sorce <simo@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Simo Sorce <simo@redhat.com>
Subject: [PATCH 1/1] Centralize dependencies on the auth unit.
Date: Tue, 30 Sep 2014 11:44:48 -0400
Message-Id: <1412091888-32220-1-git-send-email-simo@redhat.com>
In-Reply-To: <542AC20B.9040509@redhat.com>
References: <542AC20B.9040509@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With this patch either gssproxy or rpc.svcgssd are started only if the
auth module is requested, and it finds a keytab.
If the wants are in the main nfs-client or nfs-server unit files then
the two deamons are started unconditionally and would require
conditions which we can test once and for all in a single unit file
instead.

Change also Before and After statments accordingly to properly
serialize loading modules and starting daemons in 3 steps
1. load kernel GSS auth module
2. start GSS handling daemons
3. start NFS client/server daemons

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 systemd/auth-rpcgss-module.service | 3 ++-
 systemd/nfs-client.target          | 7 +++++--
 systemd/nfs-server.service         | 8 +++++---
 3 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/systemd/auth-rpcgss-module.service b/systemd/auth-rpcgss-module.service
index 3fc2f4ac924f7e9d6e24969bb9a21d88a5c144fc..0355e13e009528632e97373332db9fa3acdfd1a9 100644
--- a/systemd/auth-rpcgss-module.service
+++ b/systemd/auth-rpcgss-module.service
@@ -6,7 +6,8 @@
 # unit will fail.  But that's OK.)
 [Unit]
 Description=Kernel Module supporting RPCSEC_GSS
-Before=gssproxy.service rpc-svcgssd.service
+Before=gssproxy.service rpc-svcgssd.service rpc-gssd.service
+Wants=gssproxy.service rpc-svcgssd.service rpc-gssd.service
 ConditionPathExists=/etc/krb5.keytab
 
 [Service]
diff --git a/systemd/nfs-client.target b/systemd/nfs-client.target
index 87a1ce8cec8f39c810c9c67325161de3e6a1db47..9b792a363e14c88ecaf8e45b7a3deadb97b3acac 100644
--- a/systemd/nfs-client.target
+++ b/systemd/nfs-client.target
@@ -5,9 +5,12 @@ Wants=remote-fs-pre.target
 
 # Note: we don't "Wants=rpc-statd.service" as "mount.nfs" will arrange to
 # start that on demand if needed.
-Wants=rpc-gssd.service rpc-svcgssd.service auth-rpcgss-module.service
 Wants=nfs-blkmap.service rpc-statd-notify.service
-After=rpc-gssd.service rpc-svcgssd.service nfs-blkmap.service
+After=nfs-blkmap.service
+
+# GSS services dependencies and ordering
+Wants=auth-rpcgss-module.service
+After=rpc-gssd.service rpc-svcgssd.service gssproxy.service
 
 [Install]
 WantedBy=multi-user.target
diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index 1048c5cbbf68328a8ac8c88b67e477061cf487c7..8010aadc487005cf7f1d1774fb237457a06a5d51 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -2,15 +2,17 @@
 Description=NFS server and services
 Requires= network.target proc-fs-nfsd.mount rpcbind.target
 Requires= nfs-mountd.service
-Wants=rpc-statd.service nfs-idmapd.service auth-rpcgss-module.service
-Wants=rpc-gssd.service gssproxy.service rpc-svcgssd.service
+Wants=rpc-statd.service nfs-idmapd.service
 Wants=rpc-statd-notify.service
 
 After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
 After= nfs-idmapd.service rpc-statd.service
-After= rpc-gssd.service gssproxy.service rpc-svcgssd.service
 Before= rpc-statd-notify.service
 
+# GSS services dependencies and ordering
+Wants=auth-rpcgss-module.service
+After=rpc-gssd.service gssproxy.service rpc-svcgssd.service
+
 Wants=nfs-config.service
 After=nfs-config.service
 
-- 
2.1.0

