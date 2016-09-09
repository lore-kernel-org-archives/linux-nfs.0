Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36163 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752196AbcIISEu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Sep 2016 14:04:50 -0400
Received: by mail-oi0-f67.google.com with SMTP id s71so8338326oih.3
        for <linux-nfs@vger.kernel.org>; Fri, 09 Sep 2016 11:04:50 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v3 07/12] NFSv4.1: Deal with server reboots during delegation expiration recovery
Date: Fri,  9 Sep 2016 14:04:08 -0400
Message-Id: <1473444253-12433-8-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1473444253-12433-7-git-send-email-trond.myklebust@primarydata.com>
References: <1473444253-12433-1-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-2-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-3-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-4-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-5-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-6-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-7-git-send-email-trond.myklebust@primarydata.com>
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

