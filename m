Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33732 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758233AbcHaCMS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Aug 2016 22:12:18 -0400
Received: by mail-it0-f65.google.com with SMTP id n75so4101554ith.0
        for <linux-nfs@vger.kernel.org>; Tue, 30 Aug 2016 19:12:17 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 6/7] NFSv4.1: Deal with server reboots during delegation expiration recovery
Date: Tue, 30 Aug 2016 22:11:43 -0400
Message-Id: <1472609504-69094-7-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1472609504-69094-6-git-send-email-trond.myklebust@primarydata.com>
References: <1472609504-69094-1-git-send-email-trond.myklebust@primarydata.com>
 <1472609504-69094-2-git-send-email-trond.myklebust@primarydata.com>
 <1472609504-69094-3-git-send-email-trond.myklebust@primarydata.com>
 <1472609504-69094-4-git-send-email-trond.myklebust@primarydata.com>
 <1472609504-69094-5-git-send-email-trond.myklebust@primarydata.com>
 <1472609504-69094-6-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that if the server reboots while we're testing and recovering
from revoked delegations, we exit to allow the state manager to
handle matters.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index ff0c1a0feb9d..b873271c613a 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -874,6 +874,13 @@ restart:
 	rcu_read_unlock();
 }
 
+static inline bool nfs4_server_rebooted(const struct nfs_client *clp)
+{
+	return (clp->cl_state & (BIT(NFS4CLNT_CHECK_LEASE) |
+				BIT(NFS4CLNT_LEASE_EXPIRED) |
+				BIT(NFS4CLNT_SESSION_RESET))) != 0;
+}
+
 static void nfs_mark_test_expired_delegation(struct nfs_server *server,
 	    struct nfs_delegation *delegation)
 {
@@ -882,6 +889,19 @@ static void nfs_mark_test_expired_delegation(struct nfs_server *server,
 	set_bit(NFS4CLNT_DELEGATION_EXPIRED, &server->nfs_client->cl_state);
 }
 
+static void nfs_inode_mark_test_expired_delegation(struct nfs_server *server,
+		struct inode *inode)
+{
+	struct nfs_delegation *delegation;
+
+	rcu_read_lock();
+	delegation = rcu_dereference(NFS_I(inode)->delegation);
+	if (delegation)
+		nfs_mark_test_expired_delegation(server, delegation);
+	rcu_read_unlock();
+
+}
+
 static void nfs_delegation_mark_test_expired_server(struct nfs_server *server)
 {
 	struct nfs_delegation *delegation;
@@ -954,6 +974,12 @@ restart:
 				nfs_inode_find_state_and_recover(inode, &stateid);
 			}
 			put_rpccred(cred);
+			if (nfs4_server_rebooted(clp)) {
+				nfs_inode_mark_test_expired_delegation(server,inode);
+				iput(inode);
+				nfs_sb_deactive(server->super);
+				return;
+			}
 			iput(inode);
 			nfs_sb_deactive(server->super);
 			goto restart;
-- 
2.7.4

