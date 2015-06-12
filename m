Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:50552 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750698AbbFLSa6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jun 2015 14:30:58 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Anna.Schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] Recover from stateid-type error on SETATTR
Date: Fri, 12 Jun 2015 14:30:55 -0400
Message-ID: <1434133855-86259-1-git-send-email-kolga@netapp.com>
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
 fs/nfs/delegation.h | 6 ++++++
 fs/nfs/nfs4proc.c   | 7 ++++++-
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index e3c20a3..e37165f 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -62,6 +62,12 @@ void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
 int nfs4_have_delegation(struct inode *inode, fmode_t flags);
 int nfs4_check_delegation(struct inode *inode, fmode_t flags);
 
+static inline int nfs4_have_any_delegation(struct inode *inode)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+	return rcu_access_pointer(nfsi->delegation) ? 1 : 0;
+}
+
 #endif
 
 static inline int nfs_have_delegated_attributes(struct inode *inode)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ad7cf7e..63b3581 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -360,8 +360,13 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 		case -NFS4ERR_DELEG_REVOKED:
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_BAD_STATEID:
-			if (state == NULL)
+			if (state == NULL) {
+				if (nfs4_have_any_delegation(inode)) {
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

