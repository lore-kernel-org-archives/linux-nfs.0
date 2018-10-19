Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32816 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726542AbeJSWem (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Oct 2018 18:34:42 -0400
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 4F3B7308A953
        for <linux-nfs@vger.kernel.org>; Fri, 19 Oct 2018 14:28:21 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-120-63.rdu2.redhat.com [10.10.120.63])
        by smtp.corp.redhat.com (Postfix) with ESMTP id DF7E51001F53
        for <linux-nfs@vger.kernel.org>; Fri, 19 Oct 2018 14:28:20 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Remove osd_login
Date: Fri, 19 Oct 2018 10:28:19 -0400
Message-Id: <20181019142819.73527-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This ancient script has not been used
in years, if used at all.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac                |   8 ---
 utils/Makefile.am           |   1 -
 utils/osd_login/Makefile.am |   9 ---
 utils/osd_login/osd_login   | 118 ------------------------------------
 4 files changed, 136 deletions(-)
 delete mode 100644 utils/osd_login/Makefile.am
 delete mode 100644 utils/osd_login/osd_login

diff --git a/configure.ac b/configure.ac
index e82ff14..cf1c4b9 100644
--- a/configure.ac
+++ b/configure.ac
@@ -238,13 +238,6 @@ AC_ARG_ENABLE(nfsdcltrack,
 	enable_nfsdcltrack=$enableval,
 	enable_nfsdcltrack="yes")
 
-AC_ARG_ENABLE(osdlogin,
-	[AC_HELP_STRING([--enable-osdlogin],
-			[enable osd_login scripts @<:@default=no@:>@])],
-	enable_osdlogin=$enableval,
-	enable_osdlogin="no")
-	AM_CONDITIONAL(CONFIG_OSD_LOGIN, [test "$enable_osdlogin" = "yes" ])
-
 dnl Check for TI-RPC library and headers
 AC_LIBTIRPC
 
@@ -631,7 +624,6 @@ AC_CONFIG_FILES([
 	utils/nfsidmap/Makefile
 	utils/showmount/Makefile
 	utils/statd/Makefile
-	utils/osd_login/Makefile
 	systemd/Makefile
 	tests/Makefile
 	tests/nsm_client/Makefile])
diff --git a/utils/Makefile.am b/utils/Makefile.am
index d361aea..0a5b062 100644
--- a/utils/Makefile.am
+++ b/utils/Makefile.am
@@ -34,7 +34,6 @@ SUBDIRS = \
 	nfsstat \
 	showmount \
 	statd \
-	osd_login \
 	$(OPTDIRS)
 
 MAINTAINERCLEANFILES = Makefile.in
diff --git a/utils/osd_login/Makefile.am b/utils/osd_login/Makefile.am
deleted file mode 100644
index ded1fd3..0000000
--- a/utils/osd_login/Makefile.am
+++ /dev/null
@@ -1,9 +0,0 @@
-## Process this file with automake to produce Makefile.in
-
-# These binaries go in /sbin (not /usr/sbin), and that cannot be
-# overridden at config time.
-sbindir = /sbin
-
-dist_sbin_SCRIPTS = osd_login
-
-MAINTAINERCLEANFILES = Makefile.in
diff --git a/utils/osd_login/osd_login b/utils/osd_login/osd_login
deleted file mode 100644
index 08cd2d2..0000000
--- a/utils/osd_login/osd_login
+++ /dev/null
@@ -1,118 +0,0 @@
-#!/bin/bash
-#
-# osd_login : This script is part of the autologin feature
-#             mandated by the pnfs-objects standard.
-# It is called from objlayoutdriver.ko in the kernel.
-
-# Copyright (C) 2012, Sachin Bhamare <sbhamare@panasas.com>
-# Copyright (C) 2012, Boaz Harrosh <bharrosh@panasas.com>
-#
-# This program is free software; you can redistribute it and/or modify
-# it under the terms of the GNU General Public License version 2 as
-# published by the Free Software Foundation.
-#
-# This program is distributed in the hope that it will be useful,
-# but WITHOUT ANY WARRANTY; without even the implied warranty of
-# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-# GNU General Public License for more details.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software
-# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
-# MA 02110-1301 USA
-
-umask 022
-
-PATH="/sbin:/usr/sbin:/bin:/usr/bin"
-
-iscsiadm=/sbin/iscsiadm
-
-PARENT_PID=$BASHPID
-WATCHDOG_TIMEOUT=15
-
-protocol=""
-portal=""
-uri=""
-osdname=""
-systemid=""
-
-usage()
-{
-	echo "Usage: $0 -u <URI> -o <OSDNAME> -s <SYSTEMID>"
-	echo "Options:"
-	echo  "-u		target uri e.g. iscsi://<ip>:<port>"
-	echo  "-o		osdname of the target OSD"
-	echo  "-s		systemid of the target OSD"
-}
-
-parse_cmdline()
-{
-	argc=$#
-	if [ $# -lt 3 ]; then
-		usage
-		exit 1
-	fi
-
-	# parse the input arguments
-	while getopts "u:o:s:" options; do
-	    case $options in
-		u ) uri=$OPTARG;;
-		o ) osdname=$OPTARG;;
-		s ) systemid=$OPTARG;;
-		\? ) usage
-			exit 1;;
-		* )  usage
-			exit 1;;
-	    esac
-	done
-
-	echo "-u : $uri"
-	echo "-o : $osdname"
-	echo "-s : $systemid"
-
-	protocol=`echo $uri | awk -F ':' '{print $1}'`
-	portal=`echo $uri | awk -F '//' '{print $2}'`
-}
-
-watchdog()
-{
-	timeout=$1
-	portal=$2
-
-	sleep $timeout
-	if kill -9 $PARENT_PID; then
-	    echo "watchdog : Timed out (>$timeout seconds) while login into $portal" | logger -t "osd_login"
-	fi
-	echo "watchdog: exiting .."
-	exit 2
-}
-
-login_iscsi_osd()
-{
-	echo "login into: $1"
-	if ! $iscsiadm -m discovery -o nonpersistent -t sendtargets -p $1 --login; then
-		echo "$iscsiadm -m discovery -t sendtargets -p $1 --login returned error $? !"
-		sleep 1;
-	fi
-}
-
-echo "============= osd_login ========="
-echo "progname : $0"
-parse_cmdline "$@"
-echo "protocol: $protocol"
-echo "portal: $portal"
-
-watchdog $WATCHDOG_TIMEOUT $portal &
-watchdog_pid=$!
-
-case $protocol in
-iscsi)
-	login_iscsi_osd $portal |& logger -t "osd_login"
-	;;
-*)
-	echo "Error: protocol $protocol not supported !" | logger -t "osd_login"
-	;;
-esac
-
-kill -9 $watchdog_pid
-exit 0
-- 
2.17.2
