Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57963 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751493Ab3JAOmu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Oct 2013 10:42:50 -0400
Date: Tue, 1 Oct 2013 10:42:50 -0400
To: stable@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Marc Meledandri <m.meledandri@gmail.com>
Subject: [PATCH] nfsd4: fix leak of inode reference on delegation failure
Message-ID: <20131001144250.GJ26382@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

commit bf7bd3e98be5c74813bee6ad496139fb0a011b3b upstream, for >= 3.10.

This fixes a regression from 68a3396178e6688ad7367202cdf0af8ed03c8727
"nfsd4: shut down more of delegation earlier".

After that commit, nfs4_set_delegation() failures result in
nfs4_put_delegation being called, but nfs4_put_delegation doesn't free
the nfs4_file that has already been set by alloc_init_deleg().

This can result in an oops on later unmounting the exported filesystem.

Note also delaying the fi_had_conflict check we're able to return a
better error (hence give 4.1 clients a better idea why the delegation
failed; though note CONFLICT isn't an exact match here, as that's
supposed to indicate a current conflict, but all we know here is that
there was one recently).

Reported-by: Toralf Förster <toralf.foerster@gmx.de>
Tested-by: Toralf Förster <toralf.foerster@gmx.de>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   31 ++++++++++++++++++++-----------
 1 file changed, 20 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index eb9cf81..0874998 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -368,11 +368,8 @@ static struct nfs4_delegation *
 alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct svc_fh *current_fh)
 {
 	struct nfs4_delegation *dp;
-	struct nfs4_file *fp = stp->st_file;
 
 	dprintk("NFSD alloc_init_deleg\n");
-	if (fp->fi_had_conflict)
-		return NULL;
 	if (num_delegations > max_delegations)
 		return NULL;
 	dp = delegstateid(nfs4_alloc_stid(clp, deleg_slab));
@@ -389,8 +386,7 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	INIT_LIST_HEAD(&dp->dl_perfile);
 	INIT_LIST_HEAD(&dp->dl_perclnt);
 	INIT_LIST_HEAD(&dp->dl_recall_lru);
-	get_nfs4_file(fp);
-	dp->dl_file = fp;
+	dp->dl_file = NULL;
 	dp->dl_type = NFS4_OPEN_DELEGATE_READ;
 	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
 	dp->dl_time = 0;
@@ -3044,22 +3040,35 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 	return 0;
 }
 
-static int nfs4_set_delegation(struct nfs4_delegation *dp)
+static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
 {
-	struct nfs4_file *fp = dp->dl_file;
+	int status;
 
-	if (!fp->fi_lease)
-		return nfs4_setlease(dp);
+	if (fp->fi_had_conflict)
+		return -EAGAIN;
+	get_nfs4_file(fp);
+	dp->dl_file = fp;
+	if (!fp->fi_lease) {
+		status = nfs4_setlease(dp);
+		if (status)
+			goto out_free;
+		return 0;
+	}
 	spin_lock(&recall_lock);
 	if (fp->fi_had_conflict) {
 		spin_unlock(&recall_lock);
-		return -EAGAIN;
+		status = -EAGAIN;
+		goto out_free;
 	}
 	atomic_inc(&fp->fi_delegees);
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
 	spin_unlock(&recall_lock);
 	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 	return 0;
+out_free:
+	put_nfs4_file(fp);
+	dp->dl_file = fp;
+	return status;
 }
 
 static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
@@ -3134,7 +3143,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 	dp = alloc_init_deleg(oo->oo_owner.so_client, stp, fh);
 	if (dp == NULL)
 		goto out_no_deleg;
-	status = nfs4_set_delegation(dp);
+	status = nfs4_set_delegation(dp, stp->st_file);
 	if (status)
 		goto out_free;
 
-- 
1.7.9.5

