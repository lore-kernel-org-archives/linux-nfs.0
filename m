Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35643 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965884AbcIVRjn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 13:39:43 -0400
Received: by mail-it0-f66.google.com with SMTP id e20so5326145itc.2
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 10:39:43 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v7 10/31] NFSv4.1: Deal with server reboots during delegation expiration recovery
Date: Thu, 22 Sep 2016 13:39:00 -0400
Message-Id: <1474565961-21303-11-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474565961-21303-10-git-send-email-trond.myklebust@primarydata.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-2-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-3-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-4-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-5-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-6-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-7-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-8-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-9-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-10-git-send-email-trond.myklebust@primarydata.com>
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
index dfb300901f7e..0ffead281555 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -884,6 +884,13 @@ restart:
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
@@ -892,6 +899,19 @@ static void nfs_mark_test_expired_delegation(struct nfs_server *server,
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
@@ -964,6 +984,12 @@ restart:
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

