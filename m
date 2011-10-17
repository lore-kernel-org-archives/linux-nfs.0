Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f42.google.com ([209.85.210.42]:35346 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526Ab1JQB5N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 Oct 2011 21:57:13 -0400
Received: by pzk36 with SMTP id 36so4228000pzk.1
        for <linux-nfs@vger.kernel.org>; Sun, 16 Oct 2011 18:57:13 -0700 (PDT)
Message-ID: <4E9B8B75.4040209@tonian.com>
Date: Sun, 16 Oct 2011 18:57:09 -0700
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Silence compiler warning
References: <1318810012-15140-1-git-send-email-rees@umich.edu>
In-Reply-To: <1318810012-15140-1-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-10-16 17:06, Jim Rees wrote:
> fs/nfs/callback_proc.c: In function ‘do_callback_layoutrecall’:
> fs/nfs/callback_proc.c:115:26: warning: ‘lo’ may be used uninitialized in this function
> 
> No functional change. If no layout is found, we'll return before  using
> "lo".
> 
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  fs/nfs/callback_proc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 43926ad..93633f1 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -112,7 +112,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
>  				  struct cb_layoutrecallargs *args)
>  {
>  	struct nfs_server *server;
> -	struct pnfs_layout_hdr *lo;
> +	struct pnfs_layout_hdr *lo = NULL;
>  	struct inode *ino;
>  	bool found = false;
>  	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;

Hmm, the warning seems bogus since we use lo only iff found==true
and it is set iff found==true
I wonder why I don't see that warning.
What compiler/version are you using?
At any rate, this made me think of a cleaner way to implement this:

git diff --stat -p -M
 fs/nfs/callback_proc.c |   56 ++++++++++++++++++++++++++++++++---------------
 1 files changed, 38 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 43926ad..e8d83a7 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -108,42 +108,62 @@ int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation, const nf

 #if defined(CONFIG_NFS_V4_1)

-static u32 initiate_file_draining(struct nfs_client *clp,
-				  struct cb_layoutrecallargs *args)
+/*
+ * Lookup a layout by filehandle.
+ *
+ * Note: gets a refcount on the layout hdr and on its respective inode.
+ * Caller must put the layout hdr and the inode.
+ *
+ * TODO: keep track of all layouts (and delegations) in a hash table
+ * hashed by filehandle.
+ */
+static struct pnfs_layout_hdr * get_layout_by_fh_locked(struct nfs_client *clp, struct nfs_fh *fh)
 {
 	struct nfs_server *server;
-	struct pnfs_layout_hdr *lo;
 	struct inode *ino;
-	bool found = false;
-	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;
-	LIST_HEAD(free_me_list);
+	struct pnfs_layout_hdr *lo;

-	spin_lock(&clp->cl_lock);
-	rcu_read_lock();
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
 		list_for_each_entry(lo, &server->layouts, plh_layouts) {
-			if (nfs_compare_fh(&args->cbl_fh,
-					   &NFS_I(lo->plh_inode)->fh))
+			if (nfs_compare_fh(fh, &NFS_I(lo->plh_inode)->fh))
 				continue;
 			ino = igrab(lo->plh_inode);
 			if (!ino)
 				continue;
-			found = true;
-			/* Without this, layout can be freed as soon
-			 * as we release cl_lock.
-			 */
 			get_layout_hdr(lo);
-			break;
+			return lo;
 		}
-		if (found)
-			break;
 	}
+
+	return NULL;
+}
+
+static struct pnfs_layout_hdr * get_layout_by_fh(struct nfs_client *clp, struct nfs_fh *fh)
+{
+	struct pnfs_layout_hdr *lo;
+
+	spin_lock(&clp->cl_lock);
+	rcu_read_lock();
+	lo = get_layout_by_fh_locked(clp, fh);
 	rcu_read_unlock();
 	spin_unlock(&clp->cl_lock);

-	if (!found)
+	return lo;
+}
+
+static u32 initiate_file_draining(struct nfs_client *clp,
+				  struct cb_layoutrecallargs *args)
+{
+	struct inode *ino;
+	struct pnfs_layout_hdr *lo;
+	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;
+	LIST_HEAD(free_me_list);
+
+	lo = get_layout_by_fh(clp, &args->cbl_fh);
+	if (!lo)
 		return NFS4ERR_NOMATCHING_LAYOUT;

+	ino = lo->plh_inode;
 	spin_lock(&ino->i_lock);
 	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
 	    mark_matching_lsegs_invalid(lo, &free_me_list,
