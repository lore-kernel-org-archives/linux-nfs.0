Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:47829 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308Ab1F3K4h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jun 2011 06:56:37 -0400
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp09.au.ibm.com (8.14.4/8.13.1) with ESMTP id p5UAuTgR005222
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2011 20:56:29 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5UAt85S1073234
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2011 20:55:08 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5UAuS0i032480
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2011 20:56:28 +1000
Date: Thu, 30 Jun 2011 16:26:26 +0530
From: Prem Karat <prem.karat@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: Steve Dickson <SteveD@redhat.com>, NeilBrown <neilb@suse.de>
Subject: [PATCH] nfs-utils: fix for the bug in v1.2.4 that breaks mount.nfs
Message-ID: <20110630105626.GB25648@d6fc318.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

commit 30ebf04700654deddbf5f57d95e84ec69cea8610 failed to include these changes that breaks mount.nfs.
mount.nfs would continue to work fine with these changes

Signed-off-by: Prem Karat <prem.karat@linux.vnet.ibm.com>
---
 utils/mount/mount.c |   11 +----------
 1 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 62115bb..eea00af 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -385,14 +385,6 @@ int main(int argc, char *argv[])
 	if(!strncmp(progname, "umount", strlen("umount")))
 		exit(nfsumount(argc, argv));
 
-	if (argv[1] && argv[1][0] == '-') {
-		if(argv[1][1] == 'V')
-			printf("%s ("PACKAGE_STRING")\n", progname);
-		else
-			mount_usage();
-		exit(EX_SUCCESS);
-	}
-
 	if ((argc < 3)) {
 		mount_usage();
 		exit(EX_USAGE);
@@ -400,8 +392,7 @@ int main(int argc, char *argv[])
 
 	mount_config_init(progname);
 
-	argv[2] = argv[0]; /* so that getopt error messages are correct */
-	while ((c = getopt_long(argc - 2, argv + 2, "rvVwfno:hs",
+	while ((c = getopt_long(argc, argv, "rvVwfno:hs",
 				longopts, NULL)) != -1) {
 		switch (c) {
 		case 'r':
-- 
1.7.4

-- 
Cheers,
Prem
Linux Technology Center,
IBM Systems & Technology Labs
DID: 41776362
