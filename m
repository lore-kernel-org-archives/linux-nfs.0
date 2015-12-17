Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38083 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751242AbbLQE2I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Dec 2015 23:28:08 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 17 Dec 2015 15:27:34 +1100
Subject: [PATCH 1/2] mount.nfs: trust the exit status of "start_statd".
Cc: linux-nfs@vger.kernel.org
Message-ID: <20151217042734.7581.35502.stgit@noble>
In-Reply-To: <20151217042613.7581.1566.stgit@noble>
References: <20151217042613.7581.1566.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If DNS service is particularly slow, nfs_probe_statd() can fail even
though rpc.statd is actually running.  This happens because rpc.statd
is single threaded and could be waiting longer for DNS than
nfs_probe_statd() will wait for it.

This causes problems when mount.nfs uses nfs_probe_statd() to see if
statd is running, as is needed for NFSv3.

Currently in these circumstances there are two possible outcomes.
1/ if systemd is in use, it will be told to start rpc-statd, which
   is already running so no change.
   mount.nfs will try pinging rpc.statd a few more times and could
   eventually give up and fail the mount.
   While slow DNS may well result in slow service, it shouldn't cause
   a mount attempt to fail.

2/ if systemd is not in use, a new rpc.statd will be started.  This
   can (and has) lead to a large number of rpc.statd processes running
   on the one machine.

This patch addresses the first scenario.  If START_STATD is run and
exits with a success status, mount.nfs assumes statd is running and
allows the mount to succeed.  A separate patch will address the other
scenario.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mount/network.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 8a9bf1476d51..7240ca7bcdc4 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -794,6 +794,7 @@ int start_statd(void)
 	if (stat(START_STATD, &stb) == 0) {
 		if (S_ISREG(stb.st_mode) && (stb.st_mode & S_IXUSR)) {
 			int cnt = STATD_TIMEOUT * 10;
+			int status = 0;
 			const struct timespec ts = {
 				.tv_sec = 0,
 				.tv_nsec = 100000000,
@@ -808,7 +809,10 @@ int start_statd(void)
 						progname, strerror(errno));
 				break;
 			default: /* parent */
-				waitpid(pid, NULL,0);
+				if (waitpid(pid, &status,0) == pid &&
+				    status == 0)
+					/* assume it worked */
+					return 1;
 				break;
 			}
 			while (1) {


