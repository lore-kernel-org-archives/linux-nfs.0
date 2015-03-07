Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38770 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750842AbbCGT2h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Mar 2015 14:28:37 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t27JSaoY016772
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Sat, 7 Mar 2015 14:28:36 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-63-70.rdu2.redhat.com [10.10.63.70])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t27JSa1J009476
	for <linux-nfs@vger.kernel.org>; Sat, 7 Mar 2015 14:28:36 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfs-blkmap.service: add EnvironmentFile directive
Date: Sat,  7 Mar 2015 14:28:34 -0500
Message-Id: <1425756514-22118-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixes: https://bugzilla.linux-nfs.org/show_bug.cgi?id=281

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/nfs-blkmap.service | 1 +
 1 file changed, 1 insertion(+)

diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
index f470e3d..8ad3b03 100644
--- a/systemd/nfs-blkmap.service
+++ b/systemd/nfs-blkmap.service
@@ -13,4 +13,5 @@ PartOf=nfs-utils.service
 [Service]
 Type=forking
 PIDFile=/var/run/blkmapd.pid
+EnvironmentFile=-/run/sysconfig/nfs-utils
 ExecStart=/usr/sbin/blkmapd $BLKMAPDARGS
-- 
2.1.0

