From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/7] reiserfs: turn of ATTR_KILL_S*ID at beginning of
	reiserfs_setattr
Date: Thu, 20 Sep 2007 05:10:52 -0400
Message-ID: <200709200910.l8K9AqND001338@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, unionfs@filesystems.org,
	linux-cifs-client@lists.samba.org,
	ecryptfs-devel@lists.sourceforge.net, reiserfs-devel@vger.kernel.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <nfs-bounces@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

reiserfs_setattr can call notify_change recursively using the same
iattr struct. This could cause it to trip the BUG() in notify_change.
Fix reiserfs to clear those bits near the beginning of the function.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/reiserfs/inode.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/reiserfs/inode.c b/fs/reiserfs/inode.c
index 9ea1200..0804289 100644
--- a/fs/reiserfs/inode.c
+++ b/fs/reiserfs/inode.c
@@ -3061,7 +3061,11 @@ int reiserfs_setattr(struct dentry *dentry, struct iattr *attr)
 {
 	struct inode *inode = dentry->d_inode;
 	int error;
-	unsigned int ia_valid = attr->ia_valid;
+	unsigned int ia_valid;
+
+	/* must be turned off for recursive notify_change calls */
+	ia_valid = attr->ia_valid &= ~(ATTR_KILL_SUID|ATTR_KILL_SGID);
+
 	reiserfs_write_lock(inode->i_sb);
 	if (attr->ia_valid & ATTR_SIZE) {
 		/* version 2 items will be caught by the s_maxbytes check
-- 
1.5.2.1


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
