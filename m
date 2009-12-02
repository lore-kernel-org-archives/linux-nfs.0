From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 7/7] nfsd: increase export interface version
Date: Tue,  1 Dec 2009 19:39:43 -0500
Message-ID: <1259714383-32577-8-git-send-email-bfields@citi.umich.edu>
References: <1259714383-32577-1-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-2-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-3-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-4-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-5-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-6-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-7-git-send-email-bfields@citi.umich.edu>
Cc: Steve Dickson <steved@redhat.com>,
	Steve Dickson <SteveD@redhat.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46269 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754902AbZLBAim (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Dec 2009 19:38:42 -0500
In-Reply-To: <1259714383-32577-7-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <SteveD@redhat.com>

The V4ROOT flag is supposed to make it safe to export filesystems that
would not ordinarily have been exported, by severely restricting which
directories on the filesystem may be accessed.

Before exporting those filesystems, we must have a way for userspace
(mainly mountd) to know whether the kernel supports the new flag.  The
kernel has always silently ignored unknown export flags.

So, we bump the export version to signal mountd that the kernel has
pseudo root support.

Signed-Off-By: Steve Dickson <steved@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/export.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 0bcd10a..39c22d9 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1522,7 +1522,7 @@ static int e_show(struct seq_file *m, void *p)
 	struct svc_export *exp = container_of(cp, struct svc_export, h);
 
 	if (p == SEQ_START_TOKEN) {
-		seq_puts(m, "# Version 1.1\n");
+		seq_puts(m, "# Version 1.2\n");
 		seq_puts(m, "# Path Client(Flags) # IPs\n");
 		return 0;
 	}
-- 
1.6.3.3

