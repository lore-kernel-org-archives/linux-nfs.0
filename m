Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43801 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754192AbbFVHxb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jun 2015 03:53:31 -0400
Date: Mon, 22 Jun 2015 17:53:18 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH/RFC] NFSv4 - do not accept an incompatible delegation.
Message-ID: <20150622175318.6e840b23@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi,
 this is my proposed solution to the problem I outlined in
   NFSv4 state management issue - Linux disagrees with Netapp.
 I haven't tested it yet (no direct access to the Netapp), but
 I'll try to get some testing done.  RFC for now.

NeilBrown


When opening a file, nfs _nfs4_do_open() will return any
incompatible delegation, meaning if the delegation held for
that file does not give all the permissions required, it is
returned.
This is because various places assume that the current delegation
provides all necessary access.

However when a delegation is received, it is not validated in the
same way so it is possible to, for example, hold a read-only
delegation while the file is open write-only.
When that delegation is recalled, the NFS client will try to
reclaim the write-only open, and that will fail.

So when considering a new delegation, reject it if it is incompatible
with any open.

Signed-off-by: NeilBrown <neilb@suse.de>
URL: https://bugzilla.suse.com/show_bug.cgi?id=934203

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 029d688..92cecd3 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -377,6 +377,25 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 				old_delegation, clp);
 		if (freeme == NULL)
 			goto out;
+	} else {
+		/* Don't accept an incompatible delegation */
+		int incompatible = 0;
+		struct nfs_inode *nfsi = NFS_I(inode);
+		struct nfs4_state *state;
+
+		spin_lock(&inode->i_lock);
+		list_for_each_entry(state, &nfsi->open_states, inode_states) {
+			if ((state->state & delegation->type) != state->state) {
+				incompatible = 1;
+				break;
+			}
+		}
+		spin_unlock(&inode->i_lock);
+		if (incompatible) {
+			freeme = delegation;
+			delegation = NULL;
+			goto out;
+		}
 	}
 	list_add_tail_rcu(&delegation->super_list, &server->delegations);
 	rcu_assign_pointer(nfsi->delegation, delegation);
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
