Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35872 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753327AbcIQFNo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Sep 2016 01:13:44 -0400
Received: by mail-io0-f196.google.com with SMTP id z135so2380156ioe.3
        for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2016 22:13:43 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v5 08/25] NFSv4.1: Deal with server reboots during delegation expiration recovery
Date: Sat, 17 Sep 2016 01:13:16 -0400
Message-Id: <1474089213-104014-9-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474089213-104014-8-git-send-email-trond.myklebust@primarydata.com>
References: <1474089213-104014-1-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-2-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-3-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-4-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-5-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-6-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-7-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-8-git-send-email-trond.myklebust@primarydata.com>
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
index f0765968a819..f431fde13e90 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -875,6 +875,13 @@ restart:
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
@@ -883,6 +890,19 @@ static void nfs_mark_test_expired_delegation(struct nfs_server *server,
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
@@ -955,6 +975,12 @@ restart:
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

