Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:47482 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116Ab1F0ViV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jun 2011 17:38:21 -0400
Date: Mon, 27 Jun 2011 17:38:19 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] comment out linux 2.6 section
Message-ID: <20110627213819.GA4872@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

These should have been commented out in my previous patch that added these
lines.  Linux users will uncomment them as needed.

Signed-off-by: Jim Rees <rees@umich.edu>
---
 tests.init |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tests.init b/tests.init
index 5d93eb5..4e68930 100644
--- a/tests.init
+++ b/tests.init
@@ -211,11 +211,11 @@ LOCKTESTS=`echo tlocklfs tlock64`
 #LOCKTESTS=`echo tlocklfs tlock64`
 
 # Use with Linux 2.6 / gcc 4.0
-CFLAGS=`echo -DLINUX -DGLIBC=22 -DMMAP -DSTDARG`
-LIBS=`echo -lnsl`
-MOUNT=/bin/mount
-UMOUNT=/bin/umount
-LOCKTESTS=`echo tlocklfs tlock64`
+#CFLAGS=`echo -DLINUX -DGLIBC=22 -DMMAP -DSTDARG`
+#LIBS=`echo -lnsl`
+#MOUNT=/bin/mount
+#UMOUNT=/bin/umount
+#LOCKTESTS=`echo tlocklfs tlock64`
 
 # Use with Linux if your distro doesn't provide a "cc".
 #CC=gcc
-- 
1.7.4.1
