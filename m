From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 4/7] unionfs: fix unionfs_setattr to handle
	ATTR_KILL_S*ID
Date: Thu, 20 Sep 2007 05:10:57 -0400
Message-ID: <200709200910.l8K9AvRm001343@dantu.rdu.redhat.com>
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

Don't allow unionfs_setattr to trip the BUG() in notify_change. Clear
ATTR_MODE if the either ATTR_KILL_S*ID is set. This also allows the
lower filesystem to interpret these bits in its own way.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/unionfs/inode.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/unionfs/inode.c b/fs/unionfs/inode.c
index 687b9a7..9cb54d9 100644
--- a/fs/unionfs/inode.c
+++ b/fs/unionfs/inode.c
@@ -1021,6 +1021,13 @@ static int unionfs_setattr(struct dentry *dentry, struct iattr *ia)
 	bend = dbend(dentry);
 	inode = dentry->d_inode;
 
+	/*
+	 * mode change is for clearing setuid/setgid. Allow lower filesystem
+	 * to reinterpret it in its own way.
+	 */
+	if (ia->ia_valid & (ATTR_KILL_SUID | ATTR_KILL_SGID))
+		ia->ia_valid &= ~ATTR_MODE;
+
 	for (bindex = bstart; (bindex <= bend) || (bindex == bstart);
 	     bindex++) {
 		lower_dentry = unionfs_lower_dentry_idx(dentry, bindex);
-- 
1.5.2.1


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
