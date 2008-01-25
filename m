From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 017/100] nfsd: cleanup nfsd module initialization cleanup
Date: Fri, 25 Jan 2008 18:15:57 -0500
Message-ID: <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47331 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762069AbYAYXRZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:25 -0500
In-Reply-To: <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Handle the failure case here with something closer to the standard
kernel style.

Doesn't really matter for now, but I'd like to add a few more failure
cases, and then this'll help.

Acked-by: NeilBrown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfsctl.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index d8d50a7..ecf3779 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -694,16 +694,18 @@ static int __init init_nfsd(void)
 			entry->proc_fops =  &exports_operations;
 	}
 	retval = register_filesystem(&nfsd_fs_type);
-	if (retval) {
-		nfsd_idmap_shutdown();
-		nfsd_export_shutdown();
-		nfsd_cache_shutdown();
-		remove_proc_entry("fs/nfs/exports", NULL);
-		remove_proc_entry("fs/nfs", NULL);
-		nfsd_stat_shutdown();
-		nfsd_lockd_shutdown();
-		nfsd4_free_slabs();
-	}
+	if (retval)
+		goto out_free_all;
+	return 0;
+out_free_all:
+	nfsd_idmap_shutdown();
+	nfsd_export_shutdown();
+	nfsd_cache_shutdown();
+	remove_proc_entry("fs/nfs/exports", NULL);
+	remove_proc_entry("fs/nfs", NULL);
+	nfsd_stat_shutdown();
+	nfsd_lockd_shutdown();
+	nfsd4_free_slabs();
 	return retval;
 }
 
-- 
1.5.4.rc2.60.gb2e62

