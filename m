Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50504 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753609AbdLNRFq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Dec 2017 12:05:46 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: [PATCH] rpcbind.service: Not pulling the rpcbind.target
Date: Thu, 14 Dec 2017 12:05:44 -0500
Message-Id: <20171214170544.11793-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to systemd.special(7) manpage:

rpcbind.target
    The portmapper/rpcbind pulls in this target and orders itself before it, to indicate its availability. systemd automatically adds dependencies of type After= for this target unit to all SysV init script service units with an LSB header referring to the "$portmap" facility.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/rpcbind.service.in | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
index f8cfa9f..2b49c24 100644
--- a/systemd/rpcbind.service.in
+++ b/systemd/rpcbind.service.in
@@ -6,8 +6,8 @@ RequiresMountsFor=@statedir@
 
 # Make sure we use the IP addresses listed for
 # rpcbind.socket, no matter how this unit is started.
-Wants=rpcbind.socket
-After=rpcbind.socket
+Wants=rpcbind.socket rpcbind.target
+After=rpcbind.socket rpcbind.target
 
 [Service]
 Type=notify
-- 
2.14.3

