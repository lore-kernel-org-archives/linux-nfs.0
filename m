Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.piware.de ([37.120.164.117]:56835 "EHLO mail.piware.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755365AbbCFLQE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Mar 2015 06:16:04 -0500
From: Martin Pitt <martin.pitt@ubuntu.com>
To: linux-nfs@vger.kernel.org
Cc: Steve Langasek <steve.langasek@ubuntu.com>,
        systemd-devel@lists.freedesktop.org,
        Martin Pitt <martin.pitt@ubuntu.com>
Subject: [PATCH] systemd: start nfs-idmapd also on clients
Date: Fri,  6 Mar 2015 12:15:44 +0100
Message-Id: <1425640544-24230-2-git-send-email-martin.pitt@ubuntu.com>
In-Reply-To: <1425640544-24230-1-git-send-email-martin.pitt@ubuntu.com>
References: <1425640544-24230-1-git-send-email-martin.pitt@ubuntu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

idmapd is needed on clients too, so start it from nfs-client.target and stop
binding to it in nfs-server.service.

https://launchpad.net/bugs/1428961
---
 systemd/nfs-client.target  | 4 ++--
 systemd/nfs-idmapd.service | 2 --
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/systemd/nfs-client.target b/systemd/nfs-client.target
index 9b792a3..b12d830 100644
--- a/systemd/nfs-client.target
+++ b/systemd/nfs-client.target
@@ -5,8 +5,8 @@ Wants=remote-fs-pre.target
 
 # Note: we don't "Wants=rpc-statd.service" as "mount.nfs" will arrange to
 # start that on demand if needed.
-Wants=nfs-blkmap.service rpc-statd-notify.service
-After=nfs-blkmap.service
+Wants=nfs-blkmap.service rpc-statd-notify.service nfs-idmapd.service
+After=nfs-blkmap.service nfs-idmapd.service
 
 # GSS services dependencies and ordering
 Wants=auth-rpcgss-module.service
diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
index df3dd9d..90d3731 100644
--- a/systemd/nfs-idmapd.service
+++ b/systemd/nfs-idmapd.service
@@ -4,8 +4,6 @@ DefaultDependencies=no
 Requires=var-lib-nfs-rpc_pipefs.mount
 After=var-lib-nfs-rpc_pipefs.mount local-fs.target
 
-BindsTo=nfs-server.service
-
 Wants=nfs-config.service
 After=nfs-config.service
 
-- 
2.1.4

