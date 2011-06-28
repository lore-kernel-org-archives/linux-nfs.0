Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:57810 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757873Ab1F1PLL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2011 11:11:11 -0400
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp05.in.ibm.com (8.14.4/8.13.1) with ESMTP id p5SFB84A009590
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jun 2011 20:41:08 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5SFB8G52162914
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jun 2011 20:41:08 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5SFB7KD024906
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jun 2011 01:11:07 +1000
Received: from localhost ([9.77.203.81])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id p5SFB6Iq024688
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jun 2011 01:11:06 +1000
Date: Tue, 28 Jun 2011 20:41:05 +0530
From: Prem Karat <prem.karat@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs-utils: Don't hard code source and destination args
Message-ID: <20110628151105.GD7675@d6fc318.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Currently souce and destination parameters should be passed as first and 
second paramter while using mount.nfs. This patch allows them to be passed 
anywhere while mounting.

Current functionality is
	mount.nfs source destn -o <options>
This patch will allow to do this
	mount.nfs -o <options> source destn
		or
	mount.nfs -o <options> source -o <options> destn

Signed-off-by: Prem Karat <prem.karat@linux.vnet.ibm.com>
---
 utils/mount/mount.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index f3f0a83..62115bb 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -374,7 +374,7 @@ static int try_mount(char *spec, char *mount_point, int flags,
 int main(int argc, char *argv[])
 {
 	int c, flags = 0, mnt_err = 1, fake = 0;
-	char *spec, *mount_point, *fs_type = "nfs";
+	char *spec = NULL, *mount_point = NULL, *fs_type = "nfs";
 	char *extra_opts = NULL, *mount_opts = NULL;
 	uid_t uid = getuid();
 
@@ -398,9 +398,6 @@ int main(int argc, char *argv[])
 		exit(EX_USAGE);
 	}
 
-	spec = argv[1];
-	mount_point = argv[2];
-
 	mount_config_init(progname);
 
 	argv[2] = argv[0]; /* so that getopt error messages are correct */
@@ -447,6 +444,14 @@ int main(int argc, char *argv[])
 	if (optind != argc - 2) {
 		mount_usage();
 		goto out_usage;
+	} else {
+		while (optind < argc) {
+			if (!spec)
+				spec = argv[optind];
+			else
+				mount_point = argv[optind];
+			optind++;
+		}
 	}
 
 	if (strcmp(progname, "mount.nfs4") == 0)
-- 
1.7.4

-- 
Cheers,
Prem
Linux Technology Center,
IBM Systems & Technology Labs
DID: 41776362
