From: David Howells <dhowells@redhat.com>
Subject: [PATCH 02/18] xstat: Add a pair of system calls to make extended file
	stats available [ver #6]
Date: Thu, 15 Jul 2010 03:17:12 +0100
Message-ID: <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
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

Add a pair of system calls to make extended file stats available, including
file creation time, inode version and data version where available through the
underlying filesystem.

[This depends on the previously posted pair of patches to (a) constify a number
 of syscall string and buffer arguments and (b) rearrange AFS's use of
 i_version and i_generation].

This has a number of uses:

 (1) Creation time: The SMB protocol carries the creation time, which could be
     exported by Samba, which will in turn help CIFS make use of FS-Cache as
     that can be used for coherency data.

     This is also specified in NFSv4 as a recommended attribute and could be
     exported by NFSD [Steve French].

 (2) Lightweight stat: Ask for just those details of interest, and allow a
     netfs (such as NFS) to approximate anything not of interest, possibly
     without going to the server [Trond Myklebust, Ulrich Drepper].

 (3) Heavyweight stat: Force a netfs to go to the server, even if it thinks its
     cached attributes are up to date [Trond Myklebust].

 (4) Inode generation number: Useful for FUSE and userspace NFS servers [Bernd
     Schubert].

 (5) Data version number: Could be used by userspace NFS servers [Aneesh Kumar].

     Can also be used to modify fill_post_wcc() in NFSD which retrieves
     i_version directly, but has just called vfs_getattr().  It could get it
     from the kstat struct if it used vfs_xgetattr() instead.

 (6) BSD stat compatibility: Including more fields from the BSD stat such as
     creation time (st_btime) and inode generation number (st_gen) [Jeremy
     Allison, Bernd Schubert].

 (7) Extra coherency data may be useful in making backups [Andreas Dilger].

 (8) Allow the filesystem to indicate what it can/cannot provide: A filesystem
     can now say it doesn't support a standard stat feature if that isn't
     available.

 (9) Make the fields a consistent size on all arches, and make them large.

(10) Can be extended by using more request flags and tagging further data after
     the end of the standard return data.  Such things as the following could
     be returned:

	- BSD st_flags or FS_IOC_GETFLAGS.
	- Volume ID / Remote Device ID [Steve French].
	- Time granularity (NFSv4 time_delta) [Steve French].
	- Mask of features available on file (eg: ACLs, seclabel) [Brad Boyer,
	  Michael Kerrisk].

This was initially proposed as a set of xattrs, but the general preferance is
for an extended stat structure.


The following structures are defined for the use of these new system calls:

	struct xstat_parameters {
		unsigned long long	request_mask;
	};

	struct xstat_dev {
		unsigned int		major, minor;
	};

	struct xstat_time {
		unsigned long long	tv_sec, tv_nsec;
	};

	struct xstat {
		unsigned long long	st_result_mask;
		unsigned int		st_mode;
		unsigned int		st_nlink;
		unsigned int		st_uid;
		unsigned int		st_gid;
		struct xstat_dev	st_rdev;
		struct xstat_dev	st_dev;
		struct xstat_time	st_atime;
		struct xstat_time	st_mtime;
		struct xstat_time	st_ctime;
		struct xstat_time	st_btime;
		unsigned long long	st_ino;
		unsigned long long	st_size;
		unsigned long long	st_blksize;
		unsigned long long	st_blocks;
		unsigned long long	st_gen;
		unsigned long long	st_data_version;
		unsigned long long	st_inode_flags;
		unsigned long long	st_extra_results[0];
	};

where st_btime is the file creation time, st_gen is the inode generation
(i_generation), st_data_version is the data version number (i_version),
st_inode_flags is the flags from FS_IOC_GETFLAGS plus some extras,
request_mask and st_result_mask are bitmasks of data desired/provided and
st_extra_results[] is where as-yet undefined fields are appended.

The defined bits in request_mask and st_result_mask are:

	XSTAT_REQUEST_MODE		Want/got st_mode
	XSTAT_REQUEST_NLINK		Want/got st_nlink
	XSTAT_REQUEST_UID		Want/got st_uid
	XSTAT_REQUEST_GID		Want/got st_gid
	XSTAT_REQUEST_RDEV		Want/got st_rdev
	XSTAT_REQUEST_ATIME		Want/got st_atime
	XSTAT_REQUEST_MTIME		Want/got st_mtime
	XSTAT_REQUEST_CTIME		Want/got st_ctime
	XSTAT_REQUEST_INO		Want/got st_ino
	XSTAT_REQUEST_SIZE		Want/got st_size
	XSTAT_REQUEST_BLOCKS		Want/got st_blocks
	XSTAT_REQUEST__BASIC_STATS	The stuff in the normal stat struct
	XSTAT_REQUEST_BTIME		Want/got st_btime
	XSTAT_REQUEST_GEN		Want/got st_gen
	XSTAT_REQUEST_DATA_VERSION	Want/got st_data_version
	XSTAT_REQUEST_INODE_FLAGS	Want/got st_inode_flags
	XSTAT_REQUEST__EXTENDED_STATS	The stuff in the xstat struct
	XSTAT_REQUEST__ALL_STATS	The defined set of requestables

The defined bits in st_inode_flags are the usual FS_xxx_FL flags in the LSW,
plus some extra flags in the MSW:

	FS_SPECIAL_FL		Special kernel file, such as found in procfs
	FS_AUTOMOUNT_FL		Specific automount point
	FS_AUTOMOUNT_ANY_FL	Free-form automount directory
	FS_REMOTE_FL		File is remote
	FS_ENCRYPTED_FL		File is encrypted
	FS_SYSTEM_FL		File is marked system (DOS/NTFS/CIFS)
	FS_TEMPORARY_FL		File is temporary (NTFS/CIFS)
	FS_OFFLINE_FL		File is offline (CIFS)

Note that Ext4 returns flags outside of FS_FL_USER_VISIBLE in response to
FS_IOC_GETFLAGS.  Should FS_FL_USER_VISIBLE be extended to cover them?  Or
should the extra flags be suppressed?

The system calls are:

	ssize_t ret = xstat(int dfd,
			    const char *filename,
			    unsigned flags,
			    const struct xstat_parameters *params,
			    struct xstat *buffer,
			    size_t buflen);

	ssize_t ret = fxstat(unsigned fd,
			     unsigned flags,
			     const struct xstat_parameters *params,
			     struct xstat *buffer,
			     size_t buflen);


The dfd, filename, flags and fd parameters indicate the file to query.  There
is no equivalent of lstat() as that can be emulated with xstat() by passing
AT_SYMLINK_NOFOLLOW in flags.

AT_FORCE_ATTR_SYNC can also be set in flags.  This will require a network
filesystem to synchronise its attributes with the server.

When the system call is executed, the request_mask bitmask is read from the
parameter block to work out what the user is requesting.  If params is NULL,
then request_mask will be assumed to be XSTAT_REQUEST__BASIC_STATS.

The request_mask should be set by the caller to specify extra results that the
caller may desire.  These come in a number of classes:

 (0) dev, blksize.

     These are local data and are always available.

 (1) mode, nlinks, uid, gid, [amc]time, ino, size, blocks.

     These will be returned whether the caller asks for them or not.  The
     corresponding bits in result_mask will be set to indicate their presence.

     If the caller didn't ask for them, then they may be approximated.  For
     example, NFS won't waste any time updating them from the server, unless as
     a byproduct of updating something requested.

 (2) rdev.

     As for class (1), but this won't be returned if the file is not a blockdev
     or chardev.  The bit will be cleared if the value is not returned.

 (3) File creation time, inode generation and data version.

     These will be returned if available whether the caller asked for them or
     not.  The corresponding bits in result_mask will be set or cleared as
     appropriate to indicate their presence.

     If the caller didn't ask for them, then they may be approximated.  For
     example, NFS won't waste any time updating them from the server, unless
     as a byproduct of updating something requested.

 (4) Inode flags.

     Some of the extra flags (in the MSW) may be returned anyway, and if so,
     XSTAT_REQUEST_INODE_FLAGS will be set to indicate it.  A base set of
     flags is stored in a filesystem's file_system_type struct and is loaded
     into inode_flags by generic_fileattr() for further addition by the
     filesystem.

 (5) Extra results.

     These will only be returned if the caller asked for them by setting their
     bits in request_mask.  They will be placed in the buffer after the xstat
     struct in ascending result_mask bit order.  Any bit set in request_mask
     mask will be left set in result_mask if the result is available and
     cleared otherwise.

     The pointer into the results list will be rounded up to the nearest 8-byte
     boundary after each result is written in.  The size of each extra result
     is specific to the definition for that result.

     No extra results are currently defined.

If the buffer is insufficiently big, the syscall returns the amount of space it
will need to write the complete result set and returns a partial result in the
buffer.

At the moment, this will only work on x86_64 as it requires system calls to be
wired up.


=======
TESTING
=======

The following test program can be used to test the xstat system call:

	/* Test the xstat() system call
	 *
	 * Copyright (C) 2010 Red Hat, Inc. All Rights Reserved.
	 * Written by David Howells (dhowells@redhat.com)
	 *
	 * This program is free software; you can redistribute it and/or
	 * modify it under the terms of the GNU General Public Licence
	 * as published by the Free Software Foundation; either version
	 * 2 of the Licence, or (at your option) any later version.
	 */

	#define _GNU_SOURCE
	#define _ATFILE_SOURCE
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <unistd.h>
	#include <fcntl.h>
	#include <time.h>
	#include <sys/syscall.h>
	#include <sys/stat.h>
	#include <sys/types.h>

	#define AT_FORCE_ATTR_SYNC	0x800
	#define AT_NO_AUTOMOUNT		0x1000

	struct xstat_parameters {
		unsigned long long	request_mask;
	#define XSTAT_REQUEST_MODE		0x00000001ULL
	#define XSTAT_REQUEST_NLINK		0x00000002ULL
	#define XSTAT_REQUEST_UID		0x00000004ULL
	#define XSTAT_REQUEST_GID		0x00000008ULL
	#define XSTAT_REQUEST_RDEV		0x00000010ULL
	#define XSTAT_REQUEST_ATIME		0x00000020ULL
	#define XSTAT_REQUEST_MTIME		0x00000040ULL
	#define XSTAT_REQUEST_CTIME		0x00000080ULL
	#define XSTAT_REQUEST_INO		0x00000100ULL
	#define XSTAT_REQUEST_SIZE		0x00000200ULL
	#define XSTAT_REQUEST_BLOCKS		0x00000400ULL
	#define XSTAT_REQUEST__BASIC_STATS	0x000007ffULL
	#define XSTAT_REQUEST_BTIME		0x00000800ULL
	#define XSTAT_REQUEST_GEN		0x00001000ULL
	#define XSTAT_REQUEST_DATA_VERSION	0x00002000ULL
	#define XSTAT_REQUEST_INODE_FLAGS	0x00004000ULL
	#define XSTAT_REQUEST__EXTENDED_STATS	0x00007fffULL
	#define XSTAT_REQUEST__ALL_STATS	0x00007fffULL
	#define XSTAT_REQUEST__EXTRA_STATS	(XSTAT_REQUEST__ALL_STATS & ~XSTAT_REQUEST__EXTENDED_STATS)
	};

	struct xstat_dev {
		unsigned int	major;
		unsigned int	minor;
	};

	struct xstat_time {
		unsigned long long	tv_sec;
		unsigned long long	tv_nsec;
	};

	struct xstat {
		unsigned long long	st_result_mask;
		unsigned int		st_mode;
		unsigned int		st_nlink;
		unsigned int		st_uid;
		unsigned int		st_gid;
		struct xstat_dev	st_rdev;
		struct xstat_dev	st_dev;
		struct xstat_time	st_atim;
		struct xstat_time	st_mtim;
		struct xstat_time	st_ctim;
		struct xstat_time	st_btim;
		unsigned long long	st_ino;
		unsigned long long	st_size;
		unsigned long long	st_blksize;
		unsigned long long	st_blocks;
		unsigned long long	st_gen;
		unsigned long long	st_data_version;
		unsigned long long	st_inode_flags;
		unsigned long long	st_extra_results[0];
	};

	#define FS__STANDARD_FL		0x00000000ffffffffULL
	#define FS_SPECIAL_FL		0x0000000100000000ULL
	#define FS_AUTOMOUNT_FL		0x0000000200000000ULL
	#define FS_AUTOMOUNT_ANY_FL	0x0000000400000000ULL
	#define FS_REMOTE_FL		0x0000000800000000ULL
	#define FS_ENCRYPTED_FL		0x0000001000000000ULL
	#define FS_SYSTEM_FL		0x0000002000000000ULL
	#define FS_TEMPORARY_FL		0x0000004000000000ULL
	#define FS_OFFLINE_FL		0x0000008000000000ULL

	#define __NR_xstat				300
	#define __NR_fxstat				301

	static __attribute__((unused))
	ssize_t xstat(int dfd, const char *filename, unsigned flags,
		      struct xstat_parameters *params,
		      struct xstat *buffer, size_t bufsize)
	{
		return syscall(__NR_xstat, dfd, filename, flags,
			       params, buffer, bufsize);
	}

	static __attribute__((unused))
	ssize_t fxstat(int fd, unsigned flags,
		       struct xstat_parameters *params,
		       struct xstat *buffer, size_t bufsize)
	{
		return syscall(__NR_fxstat, fd, flags,
			       params, buffer, bufsize);
	}

	static void print_time(const char *field, const struct xstat_time *xstm)
	{
		struct tm tm;
		time_t tim;
		char buffer[100];
		int len;

		tim = xstm->tv_sec;
		if (!localtime_r(&tim, &tm)) {
			perror("localtime_r");
			exit(1);
		}
		len = strftime(buffer, 100, "%F %T", &tm);
		if (len == 0) {
			perror("strftime");
			exit(1);
		}
		printf("%s", field);
		fwrite(buffer, 1, len, stdout);
		printf(".%09llu", xstm->tv_nsec);
		len = strftime(buffer, 100, "%z", &tm);
		if (len == 0) {
			perror("strftime2");
			exit(1);
		}
		fwrite(buffer, 1, len, stdout);
		printf("\n");
	}

	static void dump_xstat(struct xstat *xst)
	{
		char buffer[256], ft;

		printf("results=%llx\n", xst->st_result_mask);

		printf(" ");
		if (xst->st_result_mask & XSTAT_REQUEST_SIZE)
			printf(" Size: %-15llu", xst->st_size);
		if (xst->st_result_mask & XSTAT_REQUEST_BLOCKS)
			printf(" Blocks: %-10llu", xst->st_blocks);
		printf(" IO Block: %-6llu ", xst->st_blksize);
		if (xst->st_result_mask & XSTAT_REQUEST_MODE) {
			switch (xst->st_mode & S_IFMT) {
			case S_IFIFO:	printf(" FIFO\n");			ft = 'p'; break;
			case S_IFCHR:	printf(" character special file\n");	ft = 'c'; break;
			case S_IFDIR:	printf(" directory\n");			ft = 'd'; break;
			case S_IFBLK:	printf(" block special file\n");	ft = 'b'; break;
			case S_IFREG:	printf(" regular file\n");		ft = '-'; break;
			case S_IFLNK:	printf(" symbolic link\n");		ft = 'l'; break;
			case S_IFSOCK:	printf(" socket\n");			ft = 's'; break;
			default:
				printf("unknown type (%o)\n", xst->st_mode & S_IFMT);
				ft = '?';
				break;
			}
		}

		sprintf(buffer, "%02x:%02x", xst->st_dev.major, xst->st_dev.minor);
		printf("Device: %-15s", buffer);
		if (xst->st_result_mask & XSTAT_REQUEST_INO)
			printf(" Inode: %-11llu", xst->st_ino);
		if (xst->st_result_mask & XSTAT_REQUEST_SIZE)
			printf(" Links: %-5u", xst->st_nlink);
		if (xst->st_result_mask & XSTAT_REQUEST_RDEV)
			printf(" Device type: %u,%u",
			       xst->st_rdev.major, xst->st_rdev.minor);
		printf("\n");

		if (xst->st_result_mask & XSTAT_REQUEST_MODE)
			printf("Access: (%04o/%c%c%c%c%c%c%c%c%c%c)  ",
			       xst->st_mode & 07777,
			       ft,
			       xst->st_mode & S_IRUSR ? 'r' : '-',
			       xst->st_mode & S_IWUSR ? 'w' : '-',
			       xst->st_mode & S_IXUSR ? 'x' : '-',
			       xst->st_mode & S_IRGRP ? 'r' : '-',
			       xst->st_mode & S_IWGRP ? 'w' : '-',
			       xst->st_mode & S_IXGRP ? 'x' : '-',
			       xst->st_mode & S_IROTH ? 'r' : '-',
			       xst->st_mode & S_IWOTH ? 'w' : '-',
			       xst->st_mode & S_IXOTH ? 'x' : '-');
		if (xst->st_result_mask & XSTAT_REQUEST_UID)
			printf("Uid: %d   \n", xst->st_uid);
		if (xst->st_result_mask & XSTAT_REQUEST_GID)
			printf("Gid: %u\n", xst->st_gid);

		if (xst->st_result_mask & XSTAT_REQUEST_ATIME)
			print_time("Access: ", &xst->st_atim);
		if (xst->st_result_mask & XSTAT_REQUEST_MTIME)
			print_time("Modify: ", &xst->st_mtim);
		if (xst->st_result_mask & XSTAT_REQUEST_CTIME)
			print_time("Change: ", &xst->st_ctim);
		if (xst->st_result_mask & XSTAT_REQUEST_BTIME)
			print_time("Create: ", &xst->st_btim);

		if (xst->st_result_mask & XSTAT_REQUEST_GEN)
			printf("Inode version: %llxh\n", xst->st_gen);
		if (xst->st_result_mask & XSTAT_REQUEST_DATA_VERSION)
			printf("Data version: %llxh\n", xst->st_data_version);

		if (xst->st_result_mask & XSTAT_REQUEST_INODE_FLAGS) {
			unsigned char bits;
			int loop, byte;

			static char flag_representation[64 + 1] =
				"????????"
				"????????"
				"????????"
				"otserAaS"
				"????????"
				"????ehTD"
				"tj?IE?XZ"
				"AdaiScus"
				;

			printf("Inode flags: %016llx (", xst->st_inode_flags);
			for (byte = 64 - 8; byte >= 0; byte -= 8) {
				bits = xst->st_inode_flags >> byte;
				for (loop = 7; loop >= 0; loop--) {
					int bit = byte + loop;

					if (bits & 0x80)
						putchar(flag_representation[63 - bit]);
					else
						putchar('-');
					bits <<= 1;
				}
				if (byte)
					putchar(' ');
			}
			printf(")\n");
		}
	}

	int main(int argc, char **argv)
	{
		struct xstat_parameters params;
		union {
			struct xstat xst;
			unsigned long long raw[4096 / 8];
		} buffer;
		int ret, atflag = AT_SYMLINK_NOFOLLOW;

		unsigned long long query = XSTAT_REQUEST__ALL_STATS;

		for (argv++; *argv; argv++) {
			if (strcmp(*argv, "-F") == 0) {
				atflag |= AT_FORCE_ATTR_SYNC;
				continue;
			}
			if (strcmp(*argv, "-L") == 0) {
				atflag &= ~AT_SYMLINK_NOFOLLOW;
				continue;
			}
			if (strcmp(*argv, "-O") == 0) {
				query &= ~XSTAT_REQUEST__BASIC_STATS;
				continue;
			}
			if (strcmp(*argv, "-A") == 0) {
				atflag |= AT_NO_AUTOMOUNT;
				continue;
			}

			memset(&buffer, 0xbf, sizeof(buffer));
			params.request_mask = query;
			ret = xstat(AT_FDCWD, *argv, atflag, &params, &buffer.xst,
				    sizeof(buffer));
			printf("xstat(%s) = %d\n", *argv, ret);
			if (ret < 0) {
				perror(*argv);
				exit(1);
			}

			dump_xstat(&buffer.xst);

			ret = (ret + 7) / 8;
			if (ret > sizeof(buffer.xst) / 8) {
				unsigned offset, print_offset = 1, col = 0;
				if (ret > sizeof(buffer) / 8)
					ret = sizeof(buffer) / 8;

				for (offset = sizeof(buffer.xst) / 8; offset < ret; offset++) {
					if (print_offset) {
						printf("%04x: ", offset * 8);
						print_offset = 0;
					}
					printf("%016llx", buffer.raw[offset]);
					col++;
					if ((col & 3) == 0) {
						printf("\n");
						print_offset = 1;
					} else {
						printf(" ");
					}
				}

				if (!print_offset)
					printf("\n");
			}
		}
		return 0;
	}

Just compile and run, passing it paths to the files you want to examine:

	[root@andromeda ~]# /tmp/xstat /proc/$$
	xstat(/proc/2074) = 160
	results=47ef
	  Size: 0               Blocks: 0          IO Block: 1024    directory
	Device: 00:03           Inode: 9072        Links: 7
	Access: (0555/dr-xr-xr-x)  Uid: 0
	Gid: 0
	Access: 2010-07-14 16:50:46.609336272+0100
	Modify: 2010-07-14 16:50:46.609336272+0100
	Change: 2010-07-14 16:50:46.609336272+0100
	Inode flags: 0000000100000000 (-------- -------- -------- -------S -------- -------- -------- --------)
	[root@andromeda ~]# /tmp/xstat /afs/archive/linuxdev/fedora9/x86_64/kernel-devel-2.6.25.10-86.fc9.x86_64.rpm
	xstat(/afs/archive/linuxdev/fedora9/x86_64/kernel-devel-2.6.25.10-86.fc9.x86_64.rpm) = 160
	results=77ef
	  Size: 5413882         Blocks: 0          IO Block: 4096    regular file
	Device: 00:15           Inode: 2288        Links: 1
	Access: (0644/-rw-r--r--)  Uid: 75338
	Gid: 0
	Access: 2008-11-05 19:47:22.000000000+0000
	Modify: 2008-11-05 19:47:22.000000000+0000
	Change: 2008-11-05 19:47:22.000000000+0000
	Inode version: 795h
	Data version: 2h
	Inode flags: 0000000800000000 (-------- -------- -------- ----r--- -------- -------- -------- --------)

Signed-off-by: David Howells <dhowells@redhat.com>
---

 arch/x86/include/asm/unistd_32.h |    4 
 arch/x86/include/asm/unistd_64.h |    4 
 fs/stat.c                        |  322 +++++++++++++++++++++++++++++++++++---
 include/linux/fcntl.h            |    1 
 include/linux/fs.h               |    4 
 include/linux/stat.h             |  119 ++++++++++++++
 include/linux/syscalls.h         |    9 +
 7 files changed, 436 insertions(+), 27 deletions(-)

diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
index beb9b5f..a9953cc 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -343,10 +343,12 @@
 #define __NR_rt_tgsigqueueinfo	335
 #define __NR_perf_event_open	336
 #define __NR_recvmmsg		337
+#define __NR_xstat		338
+#define __NR_fxstat		339
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 338
+#define NR_syscalls 340
 
 #define __ARCH_WANT_IPC_PARSE_VERSION
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
index ff4307b..c90d240 100644
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@ -663,6 +663,10 @@ __SYSCALL(__NR_rt_tgsigqueueinfo, sys_rt_tgsigqueueinfo)
 __SYSCALL(__NR_perf_event_open, sys_perf_event_open)
 #define __NR_recvmmsg				299
 __SYSCALL(__NR_recvmmsg, sys_recvmmsg)
+#define __NR_xstat				300
+__SYSCALL(__NR_xstat, sys_xstat)
+#define __NR_fxstat				301
+__SYSCALL(__NR_fxstat, sys_fxstat)
 
 #ifndef __NO_STUBS
 #define __ARCH_WANT_OLD_READDIR
diff --git a/fs/stat.c b/fs/stat.c
index 12e90e2..89d72fc 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -18,6 +18,15 @@
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
 
+/**
+ * generic_fillattr - Fill in the basic attributes from the inode struct
+ * @inode: Inode to use as the source
+ * @stat: Where to fill in the attributes
+ *
+ * Fill in the basic attributes in the kstat structure from data that's to be
+ * found on the VFS inode structure.  This is the default if no getattr inode
+ * operation is supplied.
+ */
 void generic_fillattr(struct inode *inode, struct kstat *stat)
 {
 	stat->dev = inode->i_sb->s_dev;
@@ -33,11 +42,37 @@ void generic_fillattr(struct inode *inode, struct kstat *stat)
 	stat->size = i_size_read(inode);
 	stat->blocks = inode->i_blocks;
 	stat->blksize = (1 << inode->i_blkbits);
+	stat->inode_flags = inode->i_sb->s_type->inode_flags;
+	stat->result_mask |= XSTAT_REQUEST__BASIC_STATS & ~XSTAT_REQUEST_RDEV;
+	if (unlikely(S_ISBLK(stat->mode) || S_ISCHR(stat->mode)))
+		stat->result_mask |= XSTAT_REQUEST_RDEV;
+	if (stat->inode_flags)
+		stat->result_mask |= XSTAT_REQUEST_INODE_FLAGS;
 }
-
 EXPORT_SYMBOL(generic_fillattr);
 
-int vfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
+/**
+ * vfs_xgetattr - Get the extended attributes of a file
+ * @mnt: The mountpoint to which the dentry belongs
+ * @dentry: The file of interest
+ * @stat: Where to return the statistics
+ *
+ * Ask the filesystem for a file's attributes.  The caller must have preset
+ * stat->request_mask and stat->query_flags to indicate what they want.
+ *
+ * If the file is remote, the filesystem can be forced to update the attributes
+ * from the backing store by passing AT_FORCE_ATTR_SYNC in query_flags.
+ *
+ * Bits must have been set in stat->request_mask to indicate which attributes
+ * the caller wants retrieving.  Only attributes from the set
+ * XSTAT_REQUEST__EXTENDED_STATS can be retrieved through this interface.  Any
+ * such attribute not requested may be returned anyway, but the value may be
+ * approximate, and, if remote, may not have been synchronised with the server.
+ *
+ * 0 will be returned on success, and a -ve error code if unsuccessful.
+ */
+int vfs_xgetattr(struct vfsmount *mnt, struct dentry *dentry,
+		 struct kstat *stat)
 {
 	struct inode *inode = dentry->d_inode;
 	int retval;
@@ -46,61 +81,176 @@ int vfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 	if (retval)
 		return retval;
 
+	stat->result_mask = 0;
 	if (inode->i_op->getattr)
 		return inode->i_op->getattr(mnt, dentry, stat);
 
 	generic_fillattr(inode, stat);
 	return 0;
 }
+EXPORT_SYMBOL(vfs_xgetattr);
 
+/**
+ * vfs_getattr - Get the basic attributes of a file
+ * @mnt: The mountpoint to which the dentry belongs
+ * @dentry: The file of interest
+ * @stat: Where to return the statistics
+ *
+ * Ask the filesystem for a file's attributes.  If remote, the filesystem isn't
+ * forced to update its files from the backing store.  Only the basic set of
+ * attributes will be retrieved; anyone wanting more must use vfs_getxattr(),
+ * as must anyone who wants to force attributes to be sync'd with the server.
+ *
+ * 0 will be returned on success, and a -ve error code if unsuccessful.
+ */
+int vfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
+{
+	stat->query_flags = 0;
+	stat->request_mask = XSTAT_REQUEST__BASIC_STATS;
+	return vfs_xgetattr(mnt, dentry, stat);
+}
 EXPORT_SYMBOL(vfs_getattr);
 
-int vfs_fstat(unsigned int fd, struct kstat *stat)
+/**
+ * vfs_fxstat - Get extended attributes by file descriptor
+ * @fd: The file descriptor refering to the file of interest
+ * @stat: The result structure to fill in.
+ *
+ * This function is a wrapper around vfs_xgetattr().  The main difference is
+ * that it uses a file descriptor to determine the file location.
+ *
+ * The caller must have preset stat->query_flags and stat->request_mask as for
+ * vfs_xgetattr().
+ *
+ * 0 will be returned on success, and a -ve error code if unsuccessful.
+ */
+int vfs_fxstat(unsigned int fd, struct kstat *stat)
 {
 	struct file *f = fget(fd);
 	int error = -EBADF;
 
+	if (stat->query_flags & ~KSTAT_QUERY_FLAGS)
+		return -EINVAL;
 	if (f) {
-		error = vfs_getattr(f->f_path.mnt, f->f_path.dentry, stat);
+		error = vfs_xgetattr(f->f_path.mnt, f->f_path.dentry, stat);
 		fput(f);
 	}
 	return error;
 }
+EXPORT_SYMBOL(vfs_fxstat);
+
+/**
+ * vfs_fstat - Get basic attributes by file descriptor
+ * @fd: The file descriptor refering to the file of interest
+ * @stat: The result structure to fill in.
+ *
+ * This function is a wrapper around vfs_getattr().  The main difference is
+ * that it uses a file descriptor to determine the file location.
+ *
+ * 0 will be returned on success, and a -ve error code if unsuccessful.
+ */
+int vfs_fstat(unsigned int fd, struct kstat *stat)
+{
+	stat->query_flags = 0;
+	stat->request_mask = XSTAT_REQUEST__BASIC_STATS;
+	return vfs_fxstat(fd, stat);
+}
 EXPORT_SYMBOL(vfs_fstat);
 
-int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
-		int flag)
+/**
+ * vfs_xstat - Get extended attributes by filename
+ * @dfd: A file descriptor representing the base dir for a relative filename
+ * @filename: The name of the file of interest
+ * @flags: Flags to control the query
+ * @stat: The result structure to fill in.
+ *
+ * This function is a wrapper around vfs_xgetattr().  The main difference is
+ * that it uses a filename and base directory to determine the file location.
+ * Additionally, the addition of AT_SYMLINK_NOFOLLOW to flags will prevent a
+ * symlink at the given name from being referenced.
+ *
+ * The caller must have preset stat->request_mask as for vfs_xgetattr().  The
+ * flags are also used to load up stat->query_flags.
+ *
+ * 0 will be returned on success, and a -ve error code if unsuccessful.
+ */
+int vfs_xstat(int dfd, const char __user *filename, int flags,
+	      struct kstat *stat)
 {
 	struct path path;
-	int error = -EINVAL;
-	int lookup_flags = 0;
+	int error, lookup_flags;
 
-	if ((flag & ~AT_SYMLINK_NOFOLLOW) != 0)
-		goto out;
+	if (flags & ~(AT_SYMLINK_NOFOLLOW | KSTAT_QUERY_FLAGS))
+		return -EINVAL;
 
-	if (!(flag & AT_SYMLINK_NOFOLLOW))
-		lookup_flags |= LOOKUP_FOLLOW;
+	stat->query_flags = flags & KSTAT_QUERY_FLAGS;
+	lookup_flags = (flags & AT_SYMLINK_NOFOLLOW) ? 0 : LOOKUP_FOLLOW;
 
 	error = user_path_at(dfd, filename, lookup_flags, &path);
-	if (error)
-		goto out;
-
-	error = vfs_getattr(path.mnt, path.dentry, stat);
-	path_put(&path);
-out:
+	if (!error) {
+		error = vfs_xgetattr(path.mnt, path.dentry, stat);
+		path_put(&path);
+	}
 	return error;
 }
+EXPORT_SYMBOL(vfs_xstat);
+
+/**
+ * vfs_fstatat - Get basic attributes by filename
+ * @dfd: A file descriptor representing the base dir for a relative filename
+ * @filename: The name of the file of interest
+ * @flags: Flags to control the query
+ * @stat: The result structure to fill in.
+ *
+ * This function is a wrapper around vfs_xstat().  The difference is that it
+ * preselects basic stats only.  The flags are used to load up
+ * stat->query_flags in addition to indicating symlink handling during path
+ * resolution.
+ *
+ * 0 will be returned on success, and a -ve error code if unsuccessful.
+ */
+int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
+		int flags)
+{
+	stat->request_mask = XSTAT_REQUEST__BASIC_STATS;
+	return vfs_xstat(dfd, filename, flags, stat);
+}
 EXPORT_SYMBOL(vfs_fstatat);
 
-int vfs_stat(const char __user *name, struct kstat *stat)
+/**
+ * vfs_stat - Get basic attributes by filename
+ * @filename: The name of the file of interest
+ * @stat: The result structure to fill in.
+ *
+ * This function is a wrapper around vfs_xstat().  The difference is that it
+ * preselects basic stats only, terminal symlinks are followed regardless and a
+ * remote filesystem can't be forced to query the server.  If such is desired,
+ * vfs_xstat() should be used instead.
+ *
+ * 0 will be returned on success, and a -ve error code if unsuccessful.
+ */
+int vfs_stat(const char __user *filename, struct kstat *stat)
 {
-	return vfs_fstatat(AT_FDCWD, name, stat, 0);
+	stat->request_mask = XSTAT_REQUEST__BASIC_STATS;
+	return vfs_xstat(AT_FDCWD, filename, 0, stat);
 }
 EXPORT_SYMBOL(vfs_stat);
 
+/**
+ * vfs_stat - Get basic attributes by filename, without following terminal symlink
+ * @filename: The name of the file of interest
+ * @stat: The result structure to fill in.
+ *
+ * This function is a wrapper around vfs_xstat().  The difference is that it
+ * preselects basic stats only, terminal symlinks are note followed regardless
+ * and a remote filesystem can't be forced to query the server.  If such is
+ * desired, vfs_xstat() should be used instead.
+ *
+ * 0 will be returned on success, and a -ve error code if unsuccessful.
+ */
 int vfs_lstat(const char __user *name, struct kstat *stat)
 {
-	return vfs_fstatat(AT_FDCWD, name, stat, AT_SYMLINK_NOFOLLOW);
+	return vfs_xstat(AT_FDCWD, name, AT_SYMLINK_NOFOLLOW, stat);
 }
 EXPORT_SYMBOL(vfs_lstat);
 
@@ -115,7 +265,7 @@ static int cp_old_stat(struct kstat *stat, struct __old_kernel_stat __user * sta
 {
 	static int warncount = 5;
 	struct __old_kernel_stat tmp;
-	
+
 	if (warncount > 0) {
 		warncount--;
 		printk(KERN_WARNING "VFS: Warning: %s using old stat() call. Recompile your binary.\n",
@@ -140,7 +290,7 @@ static int cp_old_stat(struct kstat *stat, struct __old_kernel_stat __user * sta
 #if BITS_PER_LONG == 32
 	if (stat->size > MAX_NON_LFS)
 		return -EOVERFLOW;
-#endif	
+#endif
 	tmp.st_size = stat->size;
 	tmp.st_atime = stat->atime.tv_sec;
 	tmp.st_mtime = stat->mtime.tv_sec;
@@ -222,7 +372,7 @@ static int cp_new_stat(struct kstat *stat, struct stat __user *statbuf)
 #if BITS_PER_LONG == 32
 	if (stat->size > MAX_NON_LFS)
 		return -EOVERFLOW;
-#endif	
+#endif
 	tmp.st_size = stat->size;
 	tmp.st_atime = stat->atime.tv_sec;
 	tmp.st_mtime = stat->mtime.tv_sec;
@@ -408,6 +558,130 @@ SYSCALL_DEFINE4(fstatat64, int, dfd, const char __user *, filename,
 }
 #endif /* __ARCH_WANT_STAT64 */
 
+/*
+ * Get the xstat parameters if supplied
+ */
+static int xstat_get_params(struct xstat_parameters __user *_params,
+			    struct kstat *stat)
+{
+	struct xstat_parameters params;
+
+	memset(stat, 0xde, sizeof(*stat));	// DEBUGGING
+
+	if (_params) {
+		if (copy_from_user(&params, _params, sizeof(params)) != 0)
+			return -EFAULT;
+		stat->request_mask =
+			params.request_mask & XSTAT_REQUEST__ALL_STATS;
+	} else {
+		stat->request_mask = XSTAT_REQUEST__BASIC_STATS;
+	}
+	stat->result_mask = 0;
+	return 0;
+}
+
+/*
+ * Set the xstat results.
+ *
+ * If the buffer size was 0, we just return the size of the buffer needed to
+ * return the full result.
+ *
+ * If bufsize indicates a buffer of insufficient size to hold the full result,
+ * we return -E2BIG.
+ *
+ * Otherwise we copy the extended stats to userspace and return the amount of
+ * data written into the buffer (or -EFAULT).
+ */
+static long xstat_set_result(struct kstat *stat,
+			     struct xstat __user *buffer, size_t bufsize)
+{
+	struct xstat tmp;
+	size_t result_size = sizeof(tmp);
+
+	if (bufsize == 0)
+		return result_size;
+	if (bufsize < result_size)
+		return -E2BIG;
+
+	/* transfer the fixed results */
+	memset(&tmp, 0, sizeof(tmp));
+	tmp.st_result_mask	= stat->result_mask;
+	tmp.st_mode		= stat->mode;
+	tmp.st_nlink		= stat->nlink;
+	tmp.st_uid		= stat->uid;
+	tmp.st_gid		= stat->gid;
+	tmp.st_blksize		= stat->blksize;
+	tmp.st_rdev.major	= MAJOR(stat->rdev);
+	tmp.st_rdev.minor	= MINOR(stat->rdev);
+	tmp.st_dev.major	= MAJOR(stat->dev);
+	tmp.st_dev.minor	= MINOR(stat->dev);
+	tmp.st_atime.tv_sec	= stat->atime.tv_sec;
+	tmp.st_atime.tv_nsec	= stat->atime.tv_nsec;
+	tmp.st_mtime.tv_sec	= stat->mtime.tv_sec;
+	tmp.st_mtime.tv_nsec	= stat->mtime.tv_nsec;
+	tmp.st_ctime.tv_sec	= stat->ctime.tv_sec;
+	tmp.st_ctime.tv_nsec	= stat->ctime.tv_nsec;
+	tmp.st_ino		= stat->ino;
+	tmp.st_size		= stat->size;
+	tmp.st_blocks		= stat->blocks;
+
+	if (tmp.st_result_mask & XSTAT_REQUEST_BTIME) {
+		tmp.st_btime.tv_sec	= stat->btime.tv_sec;
+		tmp.st_btime.tv_nsec	= stat->btime.tv_nsec;
+	}
+	if (tmp.st_result_mask & XSTAT_REQUEST_GEN)
+		tmp.st_gen		= stat->gen;
+	if (tmp.st_result_mask & XSTAT_REQUEST_DATA_VERSION)
+		tmp.st_data_version	= stat->data_version;
+	if (tmp.st_result_mask & XSTAT_REQUEST_INODE_FLAGS)
+		tmp.st_inode_flags	= stat->inode_flags;
+
+	if (copy_to_user(buffer, &tmp, result_size) != 0)
+		return -EFAULT;
+	return result_size;
+}
+
+/*
+ * System call to get extended stats by path
+ */
+SYSCALL_DEFINE6(xstat,
+		int, dfd, const char __user *, filename, unsigned, atflag,
+		struct xstat_parameters __user *, params,
+		struct xstat __user *, buffer, size_t, bufsize)
+{
+	struct kstat stat;
+	int error;
+
+	error = xstat_get_params(params, &stat);
+	if (error != 0)
+		return error;
+	error = vfs_xstat(dfd, filename, atflag, &stat);
+	if (error)
+		return error;
+	return xstat_set_result(&stat, buffer, bufsize);
+}
+
+/*
+ * System call to get extended stats by file descriptor
+ */
+SYSCALL_DEFINE5(fxstat, unsigned int, fd, unsigned int, flags,
+		struct xstat_parameters __user *, params,
+		struct xstat __user *, buffer, size_t, bufsize)
+{
+	struct kstat stat;
+	int error;
+
+	error = xstat_get_params(params, &stat);
+	if (error < 0)
+		return error;
+	stat.query_flags = flags;
+	error = vfs_fxstat(fd, &stat);
+	if (error)
+		return error;
+
+	return xstat_set_result(&stat, buffer, bufsize);
+}
+
 /* Caller is here responsible for sufficient locking (ie. inode->i_lock) */
 void __inode_add_bytes(struct inode *inode, loff_t bytes)
 {
diff --git a/include/linux/fcntl.h b/include/linux/fcntl.h
index afc00af..bcf8083 100644
--- a/include/linux/fcntl.h
+++ b/include/linux/fcntl.h
@@ -45,6 +45,7 @@
 #define AT_REMOVEDIR		0x200   /* Remove directory instead of
                                            unlinking file.  */
 #define AT_SYMLINK_FOLLOW	0x400   /* Follow symbolic links.  */
+#define AT_FORCE_ATTR_SYNC	0x800	/* Force the attributes to be sync'd with the server */
 
 #ifdef __KERNEL__
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f5e7cf2..951c36b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1735,6 +1735,7 @@ int sync_inode(struct inode *inode, struct writeback_control *wbc);
 struct file_system_type {
 	const char *name;
 	int fs_flags;
+	u64 inode_flags;	/* base inode_flags for generic_getattr() */
 	int (*get_sb) (struct file_system_type *, int,
 		       const char *, void *, struct vfsmount *);
 	void (*kill_sb) (struct super_block *);
@@ -2341,6 +2342,7 @@ extern const struct inode_operations page_symlink_inode_operations;
 extern int generic_readlink(struct dentry *, char __user *, int);
 extern void generic_fillattr(struct inode *, struct kstat *);
 extern int vfs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
+extern int vfs_xgetattr(struct vfsmount *, struct dentry *, struct kstat *);
 void __inode_add_bytes(struct inode *inode, loff_t bytes);
 void inode_add_bytes(struct inode *inode, loff_t bytes);
 void inode_sub_bytes(struct inode *inode, loff_t bytes);
@@ -2353,6 +2355,8 @@ extern int vfs_stat(const char __user *, struct kstat *);
 extern int vfs_lstat(const char __user *, struct kstat *);
 extern int vfs_fstat(unsigned int, struct kstat *);
 extern int vfs_fstatat(int , const char __user *, struct kstat *, int);
+extern int vfs_xstat(int, const char __user *, int, struct kstat *);
+extern int vfs_xfstat(unsigned int, struct kstat *);
 
 extern int do_vfs_ioctl(struct file *filp, unsigned int fd, unsigned int cmd,
 		    unsigned long arg);
diff --git a/include/linux/stat.h b/include/linux/stat.h
index 611c398..41a3c22 100644
--- a/include/linux/stat.h
+++ b/include/linux/stat.h
@@ -46,6 +46,114 @@
 
 #endif
 
+/*
+ * Extended stat structures
+ */
+struct xstat_parameters {
+	/* Query request/result mask
+	 *
+	 * Bits should be set in request_mask to request particular items
+	 * before calling xstat() or fxstat().
+	 *
+	 * For each item in the set XSTAT_REQUEST__EXTENDED_STATS:
+	 *
+	 * - if not available at all, the bit will be cleared before returning
+	 *   and the field will be cleared; otherwise,
+	 *
+	 * - if AT_FORCE_ATTR_SYNC is set, then the datum will be synchronised
+	 *   to the server and the bit will be set on return; otherwise,
+	 *
+	 * - if requested, the datum will be synchronised to a server or other
+	 *   hardware if out of date before being returned, and the bit will be
+	 *   set on return; otherwise,
+	 *
+	 * - if not requested, but available in approximate form without any
+	 *   effort, it will be filled in anyway, and the bit will be set upon
+	 *   return (it might not be up to date, however, and no attempt will
+	 *   be made to synchronise the internal state first); otherwise,
+	 *
+	 * - the bit will be cleared before returning, and the field will be
+         *   cleared.
+	 *
+	 * For each item not in the set XSTAT_REQUEST__EXTENDED_STATS
+	 * 
+	 * - if not available at all, the bit will be cleared, and no result
+         *   data will be returned; otherwise,
+	 *
+	 * - if requested, the datum will be synchronised to a server or other
+	 *   hardware before being appended if necessary, and the bit will be
+	 *   set on return; otherwise,
+	 * 
+	 * - the bit will be cleared, and no result data will be returned.
+	 *
+	 * Items in XSTAT_REQUEST__BASIC_STATS may be marked unavailable on
+	 * return, but they will have a value installed for compatibility
+	 * purposes.
+	 */
+	unsigned long long	request_mask;
+#define XSTAT_REQUEST_MODE		0x00000001ULL	/* want/got st_mode */
+#define XSTAT_REQUEST_NLINK		0x00000002ULL	/* want/got st_nlink */
+#define XSTAT_REQUEST_UID		0x00000004ULL	/* want/got st_uid */
+#define XSTAT_REQUEST_GID		0x00000008ULL	/* want/got st_gid */
+#define XSTAT_REQUEST_RDEV		0x00000010ULL	/* want/got st_rdev */
+#define XSTAT_REQUEST_ATIME		0x00000020ULL	/* want/got st_atime */
+#define XSTAT_REQUEST_MTIME		0x00000040ULL	/* want/got st_mtime */
+#define XSTAT_REQUEST_CTIME		0x00000080ULL	/* want/got st_ctime */
+#define XSTAT_REQUEST_INO		0x00000100ULL	/* want/got st_ino */
+#define XSTAT_REQUEST_SIZE		0x00000200ULL	/* want/got st_size */
+#define XSTAT_REQUEST_BLOCKS		0x00000400ULL	/* want/got st_blocks */
+#define XSTAT_REQUEST__BASIC_STATS	0x000007ffULL	/* the stuff in the normal stat struct */
+#define XSTAT_REQUEST_BTIME		0x00000800ULL	/* want/got st_btime */
+#define XSTAT_REQUEST_GEN		0x00001000ULL	/* want/got st_gen */
+#define XSTAT_REQUEST_DATA_VERSION	0x00002000ULL	/* want/got st_data_version */
+#define XSTAT_REQUEST_INODE_FLAGS	0x00004000ULL	/* want/got st_inode_flags */
+#define XSTAT_REQUEST__EXTENDED_STATS	0x00007fffULL	/* the stuff in the xstat struct */
+#define XSTAT_REQUEST__ALL_STATS	0x00007fffULL	/* the defined set of requestables */
+};
+
+struct xstat_dev {
+	unsigned int		major, minor;
+};
+
+struct xstat_time {
+	unsigned long long	tv_sec, tv_nsec;
+};
+
+struct xstat {
+	unsigned long long	st_result_mask;	/* what results were written */
+	unsigned int		st_mode;	/* file mode */
+	unsigned int		st_nlink;	/* number of hard links */
+	unsigned int		st_uid;		/* user ID of owner */
+	unsigned int		st_gid;		/* group ID of owner */
+	struct xstat_dev	st_rdev;	/* device ID of special file */
+	struct xstat_dev	st_dev;		/* ID of device containing file */
+	struct xstat_time	st_atime;	/* last access time */
+	struct xstat_time	st_mtime;	/* last data modification time */
+	struct xstat_time	st_ctime;	/* last attribute change time */
+	struct xstat_time	st_btime;	/* file creation time */
+	unsigned long long	st_ino;		/* inode number */
+	unsigned long long	st_size;	/* file size */
+	unsigned long long	st_blksize;	/* block size for filesystem I/O */
+	unsigned long long	st_blocks;	/* number of 512-byte blocks allocated */
+	unsigned long long	st_gen;		/* inode generation number */
+	unsigned long long	st_data_version; /* data version number */
+	unsigned long long	st_inode_flags;	/* inode flags (!= BSD st_flags) */
+	unsigned long long	st_extra_results[0]; /* extra requested results */
+};
+
+#define FS__STANDARD_FL		0x00000000ffffffffULL	/* As for user visible FS_IOC_GETFLAGS */
+#define FS_SPECIAL_FL		0x0000000100000000ULL	/* Special file as found in procfs/sysfs */
+#define FS_AUTOMOUNT_FL		0x0000000200000000ULL	/* Specific automount point */
+#define FS_AUTOMOUNT_ANY_FL	0x0000000400000000ULL	/* Unspecific automount directory */
+#define FS_REMOTE_FL		0x0000000800000000ULL	/* File is remote */
+#define FS_ENCRYPTED_FL		0x0000001000000000ULL	/* File is encrypted */
+#define FS_HIDDEN_FL		0x0000002000000000ULL	/* File is marked hidden (DOS+) */
+#define FS_SYSTEM_FL		0x0000004000000000ULL	/* File is marked system (DOS+) */
+#define FS_ARCHIVE_FL		0x0000008000000000ULL	/* File is marked archive (DOS+) */
+#define FS_TEMPORARY_FL		0x0000010000000000ULL	/* File is temporary (NTFS/CIFS) */
+#define FS_OFFLINE_FL		0x0000020000000000ULL	/* File is offline (CIFS) */
+#define FS_REPARSE_POINT_FL	0x0000040000000000ULL	/* Reparse point (NTFS/CIFS) */
+
 #ifdef __KERNEL__
 #define S_IRWXUGO	(S_IRWXU|S_IRWXG|S_IRWXO)
 #define S_IALLUGO	(S_ISUID|S_ISGID|S_ISVTX|S_IRWXUGO)
@@ -60,6 +168,8 @@
 #include <linux/time.h>
 
 struct kstat {
+	u64		request_mask;		/* what fields the user asked for */
+	u64		result_mask;		/* what fields the user got */
 	u64		ino;
 	dev_t		dev;
 	umode_t		mode;
@@ -67,14 +177,19 @@ struct kstat {
 	uid_t		uid;
 	gid_t		gid;
 	dev_t		rdev;
+	unsigned int	query_flags;		/* operational flags */
+#define KSTAT_QUERY_FLAGS (AT_FORCE_ATTR_SYNC)
 	loff_t		size;
-	struct timespec  atime;
+	struct timespec	atime;
 	struct timespec	mtime;
 	struct timespec	ctime;
+	struct timespec	btime;			/* file creation time */
 	unsigned long	blksize;
 	unsigned long long	blocks;
+	u64		gen;			/* inode generation */
+	u64		data_version;
+	u64		inode_flags;		/* inode flags (!= BSD st_flags) */
 };
 
 #endif
-
 #endif
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 8812a63..5d68b4c 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -44,6 +44,8 @@ struct shmid_ds;
 struct sockaddr;
 struct stat;
 struct stat64;
+struct xstat_parameters;
+struct xstat;
 struct statfs;
 struct statfs64;
 struct __sysctl_args;
@@ -824,4 +826,11 @@ asmlinkage long sys_mmap_pgoff(unsigned long addr, unsigned long len,
 			unsigned long fd, unsigned long pgoff);
 asmlinkage long sys_old_mmap(struct mmap_arg_struct __user *arg);
 
+asmlinkage long sys_xstat(int, const char __user *, unsigned,
+			  struct xstat_parameters __user *,
+			  struct xstat __user *, size_t);
+asmlinkage long sys_fxstat(unsigned, unsigned,
+			   struct xstat_parameters __user *,
+			   struct xstat __user *, size_t);
+
 #endif
