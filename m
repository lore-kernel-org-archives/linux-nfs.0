Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:56758 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752558AbeDSNbS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Apr 2018 09:31:18 -0400
Subject: [PATCH 02/24] VFS: Suppress MS_* flag defs within the kernel unless
 explicitly enabled [ver #7]
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Thu, 19 Apr 2018 14:31:16 +0100
Message-ID: <152414467628.23902.13649758337044170480.stgit@warthog.procyon.org.uk>
In-Reply-To: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
References: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Only the mount namespace code that implements mount(2) should be using the
MS_* flags.  Suppress them inside the kernel unless uapi/linux/mount.h is
included.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 arch/arc/kernel/setup.c       |    1 +
 arch/arm/kernel/atags_parse.c |    1 +
 arch/sh/kernel/setup.c        |    1 +
 arch/sparc/kernel/setup_32.c  |    1 +
 arch/sparc/kernel/setup_64.c  |    1 +
 arch/x86/kernel/setup.c       |    1 +
 drivers/base/devtmpfs.c       |    1 +
 fs/f2fs/super.c               |    2 +
 fs/namespace.c                |    1 +
 fs/pnode.c                    |    1 +
 fs/super.c                    |    1 +
 include/uapi/linux/fs.h       |   56 ++++------------------------------------
 include/uapi/linux/mount.h    |   58 +++++++++++++++++++++++++++++++++++++++++
 init/do_mounts.c              |    1 +
 init/do_mounts_initrd.c       |    1 +
 security/apparmor/lsm.c       |    1 +
 security/apparmor/mount.c     |    1 +
 security/selinux/hooks.c      |    1 +
 security/tomoyo/mount.c       |    1 +
 19 files changed, 80 insertions(+), 52 deletions(-)
 create mode 100644 include/uapi/linux/mount.h

diff --git a/arch/arc/kernel/setup.c b/arch/arc/kernel/setup.c
index b2cae79a25d7..714dc5c2baf1 100644
--- a/arch/arc/kernel/setup.c
+++ b/arch/arc/kernel/setup.c
@@ -19,6 +19,7 @@
 #include <linux/of_fdt.h>
 #include <linux/of.h>
 #include <linux/cache.h>
+#include <uapi/linux/mount.h>
 #include <asm/sections.h>
 #include <asm/arcregs.h>
 #include <asm/tlb.h>
diff --git a/arch/arm/kernel/atags_parse.c b/arch/arm/kernel/atags_parse.c
index c10a3e8ee998..a8a4333929f5 100644
--- a/arch/arm/kernel/atags_parse.c
+++ b/arch/arm/kernel/atags_parse.c
@@ -24,6 +24,7 @@
 #include <linux/root_dev.h>
 #include <linux/screen_info.h>
 #include <linux/memblock.h>
+#include <uapi/linux/mount.h>
 
 #include <asm/setup.h>
 #include <asm/system_info.h>
diff --git a/arch/sh/kernel/setup.c b/arch/sh/kernel/setup.c
index d34e998b809f..d60c7f794d7a 100644
--- a/arch/sh/kernel/setup.c
+++ b/arch/sh/kernel/setup.c
@@ -33,6 +33,7 @@
 #include <linux/of.h>
 #include <linux/of_fdt.h>
 #include <linux/uaccess.h>
+#include <uapi/linux/mount.h>
 #include <asm/io.h>
 #include <asm/page.h>
 #include <asm/elf.h>
diff --git a/arch/sparc/kernel/setup_32.c b/arch/sparc/kernel/setup_32.c
index 13664c377196..7df3d704284c 100644
--- a/arch/sparc/kernel/setup_32.c
+++ b/arch/sparc/kernel/setup_32.c
@@ -34,6 +34,7 @@
 #include <linux/kdebug.h>
 #include <linux/export.h>
 #include <linux/start_kernel.h>
+#include <uapi/linux/mount.h>
 
 #include <asm/io.h>
 #include <asm/processor.h>
diff --git a/arch/sparc/kernel/setup_64.c b/arch/sparc/kernel/setup_64.c
index 7944b3ca216a..206bf81eedaf 100644
--- a/arch/sparc/kernel/setup_64.c
+++ b/arch/sparc/kernel/setup_64.c
@@ -33,6 +33,7 @@
 #include <linux/module.h>
 #include <linux/start_kernel.h>
 #include <linux/bootmem.h>
+#include <uapi/linux/mount.h>
 
 #include <asm/io.h>
 #include <asm/processor.h>
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 6285697b6e56..29b43f69ae55 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -50,6 +50,7 @@
 #include <linux/init_ohci1394_dma.h>
 #include <linux/kvm_para.h>
 #include <linux/dma-contiguous.h>
+#include <uapi/linux/mount.h>
 
 #include <linux/errno.h>
 #include <linux/kernel.h>
diff --git a/drivers/base/devtmpfs.c b/drivers/base/devtmpfs.c
index f7768077e817..79a235184fb5 100644
--- a/drivers/base/devtmpfs.c
+++ b/drivers/base/devtmpfs.c
@@ -25,6 +25,7 @@
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/kthread.h>
+#include <uapi/linux/mount.h>
 #include "base.h"
 
 static struct task_struct *thread;
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 42d564c5ccd0..a31cc49b7295 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -1450,7 +1450,7 @@ static int f2fs_remount(struct super_block *sb, int *flags, char *data)
 		err = dquot_suspend(sb, -1);
 		if (err < 0)
 			goto restore_opts;
-	} else if (f2fs_readonly(sb) && !(*flags & MS_RDONLY)) {
+	} else if (f2fs_readonly(sb) && !(*flags & SB_RDONLY)) {
 		/* dquot_resume needs RW */
 		sb->s_flags &= ~SB_RDONLY;
 		if (sb_any_quota_suspended(sb)) {
diff --git a/fs/namespace.c b/fs/namespace.c
index 6f720ebca133..3f98e1a36b84 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -26,6 +26,7 @@
 #include <linux/bootmem.h>
 #include <linux/task_work.h>
 #include <linux/sched/task.h>
+#include <uapi/linux/mount.h>
 
 #include "pnode.h"
 #include "internal.h"
diff --git a/fs/pnode.c b/fs/pnode.c
index 53d411a371ce..1100e810d855 100644
--- a/fs/pnode.c
+++ b/fs/pnode.c
@@ -10,6 +10,7 @@
 #include <linux/mount.h>
 #include <linux/fs.h>
 #include <linux/nsproxy.h>
+#include <uapi/linux/mount.h>
 #include "internal.h"
 #include "pnode.h"
 
diff --git a/fs/super.c b/fs/super.c
index 5fa9a8d8d865..f7c5629bbbda 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -35,6 +35,7 @@
 #include <linux/fsnotify.h>
 #include <linux/lockdep.h>
 #include <linux/user_namespace.h>
+#include <uapi/linux/mount.h>
 #include "internal.h"
 
 static int thaw_super_locked(struct super_block *sb);
diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
index d2a8313fabd7..5da6c2d96af5 100644
--- a/include/uapi/linux/fs.h
+++ b/include/uapi/linux/fs.h
@@ -14,6 +14,11 @@
 #include <linux/ioctl.h>
 #include <linux/types.h>
 
+/* Use of MS_* flags within the kernel is restricted to core mount(2) code. */
+#if !defined(__KERNEL__)
+#include <linux/mount.h>
+#endif
+
 /*
  * It's silly to have NR_OPEN bigger than NR_FILE, but you can change
  * the file limit at runtime and only root can increase the per-process
@@ -101,57 +106,6 @@ struct inodes_stat_t {
 
 #define NR_FILE  8192	/* this can well be larger on a larger system */
 
-
-/*
- * These are the fs-independent mount-flags: up to 32 flags are supported
- */
-#define MS_RDONLY	 1	/* Mount read-only */
-#define MS_NOSUID	 2	/* Ignore suid and sgid bits */
-#define MS_NODEV	 4	/* Disallow access to device special files */
-#define MS_NOEXEC	 8	/* Disallow program execution */
-#define MS_SYNCHRONOUS	16	/* Writes are synced at once */
-#define MS_REMOUNT	32	/* Alter flags of a mounted FS */
-#define MS_MANDLOCK	64	/* Allow mandatory locks on an FS */
-#define MS_DIRSYNC	128	/* Directory modifications are synchronous */
-#define MS_NOATIME	1024	/* Do not update access times. */
-#define MS_NODIRATIME	2048	/* Do not update directory access times */
-#define MS_BIND		4096
-#define MS_MOVE		8192
-#define MS_REC		16384
-#define MS_VERBOSE	32768	/* War is peace. Verbosity is silence.
-				   MS_VERBOSE is deprecated. */
-#define MS_SILENT	32768
-#define MS_POSIXACL	(1<<16)	/* VFS does not apply the umask */
-#define MS_UNBINDABLE	(1<<17)	/* change to unbindable */
-#define MS_PRIVATE	(1<<18)	/* change to private */
-#define MS_SLAVE	(1<<19)	/* change to slave */
-#define MS_SHARED	(1<<20)	/* change to shared */
-#define MS_RELATIME	(1<<21)	/* Update atime relative to mtime/ctime. */
-#define MS_KERNMOUNT	(1<<22) /* this is a kern_mount call */
-#define MS_I_VERSION	(1<<23) /* Update inode I_version field */
-#define MS_STRICTATIME	(1<<24) /* Always perform atime updates */
-#define MS_LAZYTIME	(1<<25) /* Update the on-disk [acm]times lazily */
-
-/* These sb flags are internal to the kernel */
-#define MS_SUBMOUNT     (1<<26)
-#define MS_NOREMOTELOCK	(1<<27)
-#define MS_NOSEC	(1<<28)
-#define MS_BORN		(1<<29)
-#define MS_ACTIVE	(1<<30)
-#define MS_NOUSER	(1<<31)
-
-/*
- * Superblock flags that can be altered by MS_REMOUNT
- */
-#define MS_RMT_MASK	(MS_RDONLY|MS_SYNCHRONOUS|MS_MANDLOCK|MS_I_VERSION|\
-			 MS_LAZYTIME)
-
-/*
- * Old magic mount flag and mask
- */
-#define MS_MGC_VAL 0xC0ED0000
-#define MS_MGC_MSK 0xffff0000
-
 /*
  * Structure for FS_IOC_FSGETXATTR[A] and FS_IOC_FSSETXATTR.
  */
diff --git a/include/uapi/linux/mount.h b/include/uapi/linux/mount.h
new file mode 100644
index 000000000000..3f9ec42510b0
--- /dev/null
+++ b/include/uapi/linux/mount.h
@@ -0,0 +1,58 @@
+#ifndef _UAPI_LINUX_MOUNT_H
+#define _UAPI_LINUX_MOUNT_H
+
+/*
+ * These are the fs-independent mount-flags: up to 32 flags are supported
+ *
+ * Usage of these is restricted within the kernel to core mount(2) code and
+ * callers of sys_mount() only.  Filesystems should be using the SB_*
+ * equivalent instead.
+ */
+#define MS_RDONLY	 1	/* Mount read-only */
+#define MS_NOSUID	 2	/* Ignore suid and sgid bits */
+#define MS_NODEV	 4	/* Disallow access to device special files */
+#define MS_NOEXEC	 8	/* Disallow program execution */
+#define MS_SYNCHRONOUS	16	/* Writes are synced at once */
+#define MS_REMOUNT	32	/* Alter flags of a mounted FS */
+#define MS_MANDLOCK	64	/* Allow mandatory locks on an FS */
+#define MS_DIRSYNC	128	/* Directory modifications are synchronous */
+#define MS_NOATIME	1024	/* Do not update access times. */
+#define MS_NODIRATIME	2048	/* Do not update directory access times */
+#define MS_BIND		4096
+#define MS_MOVE		8192
+#define MS_REC		16384
+#define MS_VERBOSE	32768	/* War is peace. Verbosity is silence.
+				   MS_VERBOSE is deprecated. */
+#define MS_SILENT	32768
+#define MS_POSIXACL	(1<<16)	/* VFS does not apply the umask */
+#define MS_UNBINDABLE	(1<<17)	/* change to unbindable */
+#define MS_PRIVATE	(1<<18)	/* change to private */
+#define MS_SLAVE	(1<<19)	/* change to slave */
+#define MS_SHARED	(1<<20)	/* change to shared */
+#define MS_RELATIME	(1<<21)	/* Update atime relative to mtime/ctime. */
+#define MS_KERNMOUNT	(1<<22) /* this is a kern_mount call */
+#define MS_I_VERSION	(1<<23) /* Update inode I_version field */
+#define MS_STRICTATIME	(1<<24) /* Always perform atime updates */
+#define MS_LAZYTIME	(1<<25) /* Update the on-disk [acm]times lazily */
+
+/* These sb flags are internal to the kernel */
+#define MS_SUBMOUNT     (1<<26)
+#define MS_NOREMOTELOCK	(1<<27)
+#define MS_NOSEC	(1<<28)
+#define MS_BORN		(1<<29)
+#define MS_ACTIVE	(1<<30)
+#define MS_NOUSER	(1<<31)
+
+/*
+ * Superblock flags that can be altered by MS_REMOUNT
+ */
+#define MS_RMT_MASK	(MS_RDONLY|MS_SYNCHRONOUS|MS_MANDLOCK|MS_I_VERSION|\
+			 MS_LAZYTIME)
+
+/*
+ * Old magic mount flag and mask
+ */
+#define MS_MGC_VAL 0xC0ED0000
+#define MS_MGC_MSK 0xffff0000
+
+#endif /* _UAPI_LINUX_MOUNT_H */
diff --git a/init/do_mounts.c b/init/do_mounts.c
index 2c71dabe5626..ea6f21bb9440 100644
--- a/init/do_mounts.c
+++ b/init/do_mounts.c
@@ -32,6 +32,7 @@
 #include <linux/nfs_fs.h>
 #include <linux/nfs_fs_sb.h>
 #include <linux/nfs_mount.h>
+#include <uapi/linux/mount.h>
 
 #include "do_mounts.h"
 
diff --git a/init/do_mounts_initrd.c b/init/do_mounts_initrd.c
index 5a91aefa7305..65de0412f80f 100644
--- a/init/do_mounts_initrd.c
+++ b/init/do_mounts_initrd.c
@@ -18,6 +18,7 @@
 #include <linux/sched.h>
 #include <linux/freezer.h>
 #include <linux/kmod.h>
+#include <uapi/linux/mount.h>
 
 #include "do_mounts.h"
 
diff --git a/security/apparmor/lsm.c b/security/apparmor/lsm.c
index ce2b89e9ad94..9ebc9e9c3854 100644
--- a/security/apparmor/lsm.c
+++ b/security/apparmor/lsm.c
@@ -24,6 +24,7 @@
 #include <linux/audit.h>
 #include <linux/user_namespace.h>
 #include <net/sock.h>
+#include <uapi/linux/mount.h>
 
 #include "include/apparmor.h"
 #include "include/apparmorfs.h"
diff --git a/security/apparmor/mount.c b/security/apparmor/mount.c
index 6e8c7ac0b33d..45bb769d6cd7 100644
--- a/security/apparmor/mount.c
+++ b/security/apparmor/mount.c
@@ -15,6 +15,7 @@
 #include <linux/fs.h>
 #include <linux/mount.h>
 #include <linux/namei.h>
+#include <uapi/linux/mount.h>
 
 #include "include/apparmor.h"
 #include "include/audit.h"
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 4cafe6a19167..1f0316bf7e29 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -88,6 +88,7 @@
 #include <linux/msg.h>
 #include <linux/shm.h>
 #include <linux/bpf.h>
+#include <uapi/linux/mount.h>
 
 #include "avc.h"
 #include "objsec.h"
diff --git a/security/tomoyo/mount.c b/security/tomoyo/mount.c
index 807fd91dbb54..7dc7f59b7dde 100644
--- a/security/tomoyo/mount.c
+++ b/security/tomoyo/mount.c
@@ -6,6 +6,7 @@
  */
 
 #include <linux/slab.h>
+#include <uapi/linux/mount.h>
 #include "common.h"
 
 /* String table for special mount operations. */

