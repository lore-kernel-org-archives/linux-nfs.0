Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f48.google.com ([74.125.83.48]:52706 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753657Ab3AUOzH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 09:55:07 -0500
Received: by mail-ee0-f48.google.com with SMTP id t10so2856830eei.7
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jan 2013 06:55:06 -0800 (PST)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 9/9] SQUASHME: pnfsd: no use for fi_layout_states list anymore
Date: Mon, 21 Jan 2013 16:55:03 +0200
Message-Id: <1358780103-6229-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <50FD5646.4020206@tonian.com>
References: <50FD5646.4020206@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 10 ----------
 fs/nfsd/nfs4state.c |  1 -
 fs/nfsd/pnfsd.h     |  1 -
 fs/nfsd/state.h     |  1 -
 4 files changed, 13 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 3375554..4320914 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -157,10 +157,6 @@ void pnfs_clear_device_notify(struct nfs4_client *clp)
 		return new;
 	kref_init(&new->ls_ref);
 	nfsd4_init_stid(&new->ls_stid, clp, NFS4_LAYOUT_STID);
-	INIT_LIST_HEAD(&new->ls_perfile);
-	spin_lock(&layout_lock);
-	list_add(&new->ls_perfile, &fp->fi_layout_states);
-	spin_unlock(&layout_lock);
 	new->ls_roc = false;
 	return new;
 }
@@ -178,11 +174,6 @@ void pnfs_clear_device_notify(struct nfs4_client *clp)
 			container_of(kref, struct nfs4_layout_state, ls_ref);
 
 	nfsd4_unhash_stid(&ls->ls_stid);
-	if (!list_empty(&ls->ls_perfile)) {
-		spin_lock(&layout_lock);
-		list_del(&ls->ls_perfile);
-		spin_unlock(&layout_lock);
-	}
 	kfree(ls);
 }
 
@@ -1310,7 +1301,6 @@ void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp)
 			continue;
 
 		/* Return the layout */
-		list_del_init(&lo->lo_state->ls_perfile);	/* just to be on the safe side */
 		dequeue_layout(lo);
 		list_add_tail(&lo->lo_perfile, &lo_destroy_list);
 	}
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0553220..1682413 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2370,7 +2370,6 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino,
 	memset(fp->fi_access, 0, sizeof(fp->fi_access));
 #if defined(CONFIG_PNFSD)
 	INIT_LIST_HEAD(&fp->fi_layouts);
-	INIT_LIST_HEAD(&fp->fi_layout_states);
 	fp->fi_fsid.major = current_fh->fh_export->ex_fsid;
 	fp->fi_fsid.minor = 0;
 	fp->fi_fhlen = current_fh->fh_handle.fh_size;
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 35859ff..fe35466 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -44,7 +44,6 @@
 struct nfs4_layout_state {
 	struct nfs4_stid	ls_stid; /* must be first field */
 	struct kref		ls_ref;
-	struct list_head	ls_perfile;
 	bool			ls_roc;
 };
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 08a31a7..4ca6f2d 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -399,7 +399,6 @@ struct nfs4_file {
 	bool			fi_had_conflict;
 #if defined(CONFIG_PNFSD)
 	struct list_head	fi_layouts;
-	struct list_head	fi_layout_states;
 	/* used by layoutget / layoutrecall */
 	struct nfs4_fsid	fi_fsid;
 	u32			fi_fhlen;
-- 
1.7.11.7

