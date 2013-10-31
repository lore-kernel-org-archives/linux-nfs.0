Return-Path: linux-nfs-owner@vger.kernel.org
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:12703 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880Ab3JaFyh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Oct 2013 01:54:37 -0400
Received: from demuprx017.emea.nsn-intra.net ([10.150.129.56])
	by demumfd002.nsn-inter.net (8.12.11.20060308/8.12.11) with ESMTP id r9V5saLc000564
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Thu, 31 Oct 2013 06:54:36 +0100
Received: from ulegcprs1.emea.nsn-net.net ([10.151.15.253])
	by demuprx017.emea.nsn-intra.net (8.12.11.20060308/8.12.11) with ESMTP id r9V5sZs1003521
	for <linux-nfs@vger.kernel.org>; Thu, 31 Oct 2013 06:54:36 +0100
Date: Thu, 31 Oct 2013 06:54:35 +0100
From: Robert Schiele <rschiele@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] fix race condition for parallel startup of statd
Message-ID: <20131031055435.GA27362@ulegcprs1.emea.nsn-net.net>
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
 utils/mount/network.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index e2cdcaf..670767d 100644
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
+			struct timespec ts = {
+				.tv_sec = 0,
+				.tv_nsec = 100000000,
+			};
 			pid_t pid = fork();
 			switch (pid) {
 			case 0: /* child */
@@ -788,6 +794,11 @@ int start_statd(void)
 			}
 			if (nfs_probe_statd())
 				return 1;
+			while (cnt--) {
+				nanosleep(&ts, NULL);
+				if (nfs_probe_statd())
+					return 1;
+			}
 		}
 	}
 #endif
-- 
1.8.1.4
