From: akpm@linux-foundation.org
Subject: [patch 5/5] nfs: make nfs4_drop_state_owner() static
Date: Fri, 02 May 2008 13:42:45 -0700
Message-ID: <200805022042.m42Kgjsb013884@imap1.linux-foundation.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
	akpm@linux-foundation.org, bunk@kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58943 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935926AbYEBUnL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 May 2008 16:43:11 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>

nfs4_drop_state_owner() can now become static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/nfs/nfs4_fs.h   |    1 -
 fs/nfs/nfs4state.c |    2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff -puN fs/nfs/nfs4_fs.h~nfs-make-nfs4_drop_state_owner-static fs/nfs/nfs4_fs.h
--- a/fs/nfs/nfs4_fs.h~nfs-make-nfs4_drop_state_owner-static
+++ a/fs/nfs/nfs4_fs.h
@@ -206,7 +206,6 @@ struct rpc_cred *nfs4_get_renew_cred(str
 
 extern struct nfs4_state_owner * nfs4_get_state_owner(struct nfs_server *, struct rpc_cred *);
 extern void nfs4_put_state_owner(struct nfs4_state_owner *);
-extern void nfs4_drop_state_owner(struct nfs4_state_owner *);
 extern struct nfs4_state * nfs4_get_open_state(struct inode *, struct nfs4_state_owner *);
 extern void nfs4_put_open_state(struct nfs4_state *);
 extern void nfs4_close_state(struct path *, struct nfs4_state *, mode_t);
diff -puN fs/nfs/nfs4state.c~nfs-make-nfs4_drop_state_owner-static fs/nfs/nfs4state.c
--- a/fs/nfs/nfs4state.c~nfs-make-nfs4_drop_state_owner-static
+++ a/fs/nfs/nfs4state.c
@@ -282,7 +282,7 @@ nfs4_alloc_state_owner(void)
 	return sp;
 }
 
-void
+static void
 nfs4_drop_state_owner(struct nfs4_state_owner *sp)
 {
 	if (!RB_EMPTY_NODE(&sp->so_client_node)) {
_
