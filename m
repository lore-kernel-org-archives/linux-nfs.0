Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:33035 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754352Ab2CWC5g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Mar 2012 22:57:36 -0400
Message-ID: <4F6BE693.1000107@panasas.com>
Date: Thu, 22 Mar 2012 19:57:23 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
CC: NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        Benny Halevy <bhalevy@tonian.com>, "Welch, Brent" <welch@panasas.com>
Subject: [PATCH version2] osd_login: Add autologin script for objlayoutdriver.
References: <4F62DADD.3010502@panasas.com> <4F62DD6C.4040504@panasas.com>
In-Reply-To: <4F62DD6C.4040504@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Sachin Bhamare <sbhamare@panasas.com>

This script is part of the autologin feature mandated by the
pnfs-objects standard.
It is called from objlayoutdriver.ko in the kernel.

It invokes iscsiadm program to perform the iscsi login to OSDs.
It also features a watchdog which will make sure that control
returns to kernel after 15s timeout.

Signed-off-by: Sachin Bhamare <sbhamare@panasas.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 configure.ac                |    1 +
 utils/Makefile.am           |    1 +
 utils/osd_login/Makefile.am |   13 +++++
 utils/osd_login/osd_login   |  118 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 133 insertions(+), 0 deletions(-)
 create mode 100644 utils/osd_login/Makefile.am
 create mode 100755 utils/osd_login/osd_login

diff --git a/configure.ac b/configure.ac
index 67e8d2d..011a2bf 100644
--- a/configure.ac
+++ b/configure.ac
@@ -467,6 +467,7 @@ AC_CONFIG_FILES([
 	utils/nfsidmap/Makefile
 	utils/showmount/Makefile
 	utils/statd/Makefile
+	utils/osd_login/Makefile
 	tests/Makefile
 	tests/nsm_client/Makefile])
 AC_OUTPUT
diff --git a/utils/Makefile.am b/utils/Makefile.am
index d074b85..c7e5d27 100644
--- a/utils/Makefile.am
+++ b/utils/Makefile.am
@@ -28,6 +28,7 @@ SUBDIRS = \
 	nfsstat \
 	showmount \
 	statd \
+	osd_login \
 	$(OPTDIRS)
 
 MAINTAINERCLEANFILES = Makefile.in
diff --git a/utils/osd_login/Makefile.am b/utils/osd_login/Makefile.am
new file mode 100644
index 0000000..e931e36
--- /dev/null
+++ b/utils/osd_login/Makefile.am
@@ -0,0 +1,12 @@
+## Process this file with automake to produce Makefile.in
+
+OSD_LOGIN_FILES= osd_login
+
+EXTRA_DIST= $(OSD_LOGIN_FILES)
+
+all-local: $(OSD_LOGIN_FILES)
+
+install-data-hook:
+	$(INSTALL) --mode 755 osd_login $(DESTDIR)/sbin/osd_login
+
+MAINTAINERCLEANFILES = Makefile.in
diff --git a/utils/osd_login/osd_login b/utils/osd_login/osd_login
new file mode 100755
index 0000000..63967fc
--- /dev/null
+++ b/utils/osd_login/osd_login
@@ -0,0 +1,118 @@
+#!/bin/bash
+#
+# osd_login : This script is part of the autologin feature
+#             mandated by the pnfs-objects standard.
+# It is called from objlayoutdriver.ko in the kernel.
+
+# Copyright (C) 2012, Sachin Bhamare <sbhamare@panasas.com>
+# Copyright (C) 2012, Boaz Harrosh <bharrosh@panasas.com>
+#
+# This program is free software; you can redistribute it and/or modify
+# it under the terms of the GNU General Public License version 2 as
+# published by the Free Software Foundation.
+#
+# This program is distributed in the hope that it will be useful,
+# but WITHOUT ANY WARRANTY; without even the implied warranty of
+# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+# GNU General Public License for more details.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software
+# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
+# MA 02110-1301 USA
+
+umask 022
+
+PATH="/sbin:/usr/sbin:/bin:/usr/bin"
+
+iscsiadm=/sbin/iscsiadm
+
+PARENT_PID=$BASHPID
+WATCHDOG_TIMEOUT=15
+
+protocol=""
+portal=""
+uri=""
+osdname=""
+systemid=""
+
+usage()
+{
+	echo "Usage: $0 -u <URI> -o <OSDNAME> -s <SYSTEMID>"
+	echo "Options:"
+	echo  "-u		target uri e.g. iscsi://<ip>:<port>"
+	echo  "-o		osdname of the target OSD"
+	echo  "-s		systemid of the target OSD"
+}
+
+parse_cmdline()
+{
+	argc=$#
+	if [ $# -lt 3 ]; then
+		usage
+		exit 1
+	fi
+
+	# parse the input arguments
+	while getopts "u:o:s:" options; do
+	    case $options in
+		u ) uri=$OPTARG;;
+		o ) osdname=$OPTARG;;
+		s ) systemid=$OPTARG;;
+		\? ) usage
+			exit 1;;
+		* )  usage
+			exit 1;;
+	    esac
+	done
+
+	echo "-u : $uri"
+	echo "-o : $osdname"
+	echo "-s : $systemid"
+
+	protocol=`echo $uri | awk -F ':' '{print $1}'`
+	portal=`echo $uri | awk -F '//' '{print $2}'`
+}
+
+watchdog()
+{
+	timeout=$1
+	portal=$2
+
+	sleep $timeout
+	if kill -9 $PARENT_PID; then
+	    echo "watchdog : Timed out (>$timeout seconds) while login into $portal" | logger -t "osd_login"
+	fi
+	echo "watchdog: exiting .."
+	exit 2
+}
+
+login_iscsi_osd()
+{
+	echo "login into: $1"
+	if ! $iscsiadm -m discovery -o nonpersistent -t sendtargets -p $1 --login; then
+		echo "$iscsiadm -m discovery -t sendtargets -p $1 --login returned error $? !"
+		sleep 1;
+	fi
+}
+
+echo "============= osd_login ========="
+echo "progname : $0"
+parse_cmdline "$@"
+echo "protocol: $protocol"
+echo "portal: $portal"
+
+watchdog $WATCHDOG_TIMEOUT $portal &
+watchdog_pid=$!
+
+case $protocol in
+iscsi)
+	login_iscsi_osd $portal |& logger -t "osd_login"
+	;;
+*)
+	echo "Error: protocol $protocol not supported !" | logger -t "osd_login"
+	;;
+esac
+
+kill -9 $watchdog_pid
+exit 0
-- 
1.7.6.2


