Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58058 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755446AbdLONAv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Dec 2017 08:00:51 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: [PATCH][V2] rpcbind.service: Not pulling the rpcbind.target
Date: Fri, 15 Dec 2017 08:00:47 -0500
Message-Id: <20171215130047.8944-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to systemd.special(7) manpage:

rpcbind.target
    The portmapper/rpcbind pulls in this target and orders itself
    before it, to indicate its availability. systemd automatically
    adds dependencies of type After= for this target unit to
    all SysV init script service units with an LSB header
    referring to the "$portmap" facility.

Signed-off-by: Steve Dickson <steved@redhat.com>
Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1431574
---
 systemd/rpcbind.service.in | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
index f8cfa9f..9dbc82c 100644
--- a/systemd/rpcbind.service.in
+++ b/systemd/rpcbind.service.in
@@ -6,8 +6,8 @@ RequiresMountsFor=@statedir@
 
 # Make sure we use the IP addresses listed for
 # rpcbind.socket, no matter how this unit is started.
-Wants=rpcbind.socket
-After=rpcbind.socket
+Requires=rpcbind.socket
+Before=rpcbind.target
 
 [Service]
 Type=notify
-- 
2.14.3

