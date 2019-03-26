Return-Path: <SRS0=uQmJ=R5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.7 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3749AC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 02:56:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EEC102080F
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 02:56:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727394AbfCZC4i (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Mar 2019 22:56:38 -0400
Received: from mx1.redhat.com ([209.132.183.28]:56098 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727157AbfCZC4i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Mar 2019 22:56:38 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 47A0CC02490A;
        Tue, 26 Mar 2019 02:56:37 +0000 (UTC)
Received: from dhcp-12-115.nay.redhat.com (dhcp-12-115.nay.redhat.com [10.66.12.115])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 0DD754F9D7;
        Tue, 26 Mar 2019 02:56:32 +0000 (UTC)
From:   "Jianhong.Yin" <yin-jianhong@163.com>
To:     steved@redhat.com
Cc:     nfs-team@redhat.com, linux-nfs@vger.kernel.org,
        "Jianhong.Yin" <yin-jianhong@163.com>,
        Jianhong Yin <jiyin@redhat.com>
Subject: [PATCH] [cthon04] add tests.init.sh to generate right tests.init file
Date:   Tue, 26 Mar 2019 10:56:25 +0800
Message-Id: <20190326025625.4206-1-yin-jianhong@163.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 26 Mar 2019 02:56:37 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

recently nfsometer->cthon04 tests always fail on RHEL-8 and Fedora

before, tests.init is used as both shell script and Makefile
it's hard to dynamic config to compile successfully on both RHEL-7
and RHEL-8.

so I think introduce a generater to get right tests.init is better

Signed-off-by: Jianhong Yin <jiyin@redhat.com>
---
based on git://git.linux-nfs.org/projects/steved/cthon04.git
test pass on RHEL-8 RHEL-7 RHEL-6 RHEL-5 and RHEL-4

 .gitignore                    |   1 +
 Makefile                      |   8 +-
 README                        |   3 +
 tests.init => tests.init.orig |   0
 tests.init.sh                 | 390 ++++++++++++++++++++++++++++++++++
 5 files changed, 401 insertions(+), 1 deletion(-)
 rename tests.init => tests.init.orig (100%)
 create mode 100755 tests.init.sh

diff --git a/.gitignore b/.gitignore
index 0956596..67f57f3 100644
--- a/.gitignore
+++ b/.gitignore
@@ -1,4 +1,5 @@
 */*.o
+tests.init
 basic/test1
 basic/test2
 basic/test3
diff --git a/Makefile b/Makefile
index 05859bb..9fd76d9 100644
--- a/Makefile
+++ b/Makefile
@@ -7,12 +7,14 @@
 # 'make dist DESTDIR=path'	copies sources to path
 # 'make tar DESTDIR=path'       runs make dist and then packs the directory 
 # 'make rpm DESTDIR=path'       runs make tar and runs rpmbuild -ta on it 
-	
 
 DESTDIR=/no/such/path
 COPYFILES=runtests tests.init server domount.c README READWIN.txt Testitems \
 	getopt.c tests.h unixdos.h cthon04.spec
 
+# generate tests.init file
+$(shell ./tests.init.sh)
+
 include tests.init
 
 all: domount getopt
@@ -73,3 +75,7 @@ rpm: tar
 mknewdirs:
 	-mkdir $(DESTDIR)/basic $(DESTDIR)/general $(DESTDIR)/special \
 	       $(DESTDIR)/tools $(DESTDIR)/lock
+
+.PHONY: tests.init
+tests.init:
+	sh ./tests.init.sh
diff --git a/README b/README
index 28367fa..3e20792 100644
--- a/README
+++ b/README
@@ -540,6 +540,9 @@ None were found.
 See READWIN.txt for information about running the tests under DOS or
 Windows.
 
+Changes for 2019 include the following:
+
+1. Add tests.init.sh to generate tests.init file.
 
 Changes for 2004 include the following:
 
diff --git a/tests.init b/tests.init.orig
similarity index 100%
rename from tests.init
rename to tests.init.orig
diff --git a/tests.init.sh b/tests.init.sh
new file mode 100755
index 0000000..a8a856c
--- /dev/null
+++ b/tests.init.sh
@@ -0,0 +1,390 @@
+#!/bin/sh
+
+OS=${1:-Linux}
+FSTYPE=$${2:-nfs}
+Initfile=tests.init
+
+cat <<\EOF >$Initfile
+#
+#       @(#)tests.init	1.26 2003/12/30 Connectathon testsuite
+#
+MNTOPTIONS="rw,hard,intr"
+# Dummy MNTPOINT definition; should get overriden by server script.
+MNTPOINT="/mnt"
+
+SERVER=""
+SERVPATH="/server"
+TEST="-a"
+TESTARG="-t"
+
+EOF
+
+# set MOUNTCMD and UMOUNTCMD
+echo "# set MOUNTCMD and UMOUNTCMD" >>$Initfile
+case $OS in
+SVR3)
+cat <<\EOF >>$Initfile
+# Use this mount command if using:
+#	SVR3
+MOUNTCMD='./domount -f NFS,$MNTOPTIONS $SERVER\:$SERVPATH $MNTPOINT'
+EOF
+;;
+SVR4|Solaris2.x)
+cat <<\EOF >>$Initfile
+# Use this mount command if using:
+#	SVR4
+#	Solaris 2.x
+MOUNTCMD='./domount -F nfs -o $MNTOPTIONS $SERVER\:$SERVPATH $MNTPOINT'
+CFSMOUNTCMD='./domount -F cachefs -o $MNTOPTIONS $SERVER\:$SERVPATH $MNTPOINT'
+EOF
+;;
+BSD|SunOS4.x|Tru64UNIX|HPUX|Linux|AIX|MacOSX)
+cat <<\EOF >>$Initfile
+# Use this mount command if using:
+#	BSD
+#	SunOS 4.X
+#	Tru64 UNIX
+#	HPUX
+#	Linux
+#	AIX
+#	Mac OS X
+# At least some BSD systems don't recognize "hard" (since that's the
+# default), so you might also want to use this definition of MNTOPTIONS.
+MNTOPTIONS="rw,intr"
+MOUNTCMD='./domount -o $MNTOPTIONS $SERVER\:$SERVPATH $MNTPOINT'
+EOF
+;;
+DG/UX)
+cat <<\EOF >>$Initfile
+# Use this mount command if using:
+#	DG/UX
+MOUNTCMD='./domount -t nfs -o $MNTOPTIONS $SERVER\:$SERVPATH $MNTPOINT'
+EOF
+;;
+esac
+
+if test $FSTYPE = cifs; then
+	cat <<\EOF >>$Initfile
+# Use this mount command if using:
+#	SMB/CIFS
+MOUNTCMD='./domount -t cifs -o $MNTOPTIONS //$SERVER/$SERVPATH $MNTPOINT'
+EOF
+fi
+cat <<\EOF >>$Initfile
+UMOUNTCMD='./domount -u $MNTPOINT'
+
+EOF
+
+# set DASHN and BLC
+echo "# set DASHN and BLC" >>$Initfile
+case $OS in
+SVR3|SVR4|Solaris2.x|HPUX)
+cat <<\EOF >>$Initfile
+# Use the next two lines if using:
+#	SVR3
+#	SVR4
+#	Solaris 2.x
+#	HPUX
+DASHN=
+BLC=\\c
+EOF
+;;
+BSD|SunOS4.x|Linux|Tru64UNIX|MacOSX)
+cat <<\EOF >>$Initfile
+# Use the next two lines if using:
+#	BSD
+#	SunOS 4.X
+#	Linux
+#	Tru64 UNIX
+#	Mac OS X
+DASHN=-n
+BLC=
+EOF
+;;
+esac
+
+# set PATH
+echo >>$Initfile
+echo -e "# set PATH" >>$Initfile
+case $OS in
+Solaris2.x)
+cat <<\EOF >>$Initfile
+# Use this path for:
+#	Solaris 2.x
+PATH=/opt/SUNWspro/bin:/usr/ccs/bin:/sbin:/bin:/usr/bin:/usr/ucb:/etc:.
+
+# Use this path for:
+#	Solaris 2.x with GCC
+#PATH=/opt/gnu/bin:/usr/ccs/bin:/sbin:/bin:/usr/bin:/usr/ucb:/etc:.
+
+EOF
+;;
+
+HPUX)
+cat <<\EOF >>$Initfile
+# Use this path for:
+#	HPUX
+PATH=/bin:/usr/bin:/etc:/usr/etc:/usr/local/bin:/usr/contrib/bin:.
+
+EOF
+;;
+
+BSD|SunOS4.x)
+cat <<\EOF >>$Initfile
+# Use this path for:
+#	BSD
+#	SunOS 4.X
+PATH=/bin:/usr/bin:/usr/ucb:/etc:/usr/etc:.
+
+EOF
+;;
+
+Tru64UNIX|SVR4|Linux)
+cat <<\EOF >>$Initfile
+# Use this path for:
+#	Tru64 UNIX
+#	SVR4
+#	Linux
+PATH=/bin:/usr/bin:/usr/ucb:/usr/ccs/bin:/sbin:/usr/sbin:.
+
+EOF
+;;
+
+DG/UX)
+cat <<\EOF >>$Initfile
+# Use this path for:
+#	DG/UX
+PATH=/bin:/usr/bin:/usr/ucb:/etc:/usr/etc:.
+
+EOF
+;;
+
+IRIX)
+cat <<\EOF >>$Initfile
+# Use this path for:
+#	IRIX
+PATH=/bin:/usr/bin:/usr/bsd:/etc:/usr/etc:.
+
+EOF
+;;
+
+AIX)
+cat <<\EOF >>$Initfile
+# Use this path for:
+#	AIX
+PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/usr/bin/X11:/sbin:.
+
+EOF
+;;
+
+MacOSX)
+cat <<\EOF >>$Initfile
+# Use this path for:
+#	Mac OS X
+PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:.
+EOF
+;;
+esac
+
+#===============================================================================
+
+cat <<\EOF >>$Initfile
+# -----------------------------------------------
+# Defines for various variables used in scripts and makefiles.
+#
+# Do not remove the following three lines.  They may be overridden by
+# other configuration parameters lower in this file, but these three
+# variables must be defined.
+CC=cc
+CFLAGS=
+LIBS=
+LOCKTESTS=tlock
+EOF
+
+case $OS in
+SVR3)
+cat <<\EOF >>$Initfile
+# Use with SVR3 systems.
+# Add -TR2 to CFLAGS for use on Amdahl UTS systems.
+CFLAGS=-DSVR3
+LIBS=`echo -lrpc -lsocket`
+EOF
+;;
+
+BSD)
+cat <<\EOF >>$Initfile
+# Use with BSD systems.
+CC=gcc
+CFLAGS=`echo -Duse_directs -DBSD`
+MOUNT=/sbin/mount
+UMOUNT=/sbin/umount
+EOF
+;;
+
+SVR4)
+cat <<\EOF >>$Initfile
+# Use with SVR4 systems.
+CFLAGS=-DSVR4
+LIBS=`echo -lsocket -lnsl`
+EOF
+;;
+
+SunOS4.x)
+cat <<\EOF >>$Initfile
+# Use with SunOS 4.X systems
+CC=/usr/5bin/cc
+CFLAGS=`echo -DSUNOS4X -DNEED_STRERROR`
+EOF
+;;
+
+Solaris2.x)
+cat <<\EOF >>$Initfile
+# Use with Solaris 2.x systems.  Need the 5.0 C compiler (or later)
+# for 64-bit mode.
+#CC=/opt/SUNWspro/bin/cc
+# Use this with GCC
+#CC=/opt/gnu/bin/gcc
+# Use this through Solaris 2.6.  For Solaris 2.7 and later, use
+# this for 32-bit mode applications.
+#CFLAGS=`echo -DSVR4 -DMMAP -DSOLARIS2X -DSTDARG`
+# Use this with gcc (32-bit binaries):
+#CFLAGS=`echo -DSVR4 -DMMAP -DSOLARIS2X -DSTDARG -mcpu=ultrasparc`
+# For Solaris 2.7 and later, use this for 64-bit mode applications
+# (Sun compiler).
+#CFLAGS=`echo -DSVR4 -DMMAP -DSOLARIS2X -DSTDARG -xO0 -xarch=v9 -dalign -Xt -L/usr/lib/sparcv9`
+# Use this to make 64-bit binaries with gcc (3.1 or later; untested): 
+#CFLAGS=`echo -DSVR4 -DMMAP -DSOLARIS2X -DSTDARG -m64`
+LIBS=`echo -lsocket -lnsl`
+# Use this through Solaris 2.5.1.
+#LOCKTESTS=`echo tlock`
+# Use with 2.6 and later systems, 32-bit mode.
+LOCKTESTS=`echo tlocklfs tlock64`
+# Use with 2.7 and later, 64-bit mode.
+#LOCKTESTS=`echo tlocklfs`
+EOF
+;;
+
+Tru64UNIX)
+cat <<\EOF >>$Initfile
+# Use with Tru64 UNIX systems
+#CFLAGS=`echo -O -DTRU64 -DOSF1 -DMMAP -DSTDARG`
+# use the following instead of the above if using gcc
+#CFLAGS=`echo -O -DTRU64 -DOSF1 -DMMAP -DSTDARG -fwritable-strings`
+# 64-bit binaries with gcc (3.1 or later; untested):
+#CFLAGS=`echo -O -DTRU64 -DOSF1 -DMMAP -DSTDARG -fwritable-strings -m64`
+#MOUNT=/sbin/mount
+#UMOUNT=/sbin/umount
+EOF
+;;
+
+HPUX10B)
+cat <<\EOF >>$Initfile
+# Use with HPUX systems, 10.00 and earlier.
+CFLAGS=-DHPUX
+CC=/bin/cc
+RM=/bin/rm
+MAKE=/bin/make
+EOF
+;;
+
+HPUX10a)
+cat <<\EOF >>$Initfile
+# Use with HPUX 10.01.
+CFLAGS=`echo -Ae -DHPUX`
+CC=/opt/ansic/bin/cc
+RM=/bin/rm
+MAKE=/usr/bin/make
+EOF
+;;
+
+HPUX11-32)
+cat <<\EOF >>$Initfile
+# Use with HPUX 11.0, 32-bit machines.
+CFLAGS=`echo -Ae -DHPUX -D_PSTAT64 -D_LARGEFILE64_SOURCE -DPORTMAP`
+CC=/opt/ansic/bin/cc
+LIBS=`echo -lnsl`
+RM=/bin/rm
+MAKE=/usr/bin/make
+EOF
+;;
+
+HPUX11-64)
+cat <<\EOF >>$Initfile
+# Use with HPUX 11.0, 64-bit machines.
+CFLAGS=`echo -Ae -DHPUX -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE`
+CC=/opt/ansic/bin/cc
+RM=/bin/rm
+MAKE=/usr/bin/make
+EOF
+;;
+
+DG/UX)
+cat <<\EOF >>$Initfile
+# Use with DG/UX systems.
+CFLAGS=-DSVR4
+LIBS=`echo -lsocket -lnsl`
+EOF
+;;
+
+IRIX)
+cat <<\EOF >>$Initfile
+# Use with IRIX systems. Use HAVE_SOCKLEN_T for IRIX >= 6.5.19. 
+CFLAGS=`echo -g -DHAVE_SOCKLEN_T -DSTDARG -DSVR4 -DIRIX -DMMAP`
+EOF
+;;
+
+AIX)
+cat <<\EOF >>$Initfile
+# Use with AIX.
+CC=gcc
+CFLAGS=`echo -DAIX -DSTDARG -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE`
+LOCKTESTS=`echo tlocklfs`
+EOF
+;;
+
+MacOSX)
+cat <<\EOF >>$Initfile
+# Use with Mac OS X
+CFLAGS=`echo -DMACOSX -DNATIVE64 -DLARGE_LOCKS`
+MOUNT=/sbin/mount
+UMOUNT=/sbin/umount
+LOCKTESTS=`echo tlock`
+EOF
+;;
+
+Linux)
+cat <<\EOF >>$Initfile
+MOUNT=/bin/mount
+UMOUNT=/bin/umount
+LOCKTESTS=`echo tlocklfs tlock64`
+
+# Use with Linux if your distro doesn't provide a "cc".
+CC=gcc
+
+# Use with Linux 2.2 / GNU libc 2.0
+#CFLAGS=`echo -DLINUX -DGLIBC=20 -DMMAP -DSTDARG -fwritable-strings`
+#LIBS=`echo -lnsl`
+
+# Use with Linux 2.4 / GNU libc 2.2
+#CFLAGS=`echo -DLINUX -DGLIBC=22 -DMMAP -DSTDARG -fwritable-strings`
+#LIBS=`echo -lnsl`
+
+# Use with Linux 2.6 / gcc 4.0
+CFLAGS=`echo -DLINUX -DHAVE_SOCKLEN_T -DGLIBC=22 -DMMAP -DSTDARG`
+LIBS=`echo -lnsl`
+
+EOF
+
+if [ glibc-2.26 = `{ rpm -qf /etc/ld.so.conf; echo glibc-2.26; } | sort | head -n1` ]; then
+	cat <<\EOF >>$Initfile
+# Use with Linux glibc > 2.26
+CFLAGS=`echo -DLINUX -DHAVE_SOCKLEN_T -DGLIBC=22 -DMMAP -DSTDARG`
+CFLAGS+=`pkg-config --cflags libtirpc`
+LIBS=`pkg-config --libs libtirpc`
+EOF
+fi
+
+;;
+esac
+
+
-- 
2.17.2

