Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54008 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1169990AbdDXP1y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Apr 2017 11:27:54 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 5747AC05490A
        for <linux-nfs@vger.kernel.org>; Mon, 24 Apr 2017 15:27:54 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-122-178.rdu2.redhat.com [10.10.122.178])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 089648367F
        for <linux-nfs@vger.kernel.org>; Mon, 24 Apr 2017 15:27:53 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] systemd: Afters are also needed for the Wants=network-online.target
Date: Mon, 24 Apr 2017 11:27:52 -0400
Message-Id: <20170424152752.25730-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 9d4fc3fb added Wants=network-online.target which
is not enough to ensure the network is completely up
before the NFS server is started. After=network-online.target
is also needed.

Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1419351

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/nfs-mountd.service       | 1 +
 systemd/nfs-server.service       | 2 +-
 systemd/rpc-statd-notify.service | 2 +-
 systemd/rpc-statd.service        | 2 +-
 4 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
index fec0399..e8ece53 100644
--- a/systemd/nfs-mountd.service
+++ b/systemd/nfs-mountd.service
@@ -4,6 +4,7 @@ DefaultDependencies=no
 Requires=proc-fs-nfsd.mount
 Wants=network-online.target
 After=proc-fs-nfsd.mount
+After=network-online.target local-fs.target
 After=rpcbind.socket
 BindsTo=nfs-server.service
 
diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index e6b8f58..136552b 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -7,7 +7,7 @@ Wants=rpcbind.socket network-online.target
 Wants=rpc-statd.service nfs-idmapd.service
 Wants=rpc-statd-notify.service
 
-After= local-fs.target
+After= network-online.target local-fs.target
 After= proc-fs-nfsd.mount rpcbind.socket nfs-mountd.service
 After= nfs-idmapd.service rpc-statd.service
 Before= rpc-statd-notify.service
diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service
index f54d4c5..687fe31 100644
--- a/systemd/rpc-statd-notify.service
+++ b/systemd/rpc-statd-notify.service
@@ -2,7 +2,7 @@
 Description=Notify NFS peers of a restart
 DefaultDependencies=no
 Wants=network-online.target
-After=local-fs.target network.target nss-lookup.target
+After=local-fs.target network-online.target nss-lookup.target
 
 # if we run an nfs server, it needs to be running before we
 # tell clients that it has restarted.
diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
index 8cef022..f41ae20 100644
--- a/systemd/rpc-statd.service
+++ b/systemd/rpc-statd.service
@@ -4,7 +4,7 @@ DefaultDependencies=no
 Conflicts=umount.target
 Requires=nss-lookup.target rpcbind.socket
 Wants=network-online.target
-After=nss-lookup.target rpcbind.socket
+After=network-online.target nss-lookup.target rpcbind.socket
 
 PartOf=nfs-utils.service
 
-- 
2.9.3

