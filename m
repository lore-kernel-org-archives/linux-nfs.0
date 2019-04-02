Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BF32C4360F
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 09:26:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 59E6720856
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 09:26:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729609AbfDBJ0I (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 05:26:08 -0400
Received: from mx1.redhat.com ([209.132.183.28]:52434 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726284AbfDBJ0I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 2 Apr 2019 05:26:08 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 0B3E63132C5F
        for <linux-nfs@vger.kernel.org>; Tue,  2 Apr 2019 09:26:08 +0000 (UTC)
Received: from yoyang-pc.usersys.redhat.com (dhcp-12-206.nay.redhat.com [10.66.12.206])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id D381062478;
        Tue,  2 Apr 2019 09:26:06 +0000 (UTC)
Date:   Tue, 2 Apr 2019 17:26:03 +0800
From:   Yongcheng Yang <yongcheng.yang@gmail.com>
To:     Steve Dickson <steved@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: nfsidmap fail to build if no
 --with-pluginpath specified
Message-ID: <20190402092602.GC10577@yoyang-pc.usersys.redhat.com>
References: <20190402091651.17186-1-yongcheng.yang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190402091651.17186-1-yongcheng.yang@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Tue, 02 Apr 2019 09:26:08 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello Steve,

I'm not sure if this backward fix is okay or there's some better solution.

Here is the testlogs:

###############################
# Previously without the patch:
###############################

[root@ nfs-utils]# git diff
[root@ nfs-utils]# (sh autogen.sh && ./configure ) >/dev/null 2>&1
[root@ nfs-utils]# cd -
/root/bz1624542-use-after-free-in-statd-monitor-list-if-insertion-fails/nfs-utils/support/nfsidmap
[root@ nfsidmap]# make clean && make 
test -z "libnfsidmap.la" || rm -f libnfsidmap.la
rm -f ./so_locations
rm -rf .libs _libs
test -z "nsswitch.la static.la  " || rm -f nsswitch.la static.la  
rm -f ./so_locations
rm -f *.o
rm -f *.lo
...
<snip>
...
/bin/sh ../../libtool  --tag=CC   --mode=link gcc -pipe  -Wall  -Wextra  -Werror=strict-prototypes  -Werror=missing-prototypes  -Werror=missing-declarations  -Werror=format=2  -Werror=undef  -Werror=missing-include-dirs  -Werror=strict-aliasing=2  -Werror=init-self  -Werror=implicit-function-declaration  -Werror=return-type  -Werror=switch  -Werror=overflow  -Werror=parentheses  -Werror=aggregate-return  -Werror=unused-result  -fno-strict-aliasing      -g -O2 -module -avoid-version  -o nsswitch.la -rpath  nss.lo nfsidmap_common.lo ../../support/nfs/libnfsconf.la -lresolv 
libtool: link: only absolute run-paths are allowed
make: *** [nsswitch.la] Error 1
[root@ nfsidmap]# 
[root@ nfsidmap]# 
[root@ nfsidmap]# grep rpath Makefile | grep "pkgplugindir"
Makefile:#am_gums_la_rpath = -rpath $(pkgplugindir)
Makefile:#am_umich_ldap_la_rpath = -rpath $(pkgplugindir)
Makefile:       $(AM_V_CCLD)$(nsswitch_la_LINK) -rpath $(pkgplugindir) $(nsswitch_la_OBJECTS) $(nsswitch_la_LIBADD) $(LIBS)
Makefile:       $(AM_V_CCLD)$(static_la_LINK) -rpath $(pkgplugindir) $(static_la_OBJECTS) $(static_la_LIBADD) $(LIBS)
[root@ nfsidmap]# 


##################
# After this patch:
##################
[root@ nfsidmap]# git diff
diff --git a/support/nfsidmap/Makefile.am b/support/nfsidmap/Makefile.am
index cdbeb4c..9c21fa3 100644
--- a/support/nfsidmap/Makefile.am
+++ b/support/nfsidmap/Makefile.am
@@ -1,4 +1,8 @@
+if PATH_PLUGINS
 pkgplugindir=$(PATH_PLUGINS)
+else
+pkgplugindir=$(libdir)/libnfsidmap
+endif
 
 if ENABLE_LDAP
 UMICH_LDAP_LIB = umich_ldap.la
[root@ nfsidmap]#
[root@ nfs-utils]# (sh autogen.sh && ./configure ) >/dev/null 2>&1
[root@ nfs-utils]# cd -
/root/bz1624542-use-after-free-in-statd-monitor-list-if-insertion-fails/nfs-utils/support/nfsidmap
[root@ nfsidmap]# make clean && make 
test -z "libnfsidmap.la" || rm -f libnfsidmap.la
rm -f ./so_locations
rm -rf .libs _libs
test -z "nsswitch.la static.la  " || rm -f nsswitch.la static.la  
rm -f ./so_locations
rm -f *.o
rm -f *.lo
...
<snip>
...
/bin/sh ../../libtool  --tag=CC   --mode=link gcc -pipe  -Wall  -Wextra  -Werror=strict-prototypes  -Werror=missing-prototypes  -Werror=missing-declarations  -Werror=format=2  -Werror=undef  -Werror=missing-include-dirs  -Werror=strict-aliasing=2  -Werror=init-self  -Werror=implicit-function-declaration  -Werror=return-type  -Werror=switch  -Werror=overflow  -Werror=parentheses  -Werror=aggregate-return  -Werror=unused-result  -fno-strict-aliasing      -g -O2 -module -avoid-version  -o nsswitch.la -rpath /usr/lib/libnfsidmap nss.lo nfsidmap_common.lo ../../support/nfs/libnfsconf.la -lresolv 
libtool: link: gcc -shared  -fPIC -DPIC  .libs/nss.o .libs/nfsidmap_common.o  -Wl,--whole-archive ../../support/nfs/.libs/libnfsconf.a -Wl,--no-whole-archive  -lresolv  -O2   -Wl,-soname -Wl,nsswitch.so -o .libs/nsswitch.so
libtool: link: (cd .libs/nsswitch.lax/libnfsconf.a && ar x "/root/bz1624542-use-after-free-in-statd-monitor-list-if-insertion-fails/nfs-utils/support/nfsidmap/../../support/nfs/.libs/libnfsconf.a")
libtool: link: ar cru .libs/nsswitch.a  nss.o nfsidmap_common.o  .libs/nsswitch.lax/libnfsconf.a/conffile.o .libs/nsswitch.lax/libnfsconf.a/xlog.o 
libtool: link: ranlib .libs/nsswitch.a
libtool: link: rm -fr .libs/nsswitch.lax
libtool: link: ( cd ".libs" && rm -f "nsswitch.la" && ln -s "../nsswitch.la" "nsswitch.la" )
/bin/sh ../../libtool  --tag=CC   --mode=compile gcc -DHAVE_CONFIG_H -I. -I../../support/include  -I/usr/include/tirpc   -D_GNU_SOURCE -pipe  -Wall  -Wextra  -Werror=strict-prototypes  -Werror=missing-prototypes  -Werror=missing-declarations  -Werror=format=2  -Werror=undef  -Werror=missing-include-dirs  -Werror=strict-aliasing=2  -Werror=init-self  -Werror=implicit-function-declaration  -Werror=return-type  -Werror=switch  -Werror=overflow  -Werror=parentheses  -Werror=aggregate-return  -Werror=unused-result  -fno-strict-aliasing      -g -O2 -MT static.lo -MD -MP -MF .deps/static.Tpo -c -o static.lo static.c
libtool: compile:  gcc -DHAVE_CONFIG_H -I. -I../../support/include -I/usr/include/tirpc -D_GNU_SOURCE -pipe -Wall -Wextra -Werror=strict-prototypes -Werror=missing-prototypes -Werror=missing-declarations -Werror=format=2 -Werror=undef -Werror=missing-include-dirs -Werror=strict-aliasing=2 -Werror=init-self -Werror=implicit-function-declaration -Werror=return-type -Werror=switch -Werror=overflow -Werror=parentheses -Werror=aggregate-return -Werror=unused-result -fno-strict-aliasing -g -O2 -MT static.lo -MD -MP -MF .deps/static.Tpo -c static.c  -fPIC -DPIC -o .libs/static.o
libtool: compile:  gcc -DHAVE_CONFIG_H -I. -I../../support/include -I/usr/include/tirpc -D_GNU_SOURCE -pipe -Wall -Wextra -Werror=strict-prototypes -Werror=missing-prototypes -Werror=missing-declarations -Werror=format=2 -Werror=undef -Werror=missing-include-dirs -Werror=strict-aliasing=2 -Werror=init-self -Werror=implicit-function-declaration -Werror=return-type -Werror=switch -Werror=overflow -Werror=parentheses -Werror=aggregate-return -Werror=unused-result -fno-strict-aliasing -g -O2 -MT static.lo -MD -MP -MF .deps/static.Tpo -c static.c -o static.o >/dev/null 2>&1
mv -f .deps/static.Tpo .deps/static.Plo
/bin/sh ../../libtool  --tag=CC   --mode=link gcc -pipe  -Wall  -Wextra  -Werror=strict-prototypes  -Werror=missing-prototypes  -Werror=missing-declarations  -Werror=format=2  -Werror=undef  -Werror=missing-include-dirs  -Werror=strict-aliasing=2  -Werror=init-self  -Werror=implicit-function-declaration  -Werror=return-type  -Werror=switch  -Werror=overflow  -Werror=parentheses  -Werror=aggregate-return  -Werror=unused-result  -fno-strict-aliasing      -g -O2 -module -avoid-version  -o static.la -rpath /usr/lib/libnfsidmap static.lo ../../support/nfs/libnfsconf.la -lresolv 
libtool: link: gcc -shared  -fPIC -DPIC  .libs/static.o  -Wl,--whole-archive ../../support/nfs/.libs/libnfsconf.a -Wl,--no-whole-archive  -lresolv  -O2   -Wl,-soname -Wl,static.so -o .libs/static.so
libtool: link: (cd .libs/static.lax/libnfsconf.a && ar x "/root/bz1624542-use-after-free-in-statd-monitor-list-if-insertion-fails/nfs-utils/support/nfsidmap/../../support/nfs/.libs/libnfsconf.a")
libtool: link: ar cru .libs/static.a  static.o  .libs/static.lax/libnfsconf.a/conffile.o .libs/static.lax/libnfsconf.a/xlog.o 
libtool: link: ranlib .libs/static.a
libtool: link: rm -fr .libs/static.lax
libtool: link: ( cd ".libs" && rm -f "static.la" && ln -s "../static.la" "static.la" )
[root@ nfsidmap]# echo $?
0
