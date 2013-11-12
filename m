Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:55217 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756817Ab3KLVa5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 16:30:57 -0500
Received: by mail-qa0-f49.google.com with SMTP id cm18so3233044qab.15
        for <linux-nfs@vger.kernel.org>; Tue, 12 Nov 2013 13:30:57 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com, dros@netapp.com
Subject: [PATCH] nfs: don't retry detect_trunking with RPC_AUTH_UNIX more than once
Date: Tue, 12 Nov 2013 16:30:51 -0500
Message-Id: <1384291851-11154-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, when we try to mount and get back NFS4ERR_CLID_IN_USE or
NFS4ERR_WRONGSEC, we create a new rpc_clnt and then try the call again.
There is no guarantee that doing so will work however, so we can end up
retrying the call in an infinite loop.

Worse yet, we create the new client using rpc_clone_client_set_auth,
which creates the new client as a child of the old one. Thus, we can end
up with a *very* long lineage of rpc_clnts. When we go to put all of the
references to them, we can end up with a long call chain that can smash
the stack as each rpc_free_client() call can recurse back into itself.

This patch fixes this by simply ensuring that the SETCLIENTID call will
only be retried in this situation if the last attempt did not use
RPC_AUTH_UNIX.

Cc: stable@vger.kernel.org # v3.10+
Cc: Weston Andros Adamson <dros@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4state.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index c8e729d..4c26c01 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2097,6 +2097,11 @@ again:
 			break;
 	case -NFS4ERR_CLID_INUSE:
 	case -NFS4ERR_WRONGSEC:
+		/* No point in retrying if we already used RPC_AUTH_UNIX */
+		if (clnt->cl_auth->au_flavor == RPC_AUTH_UNIX) {
+			status = -EPERM;
+			break;
+		}
 		clnt = rpc_clone_client_set_auth(clnt, RPC_AUTH_UNIX);
 		if (IS_ERR(clnt)) {
 			status = PTR_ERR(clnt);
-- 
1.8.3.1

