From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/7] ecryptfs: allow lower fs to interpret
	ATTR_KILL_S*ID
Date: Mon, 17 Sep 2007 07:29:10 -0400
Message-ID: <200709171129.l8HBTA7D024365@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, unionfs@filesystems.org,
	linux-cifs-client@lists.samba.org,
	ecryptfs-devel@lists.sourceforge.net, reiserfs-devel@vger.kernel.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <ecryptfs-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ecryptfs-devel>,
	<mailto:ecryptfs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ecryptfs-devel>
List-Post: <mailto:ecryptfs-devel@lists.sourceforge.net>
List-Help: <mailto:ecryptfs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ecryptfs-devel>,
	<mailto:ecryptfs-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ecryptfs-devel-bounces@lists.sourceforge.net
Errors-To: ecryptfs-devel-bounces@lists.sourceforge.net
List-ID: <nfs.lists.sourceforge.net>

This patch makes sure ecryptfs doesn't trip the BUG() in notify_change.
It also allows the lower filesystem to interpret ATTR_KILL_S*ID in its
own way.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/ecryptfs/inode.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index 131954b..dac4199 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -959,6 +959,14 @@ static int ecryptfs_setattr(struct dentry *dentry, struct iattr *ia)
 		if (rc < 0)
 			goto out;
 	}
+
+	/*
+	 * mode change is for clearing setuid/setgid bits. Allow lower fs
+	 * to interpret this in its own way.
+	 */
+	if (ia->ia_valid & (ATTR_KILL_SUID | ATTR_KILL_SGID))
+		ia->ia_valid &= ~ATTR_MODE;
+
 	rc = notify_change(lower_dentry, ia);
 out:
 	fsstack_copy_attr_all(inode, lower_inode, NULL);
-- 
1.5.2.1


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
