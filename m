Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:38044 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395Ab2KLUBY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Nov 2012 15:01:24 -0500
Received: by mail-vc0-f174.google.com with SMTP id fk26so6536744vcb.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Nov 2012 12:01:24 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 11/11] nfsd: release the legacy reclaimable clients list in grace_done
Date: Mon, 12 Nov 2012 15:00:58 -0500
Message-Id: <1352750458-16857-12-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352750458-16857-1-git-send-email-jlayton@redhat.com>
References: <1352750458-16857-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current code holds on to this list until nfsd is shut down, but it's
never touched once the grace period ends. Release that memory back into
the wild when the grace period ends.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4recover.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 80e77cc..b03b6aa 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -404,6 +404,7 @@ nfsd4_recdir_purge_old(struct net *net, time_t boot_time)
 		vfs_fsync(rec_file, 0);
 	mnt_drop_write_file(rec_file);
 out:
+	nfs4_release_reclaim();
 	if (status)
 		printk("nfsd4: failed to purge old clients from recovery"
 			" directory %s\n", rec_file->f_path.dentry->d_name.name);
-- 
1.7.11.7

