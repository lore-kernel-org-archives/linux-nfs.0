Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:36169 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755388Ab2KIUcC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Nov 2012 15:32:02 -0500
Received: by mail-vc0-f174.google.com with SMTP id fk26so4210471vcb.19
        for <linux-nfs@vger.kernel.org>; Fri, 09 Nov 2012 12:32:01 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: fix error handling in nfsd4_remove_clid_dir
Date: Fri,  9 Nov 2012 15:31:53 -0500
Message-Id: <1352493113-22005-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the credential save fails, then we'll leak our mnt_want_write_file
reference.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4recover.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 43295d4..0f1e2e2 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -301,12 +301,13 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
 
 	status = nfs4_save_creds(&original_cred);
 	if (status < 0)
-		goto out;
+		goto out_drop_write;
 
 	status = nfsd4_unlink_clid_dir(clp->cl_recdir, HEXDIR_LEN-1);
 	nfs4_reset_creds(original_cred);
 	if (status == 0)
 		vfs_fsync(rec_file, 0);
+out_drop_write:
 	mnt_drop_write_file(rec_file);
 out:
 	if (status)
-- 
1.7.11.7

