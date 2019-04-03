Return-Path: <SRS0=5sV6=SF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.7 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FD66C4360F
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Apr 2019 03:38:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5EF6520830
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Apr 2019 03:38:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726411AbfDCDiX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 23:38:23 -0400
Received: from mx1.redhat.com ([209.132.183.28]:55912 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726183AbfDCDiX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 2 Apr 2019 23:38:23 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A47BC85363;
        Wed,  3 Apr 2019 03:38:22 +0000 (UTC)
Received: from dhcp-12-115.nay.redhat.com (dhcp-12-115.nay.redhat.com [10.66.12.115])
        by smtp.corp.redhat.com (Postfix) with ESMTP id A3EB3600D4;
        Wed,  3 Apr 2019 03:38:20 +0000 (UTC)
From:   "Jianhong.Yin" <yin-jianhong@163.com>
To:     steved@redhat.com
Cc:     ben@swartzlander.org, linux-nfs@vger.kernel.org,
        "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH v2] [cthon04] fix typo and fix make failure on ubuntu
Date:   Wed,  3 Apr 2019 11:38:13 +0800
Message-Id: <20190403033813.12333-1-yin-jianhong@163.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 03 Apr 2019 03:38:22 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

based on git://git.linux-nfs.org/projects/steved/cthon04.git
test pass on:
  RHEL-8 RHEL-7 RHEL-6 RHEL-5 and RHEL-4
  Debian-9 Ubuntu-18.10
  OpenSUSE Tumbleweed
  Slackware 14.2

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 Makefile      |  4 +--
 tests.init    | 77 ---------------------------------------------------
 tests.init.sh | 26 +++++++++--------
 3 files changed, 16 insertions(+), 91 deletions(-)
 delete mode 100644 tests.init

diff --git a/Makefile b/Makefile
index 9fd76d9..dc12956 100644
--- a/Makefile
+++ b/Makefile
@@ -13,7 +13,7 @@ COPYFILES=runtests tests.init server domount.c README READWIN.txt Testitems \
 	getopt.c tests.h unixdos.h cthon04.spec
 
 # generate tests.init file
-$(shell ./tests.init.sh)
+$(shell ./tests.init.sh $(FSTYPE) $(OS))
 
 include tests.init
 
@@ -78,4 +78,4 @@ mknewdirs:
 
 .PHONY: tests.init
 tests.init:
-	sh ./tests.init.sh
+	sh ./tests.init.sh $(FSTYPE) $(OS)
diff --git a/tests.init b/tests.init
deleted file mode 100644
index b2f642f..0000000
--- a/tests.init
+++ /dev/null
@@ -1,77 +0,0 @@
-#
-#       @(#)tests.init	1.26 2003/12/30 Connectathon testsuite
-#
-MNTOPTIONS="rw,hard,intr"
-# Dummy MNTPOINT definition; should get overriden by server script.
-MNTPOINT="/mnt"
-
-SERVER=""
-SERVPATH="/server"
-TEST="-a"
-TESTARG="-t"
-
-# set MOUNTCMD and UMOUNTCMD
-# Use this mount command if using:
-#	BSD
-#	SunOS 4.X
-#	Tru64 UNIX
-#	HPUX
-#	Linux
-#	AIX
-#	Mac OS X
-# At least some BSD systems don't recognize "hard" (since that's the
-# default), so you might also want to use this definition of MNTOPTIONS.
-MNTOPTIONS="rw,intr"
-MOUNTCMD='./domount -o $MNTOPTIONS $SERVER\:$SERVPATH $MNTPOINT'
-UMOUNTCMD='./domount -u $MNTPOINT'
-
-# set DASHN and BLC
-# Use the next two lines if using:
-#	BSD
-#	SunOS 4.X
-#	Linux
-#	Tru64 UNIX
-#	Mac OS X
-DASHN=-n
-BLC=
-
-# set PATH
-# Use this path for:
-#	Tru64 UNIX
-#	SVR4
-#	Linux
-PATH=/bin:/usr/bin:/usr/ucb:/usr/ccs/bin:/sbin:/usr/sbin:.
-
-# -----------------------------------------------
-# Defines for various variables used in scripts and makefiles.
-#
-# Do not remove the following three lines.  They may be overridden by
-# other configuration parameters lower in this file, but these three
-# variables must be defined.
-CC=cc
-CFLAGS=
-LIBS=
-LOCKTESTS=tlock
-MOUNT=/bin/mount
-UMOUNT=/bin/umount
-LOCKTESTS=`echo tlocklfs tlock64`
-
-# Use with Linux if your distro doesn't provide a "cc".
-CC=gcc
-
-# Use with Linux 2.2 / GNU libc 2.0
-#CFLAGS=`echo -DLINUX -DGLIBC=20 -DMMAP -DSTDARG -fwritable-strings`
-#LIBS=`echo -lnsl`
-
-# Use with Linux 2.4 / GNU libc 2.2
-#CFLAGS=`echo -DLINUX -DGLIBC=22 -DMMAP -DSTDARG -fwritable-strings`
-#LIBS=`echo -lnsl`
-
-# Use with Linux 2.6 / gcc 4.0
-CFLAGS=`echo -DLINUX -DHAVE_SOCKLEN_T -DGLIBC=22 -DMMAP -DSTDARG`
-LIBS=`echo -lnsl`
-
-# Use with Linux glibc > 2.26
-CFLAGS=`echo -DLINUX -DHAVE_SOCKLEN_T -DGLIBC=22 -DMMAP -DSTDARG`
-CFLAGS+=`pkg-config --cflags libtirpc`
-LIBS=`pkg-config --libs libtirpc`
diff --git a/tests.init.sh b/tests.init.sh
index 778206f..fe90e42 100755
--- a/tests.init.sh
+++ b/tests.init.sh
@@ -1,16 +1,16 @@
 #!/bin/sh
 
-OS=${1:-Linux}
-FSTYPE=$${2:-nfs}
+FSTYPE=${1:-nfs}
+OS=${2:-`uname -s`}
 Initfile=tests.init
 
-cat <<\EOF >$Initfile
+cat <<EOF >$Initfile
 #
 #       @(#)tests.init	1.26 2003/12/30 Connectathon testsuite
 #
 MNTOPTIONS="rw,hard,intr"
 # Dummy MNTPOINT definition; should get overriden by server script.
-MNTPOINT="/mnt"
+MNTPOINT="/mnt/$FSTYPE"
 
 SERVER=""
 SERVPATH="/server"
@@ -38,7 +38,7 @@ MOUNTCMD='./domount -F nfs -o $MNTOPTIONS $SERVER\:$SERVPATH $MNTPOINT'
 CFSMOUNTCMD='./domount -F cachefs -o $MNTOPTIONS $SERVER\:$SERVPATH $MNTPOINT'
 EOF
 ;;
-BSD|SunOS4.x|Tru64UNIX|HPUX|Linux|AIX|MacOSX)
+*BSD|SunOS4.x|Tru64UNIX|HPUX|Linux|AIX|MacOSX)
 cat <<\EOF >>$Initfile
 # Use this mount command if using:
 #	BSD
@@ -89,7 +89,7 @@ DASHN=
 BLC=\\c
 EOF
 ;;
-BSD|SunOS4.x|Linux|Tru64UNIX|MacOSX)
+*BSD|SunOS4.x|Linux|Tru64UNIX|MacOSX)
 cat <<\EOF >>$Initfile
 # Use the next two lines if using:
 #	BSD
@@ -105,7 +105,7 @@ esac
 
 # set PATH
 echo >>$Initfile
-echo -e "# set PATH" >>$Initfile
+echo "# set PATH" >>$Initfile
 case $OS in
 Solaris2.x)
 cat <<\EOF >>$Initfile
@@ -129,7 +129,7 @@ PATH=/bin:/usr/bin:/etc:/usr/etc:/usr/local/bin:/usr/contrib/bin:.
 EOF
 ;;
 
-BSD|SunOS4.x)
+*BSD|SunOS4.x)
 cat <<\EOF >>$Initfile
 # Use this path for:
 #	BSD
@@ -211,10 +211,10 @@ LIBS=`echo -lrpc -lsocket`
 EOF
 ;;
 
-BSD)
+*BSD)
 cat <<\EOF >>$Initfile
 # Use with BSD systems.
-CC=gcc
+CC=cc
 CFLAGS=`echo -Duse_directs -DBSD`
 MOUNT=/sbin/mount
 UMOUNT=/sbin/umount
@@ -375,7 +375,10 @@ LIBS=`echo -lnsl`
 
 EOF
 
-if [ glibc-2.26 = `{ rpm -qf /etc/ld.so.conf; echo glibc-2.26; } | sort | head -n1` ]; then
+glibc_version_base=2.26
+glibc_version_current=`ldd --version|sed -n '1{s/.* //;p}'`
+glibc_version_older=`{ echo $glibc_version_base; echo $glibc_version_current; } | sort | head -n1`
+if [ "$glibc_version_older" = "$glibc_version_base" ]; then
 	cat <<\EOF >>$Initfile
 # Use with Linux glibc > 2.26
 CFLAGS=`echo -DLINUX -DHAVE_SOCKLEN_T -DGLIBC=22 -DMMAP -DSTDARG`
@@ -387,4 +390,3 @@ fi
 ;;
 esac
 
-
-- 
2.17.2

