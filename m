Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57565 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752120Ab3ISTMF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Sep 2013 15:12:05 -0400
Date: Thu, 19 Sep 2013 15:12:03 -0400
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] exportfs: test_export shouldn't use invalid uid/gid
Message-ID: <20130919191203.GA29599@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Some newer kernels are rejecting -1 uid/gid.  Actually, worse--they're
silently ignoring any attempt to cache such exports, thus preventing
test_export from getting back the errors it needs.

And -1 wasn't a good choice anyway.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/exportfs/exportfs.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 9f79541..4331697 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -420,7 +420,7 @@ static int test_export(char *path, int with_fsid)
 	char buf[1024];
 	int fd, n;
 
-	sprintf(buf, "-test-client- %s 3 %d -1 -1 0\n",
+	sprintf(buf, "-test-client- %s 3 %d 65534 65534 0\n",
 		path,
 		with_fsid ? NFSEXP_FSID : 0);
 	fd = open("/proc/net/rpc/nfsd.export/channel", O_WRONLY);
-- 
1.7.9.5

