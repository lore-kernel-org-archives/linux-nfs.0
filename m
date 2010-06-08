From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 14/24] pnfs_submit: use fsdata to pass lseg
Date: Tue,  8 Jun 2010 00:19:11 -0400
Message-ID: <1275970761-31806-15-git-send-email-iisaman@netapp.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com>
 <1275970761-31806-2-git-send-email-iisaman@netapp.com>
 <1275970761-31806-3-git-send-email-iisaman@netapp.com>
 <1275970761-31806-4-git-send-email-iisaman@netapp.com>
 <1275970761-31806-5-git-send-email-iisaman@netapp.com>
 <1275970761-31806-6-git-send-email-iisaman@netapp.com>
 <1275970761-31806-7-git-send-email-iisaman@netapp.com>
 <1275970761-31806-8-git-send-email-iisaman@netapp.com>
 <1275970761-31806-9-git-send-email-iisaman@netapp.com>
 <1275970761-31806-10-git-send-email-iisaman@netapp.com>
 <1275970761-31806-11-git-send-email-iisaman@netapp.com>
 <1275970761-31806-12-git-send-email-iisaman@netapp.com>
 <1275970761-31806-13-git-send-email-iisaman@netapp.com>
 <1275970761-31806-14-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37342 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751843Ab0FHETr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 00:19:47 -0400
Received: from localhost.localdomain (navitha-lxp.hq.netapp.com [10.58.53.227] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o584JOQ5014203
	for <linux-nfs@vger.kernel.org>; Mon, 7 Jun 2010 21:19:34 -0700 (PDT)
In-Reply-To: <1275970761-31806-14-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Preparing for LAYUTGET invocation in nfs_write_begin to be the
only invocation in the write path.

It isn't used at all yet, but it should be properly referenced/dereferenced

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/file.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 03601d2..fde6cb5 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -420,6 +420,8 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 		file->f_path.dentry->d_name.name,
 		mapping->host->i_ino, len, (long long) pos);
 
+	pnfs_update_layout(mapping->host, NULL, NFS4_MAX_UINT64, 0, IOMODE_RW,
+			   (struct pnfs_layout_segment **) fsdata);
 start:
 	/*
 	 * Prevent starvation issues if someone is doing a consistency
@@ -428,11 +430,13 @@ start:
 	ret = wait_on_bit(&NFS_I(mapping->host)->flags, NFS_INO_FLUSHING,
 			nfs_wait_bit_killable, TASK_KILLABLE);
 	if (ret)
-		return ret;
+		goto out;
 
 	page = grab_cache_page_write_begin(mapping, index, flags);
-	if (!page)
-		return -ENOMEM;
+	if (!page) {
+		ret = -ENOMEM;
+		goto out;
+	}
 	*pagep = page;
 
 	ret = nfs_flush_incompatible(file, page);
@@ -447,6 +451,11 @@ start:
 		if (!ret)
 			goto start;
 	}
+ out:
+	if (ret) {
+		put_lseg(*fsdata);
+		*fsdata = NULL;
+	}
 	return ret;
 }
 
@@ -486,6 +495,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 
 	unlock_page(page);
 	page_cache_release(page);
+	put_lseg(fsdata);
 
 	if (status < 0)
 		return status;
-- 
1.6.6.1

