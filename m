From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] Please pull NFS client fixes for 2.6.25
Date: Fri, 07 Mar 2008 14:43:58 -0500
Message-ID: <1204919038.16746.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37070 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755855AbYCGToD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Mar 2008 14:44:03 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "hotfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git hotfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/dir.c                    |    2 ++
 fs/nfs/inode.c                  |    6 ++++--
 fs/nfs/write.c                  |    2 +-
 include/linux/nfs_fs.h          |    1 +
 net/sunrpc/xprtrdma/transport.c |    6 +++++-
 5 files changed, 13 insertions(+), 4 deletions(-)

commit 4e99a1ff3410c627a428d5ddb6cd2e7bc908a486
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Mar 6 12:34:59 2008 -0500

    NFS: Fix dentry revalidation for NFSv4 referrals and mountpoint crossings
    
    As long as the directory contents haven't changed, we should just let the
    path walk proceed to cross the mountpoint. Apart from being an optimisation
    in the case of 'nohide' mountpoint traversals, it also fixes an issue with
    referrals: referral inodes don't have valid filehandles, so calling
    nfs_revalidate_inode() on them is a bug.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c37dcd334c0b0a46a90cfa13b9f69e2aaa89bc09
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Mar 6 12:34:50 2008 -0500

    NFS: Fix the fsid revalidation in nfs_update_inode()
    
    When we detect that we've crossed a mountpoint on the remote server, we
    must take care not to use that inode to revalidate the fsid on our
    current superblock. To do so, we label the inode as a remote mountpoint,
    and check for that in nfs_update_inode().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ee1a2c564f67407947e89f1dac75ac0af0ba88c7
Author: Tom Talpey <tmt@netapp.com>
Date:   Wed Feb 27 15:04:26 2008 -0500

    SUNRPC: Fix a nfs4 over rdma transport oops
    
    Prevent an RPC oops when freeing a dynamically allocated RDMA
    buffer, used in certain special-case large metadata operations.
    
    Signed-off-by: Tom Talpey <tmt@netapp.com>
    Signed-off-by: James Lentini <jlentini@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit af1b8c2ff7c337c4e96db12d6b7b61eaa91aa069
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Feb 25 15:56:29 2008 -0800

    NFS: Fix an f_mode/f_flags confusion in fs/nfs/write.c
    
    O_SYNC is stored in filp->f_flags.
    Thanks to Al Viro for pointing out the bug.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ae04892..6cea747 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -710,6 +710,8 @@ int nfs_lookup_verify_inode(struct inode *inode, struct nameidata *nd)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 
+	if (test_bit(NFS_INO_MOUNTPOINT, &NFS_I(inode)->flags))
+		return 0;
 	if (nd != NULL) {
 		/* VFS wants an on-the-wire revalidation */
 		if (nd->flags & LOOKUP_REVAL)
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 966a885..a4c7cf2 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -299,6 +299,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 				else
 					inode->i_op = &nfs_mountpoint_inode_operations;
 				inode->i_fop = NULL;
+				set_bit(NFS_INO_MOUNTPOINT, &nfsi->flags);
 			}
 		} else if (S_ISLNK(inode->i_mode))
 			inode->i_op = &nfs_symlink_inode_operations;
@@ -1003,8 +1004,9 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 
 	server = NFS_SERVER(inode);
 	/* Update the fsid? */
-	if (S_ISDIR(inode->i_mode)
-			&& !nfs_fsid_equal(&server->fsid, &fattr->fsid))
+	if (S_ISDIR(inode->i_mode) &&
+			!nfs_fsid_equal(&server->fsid, &fattr->fsid) &&
+			!test_bit(NFS_INO_MOUNTPOINT, &nfsi->flags))
 		server->fsid = fattr->fsid;
 
 	/*
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f55c437..80c61fd 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -734,7 +734,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 	 */
 	if (nfs_write_pageuptodate(page, inode) &&
 			inode->i_flock == NULL &&
-			!(file->f_mode & O_SYNC)) {
+			!(file->f_flags & O_SYNC)) {
 		count = max(count + offset, nfs_page_length(page));
 		offset = 0;
 	}
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index a69ba80..f4a0e4c 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -195,6 +195,7 @@ struct nfs_inode {
 #define NFS_INO_ADVISE_RDPLUS	(1)		/* advise readdirplus */
 #define NFS_INO_STALE		(2)		/* possible stale inode */
 #define NFS_INO_ACL_LRU_SET	(3)		/* Inode is on the LRU list */
+#define NFS_INO_MOUNTPOINT	(4)		/* inode is remote mountpoint */
 
 static inline struct nfs_inode *NFS_I(const struct inode *inode)
 {
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 02c522c..a564c1a 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -614,7 +614,11 @@ xprt_rdma_free(void *buffer)
 		return;
 
 	req = container_of(buffer, struct rpcrdma_req, rl_xdr_buf[0]);
-	r_xprt = container_of(req->rl_buffer, struct rpcrdma_xprt, rx_buf);
+	if (req->rl_iov.length == 0) {	/* see allocate above */
+		r_xprt = container_of(((struct rpcrdma_req *) req->rl_buffer)->rl_buffer,
+				      struct rpcrdma_xprt, rx_buf);
+	} else
+		r_xprt = container_of(req->rl_buffer, struct rpcrdma_xprt, rx_buf);
 	rep = req->rl_reply;
 
 	dprintk("RPC:       %s: called on 0x%p%s\n",

