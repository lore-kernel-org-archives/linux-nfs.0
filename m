Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56762 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752333Ab1KJU0H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Nov 2011 15:26:07 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pAAKQ68u024948
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 10 Nov 2011 15:26:06 -0500
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id pAAKQ5Dh030911
	for <linux-nfs@vger.kernel.org>; Thu, 10 Nov 2011 15:26:06 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] Enable the in-kernel ID mapping upcall mechanism
Date: Thu, 10 Nov 2011 15:26:02 -0500
Message-Id: <1320956763-17935-2-git-send-email-steved@redhat.com>
In-Reply-To: <1320956763-17935-1-git-send-email-steved@redhat.com>
References: <1320956763-17935-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To solve deadlocks that can occur between the rpc.idmapd daemon
and the kernel, enables the in-kernel upcall mechanism that 
uses the key rings to start the user/group ids.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/Kconfig |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index dbcd821..94ad028 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -134,12 +134,6 @@ config NFS_USE_KERNEL_DNS
 	default y
 
 config NFS_USE_NEW_IDMAPPER
-	bool "Use the new idmapper upcall routine"
+	bool "Use the idmapper upcall routine"
 	depends on NFS_V4 && KEYS
-	help
-	  Say Y here if you want NFS to use the new idmapper upcall functions.
-	  You will need /sbin/request-key (usually provided by the keyutils
-	  package).  For details, read
-	  <file:Documentation/filesystems/nfs/idmapper.txt>.
-
-	  If you are unsure, say N.
+	default y
-- 
1.7.6.4

