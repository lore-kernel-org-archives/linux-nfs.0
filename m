Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:35523 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759153Ab3KMOIa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Nov 2013 09:08:30 -0500
Received: by mail-qa0-f51.google.com with SMTP id hu16so460503qab.3
        for <linux-nfs@vger.kernel.org>; Wed, 13 Nov 2013 06:08:29 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com, dros@netapp.com
Subject: [PATCH v2] nfs: don't retry detect_trunking with RPC_AUTH_UNIX more than once
Date: Wed, 13 Nov 2013 09:08:21 -0500
Message-Id: <1384351701-29572-1-git-send-email-jlayton@redhat.com>
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

Note too that with this change, we don't need the (i > 2) check in the
-EACCES case since we now have a more reliable test as to whether we
should reattempt.

Cc: stable@vger.kernel.org # v3.10+
Cc: Chuck Lever <chuck.lever@oracle.com>
Tested-by/Acked-by: Weston Andros Adamson <dros@netapp.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4state.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index c8e729d..6f04706 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2093,10 +2093,15 @@ again:
 			nfs4_root_machine_cred(clp);
 			goto again;
 		}
-		if (i > 2)
+		if (clnt->cl_auth->au_flavor == RPC_AUTH_UNIX)
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

