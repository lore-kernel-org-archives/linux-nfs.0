Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44129 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933151AbaLJVCT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Dec 2014 16:02:19 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBAL2Ja1005897
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 10 Dec 2014 16:02:19 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-56-60.rdu2.redhat.com [10.10.56.60])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sBAL2ITk029637
	for <linux-nfs@vger.kernel.org>; Wed, 10 Dec 2014 16:02:18 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] systemd: added the $BLKMAPDARGS var to the nfs-blkmap service
Date: Wed, 10 Dec 2014 16:02:15 -0500
Message-Id: <1418245335-8935-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/nfs-blkmap.service | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
index 68cc9e9..f470e3d 100644
--- a/systemd/nfs-blkmap.service
+++ b/systemd/nfs-blkmap.service
@@ -13,4 +13,4 @@ PartOf=nfs-utils.service
 [Service]
 Type=forking
 PIDFile=/var/run/blkmapd.pid
-ExecStart=/usr/sbin/blkmapd
+ExecStart=/usr/sbin/blkmapd $BLKMAPDARGS
-- 
2.1.0

