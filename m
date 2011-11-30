Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47343 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753269Ab1K3A5C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Nov 2011 19:57:02 -0500
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Wed, 30 Nov 2011 11:52:51 +1100
Subject: [PATCH 1/2] NFS - fix recent breakage to NFS error handling.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20111130005251.23632.79389.stgit@notabene.brown>
In-Reply-To: <20111130005231.23632.87382.stgit@notabene.brown>
References: <20111130005231.23632.87382.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit 02c24a82187d5a628c68edfe71ae60dc135cd178 made a small and
presumably unintended change to write error handling in NFS.

Previously an error from filemap_write_and_wait_range would only be of
interest if nfs_file_fsync did not return an error.  After this commit,
an error from filemap_write_and_wait_range would mean that nfs_file_fsync
would not even be called.

This means that:
 1/ you are more likely to see EIO than e.g. EDQUOT or ENOSPC.
 2/ NFS_CONTEXT_ERROR_WRITE remains set for longer so more writes are
    synchronous.

This patch restores previous behaviour.

Cc: stable@kernel.org
Cc: Josef Bacik <josef@redhat.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: NeilBrown <neilb@suse.de>
---

 fs/nfs/file.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index eca56d4..1d8e7bf 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -272,13 +272,13 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 			datasync);
 
 	ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
-	if (ret)
-		return ret;
 	mutex_lock(&inode->i_mutex);
 
 	nfs_inc_stats(inode, NFSIOS_VFSFSYNC);
 	have_error = test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
 	status = nfs_commit_inode(inode, FLUSH_SYNC);
+	if (status >= 0 && ret < 0)
+		status = ret;
 	have_error |= test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
 	if (have_error)
 		ret = xchg(&ctx->error, 0);


