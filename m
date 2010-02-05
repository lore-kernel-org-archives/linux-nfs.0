From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH] nfsd: default to kernel default for minorversion 1
Date: Fri, 5 Feb 2010 15:05:01 -0500
Message-ID: <20100205200501.GA28483@fieldses.org>
References: <1264631166-21898-1-git-send-email-bfields@citi.umich.edu> <1264631166-21898-2-git-send-email-bfields@citi.umich.edu> <20100201195821.GB19418@fieldses.org> <4B6B480C.1050307@RedHat.com> <20100205161001.GB24926@fieldses.org> <20100205192859.GE24926@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47756 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932429Ab0BEUEo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2010 15:04:44 -0500
In-Reply-To: <20100205192859.GE24926@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

The current kernel code should not be enabled by default, because it
does not yet attempt to be a conform completely to the rfc; for example,
some required pieces of protocol are missing.

Therefore the kernel defaults to leaving minorversion1 off.  When the
code matures sufficiently, that default will change.

That kernel default becomes meaningless if nfs-utils always explicitly
turns 4.1 on or off.  So, nfs-utils should by default do nothing.

Early adopters that want to turn on NFSv4.1 explicitly can still do so
using

	echo "+4.1" >/proc/fs/nfsd/versions

Signed-off-by: J.  Bruce Fields <bfields@citi.umich.edu>
---
 utils/nfsd/nfssvc.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index 7bbbaba..1fb420d 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -239,10 +239,9 @@ nfssvc_setvers(unsigned int ctlbits, int minorvers4)
 		return;
 
 	n = minorvers4 >= 0 ? minorvers4 : -minorvers4;
-	if (n >= NFSD_MINMINORVERS4 && n <= NFSD_MAXMINORVERS4)
-		    off += snprintf(ptr+off, sizeof(buf) - off, "%c4.%d",
-				    minorvers4 > 0 ? '+' : '-',
-				    n);
+	if (minorvers4 < 0 && n >= NFSD_MINMINORVERS4
+			   && n <= NFSD_MAXMINORVERS4)
+		    off += snprintf(ptr+off, sizeof(buf) - off, "-4.%d", n);
 	for (n = NFSD_MINVERS; n <= NFSD_MAXVERS; n++) {
 		if (NFSCTL_VERISSET(ctlbits, n))
 		    off += snprintf(ptr+off, sizeof(buf) - off, "+%d ", n);
-- 
1.6.3.3

