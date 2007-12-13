From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] NFS client fixes against 2.6.24-rc5
Date: Wed, 12 Dec 2007 20:22:31 -0500
Message-ID: <1197508951.8554.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	nfs@lists.sourceforge.net
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56608 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752062AbXLMBWt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Dec 2007 20:22:49 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the repository at

   git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 MAINTAINERS                    |    6 ++++--
 fs/nfs/client.c                |    6 +++---
 fs/nfs/direct.c                |    2 --
 fs/nfs/getroot.c               |   11 +++++++++++
 fs/nfs/super.c                 |    2 +-
 net/sunrpc/xprtrdma/rpc_rdma.c |    9 +--------
 6 files changed, 20 insertions(+), 16 deletions(-)

commit 78f5815368837ae7e3a0d3709c9f95f74e4d8537
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Dec 12 20:16:06 2007 -0500

    MAINTAINERS: update the NFS CLIENT entry
    
    Add in the new NFS mailing list on vger, website, and git tree info, and
    update my email address to reflect the fact that I've been working for
    netapp for the past 2 years.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a10db50a4ae813fcb2f431f2fb039933c109a925
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Dec 12 11:12:15 2007 -0500

    NFS: Fix an Oops in NFS unmount
    
    Ensure that the dummy 'root dentry' is invisible to d_find_alias(). If not,
    then it may be spliced into the tree if a parent directory from the same
    filesystem gets mounted at a later time.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a5576cfa5cd8d8aa874bd4ee500dc8a2e7cbad18
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Dec 12 11:08:33 2007 -0500

    Revert "NFS: Ensure we return zero if applications attempt to write zero bytes"
    
    This reverts commit b9148c6b80d802dbc2a7530b29915a80432e50c7.
    
    On Wed, 12 Dec 2007 10:57:30 -0500, Chuck Lever wrote
    > commit b9148c6b should be reverted.  It was recently forward-ported
    > from some years-old patches, and is clearly not needed now.
    >
    > On Dec 11, 2007, at 5:21 PM, Adrian Bunk wrote:
    >
    >> This code became dead after commit
    >> b9148c6b80d802dbc2a7530b29915a80432e50c7
    >> (which BTW doesn't seem to have changed any behaviour) and can
    >> therefore
    >> be removed.
    >>
    >> Spotted by the Coverity checker.
    >>
    >> Signed-off-by: Adrian Bunk <bunk@kernel.org>
    >>
    >> ---
    >> --- linux-2.6/fs/nfs/direct.c.old     2007-12-02 21:54:53.000000000 +0100
    >> +++ linux-2.6/fs/nfs/direct.c 2007-12-02 21:55:10.000000000 +0100
    >> @@ -897,15 +897,12 @@ ssize_t nfs_file_direct_write(struct kio
    >>       if (!count)
    >>               goto out;       /* return 0 */
    >>
    >>       retval = -EINVAL;
    >>       if ((ssize_t) count < 0)
    >>               goto out;
    >> -     retval = 0;
    >> -     if (!count)
    >> -             goto out;
    >>
    >>       retval = nfs_sync_mapping(mapping);
    >>       if (retval)
    >>               goto out;
    >>
    >>       retval = nfs_direct_write(iocb, iov, nr_segs, pos, count);
    >>
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 50e1092b3a119bb4660bb6bd2e1749dc2d8ac62e
Author: James Lentini <jlentini@netapp.com>
Date:   Mon Dec 10 11:24:48 2007 -0500

    SUNRPC xprtrdma: fix XDR tail buf marshalling for all ops
    
    rpcrdma_convert_iovs is passed an xdr_buf representing either an RPC
    request or an RPC reply. In the case of a request, several
    calculations and tests involving pos are unnecessary. In the case of a
    reply, several calculations and tests involving pos are incorrect (the
    code tests pos against the reply xdr buf's len field, which is always
    0 at the time rpcrdma_convert_iovs is executed). This change removes
    the incorrect/unnecessary calculations and tests involving pos.
    
    This fixes an observed problem when reading certain file sizes over
    NFS/RDMA.
    
    Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
    Signed-off-by: Tom Talpey <talpey@netapp.com>
    Signed-off-by: James Lentini <jlentini@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 5cef338b30c110daf547fb13d99f0c77f2a79fbc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 11 22:01:56 2007 -0500

    NFSv2/v3: Fix a memory leak when using -onolock
    
    Neil Brown said:
    > Hi Trond,
    >
    > We found that a machine which made moderately heavy use of
    > 'automount' was leaking some nfs data structures - particularly the
    > 4K allocated by rpc_alloc_iostats.
    > It turns out that this only happens with filesystems with -onolock
    > set.
    
    > The problem is that if NFS_MOUNT_NONLM is set, nfs_start_lockd doesn't
    > set server->destroy, so when the filesystem is unmounted, the
    > ->client_acl is not shutdown, and so several resources are still
    > held.  Multiple mount/umount cycles will slowly eat away memory
    > several pages at a time.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Acked-by: NeilBrown <neilb@suse.de>

commit 4584f520e1f773082ef44ff4f8969a5d992b16ec
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 11 19:01:45 2007 -0500

    NFS: Fix NFS mountpoint crossing...
    
    The check that was added to nfs_xdev_get_sb() to work around broken
    servers, works fine for NFSv2, but causes mountpoint crossing on NFSv3 to
    always return ESTALE.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 9507b42..94143d7 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2751,8 +2751,10 @@ S:	Maintained
 
 NFS CLIENT
 P:	Trond Myklebust
-M:	trond.myklebust@fys.uio.no
-L:	linux-kernel@vger.kernel.org
+M:	Trond.Myklebust@netapp.com
+L:	linux-nfs@vger.kernel.org
+W:	http://client.linux-nfs.org
+T:	git git://git.linux-nfs.org/pub/linux/nfs-2.6.git
 S:	Maintained
 
 NI5010 NETWORK DRIVER
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 70587f3..a6f6254 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -410,9 +410,6 @@ static int nfs_create_rpc_client(struct nfs_client *clp, int proto,
  */
 static void nfs_destroy_server(struct nfs_server *server)
 {
-	if (!IS_ERR(server->client_acl))
-		rpc_shutdown_client(server->client_acl);
-
 	if (!(server->flags & NFS_MOUNT_NONLM))
 		lockd_down();	/* release rpc.lockd */
 }
@@ -755,6 +752,9 @@ void nfs_free_server(struct nfs_server *server)
 
 	if (server->destroy != NULL)
 		server->destroy(server);
+
+	if (!IS_ERR(server->client_acl))
+		rpc_shutdown_client(server->client_acl);
 	if (!IS_ERR(server->client))
 		rpc_shutdown_client(server->client);
 
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 5e8d82f..3c9d16b 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -894,8 +894,6 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	retval = generic_write_checks(file, &pos, &count, 0);
 	if (retval)
 		goto out;
-	if (!count)
-		goto out;	/* return 0 */
 
 	retval = -EINVAL;
 	if ((ssize_t) count < 0)
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index 0ee4384..e6242cd 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -57,6 +57,17 @@ static int nfs_superblock_set_dummy_root(struct super_block *sb, struct inode *i
 		}
 		/* Circumvent igrab(): we know the inode is not being freed */
 		atomic_inc(&inode->i_count);
+		/*
+		 * Ensure that this dentry is invisible to d_find_alias().
+		 * Otherwise, it may be spliced into the tree by
+		 * d_materialise_unique if a parent directory from the same
+		 * filesystem gets mounted at a later time.
+		 * This again causes shrink_dcache_for_umount_subtree() to
+		 * Oops, since the test for IS_ROOT() will fail.
+		 */
+		spin_lock(&dcache_lock);
+		list_del_init(&sb->s_root->d_alias);
+		spin_unlock(&dcache_lock);
 	}
 	return 0;
 }
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2426e71..ea92920 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1475,7 +1475,7 @@ static int nfs_xdev_get_sb(struct file_system_type *fs_type, int flags,
 		error = PTR_ERR(mntroot);
 		goto error_splat_super;
 	}
-	if (mntroot->d_inode->i_op != &nfs_dir_inode_operations) {
+	if (mntroot->d_inode->i_op != server->nfs_client->rpc_ops->dir_inode_ops) {
 		dput(mntroot);
 		error = -ESTALE;
 		goto error_splat_super;
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 9e11ce7..ee8de7a 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -92,7 +92,6 @@ rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, int pos,
 		seg[n].mr_page = NULL;
 		seg[n].mr_offset = xdrbuf->head[0].iov_base;
 		seg[n].mr_len = xdrbuf->head[0].iov_len;
-		pos += xdrbuf->head[0].iov_len;
 		++n;
 	}
 
@@ -104,7 +103,6 @@ rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, int pos,
 		seg[n].mr_len = min_t(u32,
 			PAGE_SIZE - xdrbuf->page_base, xdrbuf->page_len);
 		len = xdrbuf->page_len - seg[n].mr_len;
-		pos += len;
 		++n;
 		p = 1;
 		while (len > 0) {
@@ -119,20 +117,15 @@ rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, int pos,
 		}
 	}
 
-	if (pos < xdrbuf->len && xdrbuf->tail[0].iov_len) {
+	if (xdrbuf->tail[0].iov_len) {
 		if (n == nsegs)
 			return 0;
 		seg[n].mr_page = NULL;
 		seg[n].mr_offset = xdrbuf->tail[0].iov_base;
 		seg[n].mr_len = xdrbuf->tail[0].iov_len;
-		pos += xdrbuf->tail[0].iov_len;
 		++n;
 	}
 
-	if (pos < xdrbuf->len)
-		dprintk("RPC:       %s: marshaled only %d of %d\n",
-				__func__, pos, xdrbuf->len);
-
 	return n;
 }
 
