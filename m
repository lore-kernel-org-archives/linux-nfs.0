Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34111 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754520AbcIVRjd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 13:39:33 -0400
Received: by mail-it0-f66.google.com with SMTP id 186so5343138itf.1
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 10:39:27 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v7 02/31] NFS: Fix inode corruption in nfs_prime_dcache()
Date: Thu, 22 Sep 2016 13:38:52 -0400
Message-Id: <1474565961-21303-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474565961-21303-2-git-send-email-trond.myklebust@primarydata.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Due to inode number reuse in filesystems, we can end up corrupting the
inode on our client if we apply the file attributes without ensuring that
the filehandle matches.
Typical symptoms include spurious "mode changed" reports in the syslog.

We still do want to ensure that we don't invalidate the dentry if the
inode number matches, but we don't have a filehandle.

Fixes: fa9233699cc1 ("NFS: Don't require a filehandle to refresh...")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: stable@vger.kernel.org # v4.0+
---
 fs/nfs/dir.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 177fefb26c18..6bc5a68e39f1 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -435,11 +435,11 @@ int nfs_same_file(struct dentry *dentry, struct nfs_entry *entry)
 		return 0;
 
 	nfsi = NFS_I(inode);
-	if (entry->fattr->fileid == nfsi->fileid)
-		return 1;
-	if (nfs_compare_fh(entry->fh, &nfsi->fh) == 0)
-		return 1;
-	return 0;
+	if (entry->fattr->fileid != nfsi->fileid)
+		return 0;
+	if (entry->fh->size && nfs_compare_fh(entry->fh, &nfsi->fh) != 0)
+		return 0;
+	return 1;
 }
 
 static
@@ -517,6 +517,8 @@ again:
 					&entry->fattr->fsid))
 			goto out;
 		if (nfs_same_file(dentry, entry)) {
+			if (!entry->fh->size)
+				goto out;
 			nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 			status = nfs_refresh_inode(d_inode(dentry), entry->fattr);
 			if (!status)
@@ -529,6 +531,10 @@ again:
 			goto again;
 		}
 	}
+	if (!entry->fh->size) {
+		d_lookup_done(dentry);
+		goto out;
+	}
 
 	inode = nfs_fhget(dentry->d_sb, entry->fh, entry->fattr, entry->label);
 	alias = d_splice_alias(inode, dentry);
-- 
2.7.4

