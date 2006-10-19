From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/2] NFS: Cache invalidation fixup
Date: Thu, 19 Oct 2006 13:11:13 -0400
Message-ID: <20061019171113.8593.90932.stgit@lade.trondhjem.org>
References: <20061019171113.8593.8585.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: Al Viro <viro@ftp.linux.org.uk>, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1946250AbWJSRNS@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <20061019171113.8593.8585.stgit@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

If someone has renamed a directory on the server, triggering the d_move
code in d_materialise_unique(), then we need to invalidate the
cached directory information in the source parent directory.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2cfa414..fa71936 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -936,8 +936,14 @@ static struct dentry *nfs_lookup(struct 
 no_entry:
 	res = d_materialise_unique(dentry, inode);
 	if (res != NULL) {
+		struct dentry *parent;
 		if (IS_ERR(res))
 			goto out_unlock;
+		/* Was a directory renamed! */
+		parent = dget_parent(res);
+		if (!IS_ROOT(parent))
+			nfs_mark_for_revalidate(parent->d_inode);
+		dput(parent);
 		dentry = res;
 	}
 	nfs_renew_times(dentry);
