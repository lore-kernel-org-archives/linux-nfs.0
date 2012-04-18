Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60477 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754192Ab2DRRhD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Apr 2012 13:37:03 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Luis Henriques <luis.henriques@canonical.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] NFSv4: Ensure that the LOCK code sets exception->inode
Date: Wed, 18 Apr 2012 13:36:53 -0400
Message-Id: <1334770614-10653-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1334770614-10653-1-git-send-email-Trond.Myklebust@netapp.com>
References: <20120418105147.2a6f1c55@corrin.poochiereds.net>
 <1334770614-10653-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <20120418105147.2a6f1c55@corrin.poochiereds.net>
References: <20120418105147.2a6f1c55@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All callers of nfs4_handle_exception() that need to handle
NFS4ERR_OPENMODE correctly should set exception->inode

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@vger.kernel.org [>= 3.3.1]
---
 fs/nfs/nfs4proc.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f82bde0..3c787d0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4558,7 +4558,9 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 static int nfs4_lock_reclaim(struct nfs4_state *state, struct file_lock *request)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = state->inode,
+	};
 	int err;
 
 	do {
@@ -4576,7 +4578,9 @@ static int nfs4_lock_reclaim(struct nfs4_state *state, struct file_lock *request
 static int nfs4_lock_expired(struct nfs4_state *state, struct file_lock *request)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
-	struct nfs4_exception exception = { };
+	struct nfs4_exception exception = {
+		.inode = state->inode,
+	};
 	int err;
 
 	err = nfs4_set_lock_state(state, request);
@@ -4676,6 +4680,7 @@ static int nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *
 {
 	struct nfs4_exception exception = {
 		.state = state,
+		.inode = state->inode,
 	};
 	int err;
 
-- 
1.7.7.6

