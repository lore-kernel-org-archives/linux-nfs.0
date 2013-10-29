Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:22038 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754131Ab3J2Q1v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Oct 2013 12:27:51 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] nfs.man: add description of multiple sec= options
Date: Tue, 29 Oct 2013 12:27:46 -0400
Message-ID: <1383064066-1139-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The client now supports multiple sec= options as a colon delimited list.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 utils/mount/nfs.man | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 2a42b93..17b8d88 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -380,9 +380,10 @@ If a value of zero is specified, the
 .BR mount (8)
 command exits immediately after the first failure.
 .TP 1.5i
-.BI sec= flavor
-The security flavor to use for accessing files on this mount point.
-If the server does not support this flavor, the mount operation fails.
+.BI sec= flavors
+A colon-delimited list of security flavors to use for accessing files on
+this mount point. If the server does not support any of these flavors,
+the mount operation fails.
 If
 .B sec=
 is not specified, the client attempts to find
-- 
1.8.3.1 (Apple Git-46)

