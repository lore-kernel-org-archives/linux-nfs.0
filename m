Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx6-phx2.redhat.com ([209.132.183.39]:39358 "EHLO
	mx6-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754753AbaHEPRG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Aug 2014 11:17:06 -0400
Received: from zmail10.collab.prod.int.phx2.redhat.com (zmail10.collab.prod.int.phx2.redhat.com [10.5.83.12])
	by mx6-phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s75FH5HR025251
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2014 11:17:05 -0400
Date: Tue, 5 Aug 2014 11:17:05 -0400 (EDT)
From: David Jeffery <djeffery@redhat.com>
To: linux-nfs@vger.kernel.org
Message-ID: <1438879608.14503585.1407251825405.JavaMail.zimbra@redhat.com>
In-Reply-To: <1136742914.14501494.1407251366067.JavaMail.zimbra@redhat.com>
Subject: [PATCH] nfs: Always try and release an NFS file lock, even after
 receiving a SIGKILL
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


If a task holding an NFS file lock is killed with SIGKILL, it can
error out of do_unlk without ever trying to release the lock on
the server. This triggers the WARN in locks_remove_file(), while
also leaving the lock still claimed on the NFS server.  The file's
lock state is left out of sync between client and server, requiring
a restart of one or the other in order to release this ghost lock
on the file.

do_unlk() should continue on and tell the server to release the
lock, even if nfs_iocounter_wait() reports an error do to SIGKILL.

Signed-off-by: David Jeffery <djeffery@redhat.com>

---
 file.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 4042ff5..1b09243 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -750,10 +750,8 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 
 	l_ctx = nfs_get_lock_context(nfs_file_open_context(filp));
 	if (!IS_ERR(l_ctx)) {
-		status = nfs_iocounter_wait(&l_ctx->io_count);
+		nfs_iocounter_wait(&l_ctx->io_count);
 		nfs_put_lock_context(l_ctx);
-		if (status < 0)
-			return status;
 	}
 
 	/* NOTE: special case
