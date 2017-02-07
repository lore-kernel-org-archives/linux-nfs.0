Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f176.google.com ([209.85.216.176]:34329 "EHLO
        mail-qt0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754715AbdBGTQy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 14:16:54 -0500
Received: by mail-qt0-f176.google.com with SMTP id w20so139260853qtb.1
        for <linux-nfs@vger.kernel.org>; Tue, 07 Feb 2017 11:16:54 -0800 (PST)
From: Rafael David Tinoco <rafael.tinoco@canonical.com>
To: linux-nfs@vger.kernel.org
Cc: neilb@suse.com
Subject: [PATCH] Fix nfs-mountd dependency on rpcbind
Date: Tue,  7 Feb 2017 17:16:50 -0200
Message-Id: <20170207191650.19219-1-rafael.tinoco@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Following commit 91da135f - it replaced "rpcbind.target" by "rpcbind.socket" in
some unit files - "rpcbind.socket" should also be added to "nfs-mountd.service"
as a dependency to avoid race conditions.

Usually "rpcbind.socket" is either started as a "sockets.target" dependency, or
as a dependency for "nfs-server.service", when unit files include it in
"BindsTo" or "After". Unfortunately there is a possilibility to have
"nfs-mountd.service" started when the rpcbind socket is not yet created:

systemd[1]: Starting NFS Mount Daemon...
systemd[1]: nfs-mountd.service: Control process exited, code=exited status=1
systemd[1]: Failed to start NFS Mount Daemon.
systemd[1]: nfs-mountd.service: Unit entered failed state.
systemd[1]: nfs-mountd.service: Failed with result 'exit-code'.

Nowadays "nfs-mountd.service" uses "BindTo" directive to "nfs-server.service".
That, per se, doesn't guarantee ordering for NFS server to start rpcbind and for
nfs-mountd to depend on it.

https://bugs.launchpad.net/bugs/1590799

Signed-off-by: Rafael David Tinoco <rafael.tinoco@canonical.com>
---
 systemd/nfs-mountd.service | 1 +
 1 file changed, 1 insertion(+)

diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
index 15e828b..b0a8bc0 100644
--- a/systemd/nfs-mountd.service
+++ b/systemd/nfs-mountd.service
@@ -4,6 +4,7 @@ DefaultDependencies=no
 Requires=proc-fs-nfsd.mount
 After=proc-fs-nfsd.mount
 After=network.target local-fs.target
+After=rpcbind.socket
 BindsTo=nfs-server.service
 
 [Service]
-- 
2.9.3

