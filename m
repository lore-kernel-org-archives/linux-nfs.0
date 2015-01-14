Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36278 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753266AbbANPqz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jan 2015 10:46:55 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: [PATCH 1/3] systemd: Bind rpc.idmapd to the nfs-server service
Date: Wed, 14 Jan 2015 10:46:48 -0500
Message-Id: <1421250410-7246-2-git-send-email-steved@redhat.com>
In-Reply-To: <1421250410-7246-1-git-send-email-steved@redhat.com>
References: <1421250410-7246-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since rpc.idmapd is only used by the nfs server,
to do its id mapping, bind the rpc-idmapd service
to the nfs-server service so rpc.idmapd will
started and stopped with the server.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/nfs-idmapd.service | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
index 11895e2..726038d 100644
--- a/systemd/nfs-idmapd.service
+++ b/systemd/nfs-idmapd.service
@@ -1,7 +1,7 @@
 [Unit]
 Description=NFSv4 ID-name mapping service
 
-PartOf=nfs-utils.service
+BindsTo=nfs-server.service
 
 Wants=nfs-config.service
 After=nfs-config.service
-- 
2.1.0

