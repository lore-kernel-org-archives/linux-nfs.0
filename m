Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63229 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754417AbaBRIs4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Feb 2014 03:48:56 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s1I8mtkx020875
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 18 Feb 2014 03:48:56 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-63-232.rdu2.redhat.com [10.10.63.232])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s1I8mpqS022496
	for <linux-nfs@vger.kernel.org>; Tue, 18 Feb 2014 03:48:55 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] systemd: Removed the "ordering cycle" from nfs-server.service
Date: Tue, 18 Feb 2014 03:48:49 -0500
Message-Id: <1392713329-17979-3-git-send-email-steved@redhat.com>
In-Reply-To: <1392713329-17979-1-git-send-email-steved@redhat.com>
References: <1392713329-17979-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 88ff0417 introduce 'Wants=' statements that
conditionally started other services. Those services
need to be removed from the 'After=' statements
otherwise a systemd ordering cycle is created.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/nfs-server.service | 2 --
 1 file changed, 2 deletions(-)

diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index 26df656..43be4aa 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -7,8 +7,6 @@ Wants=rpc-statd.service nfs-idmapd.service rpc-gssd.service rpc-svcgssd.service
 Wants=rpc-statd-notify.service
 
 After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
-After= nfs-idmapd.service rpc-statd.service
-After= rpc-gssd.service rpc-svcgssd.service
 Before= rpc-statd-notify.service
 
 [Service]
-- 
1.8.5.3

