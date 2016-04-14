Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:33856 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932091AbcDNMhS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Apr 2016 08:37:18 -0400
Received: by mail-qg0-f53.google.com with SMTP id c6so61699839qga.1
        for <linux-nfs@vger.kernel.org>; Thu, 14 Apr 2016 05:37:18 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 7/8] nfs: get a reference to the credential in ff_layout_alloc_lseg
Date: Thu, 14 Apr 2016 08:37:04 -0400
Message-Id: <1460637425-1580-8-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1460637425-1580-1-git-send-email-jeff.layton@primarydata.com>
References: <1460637425-1580-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're just as likely to have allocation problems here as we would if we
delay looking up the credential like we currently do. Fix the code to
get a rpc_cred reference early, as soon as the mirror is set up.

This allows us to eliminate the mirror early if there is a problem
getting an rpc credential. This also allows us to drop the uid/gid
from the layout_mirror struct as well.

In the event that we find an existing mirror where this one would go, we
swap in the new creds unconditionally, and drop the reference to the old
one.

Note that the old ff_layout_update_mirror_cred function wouldn't set
this pointer unless the DS version was 3, but we don't know what the DS
version is at this point. I'm a little unclear on why it did that as you
still need creds to talk to v4 servers as well. I have the code set
it regardless of the DS version here.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 30 +++++++++++++++-----
 fs/nfs/flexfilelayout/flexfilelayout.h    |  2 --
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 47 ++-----------------------------
 3 files changed, 25 insertions(+), 54 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index ba48fdf960e0..6889df6b7dcc 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -407,8 +407,9 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 		struct nfs4_ff_layout_mirror *mirror;
 		struct nfs4_deviceid devid;
 		struct nfs4_deviceid_node *idnode;
-		u32 ds_count;
-		u32 fh_count;
+		struct auth_cred acred = {0};
+		struct rpc_cred	*cred;
+		u32 ds_count, fh_count, id;
 		int j;
 
 		rc = -EIO;
@@ -484,24 +485,39 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 		fls->mirror_array[i]->fh_versions_cnt = fh_count;
 
 		/* user */
-		rc = decode_name(&stream, &fls->mirror_array[i]->uid);
+		rc = decode_name(&stream, &id);
 		if (rc)
 			goto out_err_free;
 
+		acred.uid = make_kuid(&init_user_ns, id);
+
 		/* group */
-		rc = decode_name(&stream, &fls->mirror_array[i]->gid);
+		rc = decode_name(&stream, &id);
 		if (rc)
 			goto out_err_free;
 
+		acred.gid = make_kgid(&init_user_ns, id);
+
+		/* find the cred for it */
+		cred = rpc_lookup_generic_cred(&acred, 0, gfp_flags);
+		if (IS_ERR(cred)) {
+			rc = PTR_ERR(cred);
+			goto out_err_free;
+		}
+
+		rcu_assign_pointer(fls->mirror_array[i]->cred, cred);
+
 		mirror = ff_layout_add_mirror(lh, fls->mirror_array[i]);
 		if (mirror != fls->mirror_array[i]) {
+			/* swap cred ptrs so free_mirror will clean up old */
+			fls->mirror_array[i]->cred = xchg(&mirror->cred, cred);
 			ff_layout_free_mirror(fls->mirror_array[i]);
 			fls->mirror_array[i] = mirror;
 		}
 
-		dprintk("%s: uid %d gid %d\n", __func__,
-			fls->mirror_array[i]->uid,
-			fls->mirror_array[i]->gid);
+		dprintk("%s: uid %u gid %u\n", __func__,
+			from_kuid(&init_user_ns, acred.uid),
+			from_kgid(&init_user_ns, acred.gid));
 	}
 
 	p = xdr_inline_decode(&stream, 4);
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index dd353bb7dc0a..c29fc853ce74 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -76,8 +76,6 @@ struct nfs4_ff_layout_mirror {
 	u32				fh_versions_cnt;
 	struct nfs_fh			*fh_versions;
 	nfs4_stateid			stateid;
-	u32				uid;
-	u32				gid;
 	struct rpc_cred			*cred;
 	atomic_t			ref;
 	spinlock_t			lock;
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index baee22929174..6ddd8a5c5ae0 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -302,42 +302,6 @@ int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
 	return 0;
 }
 
-/* currently we only support AUTH_NONE and AUTH_SYS */
-static rpc_authflavor_t
-nfs4_ff_layout_choose_authflavor(struct nfs4_ff_layout_mirror *mirror)
-{
-	if (mirror->uid == (u32)-1)
-		return RPC_AUTH_NULL;
-	return RPC_AUTH_UNIX;
-}
-
-/* fetch cred for NFSv3 DS */
-static int ff_layout_update_mirror_cred(struct nfs4_ff_layout_mirror *mirror,
-				      struct nfs4_pnfs_ds *ds)
-{
-	if (ds->ds_clp && !mirror->cred &&
-	    mirror->mirror_ds->ds_versions[0].version == 3) {
-		struct rpc_auth *auth = ds->ds_clp->cl_rpcclient->cl_auth;
-		struct rpc_cred *cred;
-		struct auth_cred acred = {
-			.uid = make_kuid(&init_user_ns, mirror->uid),
-			.gid = make_kgid(&init_user_ns, mirror->gid),
-		};
-
-		/* AUTH_NULL ignores acred */
-		cred = auth->au_ops->lookup_cred(auth, &acred, 0);
-		if (IS_ERR(cred)) {
-			dprintk("%s: lookup_cred failed with %ld\n",
-				__func__, PTR_ERR(cred));
-			return PTR_ERR(cred);
-		} else {
-			if (cmpxchg(&mirror->cred, NULL, cred))
-				put_rpccred(cred);
-		}
-	}
-	return 0;
-}
-
 static struct rpc_cred *
 ff_layout_get_mirror_cred(struct nfs4_ff_layout_mirror *mirror, u32 iomode)
 {
@@ -386,7 +350,6 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 	struct inode *ino = lseg->pls_layout->plh_inode;
 	struct nfs_server *s = NFS_SERVER(ino);
 	unsigned int max_payload;
-	rpc_authflavor_t flavor;
 
 	if (!ff_layout_mirror_valid(lseg, mirror)) {
 		pr_err_ratelimited("NFS: %s: No data server for offset index %d\n",
@@ -402,9 +365,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 	/* matching smp_wmb() in _nfs4_pnfs_v3/4_ds_connect */
 	smp_rmb();
 	if (ds->ds_clp)
-		goto out_update_creds;
-
-	flavor = nfs4_ff_layout_choose_authflavor(mirror);
+		goto out;
 
 	/* FIXME: For now we assume the server sent only one version of NFS
 	 * to use for the DS.
@@ -413,7 +374,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 			     dataserver_retrans,
 			     mirror->mirror_ds->ds_versions[0].version,
 			     mirror->mirror_ds->ds_versions[0].minor_version,
-			     flavor);
+			     RPC_AUTH_UNIX);
 
 	/* connect success, check rsize/wsize limit */
 	if (ds->ds_clp) {
@@ -438,11 +399,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 		} else
 			pnfs_error_mark_layout_for_return(ino, lseg);
 		ds = NULL;
-		goto out;
 	}
-out_update_creds:
-	if (ff_layout_update_mirror_cred(mirror, ds))
-		ds = NULL;
 out:
 	return ds;
 }
-- 
2.5.5

