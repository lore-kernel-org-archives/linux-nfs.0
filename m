Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([59.151.112.132]:41067 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751419AbaFFDRS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 23:17:18 -0400
Message-ID: <539132AF.8060805@cn.fujitsu.com>
Date: Fri, 6 Jun 2014 11:17:03 +0800
From: Ditang Chen <chendt.fnst@cn.fujitsu.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Trond Myklebust <trond.myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "yaoxp@cn.fujitsu.com" <yaoxp@cn.fujitsu.com>
Subject: [PATCH]statd: create statdpath dir if specify the "--with-statdpath=xx"
 parameter in configure nfs-utils source code
References: <539026DB.30502@cn.fujitsu.com>
In-Reply-To: <539026DB.30502@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When configure the nfs-utils source code with "--with-statdpath=/foo" parameter，
#define NSM_DEFAULT_STATEDIR "/foo" will be generated in support/include/config.h file,
but Makefile will not create "/foo" dir.

Signed-off-by: chendt.fnst@cn.fujitsu.com
Reported-by: yaoxp@cn.fujitsu.com
---
 Makefile.am | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index ae7cd16..5824adc 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -54,13 +54,13 @@ install-data-hook:
        touch $(DESTDIR)$(statedir)/xtab; chmod 644 $(DESTDIR)$(statedir)/xtab
        touch $(DESTDIR)$(statedir)/etab; chmod 644 $(DESTDIR)$(statedir)/etab
        touch $(DESTDIR)$(statedir)/rmtab; chmod 644 $(DESTDIR)$(statedir)/rmtab
-       mkdir -p $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak
-       touch $(DESTDIR)$(statedir)/state
-       chmod go-rwx $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak $(DESTDIR)$(statedir)/state
-       -chown $(statduser) $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak $(DESTDIR)$(statedir)/state
+       mkdir -p $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak
+       touch $(DESTDIR)$(statdpath)/state
+       chmod go-rwx $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak $(DESTDIR)$(statdpath)/state
+       -chown $(statduser) $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak $(DESTDIR)$(statdpath)/state

 uninstall-hook:
        rm $(DESTDIR)$(statedir)/xtab
        rm $(DESTDIR)$(statedir)/etab
        rm $(DESTDIR)$(statedir)/rmtab
-       rm $(DESTDIR)$(statedir)/state
+       rm $(DESTDIR)$(statdpath)/state
-- 
1.8.2.1

