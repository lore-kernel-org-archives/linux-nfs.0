Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52495 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755539Ab2ACW4Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Jan 2012 17:56:24 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/4] nfsd4: fix spurious 4.1 post-reboot failures
Date: Tue,  3 Jan 2012 17:56:18 -0500
Message-Id: <1325631381-9231-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1325631381-9231-1-git-send-email-bfields@redhat.com>
References: <1325631381-9231-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

In the NFSv4.1 case, this could cause a spurious "NFSD: failed to write
recovery record (err -17); please check that /var/lib/nfs/v4recovery
exists and is writable.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Reported-by: Steve Dickson <SteveD@redhat.com>
---
 fs/nfsd/nfs4recover.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index ed083b9..28712e2 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -144,8 +144,15 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 		status = PTR_ERR(dentry);
 		goto out_unlock;
 	}
-	status = -EEXIST;
 	if (dentry->d_inode)
+		/*
+		 * In the 4.1 case, where we're called from
+		 * reclaim_complete(), records from the previous reboot
+		 * may still be left, so this is OK.
+		 *
+		 * In the 4.0 case, we should never get here; but we may
+		 * as well be forgiving and just succeed silently.
+		 */
 		goto out_put;
 	status = mnt_want_write(rec_file->f_path.mnt);
 	if (status)
-- 
1.7.5.4

