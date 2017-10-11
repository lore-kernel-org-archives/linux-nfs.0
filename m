Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41754 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751459AbdJKQEN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Oct 2017 12:04:13 -0400
Date: Wed, 11 Oct 2017 12:04:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] minor exports man page typo
Message-ID: <20171011160413.GH25913@fieldses.org>
References: <20171011160243.GG25913@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171011160243.GG25913@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

---
 utils/exportfs/exports.man | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index d8de6bec2583..db47dfdee775 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -410,7 +410,7 @@ of the filesystem must be handled elsewhere.)
 
 .TP
 .IR pnfs
-This option allows enables the use of pNFS extension if protocol level
+This option enables the use of the pNFS extension if the protocol level
 is NFSv4.1 or higher, and the filesystem supports pNFS exports.  With
 pNFS clients can bypass the server and perform I/O directly to storage
 devices. The default can be explicitly requested with the
-- 
2.13.5

