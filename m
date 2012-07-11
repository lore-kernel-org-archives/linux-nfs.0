Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:50255 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538Ab2GKU36 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jul 2012 16:29:58 -0400
Received: by gglu4 with SMTP id u4so1697031ggl.19
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jul 2012 13:29:58 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/15] NFS: Don't free a state ID the server does not recognize
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 11 Jul 2012 16:29:56 -0400
Message-ID: <20120711202955.3767.78152.stgit@degas.1015granger.net>
In-Reply-To: <20120711201718.3767.66867.stgit@degas.1015granger.net>
References: <20120711201718.3767.66867.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The result of a TEST_STATEID operation can indicate a few different
things:

  o If NFS_OK is returned, then the client can continue using the
    state ID under test, and skip recovery.

  o RFC 5661 says that if the state ID was revoked, then the client
    must perform an explicit FREE_STATEID before trying to re-open.

  o If the server doesn't recognize the state ID at all, then no
    FREE_STATEID is needed, and the client can immediately continue
    with open recovery.

Let's err on the side of caution: if the server clearly tells us the
state ID is unknown, we skip the FREE_STATEID.  For any other error,
we issue a FREE_STATEID.  Sometimes that FREE_STATEID will be
unnecessary, but leaving unused state IDs on the server needlessly
ties up resources.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9a0397c..2986e65 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1764,7 +1764,8 @@ static int nfs41_check_expired_stateid(struct nfs4_state *state, nfs4_stateid *s
 	if (state->flags & flags) {
 		status = nfs41_test_stateid(server, stateid);
 		if (status != NFS_OK) {
-			nfs41_free_stateid(server, stateid);
+			if (status != -NFS4ERR_BAD_STATEID)
+				nfs41_free_stateid(server, stateid);
 			state->flags &= ~flags;
 		}
 	}
@@ -4708,7 +4709,9 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
 		if (lsp->ls_flags & NFS_LOCK_INITIALIZED) {
 			status = nfs41_test_stateid(server, &lsp->ls_stateid);
 			if (status != NFS_OK) {
-				nfs41_free_stateid(server, &lsp->ls_stateid);
+				if (status != -NFS4ERR_BAD_STATEID)
+					nfs41_free_stateid(server,
+							&lsp->ls_stateid);
 				lsp->ls_flags &= ~NFS_LOCK_INITIALIZED;
 				ret = status;
 			}

