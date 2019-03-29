Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.7 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CAD0C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 06:04:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5DA7420811
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 06:04:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728545AbfC2GEg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 02:04:36 -0400
Received: from mx1.redhat.com ([209.132.183.28]:39544 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727641AbfC2GEg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 29 Mar 2019 02:04:36 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 0DF44308FBB4;
        Fri, 29 Mar 2019 06:04:36 +0000 (UTC)
Received: from dhcp-12-115.nay.redhat.com (dhcp-12-115.nay.redhat.com [10.66.12.115])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 5D2EB83B8E;
        Fri, 29 Mar 2019 06:04:34 +0000 (UTC)
From:   "Jianhong.Yin" <yin-jianhong@163.com>
To:     steved@redhat.com
Cc:     ben@swartzlander.org, linux-nfs@vger.kernel.org,
        "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH] [cthon04] fix typo and fix make failure on ubuntu
Date:   Fri, 29 Mar 2019 14:04:28 +0800
Message-Id: <20190329060428.28870-1-yin-jianhong@163.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Fri, 29 Mar 2019 06:04:36 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

there's not rpm command on Debian/Ubuntu, get glibc version by
'ldd --version' instead 'rpm -qf /path/file'

based on git://git.linux-nfs.org/projects/steved/cthon04.git
test pass on:
  RHEL-8 RHEL-7 RHEL-6 RHEL-5 and RHEL-4
  Debian-9 Ubuntu-18.10
  OpenSUSE Tumbleweed
  Slackware 14.2

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 tests.init.sh | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/tests.init.sh b/tests.init.sh
index 778206f..db96f4a 100755
--- a/tests.init.sh
+++ b/tests.init.sh
@@ -1,7 +1,7 @@
 #!/bin/sh
 
-OS=${1:-Linux}
-FSTYPE=$${2:-nfs}
+OS=${1:-`uname -s`}
+FSTYPE=${2:-nfs}
 Initfile=tests.init
 
 cat <<\EOF >$Initfile
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

