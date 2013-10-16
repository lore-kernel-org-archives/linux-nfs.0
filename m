Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50141 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760230Ab3JPTfV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Oct 2013 15:35:21 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Anna Schumaker <bjschuma@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] Add test_sec_options.sh
Date: Wed, 16 Oct 2013 15:35:12 -0400
Message-ID: <1381952112-6793-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This script tests the nfs 'sec=' mount option against a server with
(possibly) many different exports with different security flavors.

I originally wrote this to test the patch to test my multiple sec= options
patch, so set TEST_MULTIPLE_SEC_OPTIONS to something other than "true" to test
older kernels.

Most of the config can be passed through as environment variables, but the
paths on the remote server and the function to map these paths to the allowed
security flavors is not and must be set to what exports the server has defined.

This should be useful as a stand-alone script and as well as a Jenkins test.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 helper/test_sec_options.sh | 289 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 289 insertions(+)
 create mode 100755 helper/test_sec_options.sh

diff --git a/helper/test_sec_options.sh b/helper/test_sec_options.sh
new file mode 100755
index 0000000..10b01f4
--- /dev/null
+++ b/helper/test_sec_options.sh
@@ -0,0 +1,289 @@
+#!/bin/sh
+# Copyright (c) 2013 Netapp, Inc.  All rights reserved
+#
+# test_sec_options.sh - test NFS mount security options
+# by: Weston Andros Adamson <dros@netapp.com>
+#
+
+#
+# The example config is for a server (zero) with this /etc/exports:
+#
+# /export/sys       *(sec=sys,rw,no_root_squash)
+# /export/krb5a     *(sec=krb5,rw,no_root_squash)
+# /export/krb5i     *(sec=krb5i,rw,no_root_squash)
+# /export/krb5p     *(sec=krb5p,rw,no_root_squash)
+# /export/krb5ip    *(sec=krb5i:krb5p,rw,no_root_squash)
+# /export/krb5aip   *(sec=krb5:krb5i:krb5p,rw,no_root_squash)
+#
+
+# the server to mount
+[ -z "$SERVER" ] && SERVER=zero.apikia.fake
+
+# local mountpoint
+[ -z "$LOCALDIR" ] && LOCALDIR=/mnt
+
+# exports on the server to test - if you add something here, you MUST
+# add an entry to path_to_sec_flavors
+PATHS="/export/sys /export/krb5a /export/krb5i /export/krb5p /export/krb5ip /export/krb5aip"
+
+# mapping of path -> space separated list of sec= options
+path_to_sec_flavors() {
+	case $1 in
+	/export/sys)     echo "sys"
+	;;
+	/export/krb5a)   echo "krb5"
+	;;
+	/export/krb5i)   echo "krb5i"
+	;;
+	/export/krb5p)   echo "krb5p"
+	;;
+	/export/krb5ip)  echo "krb5i krb5p"
+	;;
+	/export/krb5aip) echo "krb5 krb5i krb5p"
+	;;
+	esac
+}
+
+# test multiple sec= options too?
+[ -z "$TEST_MULTIPLE_SEC_OPTIONS" ] && TEST_MULTIPLE_SEC_OPTIONS=true
+
+# if defined will pause for $RUN_PAUSE seconds between each run
+[ -z "$RUN_PAUSE" ] && RUN_PAUSE=0.25
+
+[ -z "$GROUP_PAUSE" ] && GROUP_PAUSE=10
+
+[ -z "$VERSIONS" ] && VERSIONS="v3 v4.0 v4.1"
+
+##### END CONFIG ####
+
+# no v2 or v3
+VERSIONS_V4=$(echo $VERSIONS | sed 's/v[2-3][^ ]*//g')
+
+echo "SERVER = $SERVER"
+echo "PATHS = $PATHS"
+echo "LOCALDIR = $LOCALDIR"
+echo "VERSIONS = $VERSIONS"
+echo "VERSIONS_V4 = $VERSIONS_V4"
+echo "TEST_MULTIPLE_SEC_OPTIONS = $TEST_MULTIPLE_SEC_OPTIONS"
+echo "RUN_PAUSE = $RUN_PAUSE"
+echo "GROUP_PAUSE = $GROUP_PAUSE"
+
+SINGLE_SEC_OPTIONS="sys krb5 krb5i krb5p"
+MULTIPLE_SEC_OPTIONS="sys krb5 krb5i krb5p sys:krb5 sys:krb5i sys:krb5p sys:krb5:krb5i sys:krb5:krb5p sys:krb5i:krb5p krb5:krb5i krb5:krb5p krb5:krb5i:krb5p krb5i:krb5p sys:krb5:krb5i:krb5p"
+
+FAILURES=0
+SUCCESSES=0
+
+group_pause() {
+	if [ -n "$GROUP_PAUSE" -a "$GROUP_PAUSE" != "0" ] ; then
+		echo sleeping for $GROUP_PAUSE seconds...
+		sleep $GROUP_PAUSE
+	fi
+}
+
+has_mount() {
+	_res=$(mount | grep $LOCALDIR  | grep nfs)
+
+	if [ -n "$_res" ] ; then
+		return 0
+	fi
+
+	return 1
+}
+
+if has_mount ; then
+	echo "something else mounted on $LOCALDIR"
+	exit 1
+fi
+
+_cancel() {
+	echo
+	echo "exiting on SIGINT"
+	while has_mount ; do
+		sudo umount $LOCALDIR > /dev/null 2>&1
+	done
+	exit 1
+}
+
+splitsec() {
+	echo $* | tr -s ':' ' '
+}
+
+trap '_cancel' INT
+
+run() {
+	_opts="$1"
+	_server="$2"
+	_path="$3"
+	_local="$4"
+	_expected_result="$5"
+	_cd="$6"
+
+	if has_mount ; then
+		echo
+		echo "something mounted on $LOCALDIR"
+		exit 1
+	fi
+
+	echo -n "mount" -o "$_opts" "$_server:$_path" "$_local"
+	sudo mount -o "$_opts" "$_server:$_path" "$_local" > /dev/null 2>&1
+	_status=$?
+
+	if [ "$_status" = "0" -a -n "$_cd" ]; then
+		echo -n " && ls $_cd"
+		sudo ls $_cd > /dev/null 2>&1
+		_status=$?
+	fi
+
+
+	echo -n "  -> $_status"
+
+	if [ "$_expected_result" = "$_status" ] ; then
+		echo "  [OK]"
+		SUCCESSES=$(expr $SUCCESSES + 1)
+	else
+		echo -n "  [FAIL!!]"
+		echo "  --> expected $_expected_result, but got $_status"
+		FAILURES=$(expr $FAILURES + 1)
+	fi
+
+	sudo umount $LOCALDIR > /dev/null 2>&1
+
+	while has_mount ; do
+		sudo umount $LOCALDIR > /dev/null 2>&1
+		sleep 0.1
+	done
+
+	# sigh, gssd gets angry
+	if [ -n "$RUN_PAUSE" -a "$RUN_PAUSE" != "0" ] ; then
+		sleep $RUN_PAUSE
+	fi
+
+	return $_status
+}
+
+echo
+echo "single sec= tests"
+for vers in $VERSIONS ; do
+	for sec in $SINGLE_SEC_OPTIONS ; do
+		for path in $PATHS; do
+			_expected_result=32
+			for pathsec in $(path_to_sec_flavors $path) ; do
+				if [ "$pathsec" = "$sec" ]; then
+					# should work!
+					_expected_result=0
+				fi
+			done
+
+			run "$vers,sec=$sec" $SERVER $path $LOCALDIR $_expected_result
+			_status=$?
+
+		done
+	done
+done
+
+echo
+
+group_pause
+
+if [ "$TEST_MULTIPLE_SEC_OPTIONS" = "true" ] ; then
+	echo
+	echo "multiple sec= tests"
+	for vers in $VERSIONS ; do
+		for sec in $MULTIPLE_SEC_OPTIONS ; do
+			for path in $PATHS; do
+				_expected_result=32
+				for pathsec in $(path_to_sec_flavors $path) ; do
+					for thissec in $(splitsec $sec) ; do
+						if [ "$pathsec" = "$thissec" ]; then
+							# should work!
+							_expected_result=0
+						fi
+					done
+				done
+
+				run "$vers,sec=$sec" $SERVER $path $LOCALDIR $_expected_result
+				_status=$?
+
+			done
+		done
+	done
+fi
+
+group_pause
+
+echo
+echo "no sec= tests"
+for vers in $VERSIONS ; do
+	for path in $PATHS; do
+		run "$vers" $SERVER $path $LOCALDIR 0
+		_status=$?
+	done
+done
+
+group_pause
+
+echo
+echo "v4 secinfo tests"
+for vers in $VERSIONS_V4 ; do
+	for path in $PATHS; do
+		run "$vers" $SERVER / $LOCALDIR 0 $LOCALDIR/$path
+		_status=$?
+	done
+done
+
+group_pause
+
+echo
+echo "v4.x secinfo with single sec= tests"
+for vers in $VERSIONS_V4 ; do
+	for sec in $SINGLE_SEC_OPTIONS ; do
+		for path in $PATHS; do
+			_expected_result=2
+			for pathsec in $(path_to_sec_flavors $path) ; do
+				if [ "$pathsec" = "$sec" ]; then
+					# should work!
+					_expected_result=0
+				fi
+			done
+
+			run "$vers,sec=$sec" $SERVER / $LOCALDIR $_expected_result $LOCALDIR/$path
+			_status=$?
+
+		done
+	done
+done
+
+group_pause
+
+if [ "$TEST_MULTIPLE_SEC_OPTIONS" = "true" ] ; then
+	echo
+	echo "v4.x secinfo with multiple sec= tests"
+	for vers in $VERSIONS_V4 ; do
+		for sec in $MULTIPLE_SEC_OPTIONS ; do
+			for path in $PATHS; do
+				_expected_result=2
+				for pathsec in $(path_to_sec_flavors $path) ; do
+					for thissec in $(splitsec $sec) ; do
+						if [ "$pathsec" = "$thissec" ]; then
+							# should work!
+							_expected_result=0
+						fi
+					done
+				done
+
+				run "$vers,sec=$sec" $SERVER / $LOCALDIR $_expected_result $LOCALDIR/$path
+				_status=$?
+
+			done
+		done
+	done
+fi
+
+echo
+echo "Successfully ran $SUCCESSES tests"
+if [ "$FAILURES" != "0" ] ; then
+	echo
+	echo "$FAILURES failures!"
+fi
+exit $FAILURES
-- 
1.7.12.4 (Apple Git-37)

