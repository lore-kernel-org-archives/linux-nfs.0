Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.piware.de ([37.120.164.117]:44486 "EHLO mail.piware.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755990AbbCCR22 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2015 12:28:28 -0500
From: Martin Pitt <martin.pitt@ubuntu.com>
To: linux-nfs@vger.kernel.org
Cc: systemd-devel@lists.freedesktop.org, Martin Pitt <martin.pitt@ubuntu.com>
Subject: [PATCH 1/2] systemd: Order NFS server before client
Date: Tue,  3 Mar 2015 18:28:09 +0100
Message-Id: <1425403690-23847-2-git-send-email-martin.pitt@ubuntu.com>
In-Reply-To: <1425403690-23847-1-git-send-email-martin.pitt@ubuntu.com>
References: <1425403690-23847-1-git-send-email-martin.pitt@ubuntu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This makes mounting NFS shares from localhost work reliably, as you need to
start the server before attempting (client) mounts, and conversely on shutdown
need to unmount all shares before stopping the server to avoid hangs.
---
 systemd/nfs-server.service | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index 8010aad..b35e193 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -13,6 +13,9 @@ Before= rpc-statd-notify.service
 Wants=auth-rpcgss-module.service
 After=rpc-gssd.service gssproxy.service rpc-svcgssd.service
 
+# start/stop server before/after client
+Before=remote-fs-pre.target
+
 Wants=nfs-config.service
 After=nfs-config.service
 
-- 
2.1.4

