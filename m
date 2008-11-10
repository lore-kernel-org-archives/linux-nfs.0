From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 25/85] nfs41: make nfs4_wait_bit_killable public
Date: Mon, 10 Nov 2008 22:22:24 +0200
Message-ID: <1226348544-8023-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48762 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520AbYKJUWa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:22:30 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Rahul Iyer <iyer@netapp.com>

nfs4_wait_bit_killable to be used by NFSv4.1 session recover logic.

Signed-off-by: Rahul Iyer <iyer@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4_fs.h  |    1 +
 fs/nfs/nfs4proc.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index dd3a6d0..bef2fca 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -179,6 +179,7 @@ extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struc
 extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_proc_async_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_proc_renew(struct nfs_client *, struct rpc_cred *);
+extern int nfs4_wait_bit_killable(void *);
 extern int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait);
 extern struct dentry *nfs4_atomic_open(struct inode *, struct dentry *, struct nameidata *);
 extern int nfs4_open_revalidate(struct inode *, struct dentry *, int, struct nameidata *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6418aa8..1cc639e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2929,7 +2929,7 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server)
 	return 0;
 }
 
-static int nfs4_wait_bit_killable(void *word)
+int nfs4_wait_bit_killable(void *word)
 {
 	if (fatal_signal_pending(current))
 		return -ERESTARTSYS;
-- 
1.6.0.2

