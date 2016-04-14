Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:35546 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932125AbcDNMhT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Apr 2016 08:37:19 -0400
Received: by mail-qg0-f51.google.com with SMTP id f105so61700991qge.2
        for <linux-nfs@vger.kernel.org>; Thu, 14 Apr 2016 05:37:18 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 8/8] nfs: have flexfiles mirror keep creds for both ro and rw layouts
Date: Thu, 14 Apr 2016 08:37:05 -0400
Message-Id: <1460637425-1580-9-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1460637425-1580-1-git-send-email-jeff.layton@primarydata.com>
References: <1460637425-1580-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A mirror can be shared between multiple layouts, even with different
iomodes. That makes stats gathering simpler, but it causes a problem
when we get different creds in READ vs. RW layouts.

The current code drops the newer credentials onto the floor when this
occurs. That's problematic when you fetch a READ layout first, and then
a RW. If the READ layout doesn't have the correct creds to do a write,
then writes will fail.

We could just overwrite the READ credentials with the RW ones, but that
would break the ability for the server to fence the layout for reads if
things go awry. We need to be able to revert to the earlier READ creds
if the RW layout is returned afterward.

The simplest fix is to just keep two sets of creds per mirror. One for
READ layouts and one for RW, and then use the appropriate set depending
on the iomode of the layout segment.

Also fix up some RCU nits that sparse found.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 30 +++++++++++++++++++++++-------
 fs/nfs/flexfilelayout/flexfilelayout.h    |  3 ++-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  7 +++++--
 3 files changed, 30 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 6889df6b7dcc..aca15716ad1b 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -211,10 +211,16 @@ static struct nfs4_ff_layout_mirror *ff_layout_alloc_mirror(gfp_t gfp_flags)
 
 static void ff_layout_free_mirror(struct nfs4_ff_layout_mirror *mirror)
 {
+	struct rpc_cred	*cred;
+
 	ff_layout_remove_mirror(mirror);
 	kfree(mirror->fh_versions);
-	if (mirror->cred)
-		put_rpccred(mirror->cred);
+	cred = rcu_dereference(mirror->ro_cred);
+	if (cred)
+		put_rpccred(cred);
+	cred = rcu_dereference(mirror->rw_cred);
+	if (cred)
+		put_rpccred(cred);
 	nfs4_ff_layout_put_deviceid(mirror->mirror_ds);
 	kfree(mirror);
 }
@@ -408,7 +414,7 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 		struct nfs4_deviceid devid;
 		struct nfs4_deviceid_node *idnode;
 		struct auth_cred acred = {0};
-		struct rpc_cred	*cred;
+		struct rpc_cred	__rcu *cred;
 		u32 ds_count, fh_count, id;
 		int j;
 
@@ -499,23 +505,33 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 		acred.gid = make_kgid(&init_user_ns, id);
 
 		/* find the cred for it */
-		cred = rpc_lookup_generic_cred(&acred, 0, gfp_flags);
+		rcu_assign_pointer(cred, rpc_lookup_generic_cred(&acred, 0, gfp_flags));
 		if (IS_ERR(cred)) {
 			rc = PTR_ERR(cred);
 			goto out_err_free;
 		}
 
-		rcu_assign_pointer(fls->mirror_array[i]->cred, cred);
+		if (lgr->range.iomode == IOMODE_READ)
+			rcu_assign_pointer(fls->mirror_array[i]->ro_cred, cred);
+		else
+			rcu_assign_pointer(fls->mirror_array[i]->rw_cred, cred);
 
 		mirror = ff_layout_add_mirror(lh, fls->mirror_array[i]);
 		if (mirror != fls->mirror_array[i]) {
 			/* swap cred ptrs so free_mirror will clean up old */
-			fls->mirror_array[i]->cred = xchg(&mirror->cred, cred);
+			if (lgr->range.iomode == IOMODE_READ) {
+				cred = xchg(&mirror->ro_cred, cred);
+				rcu_assign_pointer(fls->mirror_array[i]->ro_cred, cred);
+			} else {
+				cred = xchg(&mirror->rw_cred, cred);
+				rcu_assign_pointer(fls->mirror_array[i]->rw_cred, cred);
+			}
 			ff_layout_free_mirror(fls->mirror_array[i]);
 			fls->mirror_array[i] = mirror;
 		}
 
-		dprintk("%s: uid %u gid %u\n", __func__,
+		dprintk("%s: iomode %s uid %u gid %u\n", __func__,
+			lgr->range.iomode == IOMODE_READ ? "READ" : "RW",
 			from_kuid(&init_user_ns, acred.uid),
 			from_kgid(&init_user_ns, acred.gid));
 	}
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index c29fc853ce74..1318c77aeb35 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -76,7 +76,8 @@ struct nfs4_ff_layout_mirror {
 	u32				fh_versions_cnt;
 	struct nfs_fh			*fh_versions;
 	nfs4_stateid			stateid;
-	struct rpc_cred			*cred;
+	struct rpc_cred	__rcu		*ro_cred;
+	struct rpc_cred	__rcu		*rw_cred;
 	atomic_t			ref;
 	spinlock_t			lock;
 	struct nfs4_ff_layoutstat	read_stat;
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 6ddd8a5c5ae0..56296f3df19c 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -305,9 +305,12 @@ int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
 static struct rpc_cred *
 ff_layout_get_mirror_cred(struct nfs4_ff_layout_mirror *mirror, u32 iomode)
 {
-	struct rpc_cred *cred, **pcred;
+	struct rpc_cred *cred, __rcu **pcred;
 
-	pcred = &mirror->cred;
+	if (iomode == IOMODE_READ)
+		pcred = &mirror->ro_cred;
+	else
+		pcred = &mirror->rw_cred;
 
 	rcu_read_lock();
 	do {
-- 
2.5.5

