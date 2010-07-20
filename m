From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 01/24] Enable extra compile warnings (-Wextra) by default.
Date: Tue, 20 Jul 2010 19:37:14 -0400
Message-ID: <1279669057-17509-2-git-send-email-steved@redhat.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:60369 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761882Ab0GUAm4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 20:42:56 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1ObMNW-0004K5-9J
	for linux-nfs@vger.kernel.org; Tue, 20 Jul 2010 19:37:38 -0400
In-Reply-To: <1279669057-17509-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Added -Wextra to the CFLAGS which enables more checking
during compilation, which in turn, will hopefully flag
potential problems before they occur.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/configure.ac b/configure.ac
index d90a88f..7c9e61a 100644
--- a/configure.ac
+++ b/configure.ac
@@ -400,7 +400,7 @@ case $host in
     ARCHFLAGS="" ;;
 esac
 
-my_am_cflags="-Wall -Wstrict-prototypes $ARCHFLAGS -pipe"
+my_am_cflags="-Wall -Wextra -Wstrict-prototypes $ARCHFLAGS -pipe"
 
 AC_SUBST([AM_CFLAGS], ["$my_am_cflags"])
 
-- 
1.7.0.1

