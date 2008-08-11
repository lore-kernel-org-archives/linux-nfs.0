From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] remove idmapd.conf
Date: Sun, 10 Aug 2008 23:16:25 -0400
Message-ID: <20080811031625.GA6033@fieldses.org>
References: <1218422830-5465-1-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59523 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750846AbYHKDQ1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Aug 2008 23:16:27 -0400
In-Reply-To: <1218422830-5465-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

The example idmapd.conf file is kept in libnfsidmap now, which is what's
responsible for parsing it anyway.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 utils/idmapd/idmapd.conf |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)
 delete mode 100644 utils/idmapd/idmapd.conf

Oh, also, this is unrelated, but: I just noticed I had this still lying
around.

--b.

diff --git a/utils/idmapd/idmapd.conf b/utils/idmapd/idmapd.conf
deleted file mode 100644
index acafd4b..0000000
--- a/utils/idmapd/idmapd.conf
+++ /dev/null
@@ -1,10 +0,0 @@
-[General]
-
-Verbosity = 0
-Pipefs-Directory = /var/lib/nfs/rpc_pipefs
-Domain = localdomain
-
-[Mapping]
-
-Nobody-User = nobody
-Nobody-Group = nobody
-- 
1.5.5.rc1

