Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38091 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752201AbbLQE2O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Dec 2015 23:28:14 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 17 Dec 2015 15:27:34 +1100
Subject: [PATCH 2/2] start-statd: don't run multiple rpc.statds on the one
 host.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20151217042734.7581.45571.stgit@noble>
In-Reply-To: <20151217042613.7581.1566.stgit@noble>
References: <20151217042613.7581.1566.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If rpc.statd is running but slow to respond, mount.nfs will
run "start-statd" which might start a new statd.  This is not a good
ideas as can result in lots of rpc.statds.

So inf start-statd check the pid file and if rpc.statd seems to be
running, exit with success.

(also "cd /" before running rpc.statd, just in case).

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/statd/start-statd |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/utils/statd/start-statd b/utils/statd/start-statd
index 14369e515cb2..19e6eb21d044 100755
--- a/utils/statd/start-statd
+++ b/utils/statd/start-statd
@@ -6,11 +6,19 @@
 # site.
 PATH="/sbin:/usr/sbin:/bin:/usr/bin"
 
+if [ -s /var/run/rpc.statd.pid ] &&
+       [ 1`cat /var/run/rpc.statd.pid` -gt 1 ] &&
+       kill -0 `cat /var/run/rpc.statd.pid` > /dev/null 2>&1
+then
+    # statd already running - must have been slow to respond.
+    exit 0
+fi
 # First try systemd if it's installed.
 if [ -d /run/systemd/system ]; then
     # Quit only if the call worked.
     systemctl start rpc-statd.service && exit
 fi
 
+cd /
 # Fall back to launching it ourselves.
 exec rpc.statd --no-notify


