Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45202 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752222AbbJNSXj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2015 14:23:39 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: jlayton@poochiereds.net, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com
Subject: [PATCH 01/10] NFS: keep nfs4_state for nfs4_lock_state cleanup
Date: Wed, 14 Oct 2015 14:23:28 -0400
Message-Id: <024db3a182ead54df8744b1230d0e0c0c5bb15c4.1444846590.git.bcodding@redhat.com>
In-Reply-To: <cover.1444846590.git.bcodding@redhat.com>
References: <cover.1444846590.git.bcodding@redhat.com>
In-Reply-To: <cover.1444846590.git.bcodding@redhat.com>
References: <cover.1444846590.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we fail to release a lock due to an error or signal on file close, we
might later free the lock if another lock replaces it.  Hold a reference to
the nfs4_state to ensure it is not released before freeing the
nfs4_lock_state.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4state.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index d854693..624c1e0 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -827,6 +827,7 @@ static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, f
 		return NULL;
 	nfs4_init_seqid_counter(&lsp->ls_seqid);
 	atomic_set(&lsp->ls_count, 1);
+	atomic_inc(&state->count);
 	lsp->ls_state = state;
 	lsp->ls_owner = fl_owner;
 	lsp->ls_seqid.owner_id = ida_simple_get(&server->lockowner_id, 0, 0, GFP_NOFS);
@@ -903,6 +904,7 @@ void nfs4_put_lock_state(struct nfs4_lock_state *lsp)
 		clp->cl_mvops->free_lock_state(server, lsp);
 	} else
 		nfs4_free_lock_state(server, lsp);
+	nfs4_put_open_state(state);
 }
 
 static void nfs4_fl_copy_lock(struct file_lock *dst, struct file_lock *src)
-- 
1.7.1

