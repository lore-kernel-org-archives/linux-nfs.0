Return-Path: linux-nfs-owner@vger.kernel.org
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:11596 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752900Ab3KDGxG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Nov 2013 01:53:06 -0500
Date: Mon, 4 Nov 2013 07:52:59 +0100
From: Robert Schiele <rschiele@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Jim Rees <rees@umich.edu>
Subject: [PATCH] fix race condition for parallel startup of statd
Message-ID: <20131104065259.GA21230@ulegcprs1.emea.nsn-net.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When start_statd figures out that statd is not yet running it starts
it, waits for the invoked process to complete, and finally verifies
that statd is working.  This approach works for serially mounting NFS
file systems but has a race condition for parallel mounting.

In the parallel case it can happen that two mount commands A and B
both decide that statd needs to be started. Both of them try to start
statd.  Obviously only one of them can successfully do so, let's
assume this is command A in our case.  The statd invoked by B
terminates because the resource is already claimed by the statd
invoked by A.  The termination of B's statd though is before the
statd of A has completely set up all things.  This causes the check
for a working statd of command B to fail and terminate the mount
request with an error.

To prevent this we define a timeout value.  In case the initial check
after invoking statd fails we try again in a loop 10 times a second
until the timeout is reached.

In our tests when the race occurred we typically were successful
already on the first retry within the loop.
---

This is the modified version of the patch with the loop calling
nfs_probe_statd only in one place but still leaving the loop without
a useless sleep nefore the first or after the last check.

Additionally I declared ts with a const qualifier now to make the
nature of this variable more clear.

By accident I replied to Jim only personally and not to the list and
thus the discussion leading to this modification was not reflected
there.  I am sorry for that.

Robert

 utils/mount/network.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index e2cdcaf..e8e55a5 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -58,6 +58,7 @@
 #define PMAP_TIMEOUT	(10)
 #define CONNECT_TIMEOUT	(20)
 #define MOUNT_TIMEOUT	(30)
+#define STATD_TIMEOUT	(10)
 
 #define SAFE_SOCKADDR(x)	(struct sockaddr *)(char *)(x)
 
@@ -773,6 +774,11 @@ int start_statd(void)
 #ifdef START_STATD
 	if (stat(START_STATD, &stb) == 0) {
 		if (S_ISREG(stb.st_mode) && (stb.st_mode & S_IXUSR)) {
+			int cnt = STATD_TIMEOUT * 10;
+			const struct timespec ts = {
+				.tv_sec = 0,
+				.tv_nsec = 100000000,
+			};
 			pid_t pid = fork();
 			switch (pid) {
 			case 0: /* child */
@@ -786,8 +792,13 @@ int start_statd(void)
 				waitpid(pid, NULL,0);
 				break;
 			}
-			if (nfs_probe_statd())
-				return 1;
+			while (1) {
+				if (nfs_probe_statd())
+					return 1;
+				if (! cnt--)
+					return 0;
+				nanosleep(&ts, NULL);
+			}
 		}
 	}
 #endif
-- 
1.8.1.4
