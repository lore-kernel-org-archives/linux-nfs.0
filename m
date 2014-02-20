Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:43623 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751238AbaBTG4e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Feb 2014 01:56:34 -0500
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 20 Feb 2014 17:55:30 +1100
Subject: [PATCH 3/6] systemd: add nfs-utils_env.sh for SUSE.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140220065530.7320.38662.stgit@notabene.brown>
In-Reply-To: <20140220065345.7320.49992.stgit@notabene.brown>
References: <20140220065345.7320.49992.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This script provides the required translation for
sysconfig variables understood by init.d script on openSUSE.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 systemd/SUSE-nfs-utils_env.sh |   62 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 62 insertions(+)
 create mode 100644 systemd/SUSE-nfs-utils_env.sh

diff --git a/systemd/SUSE-nfs-utils_env.sh b/systemd/SUSE-nfs-utils_env.sh
new file mode 100644
index 000000000000..8d6d94ed29e5
--- /dev/null
+++ b/systemd/SUSE-nfs-utils_env.sh
@@ -0,0 +1,62 @@
+#!/bin/sh
+
+# extract configuration from /etc/sysconfig/nfs-utils and write
+# environment to /run/sysconfig/nfs-utils to be used by systemd unit
+# files.
+# This script expect configuration as used by openSUSE-13.1 and later
+#
+
+nfs_config=/etc/sysconfig/nfs
+if test -r $nfs_config; then
+    . $nfs_config
+fi
+
+pipefs=
+if [ -n "$RPC_PIPEFS_DIR" -a "$RPC_PIPEFS_DIR" != "/var/lib/nfs/rpc_pipefs" ]; then
+    pipefs="-p /var/lib/nfs/rpc_pipefs"
+fi
+
+mountdport=
+if [ -n "$MOUNTD_PORT" ]; then
+    mountdport="-p $MOUNTD_PORT"
+fi
+
+case $NFS_GSSD_AVOID_DNS in
+    [Nn]*) ignore_dns=-D ;;
+    [Yy]*) ignore_dns=   ;;
+    *    ) ignore_dns=-D
+esac
+
+version_params=
+if [ "$NFS3_SERVER_SUPPORT" == "no" ]; then
+   version_params="--no-nfs-version 2 --no-nfs-version 3"
+fi
+if [ "$NFS4_SUPPORT" != "yes" ]; then
+   version_params="--no-nfs-version 4"
+fi
+if [ "$NFS4_SERVER_MINOR_VERSION" != "0" ]; then
+   version_params="$VERSION_PARAMS --nfs-version 4 --nfs-version 4.$NFS4_SERVER_MINOR_VERSION"
+fi
+
+if [ "$USE_KERNEL_NFSD_NUMBER" -gt 0 ]; then
+    threads=$USE_KERNEL_NFSD_NUMBER
+else
+    threads=3
+fi
+
+case $NFS_GSSD_AVOID_DNS in
+    [Nn]*) ignore_dns=-D ;;
+    [Yy]*) ignore_dns=   ;;
+    *    ) ignore_dns=-D
+esac
+
+mkdir -p /run/sysconfig
+{
+echo "RPCIDMAPDARGS=$pipefs"
+echo "RPCMOUNTDARGS=$mountdport $MOUNTD_OPTIONS $version_parms"
+echo "RPCNFSDARGS=$NFSD_OPTIONS $version_params $threads"
+echo "GSSDARGS=$ignore_dns $GSSD_OPTIONS $pipefs"
+echo "SMNOTIFYARGS=$SM_NOTIFY_OPTIONS"
+echo "STATDARGS=$STATD_OPTIONS"
+echo "SVCGSSDARGS=$SVCGSSD_OPTIONS"
+} > /run/sysconfig/nfs-utils


