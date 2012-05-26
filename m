Return-Path: linux-nfs-owner@vger.kernel.org
Received: from anakin.london.02.net ([87.194.255.134]:45301 "EHLO
	anakin.london.02.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755190Ab2EZVkB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 May 2012 17:40:01 -0400
Received: from cartman.offog.org (94.194.126.16) by anakin.london.02.net (8.5.140)
        id 4EEB63D203081E45 for linux-nfs@vger.kernel.org; Sat, 26 May 2012 22:33:52 +0100
Received: from ats by cartman.offog.org with local (Exim 4.77)
	(envelope-from <ats@offog.org>)
	id 1SYOcS-0004RX-0L
	for linux-nfs@vger.kernel.org; Sat, 26 May 2012 22:33:52 +0100
Date: Sat, 26 May 2012 22:33:51 +0100
From: Adam Sampson <ats@offog.org>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs-utils 1.2.6: fix osd_login installation
Message-ID: <20120526213351.GZ25787@cartman.at.offog.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(Also worth noting that the NEWS file in nfs-utils is obsolete, and the
README file has the wrong version number in it.)

Installing osd_login would fail if $DESTDIR/sbin didn't exist. Get
automake to do the installation, which'll fix this as a side-effect.

diff -x config.log -x config.status -ru tmp/nfs-utils-1.2.6/utils/osd_login/Makefile.am work/nfs-utils-1.2.6/utils/osd_login/Makefile.am
--- tmp/nfs-utils-1.2.6/utils/osd_login/Makefile.am	2012-05-14 15:40:52.000000000 +0100
+++ work/nfs-utils-1.2.6/utils/osd_login/Makefile.am	2012-05-26 22:25:17.890001662 +0100
@@ -1,12 +1,7 @@
 ## Process this file with automake to produce Makefile.in
 
-OSD_LOGIN_FILES= osd_login
+rootsbindir = /sbin
 
-EXTRA_DIST= $(OSD_LOGIN_FILES)
-
-all-local: $(OSD_LOGIN_FILES)
-
-install-data-hook:
-	$(INSTALL) --mode 755 osd_login $(DESTDIR)/sbin/osd_login
+rootsbin_SCRIPTS = osd_login
 
 MAINTAINERCLEANFILES = Makefile.in

-- 
Adam Sampson <ats@offog.org>                         <http://offog.org/>
