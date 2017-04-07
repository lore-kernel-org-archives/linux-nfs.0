Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49830 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755901AbdDGPHk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 11:07:40 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 74FA08E3EF
        for <linux-nfs@vger.kernel.org>; Fri,  7 Apr 2017 15:07:40 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-122-16.rdu2.redhat.com [10.10.122.16])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 24D439B8E4
        for <linux-nfs@vger.kernel.org>; Fri,  7 Apr 2017 15:07:40 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] systemd: nfs-server service should use network-online
Date: Fri,  7 Apr 2017 11:07:38 -0400
Message-Id: <20170407150738.6200-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There has been an number startup problems where parts of
the NFS server fail to start due to DNS and other
parts of the network not be up.

Reading the systemd.special it seems network.target is
a passive unit which does not wait and network-online.target
is an active unit which does not wait so that
should be used.

Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1419351

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/nfs-server.service | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index 5be5de6..7cf4ae0 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -7,8 +7,8 @@ Wants=rpcbind.socket
 Wants=rpc-statd.service nfs-idmapd.service
 Wants=rpc-statd-notify.service
 
-After= local-fs.target
-After= network.target proc-fs-nfsd.mount rpcbind.socket nfs-mountd.service
+After= local-fs.target network-online.target
+After= proc-fs-nfsd.mount rpcbind.socket nfs-mountd.service
 After= nfs-idmapd.service rpc-statd.service
 Before= rpc-statd-notify.service
 
-- 
2.9.3

