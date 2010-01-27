Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40728 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932164Ab0A0WYb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jan 2010 17:24:31 -0500
From: "J. Bruce Fields" <bfields@citi.umich.edu>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/2] nfsd: fix version-setting regression on old kernels
Date: Wed, 27 Jan 2010 17:26:05 -0500
Message-Id: <1264631166-21898-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

/proc/fs/nfsd/versions was extended to allow turning on/off minor
versions by echoing "+4.1" or "-4.1" to /proc/fs/nsfd/versions.

Unfortunately, pre-2.6.30 kernels just stop parsing at first non-digit,
so "-4.1" is interpreted as "-4".  If new nfs-utils (on old kernel)
writes "+2", "+3", "+4", then "-4.1", result therefore is to turn off
4.1.

Given that historical behavior, it may have been a mistake to extend the
interface the way we did; but at this point we're probably stuck with
it.  So, just reverse the order we write versions in.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 utils/nfsd/nfssvc.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index b8028bb..7bbbaba 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -238,17 +238,17 @@ nfssvc_setvers(unsigned int ctlbits, int minorvers4)
 	if (fd < 0)
 		return;
 
+	n = minorvers4 >= 0 ? minorvers4 : -minorvers4;
+	if (n >= NFSD_MINMINORVERS4 && n <= NFSD_MAXMINORVERS4)
+		    off += snprintf(ptr+off, sizeof(buf) - off, "%c4.%d",
+				    minorvers4 > 0 ? '+' : '-',
+				    n);
 	for (n = NFSD_MINVERS; n <= NFSD_MAXVERS; n++) {
 		if (NFSCTL_VERISSET(ctlbits, n))
 		    off += snprintf(ptr+off, sizeof(buf) - off, "+%d ", n);
 		else
 		    off += snprintf(ptr+off, sizeof(buf) - off, "-%d ", n);
 	}
-	n = minorvers4 >= 0 ? minorvers4 : -minorvers4;
-	if (n >= NFSD_MINMINORVERS4 && n <= NFSD_MAXMINORVERS4)
-		    off += snprintf(ptr+off, sizeof(buf) - off, "%c4.%d",
-				    minorvers4 > 0 ? '+' : '-',
-				    n);
 	xlog(D_GENERAL, "Writing version string to kernel: %s", buf);
 	snprintf(ptr+off, sizeof(buf) - off, "\n");
 	if (write(fd, buf, strlen(buf)) != strlen(buf))
-- 
1.6.3.3

