Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38260 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752866AbaAZU7Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 26 Jan 2014 15:59:24 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/3] nfsd4: minor nfs4_setlease cleanup
Date: Sun, 26 Jan 2014 15:59:19 -0500
Message-Id: <1390769961-30898-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1390769961-30898-1-git-send-email-bfields@redhat.com>
References: <1390769961-30898-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

As far as I can tell, this list is used only under the state lock, so we
may as well do this in the simpler order.

Acked-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5795d5f..ed3085b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3043,18 +3043,18 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 	if (!fl)
 		return -ENOMEM;
 	fl->fl_file = find_readable_file(fp);
-	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 	status = vfs_setlease(fl->fl_file, fl->fl_type, &fl);
-	if (status) {
-		list_del_init(&dp->dl_perclnt);
-		locks_free_lock(fl);
-		return status;
-	}
+	if (status)
+		goto out_free;
+	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 	fp->fi_lease = fl;
 	fp->fi_deleg_file = get_file(fl->fl_file);
 	atomic_set(&fp->fi_delegees, 1);
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
 	return 0;
+out_free:
+	locks_free_lock(fl);
+	return status;
 }
 
 static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
-- 
1.7.9.5

