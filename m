Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:21327 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752680Ab3DLT3C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Apr 2013 15:29:02 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Andy Adamson <andros@netapp.com>
Subject: [PATCH] NFSv4: Fix handling of revoked delegations by setattr
Date: Fri, 12 Apr 2013 15:28:58 -0400
Message-Id: <1365794938-28400-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, _nfs4_do_setattr() will use the delegation stateid if no
writeable open file stateid is available.
If the server revokes that delegation stateid, then the call to
nfs4_handle_exception() will fail to handle the error due to the
lack of a struct nfs4_state, and will just convert the error into
an EIO.

This patch just removes the requirement that we must have a
struct nfs4_state in order to invalidate the delegation and
retry.

Reported-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 83197fb..af05df3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -304,9 +304,13 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 		case -NFS4ERR_DELEG_REVOKED:
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_BAD_STATEID:
+			if (inode != NULL && nfs4_have_delegation(inode, FMODE_READ)) {
+				nfs_remove_bad_delegation(inode);
+				exception->retry = 1;
+				break;
+			}
 			if (state == NULL)
 				break;
-			nfs_remove_bad_delegation(state->inode);
 			ret = nfs4_schedule_stateid_recovery(server, state);
 			if (ret < 0)
 				break;
-- 
1.8.1.4

