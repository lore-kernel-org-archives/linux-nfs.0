Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3128 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754080AbaI2SWJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2014 14:22:09 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8TIM894020727
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 29 Sep 2014 14:22:08 -0400
From: Simo Sorce <simo@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Simo Sorce <simo@redhat.com>
Subject: [PATCH 1/1] Move the wants only to the auth unit.
Date: Mon, 29 Sep 2014 14:22:03 -0400
Message-Id: <1412014923-26587-2-git-send-email-simo@redhat.com>
In-Reply-To: <1412014923-26587-1-git-send-email-simo@redhat.com>
References: <1412014923-26587-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This way either gssproxy or rpc.svcgssd are started only if the auth module is
requested, and it finds a keytab.
If the wants are in the main nfs-client or nfs-server unit files then the
two deamons are started unconditionally and would require conditions which we
can test once and for all in a single unit file instead.

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 systemd/auth-rpcgss-module.service | 3 ++-
 systemd/nfs-client.target          | 4 ++--
 systemd/nfs-server.service         | 1 -
 3 files changed, 4 insertions(+), 4 deletions(-)

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
index 474f5e9ad74b70d265a7b2099556c2b9220bcdd0..f3d884a241543e41fdd91bcb0a055654b4b2c275 100644
--- a/systemd/nfs-client.target
+++ b/systemd/nfs-client.target
@@ -5,9 +5,9 @@ Wants=remote-fs-pre.target
 
 # Note: we don't "Wants=rpc-statd.service" as "mount.nfs" will arrange to
 # start that on demand if needed.
-Wants=rpc-gssd.service rpc-svcgssd.service auth-rpcgss-module.service
+Wants=auth-rpcgss-module.service
 Wants=nfs-blkmap.service rpc-statd-notify.service
-Before=rpc-gssd.service rpc-svcgssd.service nfs-blkmap.service
+Before=nfs-blkmap.service
 
 [Install]
 WantedBy=multi-user.target
diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index 1048c5cbbf68328a8ac8c88b67e477061cf487c7..a5039062ad95ca0c73c8a6c33d053a845d596185 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -3,7 +3,6 @@ Description=NFS server and services
 Requires= network.target proc-fs-nfsd.mount rpcbind.target
 Requires= nfs-mountd.service
 Wants=rpc-statd.service nfs-idmapd.service auth-rpcgss-module.service
-Wants=rpc-gssd.service gssproxy.service rpc-svcgssd.service
 Wants=rpc-statd-notify.service
 
 After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
-- 
2.1.0

