From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NFS: initialize flags field in nfs_open_context
Date: Mon, 31 Mar 2008 15:01:58 -0400
Message-ID: <1206990118-28183-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond.Myklebust@netapp.com
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

The nfs_open_context struct had a "flags" field added recently, but the
allocator isn't initializing it. It also looks like the allocator isn't
initializing the mode or list either, but they seem to be overwritten
by the caller, so that's less of an issue.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/inode.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index a4c7cf2..6f88d7c 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -506,6 +506,7 @@ static struct nfs_open_context *alloc_nfs_open_context(struct vfsmount *mnt, str
 		ctx->cred = get_rpccred(cred);
 		ctx->state = NULL;
 		ctx->lockowner = current->files;
+		ctx->flags = 0;
 		ctx->error = 0;
 		ctx->dir_cookie = 0;
 		atomic_set(&ctx->count, 1);
-- 
1.5.3.6
