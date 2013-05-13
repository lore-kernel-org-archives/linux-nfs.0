Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gerard.telenet-ops.be ([195.130.132.48]:33102 "EHLO
	gerard.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751968Ab3EMSDv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 May 2013 14:03:51 -0400
From: Luk Claes <luk@debian.org>
To: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Cc: Luk Claes <luk@debian.org>
Subject: [PATCH] nfsidmap: add default id_resolver.conf
Date: Mon, 13 May 2013 20:03:43 +0200
Message-Id: <1368468223-21982-1-git-send-email-luk@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ship default id_resolver.conf to put into /etc/request-key.d so
it is impossible to forget to add the file while upgrading.
---
 utils/nfsidmap/id_resolver.conf |    1 +
 1 file changed, 1 insertion(+)
 create mode 100644 utils/nfsidmap/id_resolver.conf

diff --git a/utils/nfsidmap/id_resolver.conf b/utils/nfsidmap/id_resolver.conf
new file mode 100644
index 0000000..2c156c6
--- /dev/null
+++ b/utils/nfsidmap/id_resolver.conf
@@ -0,0 +1 @@
+create	id_resolver	*	*	/usr/sbin/nfsidmap -t 600 %k %d
-- 
1.7.10.4

