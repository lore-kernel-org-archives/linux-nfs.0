Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52416 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750870Ab3LRUGa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Dec 2013 15:06:30 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rBIK6TA5003986
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 18 Dec 2013 15:06:30 -0500
Received: from tasleson.csb (vpn-229-185.phx2.redhat.com [10.3.229.185])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id rBIK6Tk8026837
	for <linux-nfs@vger.kernel.org>; Wed, 18 Dec 2013 15:06:29 -0500
From: Tony Asleson <tasleson@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] exportfs.c: escape path for function test_export
Date: Wed, 18 Dec 2013 14:06:27 -0600
Message-Id: <1387397189-9591-1-git-send-email-tasleson@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Verbatim patch proposal from J. Bruce Fields except calling
snprintf instead of sprintf.

Tested and appears to work with path names that have a space.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 utils/exportfs/exportfs.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 00667e9..3ca45c1 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -444,11 +444,15 @@ static int can_test(void)
 static int test_export(char *path, int with_fsid)
 {
 	char buf[1024];
+	char *bp = buf;
+	int len = sizeof(buf);
 	int fd, n;
 
-	sprintf(buf, "-test-client- %s 3 %d 65534 65534 0\n",
-		path,
-		with_fsid ? NFSEXP_FSID : 0);
+	n = snprintf(buf, len, "-test-client- ");
+	bp += n;
+	len -= n;
+	qword_add(&bp, &len, path);
+	snprintf(bp, len, " 3 %d 65534 65534 0\n", with_fsid ? NFSEXP_FSID : 0);
 	fd = open("/proc/net/rpc/nfsd.export/channel", O_WRONLY);
 	if (fd < 0)
 		return 0;
-- 
1.8.2.1

