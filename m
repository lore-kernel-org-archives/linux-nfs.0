From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] nfs: parenthesize NFS_*(inode) parameters
Date: Tue, 22 Jan 2008 16:28:03 +0200
Message-ID: <1201012083-9860-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, NFSv4@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Otherwise e.g., NFS_SERVER(&nfsi->vfs_inode) does not compile.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfs_fs.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 0477a4c..5a5d3fe 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -221,10 +221,10 @@ static inline struct nfs_inode *NFS_I(struct inode *inode)
 {
 	return container_of(inode, struct nfs_inode, vfs_inode);
 }
-#define NFS_SB(s)		((struct nfs_server *)(s->s_fs_info))
+#define NFS_SB(s)		((struct nfs_server *)((s)->s_fs_info))
 
 #define NFS_FH(inode)			(&NFS_I(inode)->fh)
-#define NFS_SERVER(inode)		(NFS_SB(inode->i_sb))
+#define NFS_SERVER(inode)		(NFS_SB((inode)->i_sb))
 #define NFS_CLIENT(inode)		(NFS_SERVER(inode)->client)
 #define NFS_PROTO(inode)		(NFS_SERVER(inode)->nfs_client->rpc_ops)
 #define NFS_COOKIEVERF(inode)		(NFS_I(inode)->cookieverf)
-- 
1.5.3.3
