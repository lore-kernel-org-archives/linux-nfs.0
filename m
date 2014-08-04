Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52682 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751053AbaHDGZQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Aug 2014 02:25:16 -0400
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 04 Aug 2014 16:24:00 +1000
Subject: [PATCH 1/2] NFS: fix two problems in lookup_revalidate in RCU-walk
Cc: linux-nfs@vger.kernel.org, kbuild test robot <fengguang.wu@intel.com>
Message-ID: <20140804062400.7621.10041.stgit@notabene.brown>
In-Reply-To: <20140804062225.7621.70050.stgit@notabene.brown>
References: <20140804062225.7621.70050.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

1/ rcu_dereference isn't correct: that field isn't
   RCU protected.   It could potentially change at any time
   so ACCESS_ONCE might be justified.

   changes to ->d_parent are protected by ->d_seq.  However
   that isn't always checked after ->d_revalidate is called,
   so it is safest to keep the double-check that ->d_parent
   hasn't changed at the end of these functions.

2/ in nfs4_lookup_revalidate, "->d_parent" was forgotten.
   So 'parent' was not the parent of 'dentry'.
   This fails safe is the context is that dentry->d_inode is
   NULL, and the result of parent->d_inode being NULL is
   that ECHILD is returned, which is always safe.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/dir.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e754d205ea54..0295f78f2976 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1102,7 +1102,7 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	int error;
 
 	if (flags & LOOKUP_RCU) {
-		parent = rcu_dereference(dentry->d_parent);
+		parent = ACCESS_ONCE(dentry->d_parent);
 		dir = ACCESS_ONCE(parent->d_inode);
 		if (!dir)
 			return -ECHILD;
@@ -1184,7 +1184,7 @@ out_set_verifier:
 	nfs_advise_use_readdirplus(dir);
  out_valid_noent:
 	if (flags & LOOKUP_RCU) {
-		if (parent != rcu_dereference(dentry->d_parent))
+		if (parent != ACCESS_ONCE(dentry->d_parent))
 			return -ECHILD;
 	} else
 		dput(parent);
@@ -1585,7 +1585,7 @@ static int nfs4_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 		struct inode *dir;
 
 		if (flags & LOOKUP_RCU) {
-			parent = rcu_dereference(dentry);
+			parent = ACCESS_ONCE(dentry->d_parent);
 			dir = ACCESS_ONCE(parent->d_inode);
 			if (!dir)
 				return -ECHILD;
@@ -1599,7 +1599,7 @@ static int nfs4_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 			ret = -ECHILD;
 		if (!(flags & LOOKUP_RCU))
 			dput(parent);
-		else if (parent != rcu_dereference(dentry))
+		else if (parent != ACCESS_ONCE(dentry->d_parent))
 			return -ECHILD;
 		goto out;
 	}


