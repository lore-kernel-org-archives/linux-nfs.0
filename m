Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61008 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756820Ab0HDJQm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Aug 2010 05:16:42 -0400
Message-ID: <4C592FAF.5090700@cn.fujitsu.com>
Date: Wed, 04 Aug 2010 17:15:27 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] Make lock inode before lock nfs4_state_owner
References: <4C592F85.8070308@cn.fujitsu.com>
In-Reply-To: <4C592F85.8070308@cn.fujitsu.com>
Content-Type: text/plain; charset=Shift_JIS
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

 We should lock inode before lock nfs4_state_owner, sometimes, we want scan
nfsi->open_states, and modify once state, so we need lock state->owner.

Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>

---
 fs/nfs/nfs4state.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 34acf59..fe34c41 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -498,8 +498,8 @@ nfs4_get_open_state(struct inode *inode, struct nfs4_state_owner *owner)
 	if (state)
 		goto out;
 	new = nfs4_alloc_open_state();
-	spin_lock(&owner->so_lock);
 	spin_lock(&inode->i_lock);
+	spin_lock(&owner->so_lock);
 	state = __nfs4_find_state_byowner(inode, owner);
 	if (state == NULL && new != NULL) {
 		state = new;
@@ -507,14 +507,14 @@ nfs4_get_open_state(struct inode *inode, struct nfs4_state_owner *owner)
 		atomic_inc(&owner->so_count);
 		list_add(&state->inode_states, &nfsi->open_states);
 		state->inode = igrab(inode);
-		spin_unlock(&inode->i_lock);
 		/* Note: The reclaim code dictates that we add stateless
 		 * and read-only stateids to the end of the list */
 		list_add_tail(&state->open_states, &owner->so_states);
 		spin_unlock(&owner->so_lock);
-	} else {
 		spin_unlock(&inode->i_lock);
+	} else {
 		spin_unlock(&owner->so_lock);
+		spin_unlock(&inode->i_lock);
 		if (new)
 			nfs4_free_open_state(new);
 	}
@@ -527,13 +527,15 @@ void nfs4_put_open_state(struct nfs4_state *state)
 	struct inode *inode = state->inode;
 	struct nfs4_state_owner *owner = state->owner;
 
-	if (!atomic_dec_and_lock(&state->count, &owner->so_lock))
-		return;
 	spin_lock(&inode->i_lock);
-	list_del(&state->inode_states);
+	if (!atomic_dec_and_lock(&state->count, &owner->so_lock)) {
+		spin_unlock(&inode->i_lock);
+		return;
+	}
 	list_del(&state->open_states);
-	spin_unlock(&inode->i_lock);
 	spin_unlock(&owner->so_lock);
+	list_del(&state->inode_states);
+	spin_unlock(&inode->i_lock);
 	iput(inode);
 	nfs4_free_open_state(state);
 	nfs4_put_state_owner(owner);
-- 
1.6.5.2



-- 
Regards
Bian Naimeng

