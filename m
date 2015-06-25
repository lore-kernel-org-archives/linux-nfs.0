Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40599 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751561AbbFYPQY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Jun 2015 11:16:24 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 5558C37C385
	for <linux-nfs@vger.kernel.org>; Thu, 25 Jun 2015 15:16:24 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-56-13.rdu2.redhat.com [10.10.56.13])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t5PFGNsD010112
	for <linux-nfs@vger.kernel.org>; Thu, 25 Jun 2015 11:16:23 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfs-server: Use rpcbind.service instead of rpbind.target
Date: Thu, 25 Jun 2015 11:16:21 -0400
Message-Id: <1435245381-25085-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To trigger the systemd socket activation support
in rpcbind, nfs-service needs to Requires/After
rpcbind.service instead of rpbind.target

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/nfs-server.service | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index db801cb..12b02f2 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -1,13 +1,13 @@
 [Unit]
 Description=NFS server and services
 DefaultDependencies=no
-Requires= network.target proc-fs-nfsd.mount rpcbind.target
+Requires= network.target proc-fs-nfsd.mount rpcbind.service
 Requires= nfs-mountd.service
 Wants=rpc-statd.service nfs-idmapd.service
 Wants=rpc-statd-notify.service
 
 After= local-fs.target
-After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
+After= network.target proc-fs-nfsd.mount rpcbind.service nfs-mountd.service
 After= nfs-idmapd.service rpc-statd.service
 Before= rpc-statd-notify.service
 
-- 
2.4.3

