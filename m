Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44364 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752089AbaKZTOD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Nov 2014 14:14:03 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sAQJE3IM004469
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:14:03 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sAQJE2Da023681
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:14:03 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sAQJE2OW037786
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:14:02 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sAQJE2mu037785
	for linux-nfs@vger.kernel.org; Wed, 26 Nov 2014 14:14:02 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 17/17] mountstats: add ms-iostat and ms-nfsstat to Makefile.am
Date: Wed, 26 Nov 2014 14:13:55 -0500
Message-Id: <1417029235-37675-18-git-send-email-smayhew@redhat.com>
In-Reply-To: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
References: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/Makefile.am | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/tools/mountstats/Makefile.am b/tools/mountstats/Makefile.am
index c2e9f99..05cc4e5 100644
--- a/tools/mountstats/Makefile.am
+++ b/tools/mountstats/Makefile.am
@@ -1,7 +1,7 @@
 ## Process this file with automake to produce Makefile.in
 PYTHON_FILES =  mountstats.py
 
-man8_MANS	= mountstats.man
+man8_MANS	= mountstats.man ms-iostat.man ms-nfsstat.man
 
 EXTRA_DIST	= $(man8_MANS) $(PYTHON_FILES)
 
@@ -9,5 +9,7 @@ all-local: $(PYTHON_FILES)
 
 install-data-hook:
 	$(INSTALL) -m 755 mountstats.py $(DESTDIR)$(sbindir)/mountstats
+	ln -sf $(DESTDIR)$(sbindir)/mountstats $(DESTDIR)$(sbindir)/ms-iostat
+	ln -sf $(DESTDIR)$(sbindir)/mountstats $(DESTDIR)$(sbindir)/ms-nfsstat
 
 MAINTAINERCLEANFILES=Makefile.in
-- 
1.9.3

