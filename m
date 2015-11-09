Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39422 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751660AbbKIQdF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Nov 2015 11:33:05 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id D5FA191EAA
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2015 16:33:05 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-54-90.rdu2.redhat.com [10.10.54.90])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tA9GX4Kx024379
	for <linux-nfs@vger.kernel.org>; Mon, 9 Nov 2015 11:33:05 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] systemd: Decouple the starting and stopping of rpcbind/nfs-server
Date: Mon,  9 Nov 2015 11:33:03 -0500
Message-Id: <1447086783-17977-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit b98f2af15 introduced a regression that cause the
starting and stop of rpcbind and the nfs-server to
be depended on each other

The starting of the NFS server should start rpcbind
but bring rpcbind down should not bring the NFS
server down.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/nfs-server.service | 2 +-
 systemd/rpc-statd.service  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index 12b02f2..317e5d6 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -1,7 +1,7 @@
 [Unit]
 Description=NFS server and services
 DefaultDependencies=no
-Requires= network.target proc-fs-nfsd.mount rpcbind.service
+Requires= network.target proc-fs-nfsd.mount rpcbind.target
 Requires= nfs-mountd.service
 Wants=rpc-statd.service nfs-idmapd.service
 Wants=rpc-statd-notify.service
diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
index 14604d7..f16ea42 100644
--- a/systemd/rpc-statd.service
+++ b/systemd/rpc-statd.service
@@ -3,7 +3,7 @@ Description=NFS status monitor for NFSv2/3 locking.
 DefaultDependencies=no
 Conflicts=umount.target
 Requires=nss-lookup.target rpcbind.target
-After=network.target nss-lookup.target rpcbind.target
+After=network.target nss-lookup.target rpcbind.service
 
 PartOf=nfs-utils.service
 
-- 
2.4.3

