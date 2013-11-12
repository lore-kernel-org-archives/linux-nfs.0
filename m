Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10803 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754132Ab3KLSme (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 13:42:34 -0500
Subject: [PATCH 2/3] statxat: Add a system call to make extended file stats
 available [ver #2]
To: viro@ZenIV.linux.org.uk
From: David Howells <dhowells@redhat.com>
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        libc-alpha@sourceware.org, linux-api@vger.kernel.org,
        andreas.gruenbacher@gmail.com, samba-technical@lists.samba.org,
        linux-fsdevel@vger.kernel.org
Date: Tue, 12 Nov 2013 18:41:42 +0000
Message-ID: <20131112184142.2880.21338.stgit@warthog.procyon.org.uk>
In-Reply-To: <20131112184127.2880.24025.stgit@warthog.procyon.org.uk>
References: <20131112184127.2880.24025.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a system call to make extended file stats available, including file
creation time, inode version and data version where available through the
underlying filesystem.


========
OVERVIEW
========

The idea was initially proposed as a set of xattrs that could be retrieved with
getxattr(), but the general preferance proved to be for a new syscall with an
extended stat structure.

This has a number of uses:

 (1) Creation time: The SMB protocol carries the creation time, which could be
     exported by Samba, which will in turn help CIFS make use of FS-Cache as
     that can be used for coherency data.

     This is also specified in NFSv4 as a recommended attribute and could be
     exported by NFSD [Steve French].

 (2) Lightweight stat: Ask for just those details of interest, and allow a
     netfs (such as NFS) to approximate anything not of interest, possibly
     without going to the server [Trond Myklebust, Ulrich Drepper, Andreas
     Dilger].

 (3) Heavyweight stat: Force a netfs to go to the server, even if it thinks its
     cached attributes are up to date [Trond Myklebust].

 (4) Data version number: Could be used by userspace NFS servers [Aneesh Kumar].

     Can also be used to modify fill_post_wcc() in NFSD which retrieves
     i_version directly, but has just called vfs_getattr().  It could get it
     from the kstat struct if it used vfs_xgetattr() instead.

 (5) BSD stat compatibility: Including more fields from the BSD stat such as
     creation time (st_btime) and inode generation number (st_gen) [Jeremy
     Allison, Bernd Schubert].

 (6) Inode generation number: Useful for FUSE and userspace NFS servers [Bernd
     Schubert].  This was asked for but later deemed unnecessary with the
     open-by-handle capability available

 (7) Extra coherency data may be useful in making backups [Andreas Dilger].

 (8) Allow the filesystem to indicate what it can/cannot provide: A filesystem
     can now say it doesn't support a standard stat feature if that isn't
     available, so if, for instance, inode numbers or UIDs don't exist or are
     fabricated locally...

 (9) Make the fields a consistent size on all arches and make them large.

(10) Store a 16-byte volume ID in the superblock that can be returned in struct
     xstat [Steve French].

(11) Include granularity fields in the time data to indicate the granularity of
     each of the times (NFSv4 time_delta) [Steve French].

(12) FS_IOC_GETFLAGS value.  These could be translated to BSD's st_flags.  Note
     that the Linux IOC flags are a mess and filesystems such as Ext4 define
     flags that aren't in linux/fs.h, so translation in the kernel may be a
     necessity (or, possibly, we provide the filesystem type too).

(13) Mask of features available on file (eg: ACLs, seclabel) [Brad Boyer,
     Michael Kerrisk].

(14) Spare space, request flags and information flags are provided for future
     expansion.


===============
NEW SYSTEM CALL
===============

The new system call is:

	int ret = statxat(int dfd,
			  const char *filename,
			  unsigned int flags,
			  unsigned int mask,
			  struct statx *buffer,
			  struct statx_auxinfo *auxinfo_buffer);

The dfd, filename and flags parameters indicate the file to query.  There is no
equivalent of lstat() as that can be emulated with statxat() by passing
AT_SYMLINK_NOFOLLOW in flags.  There is also no equivalent of fstat() as that
can be emulated by passing a NULL filename to statxat() with the fd of interest
in dfd.

AT_FORCE_ATTR_SYNC can also be set in flags.  This will require a network
filesystem to synchronise its attributes with the server.

mask is a bitmask indicating the fields in struct statx that are of interest to
the caller.  The user should set this to STATX_BASIC_STATS to get the basic set
returned by stat().

buffer points to the destination for the main data and auxinfo_buffer points to
the destination for the optional auxiliary data.  auxinfo_buffer can be NULL if
the auxiliary data is not required.

At the moment, this will only work on x86_64 and i386 as it requires the system
call to be wired up.


======================
MAIN ATTRIBUTES RECORD
======================

The following structures are defined in which to return the main attribute set:

	struct statx_dev {
		uint32_t		major, minor;
	};

	struct statx {
		uint32_t		st_mask;
		uint32_t		st_information;
		uint16_t		st_mode;
		uint16_t		__spare0[1];
		uint32_t		st_nlink;
		uint32_t		st_uid;
		uint32_t		st_gid;
		uint32_t		st_alloc_blksize;
		uint32_t		st_blksize;
		uint32_t		st_small_io_size;
		uint32_t		st_large_io_size;
		struct statx_dev	st_rdev;
		struct statx_dev	st_dev;
		int32_t			st_atime_ns;
		int32_t			st_btime_ns;
		int32_t			st_ctime_ns;
		int32_t			st_mtime_ns;
		int64_t			st_atime;
		int64_t			st_btime;
		int64_t			st_ctime;
		int64_t			st_mtime;
		uint64_t		st_ino;
		uint64_t		st_size;
		uint64_t		st_blocks;
		uint64_t		st_version;
		uint64_t		st_ioc_flags;
		uint64_t		__spare1[14];
	};

where st_information is local system information about the file, st_btime is
the file creation time, st_version is the data version number (i_version),
st_ioc_flags holds the flags from FS_IOC_GETFLAGS, st_mask is a bitmask
indicating the data provided and __spares*[] are where as-yet undefined fields
can be placed.

Time fields are split into separate seconds and nanoseconds fields to make
packing easier and the granularities are indicated in the auxiliary data.  Note
that times can be negative if before 1970; in such a case, the nanosecond
fields should also be negative if not zero.

The defined bits in request_mask and st_mask are:

	STATX_MODE		Want/got st_mode
	STATX_NLINK		Want/got st_nlink
	STATX_UID		Want/got st_uid
	STATX_GID		Want/got st_gid
	STATX_RDEV		Want/got st_rdev
	STATX_ATIME		Want/got st_atime
	STATX_MTIME		Want/got st_mtime
	STATX_CTIME		Want/got st_ctime
	STATX_INO		Want/got st_ino
	STATX_SIZE		Want/got st_size
	STATX_BLOCKS		Want/got st_blocks
	STATX_ALLOC_BLKSIZE	Want/got st_alloc_blksize
	STATX_IO_PARAMS		Want/got I/O parameters
	STATX_BASIC_STATS	[The stuff in the normal stat struct]
	STATX_BTIME		Want/got st_btime
	STATX_VERSION		Want/got st_data_version
	STATX_IOC_FLAGS		Want/got FS_IOC_GETFLAGS
	STATX_ALL_STATS		[All currently available stuff]

The defined bits in st_ioc_flags are the usual FS_xxx_FL, plus some extra flags
that might be supplied by the filesystem.  Note that Ext4 returns flags outside
of {EXT4,FS}_FL_USER_VISIBLE in response to FS_IOC_GETFLAGS.  Should
{EXT4,FS}_FL_USER_VISIBLE be extended to cover them?  Or should the extra flags
be suppressed?

The defined bits in the st_information field give local system data on a file,
how it is accessed, where it is and what it does:

	STATX_INFO_ENCRYPTED		File is encrypted
	STATX_INFO_TEMPORARY		File is temporary (NTFS/CIFS/deleted)
	STATX_INFO_FABRICATED		File was made up by filesystem
	STATX_INFO_KERNEL_API		File is kernel API (eg: procfs/sysfs)
	STATX_INFO_REMOTE		File is remote
	STATX_INFO_OFFLINE		File is offline (CIFS)
	STATX_INFO_AUTOMOUNT		Dir is automount trigger
	STATX_INFO_AUTODIR		Dir provides unlisted automounts
	STATX_INFO_NONSYSTEM_OWNERSHIP	File has non-system ownership details
	STATX_INFO_REPARSE_POINT	File is reparse point (NTFS/CIFS)

These are for the use of GUI tools that might want to mark files specially,
depending on what they are.  I've tried not to provide overlap with
st_ioc_flags where something usable exists there.

The fields in struct statx come in a number of classes:

 (0) st_dev, st_information.

     These are local data and are always available.

 (1) st_nlinks, st_uid, st_gid, st_[amc]time*, st_ino, st_size, st_blocks,
     st_blksize.

     These will be returned whether the caller asks for them or not.  The
     corresponding bits in st_mask will be set to indicate their presence.

     If the caller didn't ask for them, then they may be approximated.  For
     example, NFS won't waste any time updating them from the server, unless as
     a byproduct of updating something requested.

     If the values don't actually exist for the underlying object (such as UID
     or GID on a DOS file), then the bit won't be set in the st_mask, even if
     the caller asked for the value.  In such a case, the returned value will
     be a fabrication.

 (2) st_mode.

     The part of this that identifies the file type will always be available,
     irrespective of the setting of STATX_MODE.  The access flags and sticky
     bit are as for class (1).

 (3) st_rdev.

     As for class (1), but this won't be returned if the file is not a blockdev
     or chardev.  The bit will be cleared if the value is not returned.

 (4) File creation time (st_btime*), data version (st_version), volume_id
     (st_volume_id) and inode flags (st_ioc_flags).

     These will be returned if available whether the caller asked for them or
     not.  The corresponding bits in st_mask will be set or cleared as
     appropriate to indicate their presence.

     If the caller didn't ask for them, then they may be approximated.  For
     example, NFS won't waste any time updating them from the server, unless
     as a byproduct of updating something requested.


===========================
AUXILIARY ATTRIBUTES RECORD
===========================

The following structures are defined in which to return the auxiliary attribute
set:

	struct statx_auxinfo {
		uint32_t	sx_mask;
		uint32_t	sx_fstype;
		uint64_t	sx_supported_ioc_flags;
		uint64_t	sx_fsid;
		uint64_t	__spare[13];
		uint8_t		sx_volume_id[16];
		uint8_t		sx_volume_uuid[16];
		uint16_t	sx_atime_gran_mantissa;
		uint16_t	sx_btime_gran_mantissa;
		uint16_t	sx_ctime_gran_mantissa;
		uint16_t	sx_mtime_gran_mantissa;
		int8_t		sx_atime_gran_exponent;
		int8_t		sx_btime_gran_exponent;
		int8_t		sx_ctime_gran_exponent;
		int8_t		sx_mtime_gran_exponent;
		uint8_t		sx_volume_name[66 + 1];
		uint8_t		sx_domain_name[256 + 1];
	};

where sx_mask indicates the attributes that have been returned, sx_fstype is
the filesystem type ID as per linux/magic.h and sx_supported_ioc_flags is the
mask of flags in st_ioc_flags that are supported.

sx_*_tim_gran_* are time granularities in the form mant*10^exp (an exponent of
0 would indicate seconds, -9 would indicate nanoseconds).  Note that VFAT, for
example, has a different granularity for each time.

There are five fields for volume identification:

 (1) sx_fsid is the filesystem ID as per statfs::f_fsid.

 (2) sx_volume_id is an arbitrary binary volume ID.

 (3) sx_volume_uuid is the volume UUID

 (4) sx_volume_name is a string holding the volume name

 (5) sx_domain_name is a string holding the domain/cell/workgroup/server name.

All fields except sx_mask are optional.  The fields are controlled by a
combination of the flags in st_mask and the flags in sx_mask in the following
manner:

	st_mask & STATX_ATIME		Got sx_atime_gran_*
	st_mask & STATX_BTIME		Got sx_btime_gran_*
	st_mask & STATX_CTIME		Got sx_ctime_gran_*
	st_mask & STATX_MTIME		Got sx_mtime_gran_*
	st_mask & STATX_IOC_FLAGS	Got sx_supported_ioc_flags
	sx_mask & STATX_FSID		Got sx_fsid
	sx_mask & STATX_VOLUME_ID	Got sx_volume_id
	sx_mask & STATX_VOLUME_UUID	Got sx_volume_uuid
	sx_mask & STATX_VOLUME_NAME	Got sx_volume_name
	sx_mask & STATX_DOMAIN_NAME	Got sx_domain_name

There is also spare expansion space in __spare[].  The whole structure is 512
bytes in size.


=======
TESTING
=======

The following test program can be used to test the statx system call:

	/* Test the statxat() system call
	 *
	 * Copyright (C) 2012 Red Hat, Inc. All Rights Reserved.
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
	#include <stdint.h>
	#include <string.h>
	#include <unistd.h>
	#include <fcntl.h>
	#include <time.h>
	#include <sys/syscall.h>
	#include <sys/stat.h>
	#include <sys/types.h>

	#define AT_NO_AUTOMOUNT		0x800	/* Suppress terminal automount traversal */
	#define AT_FORCE_ATTR_SYNC	0x2000	/* Force the attributes to be sync'd with the server */

	#define STATX_MODE		0x00000001U
	#define STATX_NLINK		0x00000002U
	#define STATX_UID		0x00000004U
	#define STATX_GID		0x00000008U
	#define STATX_RDEV		0x00000010U
	#define STATX_ATIME		0x00000020U
	#define STATX_MTIME		0x00000040U
	#define STATX_CTIME		0x00000080U
	#define STATX_INO		0x00000100U
	#define STATX_SIZE		0x00000200U
	#define STATX_BLOCKS		0x00000400U
	#define STATX_BLKSIZE		0x00000800U
	#define STATX_BASIC_STATS	0x00000fffU
	#define STATX_BTIME		0x00001000U
	#define STATX_VERSION		0x00002000U
	#define STATX_IOC_FLAGS		0x00004000U
	#define STATX_VOLUME_ID		0x00008000U
	#define STATX_ALL_STATS		0x0000ffffU

	struct statx_dev {
		uint32_t		major, minor;
	};

	struct statx {
		uint32_t	st_mask;
		uint32_t	st_information;
		uint32_t	st_time_gran;
		uint16_t	st_mode;
		uint16_t	__spare0;
		uint32_t	st_uid;
		uint32_t	st_gid;
		uint32_t	st_nlink;
		uint32_t	st_blksize;
		struct statx_dev st_rdev;
		struct statx_dev st_dev;
		int32_t		st_atime_ns;
		int32_t		st_btime_ns;
		int32_t		st_ctime_ns;
		int32_t		st_mtime_ns;
		int64_t		st_atim;
		int64_t		st_btim;
		int64_t		st_ctim;
		int64_t		st_mtim;
		uint64_t	st_ino;
		uint64_t	st_size;
		uint64_t	st_blocks;
		uint64_t	st_version;
		uint64_t	st_ioc_flags;
		uint8_t		st_volume_id[16];
		uint64_t	__spare1[13];
	};

	#define STATX_INFO_ENCRYPTED		0x00000001U
	#define STATX_INFO_TEMPORARY		0x00000002U
	#define STATX_INFO_FABRICATED		0x00000004U
	#define STATX_INFO_KERNEL_API		0x00000008U
	#define STATX_INFO_REMOTE		0x00000010U
	#define STATX_INFO_OFFLINE		0x00000020U
	#define STATX_INFO_AUTOMOUNT		0x00000040U
	#define STATX_INFO_AUTODIR		0x00000080U
	#define STATX_INFO_NONSYSTEM_OWNERSHIP	0x00000100U
	#define STATX_INFO_HAS_ACL		0x00000200U
	#define STATX_INFO_REPARSE_POINT	0x00000400U

	#define FS_HIDDEN_FL			0x01000000
	#define FS_SYSTEM_FL			0x02000000
	#define FS_ARCHIVE_FL			0x04000000

	#define __NR_statxat 312

	static __attribute__((unused))
	ssize_t statxat(int dfd, const char *filename, unsigned flags,
			unsigned int mask, struct statx *buffer,
			unsigned long reserved)
	{
		return syscall(__NR_statxat, dfd, filename, flags, mask, buffer,
			       reserved);
	}

	static void print_time(const char *field, int64_t tv_sec, int32_t tv_nsec)
	{
		struct tm tm;
		time_t tim;
		char buffer[100];
		int len;

		tim = tv_sec;
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
		printf(".%09u", tv_nsec);
		len = strftime(buffer, 100, "%z", &tm);
		if (len == 0) {
			perror("strftime2");
			exit(1);
		}
		fwrite(buffer, 1, len, stdout);
		printf("\n");
	}

	static void dump_statx(struct statx *stx)
	{
		char buffer[256], ft = '?';

		printf("results=%x\n", stx->st_mask);

		printf(" ");
		if (stx->st_mask & STATX_SIZE)
			printf(" Size: %-15llu", (unsigned long long) stx->st_size);
		if (stx->st_mask & STATX_BLOCKS)
			printf(" Blocks: %-10llu", (unsigned long long) stx->st_blocks);
		printf(" IO Block: %-6llu ", (unsigned long long) stx->st_blksize);
		if (stx->st_mask & STATX_MODE) {
			switch (stx->st_mode & S_IFMT) {
			case S_IFIFO:	printf(" FIFO\n");			ft = 'p'; break;
			case S_IFCHR:	printf(" character special file\n");	ft = 'c'; break;
			case S_IFDIR:	printf(" directory\n");			ft = 'd'; break;
			case S_IFBLK:	printf(" block special file\n");	ft = 'b'; break;
			case S_IFREG:	printf(" regular file\n");		ft = '-'; break;
			case S_IFLNK:	printf(" symbolic link\n");		ft = 'l'; break;
			case S_IFSOCK:	printf(" socket\n");			ft = 's'; break;
			default:
				printf("unknown type (%o)\n", stx->st_mode & S_IFMT);
				break;
			}
		}

		sprintf(buffer, "%02x:%02x", stx->st_dev.major, stx->st_dev.minor);
		printf("Device: %-15s", buffer);
		if (stx->st_mask & STATX_INO)
			printf(" Inode: %-11llu", (unsigned long long) stx->st_ino);
		if (stx->st_mask & STATX_SIZE)
			printf(" Links: %-5u", stx->st_nlink);
		if (stx->st_mask & STATX_RDEV)
			printf(" Device type: %u,%u",
			       stx->st_rdev.major, stx->st_rdev.minor);
		printf("\n");

		if (stx->st_mask & STATX_MODE)
			printf("Access: (%04o/%c%c%c%c%c%c%c%c%c%c)  ",
			       stx->st_mode & 07777,
			       ft,
			       stx->st_mode & S_IRUSR ? 'r' : '-',
			       stx->st_mode & S_IWUSR ? 'w' : '-',
			       stx->st_mode & S_IXUSR ? 'x' : '-',
			       stx->st_mode & S_IRGRP ? 'r' : '-',
			       stx->st_mode & S_IWGRP ? 'w' : '-',
			       stx->st_mode & S_IXGRP ? 'x' : '-',
			       stx->st_mode & S_IROTH ? 'r' : '-',
			       stx->st_mode & S_IWOTH ? 'w' : '-',
			       stx->st_mode & S_IXOTH ? 'x' : '-');
		if (stx->st_mask & STATX_UID)
			printf("Uid: %d   \n", stx->st_uid);
		if (stx->st_mask & STATX_GID)
			printf("Gid: %u\n", stx->st_gid);

		if (stx->st_mask & STATX_ATIME)
			print_time("Access: ", stx->st_atim, stx->st_atime_ns);
		if (stx->st_mask & STATX_MTIME)
			print_time("Modify: ", stx->st_mtim, stx->st_mtime_ns);
		if (stx->st_mask & STATX_CTIME)
			print_time("Change: ", stx->st_ctim, stx->st_ctime_ns);
		if (stx->st_mask & STATX_BTIME)
			print_time(" Birth: ", stx->st_btim, stx->st_btime_ns);

		if (stx->st_mask & STATX_VERSION)
			printf("Data version: %llxh\n", (unsigned long long) stx->st_version);

		if (stx->st_mask & STATX_IOC_FLAGS) {
			unsigned char bits;
			int loop, byte;

			static char flag_representation[32 + 1] =
				/* FS_IOC_GETFLAGS flags: */
				"?????ASH"	/* 31-24	0x00000000-ff000000 */
				"????ehTD"	/* 23-16	0x00000000-00ff0000 */
				"tj?IE?XZ"	/* 15- 8	0x00000000-0000ff00 */
				"AdaiScus"	/*  7- 0	0x00000000-000000ff */
				;

			printf("Inode flags: %08llx (", (unsigned long long)stx->st_ioc_flags);
			for (byte = 32 - 8; byte >= 0; byte -= 8) {
				bits = stx->st_ioc_flags >> byte;
				for (loop = 7; loop >= 0; loop--) {
					int bit = byte + loop;

					if (bits & 0x80)
						putchar(flag_representation[31 - bit]);
					else
						putchar('-');
					bits <<= 1;
				}
				if (byte)
					putchar(' ');
			}
			printf(")\n");
		}

		if (stx->st_information) {
			unsigned char bits;
			int loop, byte;

			static char info_representation[32 + 1] =
				/* STATX_INFO_ flags: */
				"????????"	/* 31-24	0x00000000-ff000000 */
				"????????"	/* 23-16	0x00000000-00ff0000 */
				"?????Ran"	/* 15- 8	0x00000000-0000ff00 */
				"dmorkfte"	/*  7- 0	0x00000000-000000ff */
				;

			printf("Information: %08x (", stx->st_information);
			for (byte = 32 - 8; byte >= 0; byte -= 8) {
				bits = stx->st_information >> byte;
				for (loop = 7; loop >= 0; loop--) {
					int bit = byte + loop;

					if (bits & 0x80)
						putchar(info_representation[31 - bit]);
					else
						putchar('-');
					bits <<= 1;
				}
				if (byte)
					putchar(' ');
			}
			printf(")\n");
		}

		if (stx->st_mask & STATX_VOLUME_ID) {
			int loop;
			printf("Volume ID: ");
			for (loop = 0; loop < sizeof(stx->st_volume_id); loop++) {
				printf("%02x", stx->st_volume_id[loop]);
				if (loop == 7)
					printf("-");
			}
			printf("\n");
		}
	}

	void dump_hex(unsigned long long *data, int from, int to)
	{
		unsigned offset, print_offset = 1, col = 0;

		from /= 8;
		to = (to + 7) / 8;

		for (offset = from; offset < to; offset++) {
			if (print_offset) {
				printf("%04x: ", offset * 8);
				print_offset = 0;
			}
			printf("%016llx", data[offset]);
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

	int main(int argc, char **argv)
	{
		struct statx stx;
		int ret, raw = 0, atflag = AT_SYMLINK_NOFOLLOW;

		unsigned int mask = STATX_ALL_STATS;

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
				mask &= ~STATX_BASIC_STATS;
				continue;
			}
			if (strcmp(*argv, "-A") == 0) {
				atflag |= AT_NO_AUTOMOUNT;
				continue;
			}
			if (strcmp(*argv, "-R") == 0) {
				raw = 1;
				continue;
			}

			memset(&stx, 0xbf, sizeof(stx));
			ret = statxat(AT_FDCWD, *argv, atflag, mask, &stx, 0);
			printf("statxat(%s) = %d\n", *argv, ret);
			if (ret < 0) {
				perror(*argv);
				exit(1);
			}

			if (raw)
				dump_hex((unsigned long long *)&stx, 0, sizeof(stx));

			dump_statx(&stx);
		}
		return 0;
	}

Just compile and run, passing it paths to the files you want to examine.

Here's some example output.  Firstly, an NFS directory that crosses to another
FSID.  Note that the FABRICATED and AUTOMOUNT info flags are set.  The former
because the directory is invented locally as we don't see the underlying dir on
the server, the latter because transiting this directory will cause d_automount
to be invoked by the VFS.

	[root@andromeda tmp]# ./xstat -A /warthog/data
	statxat(/warthog/data) = 0
	results=4fef
	  Size: 4096            Blocks: 8          IO Block: 1048576  directory
	Device: 00:1d           Inode: 2           Links: 110
	Access: (3777/drwxrwxrwx)  Uid: -2
	Gid: 4294967294
	Access: 2012-04-30 09:01:55.283819565+0100
	Modify: 2012-03-28 19:01:19.405465361+0100
	Change: 2012-03-28 19:01:19.405465361+0100
	Data version: ef51734f11e92a18h
	Information: 00000254 (-------- -------- ------a- -m-r-f--)

Secondly, the result of automounting on that directory.

	[root@andromeda tmp]# ./xstat /warthog/data
	statxat(/warthog/data) = 0
	results=14fef
	  Size: 4096            Blocks: 8          IO Block: 1048576  directory
	Device: 00:1e           Inode: 2           Links: 110
	Access: (3777/drwxrwxrwx)  Uid: -2
	Gid: 4294967294
	Access: 2012-04-30 09:01:55.283819565+0100
	Modify: 2012-03-28 19:01:19.405465361+0100
	Change: 2012-03-28 19:01:19.405465361+0100
	Data version: ef51734f11e92a18h
	Information: 00000210 (-------- -------- ------a- ---r----)
	Volume ID: 8c494c34de5688ac-2e61e05d5f144b8e

Signed-off-by: David Howells <dhowells@redhat.com>
---

 arch/x86/ia32/sys_ia32.c         |    2 
 arch/x86/syscalls/syscall_32.tbl |    1 
 arch/x86/syscalls/syscall_64.tbl |    1 
 fs/ceph/inode.c                  |    2 
 fs/cifs/inode.c                  |    5 -
 fs/compat.c                      |    2 
 fs/nfsd/nfsxdr.c                 |    2 
 fs/stat.c                        |  348 ++++++++++++++++++++++++++++++++++++--
 include/linux/fs.h               |    3 
 include/linux/stat.h             |   16 ++
 include/linux/syscalls.h         |    6 +
 include/uapi/linux/fcntl.h       |    1 
 include/uapi/linux/stat.h        |  164 ++++++++++++++++++
 13 files changed, 524 insertions(+), 29 deletions(-)

diff --git a/arch/x86/ia32/sys_ia32.c b/arch/x86/ia32/sys_ia32.c
index 8e0ceecdc957..3beca27ae287 100644
--- a/arch/x86/ia32/sys_ia32.c
+++ b/arch/x86/ia32/sys_ia32.c
@@ -89,7 +89,7 @@ static int cp_stat64(struct stat64 __user *ubuf, struct kstat *stat)
 	    __put_user(stat->mtime.tv_nsec, &ubuf->st_mtime_nsec) ||
 	    __put_user(stat->ctime.tv_sec, &ubuf->st_ctime) ||
 	    __put_user(stat->ctime.tv_nsec, &ubuf->st_ctime_nsec) ||
-	    __put_user(stat->blksize, &ubuf->st_blksize) ||
+	    __put_user(stat->pref_io_size, &ubuf->st_blksize) ||
 	    __put_user(stat->blocks, &ubuf->st_blocks))
 		return -EFAULT;
 	return 0;
diff --git a/arch/x86/syscalls/syscall_32.tbl b/arch/x86/syscalls/syscall_32.tbl
index aabfb8380a1c..c530b96744c2 100644
--- a/arch/x86/syscalls/syscall_32.tbl
+++ b/arch/x86/syscalls/syscall_32.tbl
@@ -357,3 +357,4 @@
 348	i386	process_vm_writev	sys_process_vm_writev		compat_sys_process_vm_writev
 349	i386	kcmp			sys_kcmp
 350	i386	finit_module		sys_finit_module
+351	i386	statxat			sys_statxat
diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
index 38ae65dfd14f..9b65dd2efb1d 100644
--- a/arch/x86/syscalls/syscall_64.tbl
+++ b/arch/x86/syscalls/syscall_64.tbl
@@ -320,6 +320,7 @@
 311	64	process_vm_writev	sys_process_vm_writev
 312	common	kcmp			sys_kcmp
 313	common	finit_module		sys_finit_module
+314	common	statxat			sys_statxat
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/fs/ceph/inode.c b/fs/ceph/inode.c
index 8549a48115f7..77bc679b68d6 100644
--- a/fs/ceph/inode.c
+++ b/fs/ceph/inode.c
@@ -1874,7 +1874,7 @@ int ceph_getattr(struct vfsmount *mnt, struct dentry *dentry,
 			else
 				stat->size = ci->i_files + ci->i_subdirs;
 			stat->blocks = 0;
-			stat->blksize = 65536;
+			stat->pref_io_size = 65536;
 		}
 	}
 	return err;
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index 867b7cdc794a..9e9f6e5784da 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -1851,7 +1851,10 @@ int cifs_getattr(struct vfsmount *mnt, struct dentry *dentry,
 		return rc;
 
 	generic_fillattr(inode, stat);
-	stat->blksize = CIFS_MAX_MSGSIZE;
+	stat->small_io_size =
+		stat->pref_io_size =
+		stat->large_io_size = CIFS_MAX_MSGSIZE;
+	stat->alloc_blksize = 0;
 	stat->ino = CIFS_I(inode)->uniqueid;
 
 	/*
diff --git a/fs/compat.c b/fs/compat.c
index 6af20de2c1a3..dcad0e6e87ce 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -155,7 +155,7 @@ static int cp_compat_stat(struct kstat *stat, struct compat_stat __user *ubuf)
 	tmp.st_ctime = stat->ctime.tv_sec;
 	tmp.st_ctime_nsec = stat->ctime.tv_nsec;
 	tmp.st_blocks = stat->blocks;
-	tmp.st_blksize = stat->blksize;
+	tmp.st_blksize = stat->pref_io_size;
 	return copy_to_user(ubuf, &tmp, sizeof(tmp)) ? -EFAULT : 0;
 }
 
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 9c769a47ac5a..dc0a8b8e772d 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -162,7 +162,7 @@ encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 	} else {
 		*p++ = htonl((u32) stat->size);
 	}
-	*p++ = htonl((u32) stat->blksize);
+	*p++ = htonl((u32) stat->pref_io_size);
 	if (S_ISCHR(type) || S_ISBLK(type))
 		*p++ = htonl(new_encode_dev(stat->rdev));
 	else
diff --git a/fs/stat.c b/fs/stat.c
index d0ea7ef75e26..a5e603753bd3 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -18,8 +18,21 @@
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
+	struct super_block *sb = inode->i_sb;
+	struct statx_auxinfo *aux = stat->auxinfo;
+	u32 x;
+
 	stat->dev = inode->i_sb->s_dev;
 	stat->ino = inode->i_ino;
 	stat->mode = inode->i_mode;
@@ -27,17 +40,87 @@ void generic_fillattr(struct inode *inode, struct kstat *stat)
 	stat->uid = inode->i_uid;
 	stat->gid = inode->i_gid;
 	stat->rdev = inode->i_rdev;
-	stat->size = i_size_read(inode);
-	stat->atime = inode->i_atime;
 	stat->mtime = inode->i_mtime;
 	stat->ctime = inode->i_ctime;
-	stat->blksize = (1 << inode->i_blkbits);
+	stat->size = i_size_read(inode);
 	stat->blocks = inode->i_blocks;
+	stat->pref_io_size =
+		stat->large_io_size =
+		stat->small_io_size =
+		stat->alloc_blksize = 1 << inode->i_blkbits;
+
+	stat->result_mask |= STATX_BASIC_STATS & ~STATX_RDEV;
+	if (IS_NOATIME(inode))
+		stat->result_mask &= ~STATX_ATIME;
+	else
+		stat->atime = inode->i_atime;
+
+	if (S_ISREG(stat->mode) && stat->nlink == 0)
+		stat->information |= STATX_INFO_TEMPORARY;
+	if (IS_AUTOMOUNT(inode))
+		stat->information |= STATX_INFO_AUTOMOUNT;
+
+	if (unlikely(S_ISBLK(stat->mode) || S_ISCHR(stat->mode)))
+		stat->result_mask |= STATX_RDEV;
+
+	if (aux) {
+		/* if unset, assume 1s granularity */
+		uint16_t mantissa = 1;
+		uint8_t exponent = 0;
+		if (sb->s_time_gran < 1000000000) {
+			if (sb->s_time_gran < 1000)
+				exponent = -9;
+			else if (sb->s_time_gran < 1000000)
+				exponent = -6;
+			else
+				exponent = -3;
+		}
+#define set_gran(x)							\
+		do {							\
+			if (aux->sx_##x##_mantissa == 0) {		\
+				aux->sx_##x##_mantissa = mantissa;	\
+				aux->sx_##x##_exponent = exponent;	\
+			}						\
+		} while (0)
+		set_gran(atime_gran);
+		set_gran(btime_gran);
+		set_gran(ctime_gran);
+		set_gran(mtime_gran);
+
+		x  = ((u32*)&aux->sx_volume_uuid)[0] = ((u32*)&sb->s_uuid)[0];
+		x |= ((u32*)&aux->sx_volume_uuid)[1] = ((u32*)&sb->s_uuid)[1];
+		x |= ((u32*)&aux->sx_volume_uuid)[2] = ((u32*)&sb->s_uuid)[2];
+		x |= ((u32*)&aux->sx_volume_uuid)[3] = ((u32*)&sb->s_uuid)[3];
+		if (x)
+			aux->sx_mask |= STATX_VOLUME_UUID;
+		if (sb->s_id[0]) {
+			memcpy(aux->sx_volume_name, sb->s_id, sizeof(sb->s_id));
+			aux->sx_volume_name[sizeof(sb->s_id)] = '\0';
+			aux->sx_mask |= STATX_VOLUME_NAME;
+		}
+	}
 }
-
 EXPORT_SYMBOL(generic_fillattr);
 
-int vfs_getattr(struct path *path, struct kstat *stat)
+/**
+ * vfs_xgetattr - Get the enhanced basic attributes of a file
+ * @path: The file of interest
+ * @stat: Where to return the statistics
+ *
+ * Ask the filesystem for a file's attributes.  The caller must have preset
+ * stat->request_mask and stat->query_flags to indicate what they want.
+ *
+ * If the file is remote, the filesystem can be forced to update the attributes
+ * from the backing store by passing AT_FORCE_ATTR_SYNC in query_flags.
+ *
+ * Bits must have been set in stat->request_mask to indicate which attributes
+ * the caller wants retrieving.  Any such attribute not requested may be
+ * returned anyway, but the value may be approximate, and, if remote, may not
+ * have been synchronised with the server.
+ *
+ * 0 will be returned on success, and a -ve error code if unsuccessful.
+ */
+int vfs_xgetattr(struct path *path, struct kstat *stat)
 {
 	struct inode *inode = path->dentry->d_inode;
 	int retval;
@@ -46,49 +129,128 @@ int vfs_getattr(struct path *path, struct kstat *stat)
 	if (retval)
 		return retval;
 
+	stat->query_flags &= ~KSTAT_QUERY_FLAGS;
+	stat->result_mask = 0;
+	stat->information = 0;
+	stat->ioc_flags = 0;
+	if (stat->auxinfo)
+		stat->auxinfo->sx_mask = 0;
 	if (inode->i_op->getattr)
 		return inode->i_op->getattr(path->mnt, path->dentry, stat);
 
 	generic_fillattr(inode, stat);
 	return 0;
 }
+EXPORT_SYMBOL(vfs_xgetattr);
 
+/**
+ * vfs_getattr - Get the basic attributes of a file
+ * @path: The file of interest
+ * @stat: Where to return the statistics
+ *
+ * Ask the filesystem for a file's attributes.  If remote, the filesystem isn't
+ * forced to update its files from the backing store.  Only the basic set of
+ * attributes will be retrieved; anyone wanting more must use vfs_xgetattr(),
+ * as must anyone who wants to force attributes to be sync'd with the server.
+ *
+ * 0 will be returned on success, and a -ve error code if unsuccessful.
+ */
+int vfs_getattr(struct path *path, struct kstat *stat)
+{
+	stat->query_flags = 0;
+	stat->request_mask = STATX_BASIC_STATS;
+	stat->auxinfo = NULL;
+	return vfs_xgetattr(path, stat);
+}
 EXPORT_SYMBOL(vfs_getattr);
 
-int vfs_fstat(unsigned int fd, struct kstat *stat)
+/**
+ * vfs_fstatx - Get the enhanced basic attributes by file descriptor
+ * @fd: The file descriptor refering to the file of interest
+ * @stat: The result structure to fill in.
+ *
+ * This function is a wrapper around vfs_xgetattr().  The main difference is
+ * that it uses a file descriptor to determine the file location.
+ *
+ * The caller must have preset stat->query_flags, stat->request_mask and
+ * stat->auxinfo as for vfs_xgetattr().
+ *
+ * 0 will be returned on success, and a -ve error code if unsuccessful.
+ */
+int vfs_fstatx(unsigned int fd, struct kstat *stat)
 {
 	struct fd f = fdget_raw(fd);
 	int error = -EBADF;
 
 	if (f.file) {
-		error = vfs_getattr(&f.file->f_path, stat);
+		error = vfs_xgetattr(&f.file->f_path, stat);
 		fdput(f);
 	}
 	return error;
 }
+EXPORT_SYMBOL(vfs_fstatx);
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
+	stat->request_mask = STATX_BASIC_STATS;
+	stat->auxinfo = NULL;
+	return vfs_fstatx(fd, stat);
+}
 EXPORT_SYMBOL(vfs_fstat);
 
-int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
-		int flag)
+/**
+ * vfs_statx - Get basic and extra attributes by filename
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
+ * The caller must have preset stat->request_mask and stat->auxinfo as for
+ * vfs_xgetattr().  The flags are also used to load up stat->query_flags.
+ *
+ * 0 will be returned on success, and a -ve error code if unsuccessful.
+ */
+int vfs_statx(int dfd, const char __user *filename, int flags,
+	      struct kstat *stat)
 {
 	struct path path;
 	int error = -EINVAL;
-	unsigned int lookup_flags = 0;
+	unsigned int lookup_flags = LOOKUP_FOLLOW | LOOKUP_AUTOMOUNT;
 
-	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
-		      AT_EMPTY_PATH)) != 0)
-		goto out;
+	if ((flags & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
+		      AT_EMPTY_PATH | KSTAT_QUERY_FLAGS)) != 0)
+		return -EINVAL;
 
-	if (!(flag & AT_SYMLINK_NOFOLLOW))
-		lookup_flags |= LOOKUP_FOLLOW;
-	if (flag & AT_EMPTY_PATH)
+	if (flags & AT_SYMLINK_NOFOLLOW)
+		lookup_flags &= ~LOOKUP_FOLLOW;
+	if (flags & AT_NO_AUTOMOUNT)
+		lookup_flags &= ~LOOKUP_AUTOMOUNT;
+	if (flags & AT_EMPTY_PATH)
 		lookup_flags |= LOOKUP_EMPTY;
+	stat->query_flags = flags & KSTAT_QUERY_FLAGS;
+
 retry:
 	error = user_path_at(dfd, filename, lookup_flags, &path);
 	if (error)
 		goto out;
 
-	error = vfs_getattr(&path, stat);
+	error = vfs_xgetattr(&path, stat);
 	path_put(&path);
 	if (retry_estale(error, lookup_flags)) {
 		lookup_flags |= LOOKUP_REVAL;
@@ -97,17 +259,67 @@ retry:
 out:
 	return error;
 }
+EXPORT_SYMBOL(vfs_statx);
+
+/**
+ * vfs_fstatat - Get basic attributes by filename
+ * @dfd: A file descriptor representing the base dir for a relative filename
+ * @filename: The name of the file of interest
+ * @flags: Flags to control the query
+ * @stat: The result structure to fill in.
+ *
+ * This function is a wrapper around vfs_statx().  The difference is that it
+ * preselects basic stats only.  The flags are used to load up
+ * stat->query_flags in addition to indicating symlink handling during path
+ * resolution.
+ *
+ * 0 will be returned on success, and a -ve error code if unsuccessful.
+ */
+int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
+		int flags)
+{
+	stat->request_mask = STATX_BASIC_STATS;
+	stat->auxinfo = NULL;
+	return vfs_statx(dfd, filename, flags, stat);
+}
 EXPORT_SYMBOL(vfs_fstatat);
 
-int vfs_stat(const char __user *name, struct kstat *stat)
+/**
+ * vfs_stat - Get basic attributes by filename
+ * @filename: The name of the file of interest
+ * @stat: The result structure to fill in.
+ *
+ * This function is a wrapper around vfs_statx().  The difference is that it
+ * preselects basic stats only, terminal symlinks are followed regardless and a
+ * remote filesystem can't be forced to query the server.  If such is desired,
+ * vfs_statx() should be used instead.
+ *
+ * 0 will be returned on success, and a -ve error code if unsuccessful.
+ */
+int vfs_stat(const char __user *filename, struct kstat *stat)
 {
-	return vfs_fstatat(AT_FDCWD, name, stat, 0);
+	stat->request_mask = STATX_BASIC_STATS;
+	stat->auxinfo = NULL;
+	return vfs_statx(AT_FDCWD, filename, 0, stat);
 }
 EXPORT_SYMBOL(vfs_stat);
 
+/**
+ * vfs_lstat - Get basic attributes by filename, without following terminal symlink
+ * @filename: The name of the file of interest
+ * @stat: The result structure to fill in.
+ *
+ * This function is a wrapper around vfs_statx().  The difference is that it
+ * preselects basic stats only, terminal symlinks are note followed regardless
+ * and a remote filesystem can't be forced to query the server.  If such is
+ * desired, vfs_statx() should be used instead.
+ *
+ * 0 will be returned on success, and a -ve error code if unsuccessful.
+ */
 int vfs_lstat(const char __user *name, struct kstat *stat)
 {
-	return vfs_fstatat(AT_FDCWD, name, stat, AT_SYMLINK_NOFOLLOW);
+	stat->auxinfo = NULL;
+	return vfs_statx(AT_FDCWD, name, AT_SYMLINK_NOFOLLOW, stat);
 }
 EXPORT_SYMBOL(vfs_lstat);
 
@@ -122,7 +334,7 @@ static int cp_old_stat(struct kstat *stat, struct __old_kernel_stat __user * sta
 {
 	static int warncount = 5;
 	struct __old_kernel_stat tmp;
-	
+
 	if (warncount > 0) {
 		warncount--;
 		printk(KERN_WARNING "VFS: Warning: %s using old stat() call. Recompile your binary.\n",
@@ -240,7 +452,7 @@ static int cp_new_stat(struct kstat *stat, struct stat __user *statbuf)
 	tmp.st_ctime_nsec = stat->ctime.tv_nsec;
 #endif
 	tmp.st_blocks = stat->blocks;
-	tmp.st_blksize = stat->blksize;
+	tmp.st_blksize = stat->pref_io_size;
 	return copy_to_user(statbuf,&tmp,sizeof(tmp)) ? -EFAULT : 0;
 }
 
@@ -426,6 +638,98 @@ SYSCALL_DEFINE4(fstatat64, int, dfd, const char __user *, filename,
 }
 #endif /* __ARCH_WANT_STAT64 || __ARCH_WANT_COMPAT_STAT64 */
 
+/*
+ * Set the statx results.
+ */
+static long statx_set_result(struct kstat *stat, struct statx __user *buffer,
+			     struct statx_auxinfo __user *auxinfo)
+{
+	u32 mask = stat->result_mask;
+	
+#define __put_timestamp(kts, uts) (				\
+		__put_user(kts.tv_sec,	uts		) ||	\
+		__put_user(kts.tv_nsec,	uts##_ns	))
+
+	if (__put_user(mask,			&buffer->st_mask	) ||
+	    __put_user(stat->mode,		&buffer->st_mode	) ||
+	    __clear_user(&buffer->__spare0, sizeof(buffer->__spare0))	  ||
+	    __put_user(stat->nlink,		&buffer->st_nlink	) ||
+	    __put_user(stat->uid,		&buffer->st_uid		) ||
+	    __put_user(stat->gid,		&buffer->st_gid		) ||
+	    __put_user(stat->information,	&buffer->st_information	) ||
+	    __put_user(stat->pref_io_size,	&buffer->st_blksize	) ||
+	    __put_user(stat->alloc_blksize,	&buffer->st_alloc_blksize) ||
+	    __put_user(stat->small_io_size,	&buffer->st_small_io_size) ||
+	    __put_user(stat->large_io_size,	&buffer->st_large_io_size) ||
+	    __put_user(MAJOR(stat->rdev),	&buffer->st_rdev.major	) ||
+	    __put_user(MINOR(stat->rdev),	&buffer->st_rdev.minor	) ||
+	    __put_user(MAJOR(stat->dev),	&buffer->st_dev.major	) ||
+	    __put_user(MINOR(stat->dev),	&buffer->st_dev.minor	) ||
+	    __put_timestamp(stat->atime,	&buffer->st_atime	) ||
+	    __put_timestamp(stat->btime,	&buffer->st_btime	) ||
+	    __put_timestamp(stat->ctime,	&buffer->st_ctime	) ||
+	    __put_timestamp(stat->mtime,	&buffer->st_mtime	) ||
+	    __put_user(stat->ino,		&buffer->st_ino		) ||
+	    __put_user(stat->size,		&buffer->st_size	) ||
+	    __put_user(stat->blocks,		&buffer->st_blocks	) ||
+	    __put_user(stat->version,		&buffer->st_version	) ||
+	    __put_user(stat->ioc_flags,		&buffer->st_ioc_flags	) ||
+	    __clear_user(&buffer->__spare1, sizeof(buffer->__spare1)))
+		return -EFAULT;
+
+	if (auxinfo && copy_to_user(auxinfo, stat->auxinfo, sizeof(*auxinfo)))
+		return -EFAULT;
+
+	return 0;
+}
+
+/**
+ * sys_statxat - System call to get enhanced stats
+ * @dfd: Base directory to pathwalk from *or* fd to stat.
+ * @filename: File to stat *or* NULL.
+ * @flags: AT_* flags to control pathwalk.
+ * @mask: Parts of stat struct actually required.
+ * @buffer: Result buffer.
+ * @auxinfo: Auxiliary information result buffer (may be NULL).
+ *
+ * Note that if filename is NULL, then it does the equivalent of fstat() using
+ * dfd to indicate the file of interest.
+ */
+SYSCALL_DEFINE6(statxat,
+		int, dfd, const char __user *, filename, unsigned, flags,
+		unsigned int, mask,
+		struct statx __user *, buffer,
+		struct statx_auxinfo __user *, auxinfo)
+{
+	struct statx_auxinfo *aux = NULL;
+	struct kstat stat;
+	int error;
+
+	if (!access_ok(VERIFY_WRITE, buffer, sizeof(*buffer)) ||
+	    (auxinfo && !access_ok(VERIFY_WRITE, auxinfo, sizeof(*auxinfo))))
+		return -EFAULT;
+
+	memset(&stat, 0, sizeof(stat));
+	stat.query_flags = flags;
+	stat.request_mask = mask & STATX_ALL_STATS;
+
+	if (auxinfo) {
+		aux = kzalloc(sizeof(*aux), GFP_KERNEL);
+		if (!aux)
+			return -ENOMEM;
+		stat.auxinfo = aux;
+	}
+	if (filename)
+		error = vfs_statx(dfd, filename, flags, &stat);
+	else
+		error = vfs_fstatx(dfd, &stat);
+	if (error)
+		return error;
+	error = statx_set_result(&stat, buffer, auxinfo);
+	kfree(aux);
+	return error;
+}
+
 /* Caller is here responsible for sufficient locking (ie. inode->i_lock) */
 void __inode_add_bytes(struct inode *inode, loff_t bytes)
 {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 955dff5da56a..f9c071cbe7fc 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2510,6 +2510,7 @@ extern const struct inode_operations page_symlink_inode_operations;
 extern int generic_readlink(struct dentry *, char __user *, int);
 extern void generic_fillattr(struct inode *, struct kstat *);
 extern int vfs_getattr(struct path *, struct kstat *);
+extern int vfs_xgetattr(struct path *, struct kstat *);
 void __inode_add_bytes(struct inode *inode, loff_t bytes);
 void inode_add_bytes(struct inode *inode, loff_t bytes);
 void __inode_sub_bytes(struct inode *inode, loff_t bytes);
@@ -2524,6 +2525,8 @@ extern int vfs_stat(const char __user *, struct kstat *);
 extern int vfs_lstat(const char __user *, struct kstat *);
 extern int vfs_fstat(unsigned int, struct kstat *);
 extern int vfs_fstatat(int , const char __user *, struct kstat *, int);
+extern int vfs_xstat(int, const char __user *, int, struct kstat *);
+extern int vfs_xfstat(unsigned int, struct kstat *);
 
 extern int do_vfs_ioctl(struct file *filp, unsigned int fd, unsigned int cmd,
 		    unsigned long arg);
diff --git a/include/linux/stat.h b/include/linux/stat.h
index 075cb0c7eb2a..93a0275af21d 100644
--- a/include/linux/stat.h
+++ b/include/linux/stat.h
@@ -19,6 +19,12 @@
 #include <linux/uidgid.h>
 
 struct kstat {
+	u32		query_flags;		/* operational flags */
+#define KSTAT_QUERY_FLAGS (AT_FORCE_ATTR_SYNC)
+	u32		request_mask;		/* what fields the user asked for */
+	u32		result_mask;		/* what fields the user got */
+	u32		information;
+	u64		ioc_flags;		/* inode flags (FS_IOC_GETFLAGS) */
 	u64		ino;
 	dev_t		dev;
 	umode_t		mode;
@@ -27,11 +33,17 @@ struct kstat {
 	kgid_t		gid;
 	dev_t		rdev;
 	loff_t		size;
-	struct timespec  atime;
+	struct timespec	atime;
 	struct timespec	mtime;
 	struct timespec	ctime;
-	unsigned long	blksize;
+	struct timespec	btime;			/* file creation time */
+	uint32_t	alloc_blksize;
+	uint32_t	small_io_size;
+	uint32_t	pref_io_size; 
+	uint32_t	large_io_size;
 	unsigned long long	blocks;
+	u64		version;		/* data version */
+	struct statx_auxinfo *auxinfo;		/* where to store the aux info (may be NULL) */
 };
 
 #endif
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 7fac04e7ff6e..387e7669ab03 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -47,6 +47,8 @@ struct stat;
 struct stat64;
 struct statfs;
 struct statfs64;
+struct statx;
+struct statx_auxinfo;
 struct __sysctl_args;
 struct sysinfo;
 struct timespec;
@@ -847,4 +849,8 @@ asmlinkage long sys_process_vm_writev(pid_t pid,
 asmlinkage long sys_kcmp(pid_t pid1, pid_t pid2, int type,
 			 unsigned long idx1, unsigned long idx2);
 asmlinkage long sys_finit_module(int fd, const char __user *uargs, int flags);
+asmlinkage long sys_statxat(int dfd, const char __user *path, unsigned flags,
+			    unsigned mask, struct statx __user *buffer,
+			    struct statx_auxinfo __user *auxinfo);
+
 #endif
diff --git a/include/uapi/linux/fcntl.h b/include/uapi/linux/fcntl.h
index 074b886c6be0..84d32c3d353d 100644
--- a/include/uapi/linux/fcntl.h
+++ b/include/uapi/linux/fcntl.h
@@ -47,6 +47,7 @@
 #define AT_SYMLINK_FOLLOW	0x400   /* Follow symbolic links.  */
 #define AT_NO_AUTOMOUNT		0x800	/* Suppress terminal automount traversal */
 #define AT_EMPTY_PATH		0x1000	/* Allow empty relative pathname */
+#define AT_FORCE_ATTR_SYNC	0x2000	/* Force the attributes to be sync'd with the server */
 
 
 #endif /* _UAPI_LINUX_FCNTL_H */
diff --git a/include/uapi/linux/stat.h b/include/uapi/linux/stat.h
index 7fec7e36d921..6ada2b1e36e0 100644
--- a/include/uapi/linux/stat.h
+++ b/include/uapi/linux/stat.h
@@ -1,6 +1,7 @@
 #ifndef _UAPI_LINUX_STAT_H
 #define _UAPI_LINUX_STAT_H
 
+#include <linux/types.h>
 
 #if defined(__KERNEL__) || !defined(__GLIBC__) || (__GLIBC__ < 2)
 
@@ -41,5 +42,168 @@
 
 #endif
 
+/*
+ * Structures for the extended file attribute retrieval system call
+ * (statxat()).
+ *
+ * The caller passes a mask of what they're specifically interested in as a
+ * parameter to statxat().  What statxat() actually got will be indicated in
+ * st_mask upon return.
+ *
+ * For each bit in the mask argument:
+ *
+ * - if the datum is not available at all, the field and the bit will both be
+ *   cleared;
+ *
+ * - otherwise, if explicitly requested:
+ *
+ *   - the datum will be synchronised to the server if AT_FORCE_ATTR_SYNC is
+ *     set or if the datum is considered out of date, and
+ *
+ *   - the field will be filled in and the bit will be set;
+ *
+ * - otherwise, if not requested, but available in approximate form without any
+ *   effort, it will be filled in anyway, and the bit will be set upon return
+ *   (it might not be up to date, however, and no attempt will be made to
+ *   synchronise the internal state first);
+ *
+ * - otherwise the field and the bit will be cleared before returning.
+ *
+ * Items in STATX_BASIC_STATS may be marked unavailable on return, but they
+ * will have values installed for compatibility purposes so that stat() and
+ * co. can be emulated in userspace.
+ */
+struct statx_dev {
+	uint32_t	major, minor;
+};
+
+struct statx {
+	/* 0x00 */
+	uint32_t	st_mask;	/* What results were written */
+	uint32_t	st_information;	/* Information about the file */
+	uint16_t	st_mode;	/* File mode */
+	uint16_t	__spare0[1];
+	/* 0xc */
+	uint32_t	st_nlink;	/* Number of hard links */
+	uint32_t	st_uid;		/* User ID of owner */
+	uint32_t	st_gid;		/* Group ID of owner */
+	/* 0x18 - I/O parameters */
+	uint32_t	st_alloc_blksize; /* Allocation block size/alignment */
+	uint32_t	st_blksize;	/* Preferred I/O size for general usage (st_blksize) */
+	uint32_t	st_small_io_size; /* I/O size/alignment that avoids fs/page cache RMW */
+	uint32_t	st_large_io_size; /* I/O size/alignment for high bandwidth sequential I/O */
+	/* 0x28 */
+	struct statx_dev st_rdev;	/* Device ID of special file */
+	struct statx_dev st_dev;	/* ID of device containing file */
+	/* 0x38 */
+	int32_t		st_atime_ns;	/* Last access time (ns part) */
+	int32_t		st_btime_ns;	/* File creation time (ns part) */
+	int32_t		st_ctime_ns;	/* Last attribute change time (ns part) */
+	int32_t		st_mtime_ns;	/* Last data modification time (ns part) */
+	/* 0x48 */
+	int64_t		st_atime;	/* Last access time */
+	int64_t		st_btime;	/* File creation time */
+	int64_t		st_ctime;	/* Last attribute change time */
+	int64_t		st_mtime;	/* Last data modification time */
+	/* 0x68 */
+	uint64_t	st_ino;		/* Inode number */
+	uint64_t	st_size;	/* File size */
+	uint64_t	st_blocks;	/* Number of 512-byte blocks allocated */
+	uint64_t	st_version;	/* Data version number */
+	uint64_t	st_ioc_flags;	/* As FS_IOC_GETFLAGS */
+	/* 0x90 */
+	uint64_t	__spare1[14];	/* Spare space for future expansion */
+	/* 0x100 */
+};
+
+/*
+ * Flags to be st_mask
+ *
+ * Query request/result mask for statxat() and struct statx::st_mask.
+ *
+ * These bits should be set in the mask argument of statxat() to request
+ * particular items when calling statxat().
+ */
+#define STATX_MODE		0x00000001U	/* Want/got st_mode */
+#define STATX_NLINK		0x00000002U	/* Want/got st_nlink */
+#define STATX_UID		0x00000004U	/* Want/got st_uid */
+#define STATX_GID		0x00000008U	/* Want/got st_gid */
+#define STATX_RDEV		0x00000010U	/* Want/got st_rdev */
+#define STATX_ATIME		0x00000020U	/* Want/got st_atime */
+#define STATX_MTIME		0x00000040U	/* Want/got st_mtime */
+#define STATX_CTIME		0x00000080U	/* Want/got st_ctime */
+#define STATX_INO		0x00000100U	/* Want/got st_ino */
+#define STATX_SIZE		0x00000200U	/* Want/got st_size */
+#define STATX_BLOCKS		0x00000400U	/* Want/got st_blocks */
+#define STATX_ALLOC_BLKSIZE	0x00000800U	/* Want/got st_alloc_blksize */
+#define STATX_IO_PARAMS		0x00000800U	/* Want/got I/O parameters */
+#define STATX_BASIC_STATS	0x00000fffU	/* The stuff in the normal stat struct */
+#define STATX_BTIME		0x00001000U	/* Want/got st_btime */
+#define STATX_VERSION		0x00002000U	/* Want/got st_version */
+#define STATX_IOC_FLAGS		0x00004000U	/* Want/got FS_IOC_GETFLAGS */
+#define STATX_ALL_STATS		0x00007fffU	/* All supported stats */
+
+/*
+ * Flags to be found in st_information
+ *
+ * These give information about the features or the state of a file that might
+ * be of use to ordinary userspace programs such as GUIs or ls rather than
+ * specialised tools.
+ *
+ * Additional information may be found in st_ioc_flags and we try not to
+ * overlap with it.
+ */
+#define STATX_INFO_ENCRYPTED		0x00000001U /* File is encrypted */
+#define STATX_INFO_TEMPORARY		0x00000002U /* File is temporary (NTFS/CIFS) */
+#define STATX_INFO_FABRICATED		0x00000004U /* File was made up by filesystem */
+#define STATX_INFO_KERNEL_API		0x00000008U /* File is kernel API (eg: procfs/sysfs) */
+#define STATX_INFO_REMOTE		0x00000010U /* File is remote */
+#define STATX_INFO_OFFLINE		0x00000020U /* File is offline (CIFS) */
+#define STATX_INFO_AUTOMOUNT		0x00000040U /* Dir is automount trigger */
+#define STATX_INFO_AUTODIR		0x00000080U /* Dir provides unlisted automounts */
+#define STATX_INFO_NONSYSTEM_OWNERSHIP	0x00000100U /* File has non-system ownership details */
+#define STATX_INFO_REPARSE_POINT	0x00000200U /* File is reparse point (NTFS/CIFS) */
+
+/*
+ * Auxiliary information struct for statxat().
+ */
+struct statx_auxinfo {
+	/* 0x00 - General info */
+	uint32_t	sx_mask;	/* What optional fields are filled in */
+	uint32_t	sx_fstype;	/* Filesystem type from linux/magic.h */
+	/* 0x08 */
+	uint64_t	sx_supported_ioc_flags; /* supported FS_IOC_GETFLAGS flags  */
+	uint64_t	sx_fsid;	/* Short 64-bit Filesystem ID (as statfs) */
+	/* 0x18 */
+	uint64_t	__spare[13];
+	/* 0x90 */
+	uint8_t		sx_volume_id[16]; /* Volume/fs identifier */
+	uint8_t		sx_volume_uuid[16]; /* Volume/fs UUID */
+
+	/* 0xb0 - file timestamp granularity info */
+	uint16_t	sx_atime_gran_mantissa;	/* gran(secs) = mant * 10^exp */
+	uint16_t	sx_btime_gran_mantissa;
+	uint16_t	sx_ctime_gran_mantissa;
+	uint16_t	sx_mtime_gran_mantissa;
+	/* 0xb8 */
+	int8_t		sx_atime_gran_exponent;
+	int8_t		sx_btime_gran_exponent;
+	int8_t		sx_ctime_gran_exponent;
+	int8_t		sx_mtime_gran_exponent;
+	/* 0xbc */
+	uint8_t		sx_volume_name[66 + 1]; /* Volume name */
+	/* 0xff */
+	uint8_t		sx_domain_name[256 + 1]; /* Domain/cell/workgroup name */
+	/* 0x200 */
+};
+
+/*
+ * Flags to be found in sx_mask.
+ */
+#define STATX_FSID		0x00000001	/* Got sx_fsid */
+#define STATX_VOLUME_ID		0x00000002	/* Got sx_volume_id */
+#define STATX_VOLUME_UUID	0x00000004	/* Got sx_volume_uuid */
+#define STATX_VOLUME_NAME	0x00000008	/* Got sx_volume_name */
+#define STATX_DOMAIN_NAME	0x00000010	/* Got sx_domain_name */
 
 #endif /* _UAPI_LINUX_STAT_H */

