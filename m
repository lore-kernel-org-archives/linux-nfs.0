Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:55868 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755697Ab1FPQX3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2011 12:23:29 -0400
Message-Id: <41c8992e9446c712542515a85a8b4abb83476a9d.1308241259.git.rees@umich.edu>
In-Reply-To: <cover.1308241259.git.rees@umich.edu>
References: <cover.1308241259.git.rees@umich.edu>
Subject: [PATCH 2/2] remove -fwritable-strings for gcc 4.0
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Thu, 16 Jun 2011 12:23:27 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
---
 tests.init |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/tests.init b/tests.init
index 69b51bf..5d93eb5 100644
--- a/tests.init
+++ b/tests.init
@@ -210,6 +210,13 @@ LOCKTESTS=`echo tlocklfs tlock64`
 #UMOUNT=/bin/umount
 #LOCKTESTS=`echo tlocklfs tlock64`
 
+# Use with Linux 2.6 / gcc 4.0
+CFLAGS=`echo -DLINUX -DGLIBC=22 -DMMAP -DSTDARG`
+LIBS=`echo -lnsl`
+MOUNT=/bin/mount
+UMOUNT=/bin/umount
+LOCKTESTS=`echo tlocklfs tlock64`
+
 # Use with Linux if your distro doesn't provide a "cc".
 #CC=gcc
 
-- 
1.7.4.1

