Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:56221 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753002Ab1KLPxj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Nov 2011 10:53:39 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1RPFrG-0003ID-Q4
	for linux-nfs@vger.kernel.org; Sat, 12 Nov 2011 10:51:06 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] Enable the in-kernel ID mapping upcall mechanism
Date: Sat, 12 Nov 2011 10:53:36 -0500
Message-Id: <1321113217-10018-2-git-send-email-steved@redhat.com>
In-Reply-To: <1321113217-10018-1-git-send-email-steved@redhat.com>
References: <1321113217-10018-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To solve deadlocks that can occur between the rpc.idmapd daemon
and the kernel, enables the in-kernel upcall mechanism that
uses the key rings to store the user/group ids.

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
1.7.7

