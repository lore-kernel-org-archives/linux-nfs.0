Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:9976 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750753AbbFLUxd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jun 2015 16:53:33 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Anna.Schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] Recover from stateid-type error on SETATTR
Date: Fri, 12 Jun 2015 16:53:30 -0400
Message-ID: <1434142410-86401-1-git-send-email-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Client can receives stateid-type error (eg., BAD_STATEID) on SETATTR when
delegation stateid was used. When no open state exists, in case of application
calling truncate() on the file, client has no state to recover and fails with
EIO.

Instead, upon such error, return the bad delegation and then resend the
SETATTR with a zero stateid.

Signed-off: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4proc.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ad7cf7e..2a85af3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -360,8 +360,14 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 		case -NFS4ERR_DELEG_REVOKED:
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_BAD_STATEID:
-			if (state == NULL)
+			if (state == NULL) {
+				if (inode && nfs4_have_delegation(inode, 
+						FMODE_READ)) {
+					nfs4_inode_return_delegation(inode);
+					exception->retry = 1;
+				}
 				break;
+			}
 			ret = nfs4_schedule_stateid_recovery(server, state);
 			if (ret < 0)
 				break;
-- 
1.8.3.1

