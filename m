From: David Howells <dhowells@redhat.com>
Subject: [PATCH 05/18] xstat: eCryptFS: Return extended attributes [ver #6]
Date: Thu, 15 Jul 2010 03:17:15 +0100
Message-ID: <20100715021715.5544.83732.stgit@warthog.procyon.org.uk>
References: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
	samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
	dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <samba-technical-bounces@lists.samba.org>
In-Reply-To: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
List-Unsubscribe: <https://lists.samba.org/mailman/options/samba-technical>,
	<mailto:samba-technical-request@lists.samba.org?subject=unsubscribe>
List-Archive: <http://lists.samba.org/pipermail/samba-technical>
List-Post: <mailto:samba-technical@lists.samba.org>
List-Help: <mailto:samba-technical-request@lists.samba.org?subject=help>
List-Subscribe: <https://lists.samba.org/mailman/listinfo/samba-technical>,
	<mailto:samba-technical-request@lists.samba.org?subject=subscribe>
Sender: samba-technical-bounces@lists.samba.org
Errors-To: samba-technical-bounces@lists.samba.org
List-ID: <linux-nfs.vger.kernel.org>

Return extended attributes from the eCryptFS filesystem, dredged up from the
lower filesystem.

Possibly eCryptFS should also set FS_COMPR_FL on its compressed files.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/ecryptfs/inode.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index 31ef525..41bc407 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -994,8 +994,10 @@ int ecryptfs_getattr(struct vfsmount *mnt, struct dentry *dentry,
 	struct kstat lower_stat;
 	int rc;
 
-	rc = vfs_getattr(ecryptfs_dentry_to_lower_mnt(dentry),
-			 ecryptfs_dentry_to_lower(dentry), &lower_stat);
+	lower_stat.query_flags = stat->query_flags;
+	lower_stat.request_mask = stat->request_mask | XSTAT_REQUEST_BLOCKS;
+	rc = vfs_xgetattr(ecryptfs_dentry_to_lower_mnt(dentry),
+			  ecryptfs_dentry_to_lower(dentry), &lower_stat);
 	if (!rc) {
 		generic_fillattr(dentry->d_inode, stat);
 		stat->blocks = lower_stat.blocks;
