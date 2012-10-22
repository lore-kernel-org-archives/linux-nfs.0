Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 183.141.211.66.inaddr.G4.NET ([66.211.141.183]:42400 "EHLO
	Dobby.4dicksons.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755015Ab2JVVhQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2012 17:37:16 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1TQPBP-00032e-AO
	for linux-nfs@vger.kernel.org; Mon, 22 Oct 2012 17:05:16 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] Added more compile warning options
Date: Mon, 22 Oct 2012 17:00:54 -0400
Message-Id: <1350939654-25126-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To ensure the code compiles cleaner, the following warning options
are now set
    -Wall -Wextra -Wstrict-prototypes -Wstrict-aliasing
    -Wconversion -Wsign-conversion -Wmissing-prototypes
    -Wsign-conversion -pedantic -Wmissing-prototypes

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index a174bf4..197823f 100644
--- a/configure.ac
+++ b/configure.ac
@@ -448,7 +448,11 @@ case $host in
     ARCHFLAGS="" ;;
 esac
 
-my_am_cflags="-Wall -Wextra -Wstrict-prototypes $ARCHFLAGS -pipe"
+WFLAGS="-Wall -Wextra -Wstrict-prototypes -Wstrict-aliasing \
+	-Wconversion -Wsign-conversion -Wmissing-prototypes \
+	-Wsign-conversion -pedantic -Wmissing-prototypes"
+
+my_am_cflags="$WFLAGS $ARCHFLAGS -pipe"
 
 AC_SUBST([AM_CFLAGS], ["$my_am_cflags"])
 
-- 
1.7.11.7

