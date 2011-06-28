Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e23smtp04.au.ibm.com ([202.81.31.146]:40249 "EHLO
	e23smtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753804Ab1F1Klo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2011 06:41:44 -0400
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp04.au.ibm.com (8.14.4/8.13.1) with ESMTP id p5SAZTY9019011
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jun 2011 20:35:29 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5SAfd69438378
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jun 2011 20:41:39 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5SAfdnB019403
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jun 2011 20:41:39 +1000
Received: from localhost ([9.77.125.199])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id p5SAfcxF019386
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jun 2011 20:41:39 +1000
Date: Tue, 28 Jun 2011 16:11:38 +0530
From: Prem Karat <prem.karat@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] nfs-utils: Don't hard code source and destination args
Message-ID: <20110628104138.GB6600@d6fc318.ibm.com>
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
