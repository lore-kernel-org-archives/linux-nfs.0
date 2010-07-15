From: David Howells <dhowells@redhat.com>
Subject: [PATCH 09/18] xstat: Make special system filesystems return
	FS_SPECIAL_FL [ver #6]
Date: Thu, 15 Jul 2010 03:17:20 +0100
Message-ID: <20100715021720.5544.19973.stgit@warthog.procyon.org.uk>
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

Make special system filesystems return FS_SPECIAL_FL in st_inode_flags to
xstat().

Signed-off-by: David Howells <dhowells@redhat.com>
---

 arch/ia64/kernel/perfmon.c                |    7 ++++---
 arch/powerpc/platforms/cell/spufs/inode.c |    1 +
 arch/s390/hypfs/inode.c                   |    1 +
 drivers/infiniband/hw/ipath/ipath_fs.c    |    1 +
 drivers/infiniband/hw/qib/qib_fs.c        |    1 +
 drivers/isdn/capi/capifs.c                |    1 +
 drivers/misc/ibmasm/ibmasmfs.c            |    1 +
 drivers/mtd/mtdchar.c                     |    1 +
 drivers/oprofile/oprofilefs.c             |    1 +
 drivers/usb/core/inode.c                  |    1 +
 drivers/usb/gadget/f_fs.c                 |    1 +
 drivers/usb/gadget/inode.c                |    1 +
 drivers/xen/xenfs/super.c                 |    1 +
 fs/anon_inodes.c                          |    1 +
 fs/binfmt_misc.c                          |    1 +
 fs/configfs/mount.c                       |    1 +
 fs/debugfs/inode.c                        |    1 +
 fs/fuse/control.c                         |    1 +
 fs/hostfs/hostfs_kern.c                   |    1 +
 fs/nfsd/nfsctl.c                          |    1 +
 fs/ocfs2/dlmfs/dlmfs.c                    |    1 +
 fs/openpromfs/inode.c                     |    1 +
 fs/pipe.c                                 |    1 +
 fs/proc/root.c                            |    1 +
 fs/sysfs/mount.c                          |    1 +
 ipc/mqueue.c                              |    1 +
 kernel/cgroup.c                           |    1 +
 kernel/cpuset.c                           |    1 +
 net/socket.c                              |    1 +
 net/sunrpc/rpc_pipe.c                     |    1 +
 security/inode.c                          |    1 +
 security/selinux/selinuxfs.c              |    1 +
 security/smack/smackfs.c                  |    1 +
 33 files changed, 36 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index ab985f7..bc96df7 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -626,9 +626,10 @@ pfmfs_get_sb(struct file_system_type *fs_type, int flags, const char *dev_name,
 }
 
 static struct file_system_type pfm_fs_type = {
-	.name     = "pfmfs",
-	.get_sb   = pfmfs_get_sb,
-	.kill_sb  = kill_anon_super,
+	.name		= "pfmfs",
+	.inode_flags	= FS_SPECIAL_FL,
+	.get_sb		= pfmfs_get_sb,
+	.kill_sb	= kill_anon_super,
 };
 
 DEFINE_PER_CPU(unsigned long, pfm_syst_info);
diff --git a/arch/powerpc/platforms/cell/spufs/inode.c b/arch/powerpc/platforms/cell/spufs/inode.c
index e5e5f82..f7d7c84 100644
--- a/arch/powerpc/platforms/cell/spufs/inode.c
+++ b/arch/powerpc/platforms/cell/spufs/inode.c
@@ -808,6 +808,7 @@ spufs_get_sb(struct file_system_type *fstype, int flags,
 static struct file_system_type spufs_type = {
 	.owner = THIS_MODULE,
 	.name = "spufs",
+	.inode_flags = FS_SPECIAL_FL,
 	.get_sb = spufs_get_sb,
 	.kill_sb = kill_litter_super,
 };
diff --git a/arch/s390/hypfs/inode.c b/arch/s390/hypfs/inode.c
index 6b120f0..01060c6 100644
--- a/arch/s390/hypfs/inode.c
+++ b/arch/s390/hypfs/inode.c
@@ -454,6 +454,7 @@ static const struct file_operations hypfs_file_ops = {
 static struct file_system_type hypfs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "s390_hypfs",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb		= hypfs_get_super,
 	.kill_sb	= hypfs_kill_super
 };
diff --git a/drivers/infiniband/hw/ipath/ipath_fs.c b/drivers/infiniband/hw/ipath/ipath_fs.c
index 2fca708..e5bb001 100644
--- a/drivers/infiniband/hw/ipath/ipath_fs.c
+++ b/drivers/infiniband/hw/ipath/ipath_fs.c
@@ -407,6 +407,7 @@ bail:
 static struct file_system_type ipathfs_fs_type = {
 	.owner =	THIS_MODULE,
 	.name =		"ipathfs",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb =	ipathfs_get_sb,
 	.kill_sb =	ipathfs_kill_super,
 };
diff --git a/drivers/infiniband/hw/qib/qib_fs.c b/drivers/infiniband/hw/qib/qib_fs.c
index 844954b..b888a49 100644
--- a/drivers/infiniband/hw/qib/qib_fs.c
+++ b/drivers/infiniband/hw/qib/qib_fs.c
@@ -601,6 +601,7 @@ int qibfs_remove(struct qib_devdata *dd)
 static struct file_system_type qibfs_fs_type = {
 	.owner =        THIS_MODULE,
 	.name =         "ipathfs",
+	.inode_flags =	FS_SPECIAL_FL,
 	.get_sb =       qibfs_get_sb,
 	.kill_sb =      qibfs_kill_super,
 };
diff --git a/drivers/isdn/capi/capifs.c b/drivers/isdn/capi/capifs.c
index 2b83850..1208e4c 100644
--- a/drivers/isdn/capi/capifs.c
+++ b/drivers/isdn/capi/capifs.c
@@ -134,6 +134,7 @@ static int capifs_get_sb(struct file_system_type *fs_type,
 static struct file_system_type capifs_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "capifs",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb		= capifs_get_sb,
 	.kill_sb	= kill_anon_super,
 };
diff --git a/drivers/misc/ibmasm/ibmasmfs.c b/drivers/misc/ibmasm/ibmasmfs.c
index 8844a3f..0767280 100644
--- a/drivers/misc/ibmasm/ibmasmfs.c
+++ b/drivers/misc/ibmasm/ibmasmfs.c
@@ -108,6 +108,7 @@ static const struct file_operations *ibmasmfs_dir_ops = &simple_dir_operations;
 static struct file_system_type ibmasmfs_type = {
 	.owner          = THIS_MODULE,
 	.name           = "ibmasmfs",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb         = ibmasmfs_get_super,
 	.kill_sb        = kill_litter_super,
 };
diff --git a/drivers/mtd/mtdchar.c b/drivers/mtd/mtdchar.c
index 91c8013..acb4ad7 100644
--- a/drivers/mtd/mtdchar.c
+++ b/drivers/mtd/mtdchar.c
@@ -986,6 +986,7 @@ static int mtd_inodefs_get_sb(struct file_system_type *fs_type, int flags,
 
 static struct file_system_type mtd_inodefs_type = {
        .name = "mtd_inodefs",
+	.inode_flags = FS_SPECIAL_FL,
        .get_sb = mtd_inodefs_get_sb,
        .kill_sb = kill_anon_super,
 };
diff --git a/drivers/oprofile/oprofilefs.c b/drivers/oprofile/oprofilefs.c
index 2766a6d..cf3dab6 100644
--- a/drivers/oprofile/oprofilefs.c
+++ b/drivers/oprofile/oprofilefs.c
@@ -279,6 +279,7 @@ static int oprofilefs_get_sb(struct file_system_type *fs_type,
 static struct file_system_type oprofilefs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "oprofilefs",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb		= oprofilefs_get_sb,
 	.kill_sb	= kill_litter_super,
 };
diff --git a/drivers/usb/core/inode.c b/drivers/usb/core/inode.c
index 1a27618..0d942f0 100644
--- a/drivers/usb/core/inode.c
+++ b/drivers/usb/core/inode.c
@@ -586,6 +586,7 @@ static int usb_get_sb(struct file_system_type *fs_type,
 static struct file_system_type usb_fs_type = {
 	.owner =	THIS_MODULE,
 	.name =		"usbfs",
+	.inode_flags =	FS_SPECIAL_FL,
 	.get_sb =	usb_get_sb,
 	.kill_sb =	kill_litter_super,
 };
diff --git a/drivers/usb/gadget/f_fs.c b/drivers/usb/gadget/f_fs.c
index d69eccf..63d8f91 100644
--- a/drivers/usb/gadget/f_fs.c
+++ b/drivers/usb/gadget/f_fs.c
@@ -1221,6 +1221,7 @@ ffs_fs_kill_sb(struct super_block *sb)
 static struct file_system_type ffs_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "functionfs",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb		= ffs_fs_get_sb,
 	.kill_sb	= ffs_fs_kill_sb,
 };
diff --git a/drivers/usb/gadget/inode.c b/drivers/usb/gadget/inode.c
index de8a838..cb304b8 100644
--- a/drivers/usb/gadget/inode.c
+++ b/drivers/usb/gadget/inode.c
@@ -2127,6 +2127,7 @@ gadgetfs_kill_sb (struct super_block *sb)
 static struct file_system_type gadgetfs_type = {
 	.owner		= THIS_MODULE,
 	.name		= shortname,
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb		= gadgetfs_get_sb,
 	.kill_sb	= gadgetfs_kill_sb,
 };
diff --git a/drivers/xen/xenfs/super.c b/drivers/xen/xenfs/super.c
index 8924d93..d1029bf 100644
--- a/drivers/xen/xenfs/super.c
+++ b/drivers/xen/xenfs/super.c
@@ -59,6 +59,7 @@ static int xenfs_get_sb(struct file_system_type *fs_type,
 static struct file_system_type xenfs_type = {
 	.owner =	THIS_MODULE,
 	.name =		"xenfs",
+	.inode_flags =	FS_SPECIAL_FL,
 	.get_sb =	xenfs_get_sb,
 	.kill_sb =	kill_litter_super,
 };
diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
index e4b75d6..8820975 100644
--- a/fs/anon_inodes.c
+++ b/fs/anon_inodes.c
@@ -45,6 +45,7 @@ static char *anon_inodefs_dname(struct dentry *dentry, char *buffer, int buflen)
 
 static struct file_system_type anon_inode_fs_type = {
 	.name		= "anon_inodefs",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb		= anon_inodefs_get_sb,
 	.kill_sb	= kill_anon_super,
 };
diff --git a/fs/binfmt_misc.c b/fs/binfmt_misc.c
index c4e8353..df727ea 100644
--- a/fs/binfmt_misc.c
+++ b/fs/binfmt_misc.c
@@ -715,6 +715,7 @@ static struct linux_binfmt misc_format = {
 static struct file_system_type bm_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "binfmt_misc",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb		= bm_get_sb,
 	.kill_sb	= kill_litter_super,
 };
diff --git a/fs/configfs/mount.c b/fs/configfs/mount.c
index 8c8d642..11107f4 100644
--- a/fs/configfs/mount.c
+++ b/fs/configfs/mount.c
@@ -113,6 +113,7 @@ static int configfs_get_sb(struct file_system_type *fs_type,
 static struct file_system_type configfs_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "configfs",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb		= configfs_get_sb,
 	.kill_sb	= kill_litter_super,
 };
diff --git a/fs/debugfs/inode.c b/fs/debugfs/inode.c
index 30a87b3..84f09a1 100644
--- a/fs/debugfs/inode.c
+++ b/fs/debugfs/inode.c
@@ -144,6 +144,7 @@ static int debug_get_sb(struct file_system_type *fs_type,
 static struct file_system_type debug_fs_type = {
 	.owner =	THIS_MODULE,
 	.name =		"debugfs",
+	.inode_flags =	FS_SPECIAL_FL,
 	.get_sb =	debug_get_sb,
 	.kill_sb =	kill_litter_super,
 };
diff --git a/fs/fuse/control.c b/fs/fuse/control.c
index 3773fd6..798da59 100644
--- a/fs/fuse/control.c
+++ b/fs/fuse/control.c
@@ -341,6 +341,7 @@ static void fuse_ctl_kill_sb(struct super_block *sb)
 static struct file_system_type fuse_ctl_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "fusectl",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb		= fuse_ctl_get_sb,
 	.kill_sb	= fuse_ctl_kill_sb,
 };
diff --git a/fs/hostfs/hostfs_kern.c b/fs/hostfs/hostfs_kern.c
index 87ac189..07a9973 100644
--- a/fs/hostfs/hostfs_kern.c
+++ b/fs/hostfs/hostfs_kern.c
@@ -1037,6 +1037,7 @@ static int hostfs_read_sb(struct file_system_type *type,
 static struct file_system_type hostfs_type = {
 	.owner 		= THIS_MODULE,
 	.name 		= "hostfs",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb 	= hostfs_read_sb,
 	.kill_sb	= kill_anon_super,
 	.fs_flags 	= 0,
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 508941c..4e6cf14 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1397,6 +1397,7 @@ static int nfsd_get_sb(struct file_system_type *fs_type,
 static struct file_system_type nfsd_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfsd",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb		= nfsd_get_sb,
 	.kill_sb	= kill_litter_super,
 };
diff --git a/fs/ocfs2/dlmfs/dlmfs.c b/fs/ocfs2/dlmfs/dlmfs.c
index b83d610..0bba39f 100644
--- a/fs/ocfs2/dlmfs/dlmfs.c
+++ b/fs/ocfs2/dlmfs/dlmfs.c
@@ -649,6 +649,7 @@ static int dlmfs_get_sb(struct file_system_type *fs_type,
 static struct file_system_type dlmfs_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "ocfs2_dlmfs",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb		= dlmfs_get_sb,
 	.kill_sb	= kill_litter_super,
 };
diff --git a/fs/openpromfs/inode.c b/fs/openpromfs/inode.c
index ffcd04f..8bbc7ce 100644
--- a/fs/openpromfs/inode.c
+++ b/fs/openpromfs/inode.c
@@ -424,6 +424,7 @@ static int openprom_get_sb(struct file_system_type *fs_type,
 static struct file_system_type openprom_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "openpromfs",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb		= openprom_get_sb,
 	.kill_sb	= kill_anon_super,
 };
diff --git a/fs/pipe.c b/fs/pipe.c
index 279eef9..247efd1 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -1254,6 +1254,7 @@ static int pipefs_get_sb(struct file_system_type *fs_type,
 
 static struct file_system_type pipe_fs_type = {
 	.name		= "pipefs",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb		= pipefs_get_sb,
 	.kill_sb	= kill_anon_super,
 };
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 4258384..9c95a19 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -97,6 +97,7 @@ static void proc_kill_sb(struct super_block *sb)
 
 static struct file_system_type proc_fs_type = {
 	.name		= "proc",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb		= proc_get_sb,
 	.kill_sb	= proc_kill_sb,
 };
diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index 281c0c9..ec2ea3b 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -147,6 +147,7 @@ static void sysfs_kill_sb(struct super_block *sb)
 
 static struct file_system_type sysfs_fs_type = {
 	.name		= "sysfs",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb		= sysfs_get_sb,
 	.kill_sb	= sysfs_kill_sb,
 };
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index c93fd3f..bba10cf 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -1232,6 +1232,7 @@ static const struct super_operations mqueue_super_ops = {
 
 static struct file_system_type mqueue_fs_type = {
 	.name = "mqueue",
+	.inode_flags = FS_SPECIAL_FL,
 	.get_sb = mqueue_get_sb,
 	.kill_sb = kill_litter_super,
 };
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 3ac6f5b..71c81b4 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1619,6 +1619,7 @@ static void cgroup_kill_sb(struct super_block *sb) {
 
 static struct file_system_type cgroup_fs_type = {
 	.name = "cgroup",
+	.inode_flags = FS_SPECIAL_FL,
 	.get_sb = cgroup_get_sb,
 	.kill_sb = cgroup_kill_sb,
 };
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 02b9611..d5e5c56 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -250,6 +250,7 @@ static int cpuset_get_sb(struct file_system_type *fs_type,
 
 static struct file_system_type cpuset_fs_type = {
 	.name = "cpuset",
+	.inode_flags = FS_SPECIAL_FL,
 	.get_sb = cpuset_get_sb,
 };
 
diff --git a/net/socket.c b/net/socket.c
index 367d547..0aaf9f6 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -326,6 +326,7 @@ static struct vfsmount *sock_mnt __read_mostly;
 
 static struct file_system_type sock_fs_type = {
 	.name =		"sockfs",
+	.inode_flags =	FS_SPECIAL_FL,
 	.get_sb =	sockfs_get_sb,
 	.kill_sb =	kill_anon_super,
 };
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 95ccbcf..1e1d477 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1033,6 +1033,7 @@ rpc_get_sb(struct file_system_type *fs_type,
 static struct file_system_type rpc_pipe_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "rpc_pipefs",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb		= rpc_get_sb,
 	.kill_sb	= kill_litter_super,
 };
diff --git a/security/inode.c b/security/inode.c
index 1c812e8..7a904bb 100644
--- a/security/inode.c
+++ b/security/inode.c
@@ -139,6 +139,7 @@ static int get_sb(struct file_system_type *fs_type,
 static struct file_system_type fs_type = {
 	.owner =	THIS_MODULE,
 	.name =		"securityfs",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb =	get_sb,
 	.kill_sb =	kill_litter_super,
 };
diff --git a/security/selinux/selinuxfs.c b/security/selinux/selinuxfs.c
index 0293843..9c4bc22 100644
--- a/security/selinux/selinuxfs.c
+++ b/security/selinux/selinuxfs.c
@@ -1706,6 +1706,7 @@ static int sel_get_sb(struct file_system_type *fs_type,
 
 static struct file_system_type sel_fs_type = {
 	.name		= "selinuxfs",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb		= sel_get_sb,
 	.kill_sb	= kill_litter_super,
 };
diff --git a/security/smack/smackfs.c b/security/smack/smackfs.c
index a2b72d7..56a8cc1 100644
--- a/security/smack/smackfs.c
+++ b/security/smack/smackfs.c
@@ -1325,6 +1325,7 @@ static int smk_get_sb(struct file_system_type *fs_type,
 
 static struct file_system_type smk_fs_type = {
 	.name		= "smackfs",
+	.inode_flags	= FS_SPECIAL_FL,
 	.get_sb		= smk_get_sb,
 	.kill_sb	= kill_litter_super,
 };
