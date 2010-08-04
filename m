Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57593 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757428Ab0HDJTu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Aug 2010 05:19:50 -0400
Message-ID: <4C59306A.9090302@cn.fujitsu.com>
Date: Wed, 04 Aug 2010 17:18:34 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] We should clear NFS_DELEGATED_STATE after return delegation
References: <4C592F85.8070308@cn.fujitsu.com>
In-Reply-To: <4C592F85.8070308@cn.fujitsu.com>
Content-Type: text/plain; charset=Shift_JIS
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

 We should clear NFS_DELEGATED_STATE bit for inode->open_states after return delegation.

Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>

---
 fs/nfs/nfs4proc.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 70015dd..76cdef4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -933,16 +933,29 @@ no_delegation:
 
 static void nfs4_return_incompatible_delegation(struct inode *inode, fmode_t fmode)
 {
+	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_delegation *delegation;
+	struct nfs4_state *state;
 
 	rcu_read_lock();
-	delegation = rcu_dereference(NFS_I(inode)->delegation);
+	delegation = rcu_dereference(nfsi->delegation);
 	if (delegation == NULL || (delegation->type & fmode) == fmode) {
 		rcu_read_unlock();
 		return;
 	}
 	rcu_read_unlock();
 	nfs_inode_return_delegation(inode);
+
+	spin_lock(&inode->i_lock);
+	list_for_each_entry(state, &nfsi->open_states, inode_states) {
+		if (state->owner == NULL)
+			continue;
+
+		spin_lock(&state->owner->so_lock);
+		clear_bit(NFS_DELEGATED_STATE, &state->flags);
+		spin_unlock(&state->owner->so_lock);
+	}
+	spin_unlock(&inode->i_lock);
 }
 
 static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
-- 
1.6.5.2



