From: Neil Brown <neilb@suse.de>
Subject: [PATCH nfs-utils] Ensure statd gets started if required when non-root user mounts an NFS filesystem.
Date: Mon, 24 Nov 2008 11:07:19 +1100
Message-ID: <18729.61495.911485.826997@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53243 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751751AbYKXAHU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 23 Nov 2008 19:07:20 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


openSUSE-11.1 betas rely in mount.nfs to start statd when required.
This helped me discover that it doesn't work when a non-root user is
mounting a filesystem as the setuid status gets lots.
This patch fixes it.

Thanks,
NeilBrown



>From 78d2001f031553ef90db708d5a7b3fbb9b31a873 Mon Sep 17 00:00:00 2001
From: Neil Brown <neilb@suse.de>
Date: Mon, 24 Nov 2008 11:00:19 +1100
Subject: [PATCH] Ensure statd gets started if required when non-root user mounts an NFS filesystem.

The first time an NFS filesystem is mounted, we start statd from /sbin/mount.nfs.
If this first time is a non-root user doing the mount, (thanks to e.g. the
'users' option in /etc/fstab) then we need to be sure that the 'setuid' status
from mount.nfs is inherited through to rpc.statd so that it runs as root.

There are two places where we loose our setuid status due to the shell
(/bin/sh) discarding.

1/ mount.nfs uses "system" to run /usr/sbin/start-statd.  This runs a shell
  which is likely to drop privileges.  So change that code to use
  'fork' and 'execl' explicitly.
2/ start-statd is a shell script.  To convince the shell to allow the
  program to run in privileged mode, we need to add a "-p" flag.

We could just call
    setuid(getuid())
at some appropriate time, and it might be worth doing that as well, however
I think that getting rid of 'system()' is a good idea and once that is
done, the adding of '-p' is trivial and sufficient.

Signed-off-by: Neil Brown <neilb@suse.de>
---
 utils/mount/network.c   |   13 ++++++++++++-
 utils/statd/start-statd |    2 +-
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 2db694d..541003a 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -705,7 +705,18 @@ int start_statd(void)
 #ifdef START_STATD
 	if (stat(START_STATD, &stb) == 0) {
 		if (S_ISREG(stb.st_mode) && (stb.st_mode & S_IXUSR)) {
-			system(START_STATD);
+			pid_t pid = fork();
+			switch (pid) {
+			case 0: /* child */
+				execl(START_STATD, START_STATD, NULL);
+				exit(1);
+			case -1: /* error */
+				perror("Fork failed");
+				break;
+			default: /* parent */
+				waitpid(pid, NULL,0);
+				break;
+			}
 			if (probe_statd())
 				return 1;
 		}
diff --git a/utils/statd/start-statd b/utils/statd/start-statd
index 6e7ea04..c7805ee 100644
--- a/utils/statd/start-statd
+++ b/utils/statd/start-statd
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/bin/sh -p
 # nfsmount calls this script when mounting a filesystem with locking
 # enabled, but when statd does not seem to be running (based on
 # /var/run/rpc.statd.pid).
-- 
1.5.6.5

