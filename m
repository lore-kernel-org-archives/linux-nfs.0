Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:45951 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752850Ab2CSMxH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2012 08:53:07 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1S9c5B-0000X9-DV
	for linux-nfs@vger.kernel.org; Mon, 19 Mar 2012 08:53:05 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] Makefile.am: install target in doc/Makefile.am doesn't honor sysconfdir
Date: Mon, 19 Mar 2012 08:51:48 -0400
Message-Id: <1332161508-20391-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 doc/Makefile.am |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/doc/Makefile.am b/doc/Makefile.am
index cc4fa76..f8c88b5 100644
--- a/doc/Makefile.am
+++ b/doc/Makefile.am
@@ -1,5 +1,5 @@
 
 install: install-am
-	$(mkinstalldirs) $(DESTDIR)/etc
-	cp -p ./etc_netconfig $(DESTDIR)/etc/netconfig
-	chmod 0644 $(DESTDIR)/etc/netconfig
+	$(mkinstalldirs) $(DESTDIR)/$(sysconfdir)
+	cp -p ./etc_netconfig $(DESTDIR)/$(sysconfdir)/netconfig
+	chmod 0644 $(DESTDIR)/$(sysconfdir)/netconfig
-- 
1.7.7.5

