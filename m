Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([59.151.112.132]:26566 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751125AbaFEIOd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 04:14:33 -0400
Message-ID: <539026DB.30502@cn.fujitsu.com>
Date: Thu, 5 Jun 2014 16:14:19 +0800
From: Ditang Chen <chendt.fnst@cn.fujitsu.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH]statd: create statdpath dir if specify the "--with-statdpath=xx"
 parameter in configure nfs-utils source code
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When configure the nfs-utils source code with "--with-statdpath=/foo" parameter，
#define NSM_DEFAULT_STATEDIR "/foo" will be generated in support/include/config.h file,
but Makefile will not create "/foo" dir.

Signed-off-by: chendt.fnst@cn.fujitsu.com
---
 Makefile.am | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index ae7cd16..5c9ef44 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -54,10 +54,10 @@ install-data-hook:
 	touch $(DESTDIR)$(statedir)/xtab; chmod 644 $(DESTDIR)$(statedir)/xtab
 	touch $(DESTDIR)$(statedir)/etab; chmod 644 $(DESTDIR)$(statedir)/etab
 	touch $(DESTDIR)$(statedir)/rmtab; chmod 644 $(DESTDIR)$(statedir)/rmtab
-	mkdir -p $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak
 	touch $(DESTDIR)$(statedir)/state
-	chmod go-rwx $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak $(DESTDIR)$(statedir)/state
-	-chown $(statduser) $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak $(DESTDIR)$(statedir)/state
+	mkdir -p $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak
+	chmod go-rwx $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak $(DESTDIR)$(statedir)/state
+	-chown $(statduser) $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak $(DESTDIR)$(statedir)/state
 
 uninstall-hook:
 	rm $(DESTDIR)$(statedir)/xtab
-- 
1.8.2.1
