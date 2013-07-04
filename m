Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f176.google.com ([209.85.128.176]:56897 "EHLO
	mail-ve0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752598Ab3GDKf3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jul 2013 06:35:29 -0400
Received: by mail-ve0-f176.google.com with SMTP id c13so909162vea.35
        for <linux-nfs@vger.kernel.org>; Thu, 04 Jul 2013 03:35:29 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, smayhew@redhat.com
Subject: [PATCH] nfs: set verifier on existing dentries in nfs_prime_dcache
Date: Thu,  4 Jul 2013 06:35:23 -0400
Message-Id: <1372934123-2574-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_prime_dcache currently only sets the verifier when it doesn't
initially a matching dentry in the dcache. Set the verifier in the case
where we do find a dentry in the dcache. This ensures that we don't
have to look up the dentry again if we want to use it after a readdir.

Cc: Scott Mayhew <smayhew@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/dir.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e093e73..b4043e5 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -448,6 +448,7 @@ void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry)
 	if (dentry != NULL) {
 		if (nfs_same_file(dentry, entry)) {
 			nfs_refresh_inode(dentry->d_inode, entry->fattr);
+			nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 			goto out;
 		} else {
 			if (d_invalidate(dentry) != 0)
-- 
1.8.1.4

