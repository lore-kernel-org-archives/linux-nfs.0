From: David Howells <dhowells@redhat.com>
Subject: [PATCH 10/18] xstat: Make network filesystems return FS_REMOTE_FL
	[ver #6]
Date: Thu, 15 Jul 2010 03:17:21 +0100
Message-ID: <20100715021721.5544.64276.stgit@warthog.procyon.org.uk>
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

Make network filesystems return FS_REMOTE_FL in st_inode_flags to xstat().

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/super.c   |    1 +
 fs/ceph/super.c  |    1 +
 fs/cifs/cifsfs.c |    1 +
 fs/coda/inode.c  |    1 +
 fs/ncpfs/inode.c |    1 +
 fs/nfs/super.c   |    7 +++++++
 fs/smbfs/inode.c |    1 +
 7 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/fs/afs/super.c b/fs/afs/super.c
index e932e5a..daaa3d4 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -40,6 +40,7 @@ static int afs_statfs(struct dentry *dentry, struct kstatfs *buf);
 struct file_system_type afs_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "afs",
+	.inode_flags	= FS_REMOTE_FL,
 	.get_sb		= afs_get_sb,
 	.kill_sb	= kill_anon_super,
 	.fs_flags	= 0,
diff --git a/fs/ceph/super.c b/fs/ceph/super.c
index fa87f51..f486ac8 100644
--- a/fs/ceph/super.c
+++ b/fs/ceph/super.c
@@ -1019,6 +1019,7 @@ static void ceph_kill_sb(struct super_block *s)
 static struct file_system_type ceph_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "ceph",
+	.inode_flags	= FS_REMOTE_FL,
 	.get_sb		= ceph_get_sb,
 	.kill_sb	= ceph_kill_sb,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE,
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index ef9a773..eb2c517 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -586,6 +586,7 @@ static int cifs_setlease(struct file *file, long arg, struct file_lock **lease)
 struct file_system_type cifs_fs_type = {
 	.owner = THIS_MODULE,
 	.name = "cifs",
+	.inode_flags = FS_REMOTE_FL,
 	.get_sb = cifs_get_sb,
 	.kill_sb = kill_anon_super,
 	/*  .fs_flags */
diff --git a/fs/coda/inode.c b/fs/coda/inode.c
index d97f993..cb05427 100644
--- a/fs/coda/inode.c
+++ b/fs/coda/inode.c
@@ -308,6 +308,7 @@ static int coda_get_sb(struct file_system_type *fs_type,
 struct file_system_type coda_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "coda",
+	.inode_flags	= FS_REMOTE_FL,
 	.get_sb		= coda_get_sb,
 	.kill_sb	= kill_anon_super,
 	.fs_flags	= FS_BINARY_MOUNTDATA,
diff --git a/fs/ncpfs/inode.c b/fs/ncpfs/inode.c
index fa33851..c5892a1 100644
--- a/fs/ncpfs/inode.c
+++ b/fs/ncpfs/inode.c
@@ -1018,6 +1018,7 @@ static int ncp_get_sb(struct file_system_type *fs_type,
 static struct file_system_type ncp_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "ncpfs",
+	.inode_flags	= FS_REMOTE_FL,
 	.get_sb		= ncp_get_sb,
 	.kill_sb	= kill_anon_super,
 	.fs_flags	= FS_BINARY_MOUNTDATA,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f9df16d..2553683 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -251,6 +251,7 @@ static int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
 static struct file_system_type nfs_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs",
+	.inode_flags	= FS_REMOTE_FL,
 	.get_sb		= nfs_get_sb,
 	.kill_sb	= nfs_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
@@ -259,6 +260,7 @@ static struct file_system_type nfs_fs_type = {
 struct file_system_type nfs_xdev_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs",
+	.inode_flags	= FS_REMOTE_FL,
 	.get_sb		= nfs_xdev_get_sb,
 	.kill_sb	= nfs_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
@@ -297,6 +299,7 @@ static void nfs4_kill_super(struct super_block *sb);
 static struct file_system_type nfs4_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
+	.inode_flags	= FS_REMOTE_FL,
 	.get_sb		= nfs4_get_sb,
 	.kill_sb	= nfs4_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
@@ -305,6 +308,7 @@ static struct file_system_type nfs4_fs_type = {
 static struct file_system_type nfs4_remote_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
+	.inode_flags	= FS_REMOTE_FL,
 	.get_sb		= nfs4_remote_get_sb,
 	.kill_sb	= nfs4_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
@@ -313,6 +317,7 @@ static struct file_system_type nfs4_remote_fs_type = {
 struct file_system_type nfs4_xdev_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
+	.inode_flags	= FS_REMOTE_FL,
 	.get_sb		= nfs4_xdev_get_sb,
 	.kill_sb	= nfs4_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
@@ -321,6 +326,7 @@ struct file_system_type nfs4_xdev_fs_type = {
 static struct file_system_type nfs4_remote_referral_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
+	.inode_flags	= FS_REMOTE_FL,
 	.get_sb		= nfs4_remote_referral_get_sb,
 	.kill_sb	= nfs4_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
@@ -329,6 +335,7 @@ static struct file_system_type nfs4_remote_referral_fs_type = {
 struct file_system_type nfs4_referral_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
+	.inode_flags	= FS_REMOTE_FL,
 	.get_sb		= nfs4_referral_get_sb,
 	.kill_sb	= nfs4_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
diff --git a/fs/smbfs/inode.c b/fs/smbfs/inode.c
index 9551cb6..e47d86a 100644
--- a/fs/smbfs/inode.c
+++ b/fs/smbfs/inode.c
@@ -800,6 +800,7 @@ static int smb_get_sb(struct file_system_type *fs_type,
 static struct file_system_type smb_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "smbfs",
+	.inode_flags	= FS_REMOTE_FL,
 	.get_sb		= smb_get_sb,
 	.kill_sb	= kill_anon_super,
 	.fs_flags	= FS_BINARY_MOUNTDATA,
