Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53464 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752711AbaAXPwh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Jan 2014 10:52:37 -0500
Date: Fri, 24 Jan 2014 10:52:13 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond.Myklebust@primarydata.com
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 7/7] nfs: page cache invalidation for dio
Message-ID: <20140124105213.2c40a783@tlielax.poochiereds.net>
In-Reply-To: <20140122070409.503db5c2@tlielax.poochiereds.net>
References: <20131114165027.355613182@bombadil.infradead.org>
 <20131114165042.205194841@bombadil.infradead.org>
 <20131114133551.5d08b5cd@tlielax.poochiereds.net>
 <20131115142847.GA1107@infradead.org>
 <20131115095241.2c5e1cfb@tlielax.poochiereds.net>
 <20131115150204.GA8105@infradead.org>
 <20131115103324.6a3cf978@tlielax.poochiereds.net>
 <20140121142159.210ca0b8@tlielax.poochiereds.net>
 <20140122082414.GA12530@infradead.org>
 <20140122070409.503db5c2@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 22 Jan 2014 07:04:09 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> On Wed, 22 Jan 2014 00:24:14 -0800
> Christoph Hellwig <hch@infradead.org> wrote:
> 
> > On Tue, Jan 21, 2014 at 02:21:59PM -0500, Jeff Layton wrote:
> > > In any case, this helps but it's a little odd. With this patch, you add
> > > an invalidate_inode_pages2 call prior to doing the DIO. But, you've
> > > also left in the call to nfs_zap_mapping in the completion codepath.
> > > 
> > > So now, we shoot down the mapping prior to doing a DIO write, and then
> > > mark the mapping for invalidation again when the write completes. Was
> > > that intentional?
> > > 
> > > It seems a little excessive and might hurt performance in some cases.
> > > OTOH, if you mix buffered and DIO you're asking for trouble anyway and
> > > this approach seems to give better cache coherency.
> > 
> > Thile follows the model implemented and documented in
> > generic_file_direct_write().
> > 
> 
> Ok, thanks. That makes sense, and the problem described in those
> comments is almost exactly the one I've seen in practice.
> 
> I'm still not 100% thrilled with the way that the NFS_INO_INVALID_DATA
> flag is handled, but that really has nothing to do with this patchset.
> 
> You can add my Tested-by to the set if you like...
> 

(re-sending with Trond's address fixed)

I may have spoken too soon...

This patchset didn't fix the problem once I cranked up the concurrency
from 100 child tasks to 1000. I think that HCH's patchset makes sense
and helps narrow the race window some, but the way that
nfs_revalidate_mapping/nfs_invalidate_mapping work is just racy.

The following patch does seem to fix it however. It's a combination of
a test patch that Trond gave me a while back and another change to
serialize the nfs_invalidate_mapping ops.

I think it's a reasonable approach to deal with the problem, but we
likely have some other areas that will need similar treatment since
they also check NFS_INO_INVALID_DATA: 

    nfs_write_pageuptodate
    nfs_readdir_search_for_cookie
    nfs_update_inode

Trond, thoughts? It's not quite ready for merge, but I'd like to get an
opinion on the basic approach, or whether you have an idea of how
better handle the races here:

------------------8<--------------------

NFS: fix the handling of NFS_INO_INVALID_DATA flag in nfs_revalidate_mapping

There is a possible race in how the nfs_invalidate_mapping is handled.
Currently, we go and invalidate the pages in the file and then clear
NFS_INO_INVALID_DATA.

The problem is that it's possible for a stale page to creep into the
mapping after the page was invalidated (i.e., via readahead). If another
writer comes along and sets the flag after that happens but before
invalidate_inode_pages2 returns then we could clear the flag
without the cache having been properly invalidated.

So, we must clear the flag first and then invalidate the pages.  This
however, opens another race:

It's possible to have two concurrent read() calls that end up in
nfs_revalidate_mapping at the same time. The first one clears the
NFS_INO_INVALID_DATA flag and then goes to call nfs_invalidate_mapping.

Just before calling that though, the other task races in, checks the
flag and finds it cleared. At that point, it sees that the mapping is
good and gets the lock on the page, allowing the read() to be satisfied
from the cache even though the data is no longer valid.

This effect is easily manifested by running diotest3 from the LTP test
suite on NFS. That program does a series of DIO writes and buffered
reads. The operations are serialized and page-aligned but the existing
code fails the test since it occasionally allows a read to come out of
the cache instead of being done on the wire when it should. While mixing
direct and buffered I/O isn't recommended, I believe it's possible to
hit this in other ways that just use buffered I/O, even though that
makes it harder to reproduce.

The problem is that the checking/clearing of that flag and the
invalidation of the mapping need to be as a unit. Fix this by
serializing concurrent invalidations with a bitlock.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/inode.c         | 32 +++++++++++++++++++++++++++-----
 include/linux/nfs_fs.h |  1 +
 2 files changed, 28 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 00ad1c2..6fa07e1 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -977,11 +977,11 @@ static int nfs_invalidate_mapping(struct inode *inode, struct address_space *map
 		if (ret < 0)
 			return ret;
 	}
-	spin_lock(&inode->i_lock);
-	nfsi->cache_validity &= ~NFS_INO_INVALID_DATA;
-	if (S_ISDIR(inode->i_mode))
+	if (S_ISDIR(inode->i_mode)) {
+		spin_lock(&inode->i_lock);
 		memset(nfsi->cookieverf, 0, sizeof(nfsi->cookieverf));
-	spin_unlock(&inode->i_lock);
+		spin_unlock(&inode->i_lock);
+	}
 	nfs_inc_stats(inode, NFSIOS_DATAINVALIDATE);
 	nfs_fscache_wait_on_invalidate(inode);
 
@@ -1007,6 +1007,7 @@ static bool nfs_mapping_need_revalidate_inode(struct inode *inode)
 int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
+	unsigned long *bitlock = &NFS_I(inode)->flags;
 	int ret = 0;
 
 	/* swapfiles are not supposed to be shared. */
@@ -1018,12 +1019,33 @@ int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
 		if (ret < 0)
 			goto out;
 	}
+
+	/*
+	 * We must clear NFS_INO_INVALID_DATA first to ensure that
+	 * invalidations that come in while we're shooting down the mappings
+	 * are respected. But, that leaves a race window where one revalidator
+	 * can clear the flag, and then another checks it before the mapping
+	 * gets invalidated. Fix that by serializing access to this part of
+	 * the function.
+	 */
+	ret = wait_on_bit_lock(bitlock, NFS_INO_INVALIDATING,
+				nfs_wait_bit_killable, TASK_KILLABLE);
+	if (ret)
+		goto out;
+
+	spin_lock(&inode->i_lock);
 	if (nfsi->cache_validity & NFS_INO_INVALID_DATA) {
+		nfsi->cache_validity &= ~NFS_INO_INVALID_DATA;
+		spin_unlock(&inode->i_lock);
 		trace_nfs_invalidate_mapping_enter(inode);
 		ret = nfs_invalidate_mapping(inode, mapping);
 		trace_nfs_invalidate_mapping_exit(inode, ret);
-	}
+	} else
+		spin_unlock(&inode->i_lock);
 
+	clear_bit_unlock(NFS_INO_INVALIDATING, bitlock);
+	smp_mb__after_clear_bit();
+	wake_up_bit(bitlock, NFS_INO_INVALIDATING);
 out:
 	return ret;
 }
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 4899737..18fb16f 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -215,6 +215,7 @@ struct nfs_inode {
 #define NFS_INO_ADVISE_RDPLUS	(0)		/* advise readdirplus */
 #define NFS_INO_STALE		(1)		/* possible stale inode */
 #define NFS_INO_ACL_LRU_SET	(2)		/* Inode is on the LRU list */
+#define NFS_INO_INVALIDATING	(3)		/* inode is being invalidated */
 #define NFS_INO_FLUSHING	(4)		/* inode is flushing out data */
 #define NFS_INO_FSCACHE		(5)		/* inode can be cached by FS-Cache */
 #define NFS_INO_FSCACHE_LOCK	(6)		/* FS-Cache cookie management lock */
-- 
1.8.5.3

