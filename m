Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:34984 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753267Ab1LFVNm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Dec 2011 16:13:42 -0500
Received: by yenm1 with SMTP id m1so3368414yen.19
        for <linux-nfs@vger.kernel.org>; Tue, 06 Dec 2011 13:13:41 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] NFS: Clean up nfs4_find_state_owners_locked()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 06 Dec 2011 16:13:39 -0500
Message-ID: <20111206211339.5969.64168.stgit@degas.1015granger.net>
In-Reply-To: <20111206210723.5969.85159.stgit@degas.1015granger.net>
References: <20111206210723.5969.85159.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There's no longer a need to check the so_server field in the state
owner, because nowadays the RB tree we search for state owners
contains owners for that only server.

Make nfs4_find_state_owners_locked() use the same tree searching logic
as nfs4_insert_state_owner_locked().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4state.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 39914be..8794b82 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -377,31 +377,22 @@ nfs4_find_state_owner_locked(struct nfs_server *server, struct rpc_cred *cred)
 {
 	struct rb_node **p = &server->state_owners.rb_node,
 		       *parent = NULL;
-	struct nfs4_state_owner *sp, *res = NULL;
+	struct nfs4_state_owner *sp;
 
 	while (*p != NULL) {
 		parent = *p;
 		sp = rb_entry(parent, struct nfs4_state_owner, so_server_node);
 
-		if (server < sp->so_server) {
-			p = &parent->rb_left;
-			continue;
-		}
-		if (server > sp->so_server) {
-			p = &parent->rb_right;
-			continue;
-		}
 		if (cred < sp->so_cred)
 			p = &parent->rb_left;
 		else if (cred > sp->so_cred)
 			p = &parent->rb_right;
 		else {
 			atomic_inc(&sp->so_count);
-			res = sp;
-			break;
+			return sp;
 		}
 	}
-	return res;
+	return NULL;
 }
 
 static struct nfs4_state_owner *

