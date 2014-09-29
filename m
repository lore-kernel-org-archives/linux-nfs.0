Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58253 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751601AbaI2Pew (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2014 11:34:52 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8TFYp6J005746
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 29 Sep 2014 11:34:51 -0400
Received: from smallhat.boston.devel.redhat.com (vpn-58-57.rdu2.redhat.com [10.10.58.57])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s8TFYLO0023219
	for <linux-nfs@vger.kernel.org>; Mon, 29 Sep 2014 11:34:43 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfs-client.target: Removed a ordering cycle with nfs-server.service
Date: Mon, 29 Sep 2014 11:33:37 -0400
Message-Id: <1412004817-14432-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On a VM that boots very fast and with out kerberos
enabled a systemd ordering cycle happens between
nfs-client and nfs-server units when both were
enabled.

Having nfs-client start the gssd daemons in the
same matter as the nfs-server does ('After=') seemed
to eliminated the ordering cycle.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/nfs-client.target | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/systemd/nfs-client.target b/systemd/nfs-client.target
index 474f5e9..87a1ce8 100644
--- a/systemd/nfs-client.target
+++ b/systemd/nfs-client.target
@@ -7,7 +7,7 @@ Wants=remote-fs-pre.target
 # start that on demand if needed.
 Wants=rpc-gssd.service rpc-svcgssd.service auth-rpcgss-module.service
 Wants=nfs-blkmap.service rpc-statd-notify.service
-Before=rpc-gssd.service rpc-svcgssd.service nfs-blkmap.service
+After=rpc-gssd.service rpc-svcgssd.service nfs-blkmap.service
 
 [Install]
 WantedBy=multi-user.target
-- 
1.9.3

