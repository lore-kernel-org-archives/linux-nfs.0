Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19769 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754321AbaA1Srx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jan 2014 13:47:53 -0500
Date: Tue, 28 Jan 2014 13:47:46 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linuxnfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3] NFS: Fix races in nfs_revalidate_mapping
Message-ID: <20140128134746.0121e707@tlielax.poochiereds.net>
In-Reply-To: <ADCA6406-8E6D-4B94-8420-E4A4C49DB5C1@primarydata.com>
References: <1390923699-11011-1-git-send-email-trond.myklebust@primarydata.com>
	<1390924222-12869-1-git-send-email-trond.myklebust@primarydata.com>
	<20140128110531.67516646@tlielax.poochiereds.net>
	<ADCA6406-8E6D-4B94-8420-E4A4C49DB5C1@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 28 Jan 2014 12:24:34 -0500
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> 
> On Jan 28, 2014, at 11:05, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > On Tue, 28 Jan 2014 10:50:22 -0500
> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> > 
> >> Commit d529ef83c355f97027ff85298a9709fe06216a66 (NFS: fix the handling
> >> of NFS_INO_INVALID_DATA flag in nfs_revalidate_mapping) introduces
> >> a potential race, since it doesn't test the value of nfsi->cache_validity
> >> and set the bitlock in nfsi->flags atomically.
> >> 
> >> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> >> Cc: Jeff Layton <jlayton@redhat.com>
> >> ---
> >> fs/nfs/inode.c | 28 ++++++++++++++--------------
> >> 1 file changed, 14 insertions(+), 14 deletions(-)
> >> 
> >> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> >> index 0a972ee9ccc1..e5070aa5f175 100644
> >> --- a/fs/nfs/inode.c
> >> +++ b/fs/nfs/inode.c
> >> @@ -1038,24 +1038,24 @@ int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
> >> 				  nfs_wait_bit_killable, TASK_KILLABLE);
> >> 		if (ret)
> >> 			goto out;
> >> -		if (!(nfsi->cache_validity & NFS_INO_INVALID_DATA))
> >> -			goto out;
> >> -		if (!test_and_set_bit_lock(NFS_INO_INVALIDATING, bitlock))
> >> +		spin_lock(&inode->i_lock);
> >> +		if (test_bit(NFS_INO_INVALIDATING, bitlock)) {
> >> +			spin_unlock(&inode->i_lock);
> >> +			continue;
> >> +		}
> >> +		if (nfsi->cache_validity & NFS_INO_INVALID_DATA)
> >> 			break;
> >> -	}
> >> -
> >> -	spin_lock(&inode->i_lock);
> >> -	if (nfsi->cache_validity & NFS_INO_INVALID_DATA) {
> >> -		nfsi->cache_validity &= ~NFS_INO_INVALID_DATA;
> >> -		spin_unlock(&inode->i_lock);
> >> -		trace_nfs_invalidate_mapping_enter(inode);
> >> -		ret = nfs_invalidate_mapping(inode, mapping);
> >> -		trace_nfs_invalidate_mapping_exit(inode, ret);
> >> -	} else {
> >> -		/* something raced in and cleared the flag */
> >> 		spin_unlock(&inode->i_lock);
> >> +		goto out;
> >> 	}
> >> 
> >> +	set_bit(NFS_INO_INVALIDATING, bitlock);
> > 
> > Do we need a memory barrier here to ensure the ordering or does the
> > set_bit() have one implied? Note that nfs_readdir_search_for_cookie and
> > nfs_write_pageuptodate don't hold the i_lock when checking these values.
> 
> There seems little point in putting a barrier here. If we need stronger semantics, then we can and should use the spin lock. That said, neither nfs_readdir_search_for_cookie nor nfs_write_pageuptodate is required by close-to-open to have such semantics: the strong checks happen at open().
> 

Hmm...I don't know...

The concern I'd have is that if the clearing of NFS_INO_INVALID_DATA
gets reordered before the set of NFS_INO_INVALIDATING, then we could
end up with another task (e.g. in nfs_write_pageuptodate) seeing them
both as clear when the pages really are no longer valid.

Maybe something like this?

-------------------------8<----------------------------

[PATCH] nfs: add memory barriers around NFS_INO_INVALID_DATA and NFS_INO_INVALIDATING

If the setting of NFS_INO_INVALIDATING gets reordered to before the
clearing of NFS_INO_INVALID_DATA, then another task may hit a race
window where both appear to be clear, even though the inode's pages are
still in need of invalidation. Fix this by adding the appropriate memory
barriers.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/dir.c   | 14 +++++++++++---
 fs/nfs/inode.c |  1 +
 fs/nfs/write.c |  1 +
 3 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index b39a046..be38b57 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -274,6 +274,15 @@ out_eof:
 	return -EBADCOOKIE;
 }
 
+static bool
+nfs_readdir_inode_mapping_valid(struct nfs_inode *nfsi)
+{
+	if (nfsi->cache_validity & (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA))
+		return false;
+	smp_rmb();
+	return !test_bit(NFS_INO_INVALIDATING, &nfsi->flags);
+}
+
 static
 int nfs_readdir_search_for_cookie(struct nfs_cache_array *array, nfs_readdir_descriptor_t *desc)
 {
@@ -287,9 +296,8 @@ int nfs_readdir_search_for_cookie(struct nfs_cache_array *array, nfs_readdir_des
 			struct nfs_open_dir_context *ctx = desc->file->private_data;
 
 			new_pos = desc->current_index + i;
-			if (ctx->attr_gencount != nfsi->attr_gencount
-			    || (nfsi->cache_validity & (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA))
-			    || test_bit(NFS_INO_INVALIDATING, &nfsi->flags)) {
+			if (ctx->attr_gencount != nfsi->attr_gencount ||
+			    !nfs_readdir_inode_mapping_valid(nfsi)) {
 				ctx->duped = 0;
 				ctx->attr_gencount = nfsi->attr_gencount;
 			} else if (new_pos < desc->ctx->pos) {
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e5070aa..02e1851 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1050,6 +1050,7 @@ int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
 	}
 
 	set_bit(NFS_INO_INVALIDATING, bitlock);
+	smp_wmb();
 	nfsi->cache_validity &= ~NFS_INO_INVALID_DATA;
 	spin_unlock(&inode->i_lock);
 	trace_nfs_invalidate_mapping_enter(inode);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 5511a42..9a3b6a4 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -915,6 +915,7 @@ static bool nfs_write_pageuptodate(struct page *page, struct inode *inode)
 		goto out;
 	if (nfsi->cache_validity & (NFS_INO_INVALID_DATA|NFS_INO_REVAL_PAGECACHE))
 		return false;
+	smp_rmb();
 	if (test_bit(NFS_INO_INVALIDATING, &nfsi->flags))
 		return false;
 out:
-- 
1.8.5.3




