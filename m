From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NFS: remove error field from nfs_readdir_descriptor_t (resend)
Date: Tue, 12 Feb 2008 06:49:01 -0500
Message-ID: <1202816941-10664-1-git-send-email-jlayton@redhat.com>
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

Hi Trond,

I sent this minor cleanup patch a couple of weeks ago and never got a
response. Any thoughts on it?

---------[snip]----------

The error field in nfs_readdir_descriptor_t is never used outside of the
function in which it is set. Remove the field and change the place that
does use it to use an existing local variable.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/dir.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 476cb0f..ae04892 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -154,7 +154,6 @@ typedef struct {
 	struct nfs_entry *entry;
 	decode_dirent_t	decode;
 	int		plus;
-	int		error;
 	unsigned long	timestamp;
 	int		timestamp_valid;
 } nfs_readdir_descriptor_t;
@@ -213,7 +212,6 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page *page)
 	return 0;
  error:
 	unlock_page(page);
-	desc->error = error;
 	return -EIO;
 }
 
@@ -483,13 +481,13 @@ int uncached_readdir(nfs_readdir_descriptor_t *desc, void *dirent,
 		goto out;
 	}
 	timestamp = jiffies;
-	desc->error = NFS_PROTO(inode)->readdir(file->f_path.dentry, cred, *desc->dir_cookie,
-						page,
+	status = NFS_PROTO(inode)->readdir(file->f_path.dentry, cred,
+						*desc->dir_cookie, page,
 						NFS_SERVER(inode)->dtsize,
 						desc->plus);
 	desc->page = page;
 	desc->ptr = kmap(page);		/* matching kunmap in nfs_do_filldir */
-	if (desc->error >= 0) {
+	if (status >= 0) {
 		desc->timestamp = timestamp;
 		desc->timestamp_valid = 1;
 		if ((status = dir_decode(desc)) == 0)
-- 
1.5.3.8
