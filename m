Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35230 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751385AbbKTO4I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2015 09:56:08 -0500
Subject: [PATCH 08/12] fsinfo: Add a system call to make enhanced filesystem
 info available
From: David Howells <dhowells@redhat.com>
To: arnd@arndb.de
Cc: linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Date: Fri, 20 Nov 2015 14:56:01 +0000
Message-ID: <20151120145601.18930.22002.stgit@warthog.procyon.org.uk>
In-Reply-To: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a system call to make enhanced filesystem information available - this
is the counterpart to the addition of the enhanced stat syscall.  The extra
data includes information about the timestamps, available IOC flags, volume
identifiers and the domain or server name of a network filesystem.


===============
NEW SYSTEM CALL
===============

The new system call is:

	int ret = fsinfo(int dfd,
			 const char *filename,
			 unsigned int flags,
			 unsigned int request,
			 void *buffer);

The dfd, filename and flags parameters indicate the file to query.  There
is no equivalent of lstat() as that can be emulated with fsinfo() by
passing AT_SYMLINK_NOFOLLOW in flags.  There is also no equivalent of
fstat() as that can be emulated by passing a NULL filename to fsinfo() with
the fd of interest in dfd.  AT_NO_AUTOMOUNT can also be used to allow
automount points to be queried without triggering it.

AT_FORCE_ATTR_SYNC can be set in flags.  This will require a network
filesystem to synchronise its attributes with the server.

AT_NO_ATTR_SYNC can be set in flags.  This will suppress synchronisation
with the server in a network filesystem.  The resulting values should be
considered approximate.

request indicates what is desired.  Currently this only available request
value is 0.

buffer points to the destination for the main data.

At the moment, this will only work on x86_64 and i386 as it requires the system
call to be wired up.


========================================
REQUEST 0: FILESYSTEM INFORMATION RECORD
========================================

The following structures are defined in which to return the filesystem
information set:

	struct fsinfo {
		__u32	f_mask;
		__u32	f_fstype;
		__u64	f_dev;
		__u64	f_blocks;
		__u64	f_bfree;
		__u64	f_bavail;
		__u64	f_files;
		__u64	f_ffree;
		__u64	f_favail;
		__u32	f_bsize;
		__u16	f_frsize;
		__u16	f_namelen;
		__u64	f_flags;
		__u64	f_fsid;
		__u64	f_supported_ioc_flags;
		__s64	f_min_time;
		__s64	f_max_time;
		__u16	f_atime_gran_mantissa;
		__u16	f_btime_gran_mantissa;
		__u16	f_ctime_gran_mantissa;
		__u16	f_mtime_gran_mantissa;
		__s8	f_atime_gran_exponent;
		__s8	f_btime_gran_exponent;
		__s8	f_ctime_gran_exponent;
		__s8	f_mtime_gran_exponent;
		__u8	__spare6c[0x80 - 0x7c];
		__u8	__spare80[0xd0 - 0x80];
		char	f_fs_name[15 + 1];
		__u8	f_volume_id[16];
		__u8	f_volume_uuid[16];
		char	f_volume_name[255 + 1];
		char	f_domain_name[255 + 1];
		__u8	__spare300[0x400 - 0x300];
	};

where f_mask indicates the attributes that have been returned, f_fs_name is
the filesystem name as text, f_fstype is the filesystem type ID as per
linux/magic.h and f_supported_ioc_flags is the mask of flags in
st_ioc_flags that are supported.

f_?time_gran_* are time granularities in the form mant*10^exp (an exponent
of 0 would indicate seconds, -9 would indicate nanoseconds).  Note that
FAT, for example, has a different granularity for each time.

f_min_time and f_max_time give the range of the timestamps in seconds.  It
is assumed that all the timestamps in a filesystem have the same range, if
not the same resolution (ie. FAT).

f_blocks, f_bfree, f_bavail, f_files, f_ffree, f_favail, f_bsize, f_frsize,
f_namelen and f_flags are as for statfs.

There are five fields for volume identification:

 (1) f_fsid is the filesystem ID as per statfs::f_fsid.

 (2) f_volume_id is an arbitrary binary volume ID.

 (3) f_volume_uuid is the volume UUID

 (4) f_volume_name is a string holding the volume name

 (5) f_domain_name is a string holding the domain/cell/workgroup/server
     name.

All fields except f_mask are optional.  The fields are controlled by a
combination of the flags in st_mask (as returned by statx()) and the flags
in f_mask in the following manner:

	st_mask & STATX_ATIME		Got f_atime_gran_*
	st_mask & STATX_BTIME		Got f_btime_gran_*
	st_mask & STATX_CTIME		Got f_ctime_gran_*
	st_mask & STATX_MTIME		Got f_mtime_gran_*
	st_mask & STATX_?TIME		Got f_zero_time_offset
	st_mask & STATX_IOC_FLAGS	Got f_supported_ioc_flags
	f_mask & STATX_BLOCKS_INFO	Got f_blocks, f_bfree, f_bavail, f_bsize
	f_mask & STATX_FILES_INFO	Got f_files, f_ffree, f_favail
	f_mask & STATX_FSID		Got f_fsid
	f_mask & STATX_VOLUME_ID	Got f_volume_id
	f_mask & STATX_VOLUME_UUID	Got f_volume_uuid
	f_mask & STATX_VOLUME_NAME	Got f_volume_name
	f_mask & STATX_DOMAIN_NAME	Got f_domain_name

There is also spare expansion space in __spare*[].  The whole structure is
1024 bytes in size.


=======
TESTING
=======

A sample program is provided that can be used to test the fsinfo() system
call:

	./samples/statx/test-fsinfo.c

This will be built automatically with CONFIG_SAMPLES=y.  When run, it
should be passed the paths to the files you want to examine.

Here's some example output.

	[root@andromeda ~]# ./test-fsinfo /usr/
	fsinfo(/usr/) = 0
	mask  : 5f
	dev   : 08:02
	fs    : type=ef53 name=ext3
	ioc   : 0
	nameln: 255
	flags : 1020
	times : range=ffffffff80000000-7fffffff
	atime : gran=1s
	btime : gran=1s
	ctime : gran=1s
	mtime : gran=1s
	blocks: n=2505737 fr=308288 av=177258
	files : n=2621440 fr=2428582 av=2428582
	bsize : 4096
	frsize: 4096
	fsid  : 8bc3c470dfcc8abf
	uuid  : 2f07dbcf-6b6f-41fe-908d-17101bab8275

Signed-off-by: David Howells <dhowells@redhat.com>
---

 arch/x86/entry/syscalls/syscall_32.tbl |    1 
 arch/x86/entry/syscalls/syscall_64.tbl |    1 
 fs/statfs.c                            |  218 ++++++++++++++++++++++++++++++++
 include/linux/fs.h                     |    2 
 include/linux/syscalls.h               |    3 
 include/uapi/linux/stat.h              |   69 ++++++++++
 samples/statx/Makefile                 |    5 +
 samples/statx/test-fsinfo.c            |  179 ++++++++++++++++++++++++++
 8 files changed, 477 insertions(+), 1 deletion(-)
 create mode 100644 samples/statx/test-fsinfo.c

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index 6e570ee4241d..5faee9d28a21 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -383,3 +383,4 @@
 374	i386	userfaultfd		sys_userfaultfd
 375	i386	membarrier		sys_membarrier
 376	i386	statx			sys_statx
+377	i386	fsinfo			sys_fsinfo
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index cbfef23f8067..8b0958fdc86f 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -332,6 +332,7 @@
 323	common	userfaultfd		sys_userfaultfd
 324	common	membarrier		sys_membarrier
 325	common	statx			sys_statx
+326	common	fsinfo			sys_fsinfo
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/fs/statfs.c b/fs/statfs.c
index 083dc0ac9140..99604cb42e8d 100644
--- a/fs/statfs.c
+++ b/fs/statfs.c
@@ -239,3 +239,221 @@ SYSCALL_DEFINE2(ustat, unsigned, dev, struct ustat __user *, ubuf)
 
 	return copy_to_user(ubuf, &tmp, sizeof(struct ustat)) ? -EFAULT : 0;
 }
+
+/**
+ * vfs_get_fsinfo_from_statfs - Fill in some of fsinfo from ->statfs()
+ * @dentry: The filesystem to query
+ * @fsinfo: The filesystem information record to fill in
+ * @flags: One of AT_{NO|FORCE}_SYNC_ATTR or 0
+ *
+ * Fill in some of the filesystem information record from data retrieved via
+ * the statfs superblock method.  This is called if there is no ->fsinfo() op
+ * and may also be called by a filesystem's ->fsinfo() op.
+ */
+int vfs_get_fsinfo_from_statfs(struct dentry *dentry,
+			       struct fsinfo *fsinfo, unsigned flags)
+{
+	struct kstatfs buf;
+	int ret;
+
+	ret = statfs_by_dentry(dentry, &buf);
+	if (ret < 0)
+		return ret;
+
+	if (buf.f_blocks) {
+		fsinfo->f_mask |= FSINFO_BLOCKS_INFO;
+		fsinfo->f_blocks = buf.f_blocks;
+		fsinfo->f_bfree  = buf.f_bfree;
+		fsinfo->f_bavail = buf.f_bavail;
+	}
+
+	if (buf.f_files) {
+		fsinfo->f_mask |= FSINFO_FILES_INFO;
+		fsinfo->f_files  = buf.f_files;
+		fsinfo->f_ffree  = buf.f_ffree;
+		fsinfo->f_favail = buf.f_ffree;
+	}
+
+	fsinfo->f_namelen = buf.f_namelen;
+	if (buf.f_bsize > 0) {
+		fsinfo->f_mask |= FSINFO_BSIZE;
+		fsinfo->f_bsize	= buf.f_bsize;
+	}
+	if (buf.f_frsize > 0) {
+		fsinfo->f_frsize = buf.f_frsize;
+		fsinfo->f_mask |= FSINFO_FRSIZE;
+	} else if (fsinfo->f_mask & FSINFO_BSIZE) {
+		fsinfo->f_frsize = fsinfo->f_bsize;
+	}
+
+	if (dentry->d_sb->s_op->statfs != simple_statfs) {
+		memcpy(&fsinfo->f_fsid, &buf.f_fsid, sizeof(fsinfo->f_fsid));
+		fsinfo->f_mask |= FSINFO_FSID;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(vfs_get_fsinfo_from_statfs);
+
+/*
+ * Preset bits of the data to be returned with defaults.
+ */
+static void vfs_fsinfo_preset(struct dentry *dentry, struct fsinfo *fsinfo)
+{
+	struct super_block *sb = dentry->d_sb;
+	/* If unset, assume 1s granularity */
+	uint16_t mantissa = 1;
+	uint8_t exponent = 0;
+	u32 x;
+
+	fsinfo->f_fstype = sb->s_magic;
+	strcpy(fsinfo->f_fs_name, sb->s_type->name);
+
+	fsinfo->f_min_time = S64_MIN;
+	fsinfo->f_max_time = S64_MAX;
+	if (sb->s_time_gran < 1000000000) {
+		if (sb->s_time_gran < 1000)
+			exponent = -9;
+		else if (sb->s_time_gran < 1000000)
+			exponent = -6;
+		else
+			exponent = -3;
+	}
+#define set_gran(x)						\
+	do {							\
+		fsinfo->f_##x##_mantissa = mantissa;		\
+		fsinfo->f_##x##_exponent = exponent;		\
+	} while (0)
+	set_gran(atime_gran);
+	set_gran(btime_gran);
+	set_gran(ctime_gran);
+	set_gran(mtime_gran);
+
+	x  = ((u32 *)&fsinfo->f_volume_uuid)[0] = ((u32 *)&sb->s_uuid)[0];
+	x |= ((u32 *)&fsinfo->f_volume_uuid)[1] = ((u32 *)&sb->s_uuid)[1];
+	x |= ((u32 *)&fsinfo->f_volume_uuid)[2] = ((u32 *)&sb->s_uuid)[2];
+	x |= ((u32 *)&fsinfo->f_volume_uuid)[3] = ((u32 *)&sb->s_uuid)[3];
+	if (x)
+		fsinfo->f_mask |= FSINFO_VOLUME_UUID;
+}
+
+/*
+ * Retrieve the filesystem info.  We make some stuff up if the operation is not
+ * supported.
+ */
+static int vfs_fsinfo(struct path *path, struct fsinfo *fsinfo, unsigned flags)
+{
+	struct dentry *dentry = path->dentry;
+	int (*get_fsinfo)(struct dentry *, struct fsinfo *, unsigned) =
+		dentry->d_sb->s_op->get_fsinfo;
+	int ret;
+
+	if (!get_fsinfo) {
+		if (!dentry->d_sb->s_op->statfs)
+			return -ENOSYS;
+		get_fsinfo = vfs_get_fsinfo_from_statfs;
+	}
+
+	ret = security_sb_statfs(dentry);
+	if (ret)
+		return ret;
+
+	vfs_fsinfo_preset(dentry, fsinfo);
+	ret = get_fsinfo(dentry, fsinfo, flags);
+	if (ret < 0)
+		return ret;
+
+	fsinfo->f_dev_major = MAJOR(dentry->d_sb->s_dev);
+	fsinfo->f_dev_minor = MINOR(dentry->d_sb->s_dev);
+	fsinfo->f_flags = calculate_f_flags(path->mnt);
+	return 0;
+}
+
+static int vfs_fsinfo_path(int dfd, const char __user *filename, int flags,
+			   struct fsinfo *fsinfo)
+{
+	struct path path;
+	unsigned lookup_flags = LOOKUP_FOLLOW | LOOKUP_AUTOMOUNT;
+	int ret = -EINVAL;
+
+	if ((flags & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
+		       AT_EMPTY_PATH | KSTAT_QUERY_FLAGS)) != 0)
+		return -EINVAL;
+
+	if (flags & AT_SYMLINK_NOFOLLOW)
+		lookup_flags &= ~LOOKUP_FOLLOW;
+	if (flags & AT_NO_AUTOMOUNT)
+		lookup_flags &= ~LOOKUP_AUTOMOUNT;
+	if (flags & AT_EMPTY_PATH)
+		lookup_flags |= LOOKUP_EMPTY;
+
+retry:
+	ret = user_path_at(dfd, filename, lookup_flags, &path);
+	if (ret)
+		goto out;
+
+	ret = vfs_fsinfo(&path, fsinfo, flags);
+	path_put(&path);
+	if (retry_estale(ret, lookup_flags)) {
+		lookup_flags |= LOOKUP_REVAL;
+		goto retry;
+	}
+out:
+	return ret;
+}
+
+static int vfs_fsinfo_fd(unsigned int fd, unsigned flags, struct fsinfo *fsinfo)
+{
+	struct fd f = fdget_raw(fd);
+	int ret = -EBADF;
+
+	if (f.file) {
+		ret = vfs_fsinfo(&f.file->f_path, fsinfo, flags);
+		fdput(f);
+	}
+	return ret;
+}
+
+/**
+ * sys_fsinfo - System call to get enhanced filesystem information
+ * @dfd: Base directory to pathwalk from *or* fd to stat.
+ * @filename: File to stat *or* NULL.
+ * @flags: AT_* flags to control pathwalk.
+ * @request: Request being made.
+ * @buffer: Result buffer.
+ *
+ * Note that if filename is NULL, then dfd is used to indicate the file of
+ * interest.
+ *
+ * Currently, the only permitted request value is 0.
+ */
+SYSCALL_DEFINE5(fsinfo,
+		int, dfd, const char __user *, filename, unsigned, flags,
+		unsigned, request, void __user *, buffer)
+{
+	struct fsinfo *fsinfo;
+	int ret;
+
+	if (request != 0)
+		return -EINVAL;
+	if ((flags & AT_FORCE_ATTR_SYNC) && (flags & AT_NO_ATTR_SYNC))
+		return -EINVAL;
+	if (!access_ok(VERIFY_WRITE, buffer, sizeof(*buffer)))
+		return -EFAULT;
+
+	fsinfo = kzalloc(sizeof(struct fsinfo), GFP_KERNEL);
+	if (!fsinfo)
+		return -ENOMEM;
+
+	if (filename)
+		ret = vfs_fsinfo_path(dfd, filename, flags, fsinfo);
+	else
+		ret = vfs_fsinfo_fd(dfd, flags, fsinfo);
+	if (ret)
+		goto error;
+
+	if (copy_to_user(buffer, fsinfo, sizeof(struct fsinfo)))
+		ret = -EFAULT;
+error:
+	kfree(fsinfo);
+	return ret;
+}
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 8fb641ac1027..a7b629e99743 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1711,6 +1711,7 @@ struct super_operations {
 	int (*thaw_super) (struct super_block *);
 	int (*unfreeze_fs) (struct super_block *);
 	int (*statfs) (struct dentry *, struct kstatfs *);
+	int (*get_fsinfo) (struct dentry *, struct fsinfo *, unsigned);
 	int (*remount_fs) (struct super_block *, int *, char *);
 	void (*umount_begin) (struct super_block *);
 
@@ -2027,6 +2028,7 @@ extern int vfs_statfs(struct path *, struct kstatfs *);
 extern int user_statfs(const char __user *, struct kstatfs *);
 extern int fd_statfs(int, struct kstatfs *);
 extern int vfs_ustat(dev_t, struct kstatfs *);
+extern int vfs_get_fsinfo_from_statfs(struct dentry *, struct fsinfo *, unsigned);
 extern int freeze_super(struct super_block *super);
 extern int thaw_super(struct super_block *super);
 extern bool our_mnt(struct vfsmount *mnt);
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 09eb280f6bf6..d4fd7e4682f5 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -49,6 +49,7 @@ struct stat64;
 struct statfs;
 struct statfs64;
 struct statx;
+struct fsinfo;
 struct __sysctl_args;
 struct sysinfo;
 struct timespec;
@@ -889,5 +890,7 @@ asmlinkage long sys_execveat(int dfd, const char __user *filename,
 asmlinkage long sys_membarrier(int cmd, int flags);
 asmlinkage long sys_statx(int dfd, const char __user *path, unsigned flags,
 			  unsigned mask, struct statx __user *buffer);
+asmlinkage long sys_fsinfo(int dfd, const char __user *path, unsigned flags,
+			   unsigned request, void __user *buffer);
 
 #endif
diff --git a/include/uapi/linux/stat.h b/include/uapi/linux/stat.h
index 41a5412e7ad5..d0ce8fb7f848 100644
--- a/include/uapi/linux/stat.h
+++ b/include/uapi/linux/stat.h
@@ -158,4 +158,73 @@ struct statx {
 #define STATX_INFO_NONSYSTEM_OWNERSHIP	0x00000100U /* File has non-system ownership details */
 #define STATX_INFO_REPARSE_POINT	0x00000200U /* File is reparse point (NTFS/CIFS) */
 
+/*
+ * Information struct for fsinfo() request 0.
+ */
+struct fsinfo {
+	/* 0x00 - General info */
+	__u32	f_mask;		/* What optional fields are filled in */
+	__u32	f_fstype;	/* Filesystem type from linux/magic.h [uncond] */
+	__u32	f_dev_major;	/* As st_dev_* from struct statx [uncond] */
+	__u32	f_dev_minor;
+
+	/* 0x10 - statfs information */
+	__u64	f_blocks;	/* Total number of blocks in fs */
+	__u64	f_bfree;	/* Total number of free blocks */
+	__u64	f_bavail;	/* Number of free blocks available to ordinary user */
+	__u64	f_files;	/* Total number of file nodes in fs */
+	__u64	f_ffree;	/* Number of free file nodes */
+	__u64	f_favail;	/* Number of free file nodes available to ordinary user */
+	/* 0x40 */
+	__u32	f_bsize;	/* Optimal block size */
+	__u16	f_frsize;	/* Fragment size */
+	__u16	f_namelen;	/* Maximum name length [uncond] */
+	__u64	f_flags;	/* Filesystem mount flags */
+	/* 0x50 */
+	__u64	f_fsid;		/* Short 64-bit Filesystem ID (as statfs) */
+	__u64	f_supported_ioc_flags; /* supported FS_IOC_GETFLAGS flags  */
+
+	/* 0x60 - File timestamp info */
+	__s64	f_min_time;	/* Minimum timestamp value in seconds */
+	__s64	f_max_time;	/* Maximum timestamp value in seconds */
+	/* 0x70 */
+	__u16	f_atime_gran_mantissa;	/* granularity(secs) = mant * 10^exp */
+	__u16	f_btime_gran_mantissa;
+	__u16	f_ctime_gran_mantissa;
+	__u16	f_mtime_gran_mantissa;
+	__s8	f_atime_gran_exponent;
+	__s8	f_btime_gran_exponent;
+	__s8	f_ctime_gran_exponent;
+	__s8	f_mtime_gran_exponent;
+	__u8	__spare6c[0x80 - 0x7c];
+
+	/* 0x80 */
+	__u8	__spare80[0xd0 - 0x80];
+	/* 0xd0 */
+	char	f_fs_name[15 + 1]; /* Filesystem name [uncond] */
+	/* 0xe0 */
+	__u8	f_volume_id[16]; /* Volume/fs identifier */
+	__u8	f_volume_uuid[16]; /* Volume/fs UUID */
+	/* 0x100 */
+	char	f_volume_name[255 + 1]; /* Volume name */
+	/* 0x200 */
+	char	f_domain_name[255 + 1]; /* Domain/cell/workgroup name */
+	/* 0x300 */
+	__u8	__spare300[0x400 - 0x300];
+	/* 0x400 */
+};
+
+/*
+ * Flags to be found in f_mask.
+ */
+#define FSINFO_BLOCKS_INFO	0x00000001	/* Got f_blocks, f_bfree, f_bavail */
+#define FSINFO_FILES_INFO	0x00000002	/* Got f_files, f_ffree, f_favail */
+#define FSINFO_BSIZE		0x00000004	/* Got f_bsize */
+#define FSINFO_FRSIZE		0x00000008	/* Got f_frsize */
+#define FSINFO_FSID		0x00000010	/* Got f_fsid */
+#define FSINFO_VOLUME_ID	0x00000020	/* Got f_volume_id */
+#define FSINFO_VOLUME_UUID	0x00000040	/* Got f_volume_uuid */
+#define FSINFO_VOLUME_NAME	0x00000080	/* Got f_volume_name */
+#define FSINFO_DOMAIN_NAME	0x00000100	/* Got f_domain_name */
+
 #endif /* _UAPI_LINUX_STAT_H */
diff --git a/samples/statx/Makefile b/samples/statx/Makefile
index 6765dabc4c8d..bd8c3c34206d 100644
--- a/samples/statx/Makefile
+++ b/samples/statx/Makefile
@@ -2,9 +2,12 @@
 obj- := dummy.o
 
 # List of programs to build
-hostprogs-y := test-statx
+hostprogs-y := test-statx test-fsinfo
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
 
 HOSTCFLAGS_test-statx.o += -I$(objtree)/usr/include
+
+HOSTCFLAGS_test-fsinfo.o += -I$(objtree)/usr/include
+HOSTLOADLIBES_test-fsinfo += -lm
diff --git a/samples/statx/test-fsinfo.c b/samples/statx/test-fsinfo.c
new file mode 100644
index 000000000000..7724390b0aa4
--- /dev/null
+++ b/samples/statx/test-fsinfo.c
@@ -0,0 +1,179 @@
+/* Test the fsinfo() system call
+ *
+ * Copyright (C) 2015 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#define _GNU_SOURCE
+#define _ATFILE_SOURCE
+#include <stdio.h>
+#include <stdlib.h>
+#include <stdint.h>
+#include <string.h>
+#include <unistd.h>
+#include <ctype.h>
+#include <errno.h>
+#include <time.h>
+#include <math.h>
+#include <sys/syscall.h>
+#include <linux/stat.h>
+#include <linux/fcntl.h>
+#include <sys/stat.h>
+
+#define __NR_fsinfo 326
+
+static __attribute__((unused))
+ssize_t fsinfo(int dfd, const char *filename, unsigned flags,
+	       unsigned request, void *buffer)
+{
+	return syscall(__NR_fsinfo, dfd, filename, flags, request, buffer);
+}
+
+static void dump_fsinfo(struct fsinfo *f)
+{
+	printf("mask  : %x\n", f->f_mask);
+	printf("dev   : %02x:%02x\n", f->f_dev_major, f->f_dev_minor);
+	printf("fs    : type=%x name=%s\n", f->f_fstype, f->f_fs_name);
+	printf("ioc   : %llx\n", (unsigned long long)f->f_supported_ioc_flags);
+	printf("nameln: %u\n", f->f_namelen);
+	printf("flags : %llx\n", (unsigned long long)f->f_flags);
+	printf("times : range=%llx-%llx\n",
+	       (unsigned long long)f->f_min_time,
+	       (unsigned long long)f->f_max_time);
+
+#define print_time(G) \
+	printf(#G"time : gran=%gs\n",			\
+	       (f->f_##G##time_gran_mantissa *		\
+		pow(10., f->f_##G##time_gran_exponent)))
+	print_time(a);
+	print_time(b);
+	print_time(c);
+	print_time(m);
+
+
+	if (f->f_mask & FSINFO_BLOCKS_INFO)
+		printf("blocks: n=%llu fr=%llu av=%llu\n",
+		       (unsigned long long)f->f_blocks,
+		       (unsigned long long)f->f_bfree,
+		       (unsigned long long)f->f_bavail);
+
+	if (f->f_mask & FSINFO_FILES_INFO)
+		printf("files : n=%llu fr=%llu av=%llu\n",
+		       (unsigned long long)f->f_files,
+		       (unsigned long long)f->f_ffree,
+		       (unsigned long long)f->f_favail);
+
+	if (f->f_mask & FSINFO_BSIZE)
+		printf("bsize : %u\n", f->f_bsize);
+
+	if (f->f_mask & FSINFO_FRSIZE)
+		printf("frsize: %u\n", f->f_frsize);
+
+	if (f->f_mask & FSINFO_FSID)
+		printf("fsid  : %llx\n", (unsigned long long)f->f_fsid);
+
+	if (f->f_mask & FSINFO_VOLUME_ID) {
+		int printable = 1, loop;
+		printf("volid : ");
+		for (loop = 0; loop < sizeof(f->f_volume_id); loop++)
+			if (!isprint(f->f_volume_id[loop]))
+				printable = 0;
+		if (printable) {
+			printf("'%.*s'", 16, f->f_volume_id);
+		} else {
+			for (loop = 0; loop < sizeof(f->f_volume_id); loop++) {
+				if (loop % 4 == 0 && loop != 0)
+					printf(" ");
+				printf("%02x", f->f_volume_id[loop]);
+			}
+		}
+		printf("\n");
+	}
+
+	if (f->f_mask & FSINFO_VOLUME_UUID)
+		printf("uuid  : "
+		       "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x"
+		       "-%02x%02x%02x%02x%02x%02x\n",
+		       f->f_volume_uuid[ 0], f->f_volume_uuid[ 1],
+		       f->f_volume_uuid[ 2], f->f_volume_uuid[ 3],
+		       f->f_volume_uuid[ 4], f->f_volume_uuid[ 5],
+		       f->f_volume_uuid[ 6], f->f_volume_uuid[ 7],
+		       f->f_volume_uuid[ 8], f->f_volume_uuid[ 9],
+		       f->f_volume_uuid[10], f->f_volume_uuid[11],
+		       f->f_volume_uuid[12], f->f_volume_uuid[13],
+		       f->f_volume_uuid[14], f->f_volume_uuid[15]);
+	if (f->f_mask & FSINFO_VOLUME_NAME)
+		printf("volume: '%s'\n", f->f_volume_name);
+	if (f->f_mask & FSINFO_DOMAIN_NAME)
+		printf("domain: '%s'\n", f->f_domain_name);
+}
+
+static void dump_hex(unsigned long long *data, int from, int to)
+{
+	unsigned offset, print_offset = 1, col = 0;
+
+	from /= 8;
+	to = (to + 7) / 8;
+
+	for (offset = from; offset < to; offset++) {
+		if (print_offset) {
+			printf("%04x: ", offset * 8);
+			print_offset = 0;
+		}
+		printf("%016llx", data[offset]);
+		col++;
+		if ((col & 3) == 0) {
+			printf("\n");
+			print_offset = 1;
+		} else {
+			printf(" ");
+		}
+	}
+
+	if (!print_offset)
+		printf("\n");
+}
+
+int main(int argc, char **argv)
+{
+	struct fsinfo f;
+	int ret, raw = 0, atflag = AT_SYMLINK_NOFOLLOW;
+
+	for (argv++; *argv; argv++) {
+		if (strcmp(*argv, "-F") == 0) {
+			atflag |= AT_FORCE_ATTR_SYNC;
+			continue;
+		}
+		if (strcmp(*argv, "-L") == 0) {
+			atflag &= ~AT_SYMLINK_NOFOLLOW;
+			continue;
+		}
+		if (strcmp(*argv, "-A") == 0) {
+			atflag |= AT_NO_AUTOMOUNT;
+			continue;
+		}
+		if (strcmp(*argv, "-R") == 0) {
+			raw = 1;
+			continue;
+		}
+
+		memset(&f, 0xbd, sizeof(f));
+		ret = fsinfo(AT_FDCWD, *argv, atflag, 0, &f);
+		printf("fsinfo(%s) = %d\n", *argv, ret);
+		if (ret < 0) {
+			perror(*argv);
+			exit(1);
+		}
+
+		if (raw)
+			dump_hex((unsigned long long *)&f, 0, sizeof(f));
+
+		dump_fsinfo(&f);
+	}
+	return 0;
+}

