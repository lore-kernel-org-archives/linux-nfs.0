Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40963 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757677Ab2DXV3h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 17:29:37 -0400
Date: Tue, 24 Apr 2012 17:29:11 -0400
To: David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org, wine-devel@winehq.org, kfm-devel@kde.org,
        nautilus-list@gnome.org, linux-api@vger.kernel.org,
        libc-alpha@sourceware.org
Subject: Re: [PATCH 1/6] xstat: Add a pair of system calls to make extended
 file stats available
Message-ID: <20120424212911.GA26073@fieldses.org>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
 <20120419140612.17272.57774.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120419140612.17272.57774.stgit@warthog.procyon.org.uk>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 19, 2012 at 03:06:12PM +0100, David Howells wrote:
> Add a pair of system calls to make extended file stats available, including
> file creation time, inode version and data version where available through the
> underlying filesystem.
> 
> The idea was initially proposed as a set of xattrs that could be retrieved with
> getxattr(), but the general preferance proved to be for new syscalls with an
> extended stat structure.
> 
> This has a number of uses:
> 
>  (1) Creation time: The SMB protocol carries the creation time, which could be
>      exported by Samba, which will in turn help CIFS make use of FS-Cache as
>      that can be used for coherency data.
> 
>      This is also specified in NFSv4 as a recommended attribute and could be
>      exported by NFSD [Steve French].
> 
>  (2) Lightweight stat: Ask for just those details of interest, and allow a
>      netfs (such as NFS) to approximate anything not of interest, possibly
>      without going to the server [Trond Myklebust, Ulrich Drepper].
> 
>  (3) Heavyweight stat: Force a netfs to go to the server, even if it thinks its
>      cached attributes are up to date [Trond Myklebust].
> 
>  (4) Inode generation number: Useful for FUSE and userspace NFS servers [Bernd
>      Schubert].
> 
>  (5) Data version number: Could be used by userspace NFS servers [Aneesh Kumar].
> 
>      Can also be used to modify fill_post_wcc() in NFSD which retrieves
>      i_version directly, but has just called vfs_getattr().  It could get it
>      from the kstat struct if it used vfs_xgetattr() instead.
> 
>  (6) BSD stat compatibility: Including more fields from the BSD stat such as
>      creation time (st_btime) and inode generation number (st_gen) [Jeremy
>      Allison, Bernd Schubert].
> 
>  (7) Extra coherency data may be useful in making backups [Andreas Dilger].
> 
>  (8) Allow the filesystem to indicate what it can/cannot provide: A filesystem
>      can now say it doesn't support a standard stat feature if that isn't
>      available, so if, for instance, inode numbers or UIDs don't exist...
> 
>  (9) Make the fields a consistent size on all arches and make them large.
> 
> (10) Store a 16-byte volume ID in the superblock that can be returned in struct
>      xstat [Steve French].
> 
> (11) Include granularity fields in the time data to indicate the granularity of
>      each of the times (NFSv4 time_delta) [Steve French].

It looks like you're including this with *each* time?  But surely
there's no filesystem with different granularity (say) for ctime than
for mtime.  Also, nfsd will want only one time_delta, not one for each
time.

Note also we need to document carefully what this means: I think it
should be the granularity that the filesystem is capable of
representing, but people are sometimes surprised to find out that the
actual time source is usually more coarse-grained than that.

--b.

> 
> (12) FS_IOC_GETFLAGS value.  These could be translated to BSD's st_flags.
> 
> (13) Mask of features available on file (eg: ACLs, seclabel) [Brad Boyer,
>      Michael Kerrisk].
> 
> (14) Spare space, request flags and information flags are provided for future
>      expansion.
> 
> 
> The following structures are defined for the use of these new system calls:
> 
> 	struct xstat_dev {
> 		uint32_t		major, minor;
> 	};
> 
> 	struct xstat_time {
> 		uint64_t		tv_sec;
> 		uint32_t		tv_nsec;
> 		uint32_t		tv_granularity;
> 	};
> 
> 	struct xstat {
> 		uint32_t		st_mask;
> 		uint32_t		st_mode;
> 		uint32_t		st_nlink;
> 		uint32_t		st_uid;
> 		uint32_t		st_gid;
> 		uint32_t		st_information;
> 		uint32_t		st_ioc_flags;
> 		uint32_t		st_blksize;
> 		struct xstat_dev	st_rdev;
> 		struct xstat_dev	st_dev;
> 		struct xstat_time	st_atime;
> 		struct xstat_time	st_btime;
> 		struct xstat_time	st_ctime;
> 		struct xstat_time	st_mtime;
> 		uint64_t		st_ino;
> 		uint64_t		st_size;
> 		uint64_t		st_blocks;
> 		uint64_t		st_gen;
> 		uint64_t		st_version;
> 		uint8_t			st_volume_id[16];
> 		uint64_t		__spares[11];
> 	};
> 
> where st_information is local system information about the file, st_btime is
> the file creation time, st_gen is the inode generation (i_generation),
> st_data_version is the data version number (i_version), st_ioc_flags is the
> flags from FS_IOC_GETFLAGS, st_volume_id is where the volume identified is
> stored, st_result_mask is a bitmask indicating the data provided and __spares[]
> are where as-yet undefined fields can be placed.
> 
> The defined bits in request_mask and st_mask are:
> 
> 	XSTAT_MODE		Want/got st_mode
> 	XSTAT_NLINK		Want/got st_nlink
> 	XSTAT_UID		Want/got st_uid
> 	XSTAT_GID		Want/got st_gid
> 	XSTAT_RDEV		Want/got st_rdev
> 	XSTAT_ATIME		Want/got st_atime
> 	XSTAT_MTIME		Want/got st_mtime
> 	XSTAT_CTIME		Want/got st_ctime
> 	XSTAT_INO		Want/got st_ino
> 	XSTAT_SIZE		Want/got st_size
> 	XSTAT_BLOCKS		Want/got st_blocks
> 	XSTAT_BASIC_STATS	[The stuff in the normal stat struct]
> 	XSTAT_IOC_FLAGS		Want/got FS_IOC_GETFLAGS
> 	XSTAT_BTIME		Want/got st_btime
> 	XSTAT_GEN		Want/got st_gen
> 	XSTAT_VERSION		Want/got st_data_version
> 	XSTAT_VOLUME_ID		Want/got st_volume_id
> 	XSTAT_ALL_STATS		[All currently available stuff]
> 
> The defined bits in st_ioc_flags are the usual FS_xxx_FL, plus some extra flags
> that might be supplied by the filesystem.  Note that Ext4 returns flags outside
> of {EXT4,FS}_FL_USER_VISIBLE in response to FS_IOC_GETFLAGS.  Should
> {EXT4,FS}_FL_USER_VISIBLE be extended to cover them?  Or should the extra flags
> be suppressed?
> 
> The defined bits in the st_information field give local system data on a file,
> how it is accessed, where it is and what it does:
> 
> 	XSTAT_INFO_ENCRYPTED		File is encrypted
> 	XSTAT_INFO_TEMPORARY		File is temporary (NTFS/CIFS/deleted)
> 	XSTAT_INFO_FABRICATED		File was made up by filesystem
> 	XSTAT_INFO_KERNEL_API		File is kernel API (eg: procfs/sysfs)
> 	XSTAT_INFO_REMOTE		File is remote
> 	XSTAT_INFO_OFFLINE		File is offline (CIFS)
> 	XSTAT_INFO_AUTOMOUNT		Dir is automount trigger
> 	XSTAT_INFO_AUTODIR		Dir provides unlisted automounts
> 	XSTAT_INFO_NONSYSTEM_OWNERSHIP	File has non-system ownership details
> 	XSTAT_INFO_HAS_ACL		File has an ACL of some sort
> 	XSTAT_INFO_REPARSE_POINT	File is reparse point (NTFS/CIFS)
> 	XSTAT_INFO_HIDDEN		File is marked hidden (DOS+)
> 	XSTAT_INFO_SYSTEM		File is marked system (DOS+)
> 	XSTAT_INFO_ARCHIVE		File is marked archive (DOS+)
> 
> These are for the use of GUI tools that might want to mark files specially,
> depending on what they are.  I've tried not to provide overlap with
> st_ioc_flags where something usable exists there.  Should Hidden, System and
> Archive flags be associated with ioc_flags, perhaps with ioc_flags extended to
> 64-bits?
> 
> 
> The system calls are:
> 
> 	ssize_t ret = xstat(int dfd,
> 			    const char *filename,
> 			    unsigned int flags,
> 			    unsigned int mask,
> 			    struct xstat *buffer);
> 
> 	ssize_t ret = fxstat(unsigned fd,
> 			     unsigned int flags,
> 			     unsigned int mask,
> 			     struct xstat *buffer);
> 
> 
> The dfd, filename, flags and fd parameters indicate the file to query.  There
> is no equivalent of lstat() as that can be emulated with xstat() by passing
> AT_SYMLINK_NOFOLLOW in flags.
> 
> AT_FORCE_ATTR_SYNC can also be set in flags.  This will require a network
> filesystem to synchronise its attributes with the server.
> 
> mask is a bitmask indicating the fields in struct xstat that are of interest to
> the caller.  The user should set this to XSTAT__BASIC_STATS to get the
> basic set returned by stat().
> 
> Should there just be one xstat() syscall that does fxstat() if filename is NULL?
> 
> The fields in struct xstat come in a number of classes:
> 
>  (0) st_dev, st_blksize, st_information.
> 
>      These are local data and are always available.
> 
>  (1) st_mode, st_nlinks, st_uid, st_gid, st_[amc]time, st_ino, st_size,
>      st_blocks.
> 
>      These will be returned whether the caller asks for them or not.  The
>      corresponding bits in result_mask will be set to indicate their presence.
> 
>      If the caller didn't ask for them, then they may be approximated.  For
>      example, NFS won't waste any time updating them from the server, unless as
>      a byproduct of updating something requested.
> 
>      If the values don't actually exist for the underlying object (such as UID
>      or GID on a DOS file), then the bit won't be set in the result_mask, even
>      if the caller asked for the value and the returned value will be a
>      fabrication.
> 
>  (2) st_rdev.
> 
>      As for class (1), but this won't be returned if the file is not a blockdev
>      or chardev.  The bit will be cleared if the value is not returned.
> 
>  (3) File creation time (st_btime), inode generation (st_gen), data version
>      (st_version), volume_id (st_volume_id) and inode flags (st_ioc_flags).
> 
>      These will be returned if available whether the caller asked for them or
>      not.  The corresponding bits in result_mask will be set or cleared as
>      appropriate to indicate their presence.
> 
>      If the caller didn't ask for them, then they may be approximated.  For
>      example, NFS won't waste any time updating them from the server, unless
>      as a byproduct of updating something requested.
> 
> At the moment, this will only work on x86_64 and i386 as it requires system
> calls to be wired up.
> 
> 
> =======
> TESTING
> =======
> 
> The following test program can be used to test the xstat system call:
> 
> 	/* Test the xstat() system call
> 	 *
> 	 * Copyright (C) 2010 Red Hat, Inc. All Rights Reserved.
> 	 * Written by David Howells (dhowells@redhat.com)
> 	 *
> 	 * This program is free software; you can redistribute it and/or
> 	 * modify it under the terms of the GNU General Public Licence
> 	 * as published by the Free Software Foundation; either version
> 	 * 2 of the Licence, or (at your option) any later version.
> 	 */
> 
> 	#define _GNU_SOURCE
> 	#define _ATFILE_SOURCE
> 	#include <stdio.h>
> 	#include <stdlib.h>
> 	#include <string.h>
> 	#include <unistd.h>
> 	#include <fcntl.h>
> 	#include <time.h>
> 	#include <sys/syscall.h>
> 	#include <sys/stat.h>
> 	#include <sys/types.h>
> 
> 	#define AT_NO_AUTOMOUNT		0x800
> 	#define AT_FORCE_ATTR_SYNC	0x2000
> 
> 	#define XSTAT_MODE		0x00000001U
> 	#define XSTAT_NLINK		0x00000002U
> 	#define XSTAT_UID		0x00000004U
> 	#define XSTAT_GID		0x00000008U
> 	#define XSTAT_RDEV		0x00000010U
> 	#define XSTAT_ATIME		0x00000020U
> 	#define XSTAT_MTIME		0x00000040U
> 	#define XSTAT_CTIME		0x00000080U
> 	#define XSTAT_INO		0x00000100U
> 	#define XSTAT_SIZE		0x00000200U
> 	#define XSTAT_BLOCKS		0x00000400U
> 	#define XSTAT_BASIC_STATS	0x000007ffU
> 	#define XSTAT_BTIME		0x00000800U
> 	#define XSTAT_GEN		0x00001000U
> 	#define XSTAT_VERSION		0x00002000U
> 	#define XSTAT_IOC_FLAGS		0x00004000U
> 	#define XSTAT_VOLUME_ID		0x00008000U
> 	#define XSTAT_ALL_STATS		0x0000ffffU
> 
> 	struct xstat_dev {
> 		uint32_t		major;
> 		uint32_t		minor;
> 	};
> 
> 	struct xstat_time {
> 		uint64_t		tv_sec;
> 		uint32_t		tv_nsec;
> 		uint32_t		tv_granularity;
> 	};
> 
> 	struct xstat {
> 		uint32_t		st_mask;
> 		uint32_t		st_mode;
> 		uint32_t		st_nlink;
> 		uint32_t		st_uid;
> 		uint32_t		st_gid;
> 		uint32_t		st_information;
> 		uint32_t		st_ioc_flags;
> 		uint32_t		st_blksize;
> 		struct xstat_dev	st_rdev;
> 		struct xstat_dev	st_dev;
> 		struct xstat_time	st_atim;
> 		struct xstat_time	st_btim;
> 		struct xstat_time	st_ctim;
> 		struct xstat_time	st_mtim;
> 		uint64_t		st_ino;
> 		uint64_t		st_size;
> 		uint64_t		st_blksize;
> 		uint64_t		st_blocks;
> 		uint64_t		st_gen;
> 		uint64_t		st_version;
> 		uint64_t		st_volume_id[16];
> 		uint64_t		st_spares[11];
> 	};
> 
> 	#define XSTAT_INFO_ENCRYPTED		0x00000001U
> 	#define XSTAT_INFO_TEMPORARY		0x00000002U
> 	#define XSTAT_INFO_FABRICATED		0x00000004U
> 	#define XSTAT_INFO_KERNEL_API		0x00000008U
> 	#define XSTAT_INFO_REMOTE		0x00000010U
> 	#define XSTAT_INFO_OFFLINE		0x00000020U
> 	#define XSTAT_INFO_AUTOMOUNT		0x00000040U
> 	#define XSTAT_INFO_AUTODIR		0x00000080U
> 	#define XSTAT_INFO_NONSYSTEM_OWNERSHIP	0x00000100U
> 	#define XSTAT_INFO_HAS_ACL		0x00000200U
> 	#define XSTAT_INFO_REPARSE_POINT	0x00000400U
> 	#define XSTAT_INFO_HIDDEN		0x00000800U
> 	#define XSTAT_INFO_SYSTEM		0x00001000U
> 	#define XSTAT_INFO_ARCHIVE		0x00002000U
> 
> 	#define __NR_xstat				312
> 	#define __NR_fxstat				313
> 
> 	static __attribute__((unused))
> 	ssize_t xstat(int dfd, const char *filename, unsigned flags,
> 		      unsigned int mask, struct xstat *buffer)
> 	{
> 		return syscall(__NR_xstat, dfd, filename, flags, mask, buffer);
> 	}
> 
> 	static __attribute__((unused))
> 	ssize_t fxstat(int fd, unsigned flags,
> 		       unsigned int mask, struct xstat *buffer)
> 	{
> 		return syscall(__NR_fxstat, fd, flags, mask, buffer);
> 	}
> 
> 	static void print_time(const char *field, const struct xstat_time *xstm)
> 	{
> 		struct tm tm;
> 		time_t tim;
> 		char buffer[100];
> 		int len;
> 
> 		tim = xstm->tv_sec;
> 		if (!localtime_r(&tim, &tm)) {
> 			perror("localtime_r");
> 			exit(1);
> 		}
> 		len = strftime(buffer, 100, "%F %T", &tm);
> 		if (len == 0) {
> 			perror("strftime");
> 			exit(1);
> 		}
> 		printf("%s", field);
> 		fwrite(buffer, 1, len, stdout);
> 		printf(".%09u", xstm->tv_nsec);
> 		len = strftime(buffer, 100, "%z", &tm);
> 		if (len == 0) {
> 			perror("strftime2");
> 			exit(1);
> 		}
> 		fwrite(buffer, 1, len, stdout);
> 		printf("\n");
> 	}
> 
> 	static void dump_xstat(struct xstat *xst)
> 	{
> 		char buffer[256], ft;
> 
> 		printf("results=%x\n", xst->st_mask);
> 
> 		printf(" ");
> 		if (xst->st_mask & XSTAT_SIZE)
> 			printf(" Size: %-15llu", (unsigned long long) xst->st_size);
> 		if (xst->st_mask & XSTAT_BLOCKS)
> 			printf(" Blocks: %-10llu", (unsigned long long) xst->st_blocks);
> 		printf(" IO Block: %-6llu ", (unsigned long long) xst->st_blksize);
> 		if (xst->st_mask & XSTAT_MODE) {
> 			switch (xst->st_mode & S_IFMT) {
> 			case S_IFIFO:	printf(" FIFO\n");			ft = 'p'; break;
> 			case S_IFCHR:	printf(" character special file\n");	ft = 'c'; break;
> 			case S_IFDIR:	printf(" directory\n");			ft = 'd'; break;
> 			case S_IFBLK:	printf(" block special file\n");	ft = 'b'; break;
> 			case S_IFREG:	printf(" regular file\n");		ft = '-'; break;
> 			case S_IFLNK:	printf(" symbolic link\n");		ft = 'l'; break;
> 			case S_IFSOCK:	printf(" socket\n");			ft = 's'; break;
> 			default:
> 				printf("unknown type (%o)\n", xst->st_mode & S_IFMT);
> 				ft = '?';
> 				break;
> 			}
> 		}
> 
> 		sprintf(buffer, "%02x:%02x", xst->st_dev.major, xst->st_dev.minor);
> 		printf("Device: %-15s", buffer);
> 		if (xst->st_mask & XSTAT_INO)
> 			printf(" Inode: %-11llu", (unsigned long long) xst->st_ino);
> 		if (xst->st_mask & XSTAT_SIZE)
> 			printf(" Links: %-5u", xst->st_nlink);
> 		if (xst->st_mask & XSTAT_RDEV)
> 			printf(" Device type: %u,%u",
> 			       xst->st_rdev.major, xst->st_rdev.minor);
> 		printf("\n");
> 
> 		if (xst->st_mask & XSTAT_MODE)
> 			printf("Access: (%04o/%c%c%c%c%c%c%c%c%c%c)  ",
> 			       xst->st_mode & 07777,
> 			       ft,
> 			       xst->st_mode & S_IRUSR ? 'r' : '-',
> 			       xst->st_mode & S_IWUSR ? 'w' : '-',
> 			       xst->st_mode & S_IXUSR ? 'x' : '-',
> 			       xst->st_mode & S_IRGRP ? 'r' : '-',
> 			       xst->st_mode & S_IWGRP ? 'w' : '-',
> 			       xst->st_mode & S_IXGRP ? 'x' : '-',
> 			       xst->st_mode & S_IROTH ? 'r' : '-',
> 			       xst->st_mode & S_IWOTH ? 'w' : '-',
> 			       xst->st_mode & S_IXOTH ? 'x' : '-');
> 		if (xst->st_mask & XSTAT_UID)
> 			printf("Uid: %d   \n", xst->st_uid);
> 		if (xst->st_mask & XSTAT_GID)
> 			printf("Gid: %u\n", xst->st_gid);
> 
> 		if (xst->st_mask & XSTAT_ATIME)
> 			print_time("Access: ", &xst->st_atim);
> 		if (xst->st_mask & XSTAT_MTIME)
> 			print_time("Modify: ", &xst->st_mtim);
> 		if (xst->st_mask & XSTAT_CTIME)
> 			print_time("Change: ", &xst->st_ctim);
> 		if (xst->st_mask & XSTAT_BTIME)
> 			print_time("Create: ", &xst->st_btim);
> 
> 		if (xst->st_mask & XSTAT_GEN)
> 			printf("Inode version: %llxh\n", (unsigned long long) xst->st_gen);
> 		if (xst->st_mask & XSTAT_VERSION)
> 			printf("Data version: %llxh\n", (unsigned long long) xst->st_version);
> 
> 		if (xst->st_mask & XSTAT_IOC_FLAGS) {
> 			unsigned char bits;
> 			int loop, byte;
> 
> 			static char flag_representation[32 + 1] =
> 				/* FS_IOC_GETFLAGS flags: */
> 				"????????"	/* 31-24	0x00000000-ff000000  */
> 				"????ehTD"	/* 23-16	0x00000000-00ff0000  */
> 				"tj?IE?XZ"	/* 15- 8	0x00000000-0000ff00  */
> 				"AdaiScus"	/*  7- 0	0x00000000-000000ff */
> 				;
> 
> 			printf("Inode flags: %08x (", xst->st_ioc_flags);
> 			for (byte = 32 - 8; byte >= 0; byte -= 8) {
> 				bits = xst->st_ioc_flags >> byte;
> 				for (loop = 7; loop >= 0; loop--) {
> 					int bit = byte + loop;
> 
> 					if (bits & 0x80)
> 						putchar(flag_representation[31 - bit]);
> 					else
> 						putchar('-');
> 					bits <<= 1;
> 				}
> 				if (byte)
> 					putchar(' ');
> 			}
> 			printf(")\n");
> 		}
> 
> 		if (xst->st_information) {
> 			unsigned char bits;
> 			int loop, byte;
> 
> 			static char info_representation[32 + 1] =
> 				/* XSTAT_INFO_ flags: */
> 				"????????"	/* 31-24	0x00000000-ff000000  */
> 				"????????"	/* 23-16	0x00000000-00ff0000  */
> 				"??ASHRan"	/* 15- 8	0x00000000-0000ff00  */
> 				"dmorkfte"	/*  7- 0	0x00000000-000000ff */
> 				;
> 
> 			printf("Information: %08x (", xst->st_information);
> 			for (byte = 32 - 8; byte >= 0; byte -= 8) {
> 				bits = xst->st_information >> byte;
> 				for (loop = 7; loop >= 0; loop--) {
> 					int bit = byte + loop;
> 
> 					if (bits & 0x80)
> 						putchar(info_representation[31 - bit]);
> 					else
> 						putchar('-');
> 					bits <<= 1;
> 				}
> 				if (byte)
> 					putchar(' ');
> 			}
> 			printf(")\n");
> 		}
> 
> 		if (xst->st_mask & XSTAT_VOLUME_ID) {
> 			int loop;
> 			printf("Volume ID: ");
> 			for (loop = 0; loop < sizeof(xst->st_volume_id); loop++) {
> 				printf("%02x", xst->st_volume_id[loop]);
> 				if (loop == 7)
> 					printf("-");
> 			}
> 			printf("\n");
> 		}
> 	}
> 
> 	void dump_hex(unsigned long long *data, int from, int to)
> 	{
> 		unsigned offset, print_offset = 1, col = 0;
> 
> 		from /= 8;
> 		to = (to + 7) / 8;
> 
> 		for (offset = from; offset < to; offset++) {
> 			if (print_offset) {
> 				printf("%04x: ", offset * 8);
> 				print_offset = 0;
> 			}
> 			printf("%016llx", data[offset]);
> 			col++;
> 			if ((col & 3) == 0) {
> 				printf("\n");
> 				print_offset = 1;
> 			} else {
> 				printf(" ");
> 			}
> 		}
> 
> 		if (!print_offset)
> 			printf("\n");
> 	}
> 
> 	int main(int argc, char **argv)
> 	{
> 		struct xstat xst;
> 		int ret, raw = 0, atflag = AT_SYMLINK_NOFOLLOW;
> 
> 		unsigned int mask = XSTAT_ALL_STATS;
> 
> 		for (argv++; *argv; argv++) {
> 			if (strcmp(*argv, "-F") == 0) {
> 				atflag |= AT_FORCE_ATTR_SYNC;
> 				continue;
> 			}
> 			if (strcmp(*argv, "-L") == 0) {
> 				atflag &= ~AT_SYMLINK_NOFOLLOW;
> 				continue;
> 			}
> 			if (strcmp(*argv, "-O") == 0) {
> 				mask &= ~XSTAT_BASIC_STATS;
> 				continue;
> 			}
> 			if (strcmp(*argv, "-A") == 0) {
> 				atflag |= AT_NO_AUTOMOUNT;
> 				continue;
> 			}
> 			if (strcmp(*argv, "-R") == 0) {
> 				raw = 1;
> 				continue;
> 			}
> 
> 			memset(&xst, 0xbf, sizeof(xst));
> 			ret = xstat(AT_FDCWD, *argv, atflag, mask, &xst);
> 			printf("xstat(%s) = %d\n", *argv, ret);
> 			if (ret < 0) {
> 				perror(*argv);
> 				exit(1);
> 			}
> 
> 			if (raw)
> 				dump_hex((unsigned long long *)&xst, 0, sizeof(xst));
> 
> 			dump_xstat(&xst);
> 		}
> 		return 0;
> 	}
> 
> Just compile and run, passing it paths to the files you want to examine:
> 
> 	[root@andromeda ~]# /tmp/xstat /proc/$$
> 	xstat(/proc/2074) = 160
> 	results=47ef
> 	  Size: 0               Blocks: 0          IO Block: 1024    directory
> 	Device: 00:03           Inode: 9072        Links: 7
> 	Access: (0555/dr-xr-xr-x)  Uid: 0
> 	Gid: 0
> 	Access: 2010-07-14 16:50:46.609336272+0100
> 	Modify: 2010-07-14 16:50:46.609336272+0100
> 	Change: 2010-07-14 16:50:46.609336272+0100
> 	Inode flags: 0000000100000000 (-------- -------- -------- -------S -------- -------- -------- --------)
> 	[root@andromeda ~]# /tmp/xstat /afs/archive/linuxdev/fedora9/x86_64/kernel-devel-2.6.25.10-86.fc9.x86_64.rpm
> 	xstat(/afs/archive/linuxdev/fedora9/x86_64/kernel-devel-2.6.25.10-86.fc9.x86_64.rpm) = 160
> 	results=77ef
> 	  Size: 5413882         Blocks: 0          IO Block: 4096    regular file
> 	Device: 00:15           Inode: 2288        Links: 1
> 	Access: (0644/-rw-r--r--)  Uid: 75338
> 	Gid: 0
> 	Access: 2008-11-05 19:47:22.000000000+0000
> 	Modify: 2008-11-05 19:47:22.000000000+0000
> 	Change: 2008-11-05 19:47:22.000000000+0000
> 	Inode version: 795h
> 	Data version: 2h
> 	Inode flags: 0000000800000000 (-------- -------- -------- ----r--- -------- -------- -------- --------)
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
> 
>  arch/x86/syscalls/syscall_32.tbl |    2 
>  arch/x86/syscalls/syscall_64.tbl |    2 
>  fs/stat.c                        |  350 +++++++++++++++++++++++++++++++++++---
>  include/linux/fcntl.h            |    1 
>  include/linux/fs.h               |    4 
>  include/linux/stat.h             |  126 +++++++++++++-
>  include/linux/syscalls.h         |    7 +
>  7 files changed, 461 insertions(+), 31 deletions(-)
> 
> diff --git a/arch/x86/syscalls/syscall_32.tbl b/arch/x86/syscalls/syscall_32.tbl
> index 29f9f05..980eb5a 100644
> --- a/arch/x86/syscalls/syscall_32.tbl
> +++ b/arch/x86/syscalls/syscall_32.tbl
> @@ -355,3 +355,5 @@
>  346	i386	setns			sys_setns
>  347	i386	process_vm_readv	sys_process_vm_readv		compat_sys_process_vm_readv
>  348	i386	process_vm_writev	sys_process_vm_writev		compat_sys_process_vm_writev
> +349	i386	xstat			sys_xstat
> +350	i386	fxstat			sys_fxstat
> diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
> index dd29a9e..7ae24bb 100644
> --- a/arch/x86/syscalls/syscall_64.tbl
> +++ b/arch/x86/syscalls/syscall_64.tbl
> @@ -318,6 +318,8 @@
>  309	common	getcpu			sys_getcpu
>  310	64	process_vm_readv	sys_process_vm_readv
>  311	64	process_vm_writev	sys_process_vm_writev
> +312	common	xstat			sys_xstat
> +313	common	fxstat			sys_fxstat
>  #
>  # x32-specific system call numbers start at 512 to avoid cache impact
>  # for native 64-bit operation.
> diff --git a/fs/stat.c b/fs/stat.c
> index c733dc5..af3ef33 100644
> --- a/fs/stat.c
> +++ b/fs/stat.c
> @@ -18,8 +18,20 @@
>  #include <asm/uaccess.h>
>  #include <asm/unistd.h>
>  
> +/**
> + * generic_fillattr - Fill in the basic attributes from the inode struct
> + * @inode: Inode to use as the source
> + * @stat: Where to fill in the attributes
> + *
> + * Fill in the basic attributes in the kstat structure from data that's to be
> + * found on the VFS inode structure.  This is the default if no getattr inode
> + * operation is supplied.
> + */
>  void generic_fillattr(struct inode *inode, struct kstat *stat)
>  {
> +	struct super_block *sb = inode->i_sb;
> +	u32 x;
> +
>  	stat->dev = inode->i_sb->s_dev;
>  	stat->ino = inode->i_ino;
>  	stat->mode = inode->i_mode;
> @@ -27,17 +39,61 @@ void generic_fillattr(struct inode *inode, struct kstat *stat)
>  	stat->uid = inode->i_uid;
>  	stat->gid = inode->i_gid;
>  	stat->rdev = inode->i_rdev;
> -	stat->size = i_size_read(inode);
> -	stat->atime = inode->i_atime;
>  	stat->mtime = inode->i_mtime;
>  	stat->ctime = inode->i_ctime;
> -	stat->blksize = (1 << inode->i_blkbits);
> +	stat->size = i_size_read(inode);
>  	stat->blocks = inode->i_blocks;
> -}
> +	stat->blksize = (1 << inode->i_blkbits);
>  
> +	stat->result_mask |= XSTAT_BASIC_STATS & ~XSTAT_RDEV;
> +	if (IS_NOATIME(inode))
> +		stat->result_mask &= ~XSTAT_ATIME;
> +	else
> +		stat->atime = inode->i_atime;
> +
> +	if (S_ISREG(stat->mode) && stat->nlink == 0)
> +		stat->information |= XSTAT_INFO_TEMPORARY;
> +	if (IS_AUTOMOUNT(inode))
> +		stat->information |= XSTAT_INFO_AUTOMOUNT;
> +	if (IS_POSIXACL(inode))
> +		stat->information |= XSTAT_INFO_HAS_ACL;
> +
> +	/* if unset, assume 1s granularity */
> +	stat->tv_granularity = sb->s_time_gran ?: 1000000000U;
> +
> +	if (unlikely(S_ISBLK(stat->mode) || S_ISCHR(stat->mode)))
> +		stat->result_mask |= XSTAT_RDEV;
> +
> +	x  = ((u32*)&stat->volume_id)[0] = ((u32*)&sb->s_volume_id)[0];
> +	x |= ((u32*)&stat->volume_id)[1] = ((u32*)&sb->s_volume_id)[1];
> +	x |= ((u32*)&stat->volume_id)[2] = ((u32*)&sb->s_volume_id)[2];
> +	x |= ((u32*)&stat->volume_id)[3] = ((u32*)&sb->s_volume_id)[3];
> +	if (x)
> +		stat->result_mask |= XSTAT_VOLUME_ID;
> +}
>  EXPORT_SYMBOL(generic_fillattr);
>  
> -int vfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
> +/**
> + * vfs_xgetattr - Get the basic and extra attributes of a file
> + * @mnt: The mountpoint to which the dentry belongs
> + * @dentry: The file of interest
> + * @stat: Where to return the statistics
> + *
> + * Ask the filesystem for a file's attributes.  The caller must have preset
> + * stat->request_mask and stat->query_flags to indicate what they want.
> + *
> + * If the file is remote, the filesystem can be forced to update the attributes
> + * from the backing store by passing AT_FORCE_ATTR_SYNC in query_flags.
> + *
> + * Bits must have been set in stat->request_mask to indicate which attributes
> + * the caller wants retrieving.  Any such attribute not requested may be
> + * returned anyway, but the value may be approximate, and, if remote, may not
> + * have been synchronised with the server.
> + *
> + * 0 will be returned on success, and a -ve error code if unsuccessful.
> + */
> +int vfs_xgetattr(struct vfsmount *mnt, struct dentry *dentry,
> +		 struct kstat *stat)
>  {
>  	struct inode *inode = dentry->d_inode;
>  	int retval;
> @@ -46,64 +102,184 @@ int vfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
>  	if (retval)
>  		return retval;
>  
> +	stat->result_mask = 0;
> +	stat->information = 0;
> +	stat->ioc_flags = 0;
>  	if (inode->i_op->getattr)
>  		return inode->i_op->getattr(mnt, dentry, stat);
>  
>  	generic_fillattr(inode, stat);
>  	return 0;
>  }
> +EXPORT_SYMBOL(vfs_xgetattr);
>  
> +/**
> + * vfs_getattr - Get the basic attributes of a file
> + * @mnt: The mountpoint to which the dentry belongs
> + * @dentry: The file of interest
> + * @stat: Where to return the statistics
> + *
> + * Ask the filesystem for a file's attributes.  If remote, the filesystem isn't
> + * forced to update its files from the backing store.  Only the basic set of
> + * attributes will be retrieved; anyone wanting more must use vfs_getxattr(),
> + * as must anyone who wants to force attributes to be sync'd with the server.
> + *
> + * 0 will be returned on success, and a -ve error code if unsuccessful.
> + */
> +int vfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
> +{
> +	stat->query_flags = 0;
> +	stat->request_mask = XSTAT_BASIC_STATS;
> +	return vfs_xgetattr(mnt, dentry, stat);
> +}
>  EXPORT_SYMBOL(vfs_getattr);
>  
> -int vfs_fstat(unsigned int fd, struct kstat *stat)
> +/**
> + * vfs_fxstat - Get basic and extra attributes by file descriptor
> + * @fd: The file descriptor refering to the file of interest
> + * @stat: The result structure to fill in.
> + *
> + * This function is a wrapper around vfs_xgetattr().  The main difference is
> + * that it uses a file descriptor to determine the file location.
> + *
> + * The caller must have preset stat->query_flags and stat->request_mask as for
> + * vfs_xgetattr().
> + *
> + * 0 will be returned on success, and a -ve error code if unsuccessful.
> + */
> +int vfs_fxstat(unsigned int fd, struct kstat *stat)
>  {
>  	struct file *f = fget(fd);
>  	int error = -EBADF;
>  
> +	if (stat->query_flags & ~KSTAT_QUERY_FLAGS)
> +		return -EINVAL;
>  	if (f) {
> -		error = vfs_getattr(f->f_path.mnt, f->f_path.dentry, stat);
> +		error = vfs_xgetattr(f->f_path.mnt, f->f_path.dentry, stat);
>  		fput(f);
>  	}
>  	return error;
>  }
> +EXPORT_SYMBOL(vfs_fxstat);
> +
> +/**
> + * vfs_fstat - Get basic attributes by file descriptor
> + * @fd: The file descriptor refering to the file of interest
> + * @stat: The result structure to fill in.
> + *
> + * This function is a wrapper around vfs_getattr().  The main difference is
> + * that it uses a file descriptor to determine the file location.
> + *
> + * 0 will be returned on success, and a -ve error code if unsuccessful.
> + */
> +int vfs_fstat(unsigned int fd, struct kstat *stat)
> +{
> +	stat->query_flags = 0;
> +	stat->request_mask = XSTAT_BASIC_STATS;
> +	return vfs_fxstat(fd, stat);
> +}
>  EXPORT_SYMBOL(vfs_fstat);
>  
> -int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
> -		int flag)
> +/**
> + * vfs_xstat - Get basic and extra attributes by filename
> + * @dfd: A file descriptor representing the base dir for a relative filename
> + * @filename: The name of the file of interest
> + * @flags: Flags to control the query
> + * @stat: The result structure to fill in.
> + *
> + * This function is a wrapper around vfs_xgetattr().  The main difference is
> + * that it uses a filename and base directory to determine the file location.
> + * Additionally, the addition of AT_SYMLINK_NOFOLLOW to flags will prevent a
> + * symlink at the given name from being referenced.
> + *
> + * The caller must have preset stat->request_mask as for vfs_xgetattr().  The
> + * flags are also used to load up stat->query_flags.
> + *
> + * 0 will be returned on success, and a -ve error code if unsuccessful.
> + */
> +int vfs_xstat(int dfd, const char __user *filename, int flags,
> +	      struct kstat *stat)
>  {
>  	struct path path;
> -	int error = -EINVAL;
> -	int lookup_flags = 0;
> +	int error, lookup_flags = LOOKUP_FOLLOW | LOOKUP_AUTOMOUNT;
>  
> -	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
> -		      AT_EMPTY_PATH)) != 0)
> -		goto out;
> +	if ((flags & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
> +		      AT_EMPTY_PATH | KSTAT_QUERY_FLAGS)) != 0)
> +		return -EINVAL;
>  
> -	if (!(flag & AT_SYMLINK_NOFOLLOW))
> -		lookup_flags |= LOOKUP_FOLLOW;
> -	if (flag & AT_EMPTY_PATH)
> +	if (flags & AT_SYMLINK_NOFOLLOW)
> +		lookup_flags &= ~LOOKUP_FOLLOW;
> +	if (flags & AT_NO_AUTOMOUNT)
> +		lookup_flags &= ~LOOKUP_AUTOMOUNT;
> +	if (flags & AT_EMPTY_PATH)
>  		lookup_flags |= LOOKUP_EMPTY;
>  
> +	stat->query_flags = flags & KSTAT_QUERY_FLAGS;
>  	error = user_path_at(dfd, filename, lookup_flags, &path);
> -	if (error)
> -		goto out;
> -
> -	error = vfs_getattr(path.mnt, path.dentry, stat);
> -	path_put(&path);
> -out:
> +	if (!error) {
> +		error = vfs_xgetattr(path.mnt, path.dentry, stat);
> +		path_put(&path);
> +	}
>  	return error;
>  }
> +EXPORT_SYMBOL(vfs_xstat);
> +
> +/**
> + * vfs_fstatat - Get basic attributes by filename
> + * @dfd: A file descriptor representing the base dir for a relative filename
> + * @filename: The name of the file of interest
> + * @flags: Flags to control the query
> + * @stat: The result structure to fill in.
> + *
> + * This function is a wrapper around vfs_xstat().  The difference is that it
> + * preselects basic stats only.  The flags are used to load up
> + * stat->query_flags in addition to indicating symlink handling during path
> + * resolution.
> + *
> + * 0 will be returned on success, and a -ve error code if unsuccessful.
> + */
> +int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
> +		int flags)
> +{
> +	stat->request_mask = XSTAT_BASIC_STATS;
> +	return vfs_xstat(dfd, filename, flags, stat);
> +}
>  EXPORT_SYMBOL(vfs_fstatat);
>  
> -int vfs_stat(const char __user *name, struct kstat *stat)
> +/**
> + * vfs_stat - Get basic attributes by filename
> + * @filename: The name of the file of interest
> + * @stat: The result structure to fill in.
> + *
> + * This function is a wrapper around vfs_xstat().  The difference is that it
> + * preselects basic stats only, terminal symlinks are followed regardless and a
> + * remote filesystem can't be forced to query the server.  If such is desired,
> + * vfs_xstat() should be used instead.
> + *
> + * 0 will be returned on success, and a -ve error code if unsuccessful.
> + */
> +int vfs_stat(const char __user *filename, struct kstat *stat)
>  {
> -	return vfs_fstatat(AT_FDCWD, name, stat, 0);
> +	stat->request_mask = XSTAT_BASIC_STATS;
> +	return vfs_xstat(AT_FDCWD, filename, 0, stat);
>  }
>  EXPORT_SYMBOL(vfs_stat);
>  
> +/**
> + * vfs_stat - Get basic attributes by filename, without following terminal symlink
> + * @filename: The name of the file of interest
> + * @stat: The result structure to fill in.
> + *
> + * This function is a wrapper around vfs_xstat().  The difference is that it
> + * preselects basic stats only, terminal symlinks are note followed regardless
> + * and a remote filesystem can't be forced to query the server.  If such is
> + * desired, vfs_xstat() should be used instead.
> + *
> + * 0 will be returned on success, and a -ve error code if unsuccessful.
> + */
>  int vfs_lstat(const char __user *name, struct kstat *stat)
>  {
> -	return vfs_fstatat(AT_FDCWD, name, stat, AT_SYMLINK_NOFOLLOW);
> +	return vfs_xstat(AT_FDCWD, name, AT_SYMLINK_NOFOLLOW, stat);
>  }
>  EXPORT_SYMBOL(vfs_lstat);
>  
> @@ -118,7 +294,7 @@ static int cp_old_stat(struct kstat *stat, struct __old_kernel_stat __user * sta
>  {
>  	static int warncount = 5;
>  	struct __old_kernel_stat tmp;
> -	
> +
>  	if (warncount > 0) {
>  		warncount--;
>  		printk(KERN_WARNING "VFS: Warning: %s using old stat() call. Recompile your binary.\n",
> @@ -143,7 +319,7 @@ static int cp_old_stat(struct kstat *stat, struct __old_kernel_stat __user * sta
>  #if BITS_PER_LONG == 32
>  	if (stat->size > MAX_NON_LFS)
>  		return -EOVERFLOW;
> -#endif	
> +#endif
>  	tmp.st_size = stat->size;
>  	tmp.st_atime = stat->atime.tv_sec;
>  	tmp.st_mtime = stat->mtime.tv_sec;
> @@ -225,7 +401,7 @@ static int cp_new_stat(struct kstat *stat, struct stat __user *statbuf)
>  #if BITS_PER_LONG == 32
>  	if (stat->size > MAX_NON_LFS)
>  		return -EOVERFLOW;
> -#endif	
> +#endif
>  	tmp.st_size = stat->size;
>  	tmp.st_atime = stat->atime.tv_sec;
>  	tmp.st_mtime = stat->mtime.tv_sec;
> @@ -412,6 +588,122 @@ SYSCALL_DEFINE4(fstatat64, int, dfd, const char __user *, filename,
>  }
>  #endif /* __ARCH_WANT_STAT64 */
>  
> +/*
> + * Get the xstat parameters if supplied
> + */
> +static int xstat_get_params(unsigned int mask, struct xstat __user *buffer,
> +			    struct kstat *stat)
> +{
> +	memset(stat, 0xde, sizeof(*stat));	// DEBUGGING
> +
> +	if (!access_ok(VERIFY_WRITE, buffer, sizeof(*buffer)))
> +		return -EFAULT;
> +
> +	stat->request_mask = mask & XSTAT_ALL_STATS;
> +	stat->result_mask = 0;
> +	return 0;
> +}
> +
> +/*
> + * Set the xstat results.
> + *
> + * If the buffer size was 0, we just return the size of the buffer needed to
> + * return the full result.
> + *
> + * If bufsize indicates a buffer of insufficient size to hold the full result,
> + * we return -E2BIG.
> + *
> + * Otherwise we copy the extended stats to userspace and return the amount of
> + * data written into the buffer (or -EFAULT).
> + */
> +static long xstat_set_result(struct kstat *stat, struct xstat __user *buffer)
> +{
> +	u32 mask = stat->result_mask, gran = stat->tv_granularity;
> +
> +#define __put_timestamp(kts, uts) (					\
> +		__put_user(kts.tv_sec,	uts.tv_sec		) ||	\
> +		__put_user(kts.tv_nsec,	uts.tv_nsec		) ||	\
> +		__put_user(gran,	uts.tv_granularity	))
> +
> +	/* clear out anything we're not returning */
> +	if (!(mask & XSTAT_IOC_FLAGS))
> +		stat->ioc_flags = 0;
> +	if (!(mask & XSTAT_BTIME))
> +		memset(&stat->btime, 0, sizeof(stat->btime));
> +	if (!(mask & XSTAT_GEN))
> +		stat->gen = 0;
> +	if (!(mask & XSTAT_VERSION))
> +		stat->version = 0;
> +	if (!(mask & XSTAT_VOLUME_ID))
> +		memset(&stat->volume_id, 0, sizeof(stat->volume_id));
> +	
> +	/* transfer the results */
> +	if (__put_user(mask,			&buffer->st_mask	) ||
> +	    __put_user(stat->mode,		&buffer->st_mode	) ||
> +	    __put_user(stat->nlink,		&buffer->st_nlink	) ||
> +	    __put_user(stat->uid,		&buffer->st_uid		) ||
> +	    __put_user(stat->gid,		&buffer->st_gid		) ||
> +	    __put_user(stat->information,	&buffer->st_information	) ||
> +	    __put_user(stat->ioc_flags,		&buffer->st_ioc_flags	) ||
> +	    __put_user(stat->blksize,		&buffer->st_blksize	) ||
> +	    __put_user(MAJOR(stat->rdev),	&buffer->st_rdev.major	) ||
> +	    __put_user(MINOR(stat->rdev),	&buffer->st_rdev.minor	) ||
> +	    __put_user(MAJOR(stat->dev),	&buffer->st_dev.major	) ||
> +	    __put_user(MINOR(stat->dev),	&buffer->st_dev.minor	) ||
> +	    __put_timestamp(stat->atime,	&buffer->st_atime	) ||
> +	    __put_timestamp(stat->btime,	&buffer->st_btime	) ||
> +	    __put_timestamp(stat->ctime,	&buffer->st_ctime	) ||
> +	    __put_timestamp(stat->mtime,	&buffer->st_mtime	) ||
> +	    __put_user(stat->ino,		&buffer->st_ino		) ||
> +	    __put_user(stat->size,		&buffer->st_size	) ||
> +	    __put_user(stat->blocks,		&buffer->st_blocks	) ||
> +	    __put_user(stat->gen,		&buffer->st_gen		) ||
> +	    __put_user(stat->version,		&buffer->st_version	) ||
> +	    __copy_to_user(&buffer->st_volume_id, &stat->volume_id,
> +			   sizeof(buffer->st_volume_id)			) ||
> +	    __clear_user(&buffer->__spares, sizeof(buffer->__spares)))
> +		return -EFAULT;
> +	return 0;
> +}
> +
> +/*
> + * System call to get extended stats by path
> + */
> +SYSCALL_DEFINE5(xstat,
> +		int, dfd, const char __user *, filename, unsigned, flags,
> +		unsigned int, mask, struct xstat __user *, buffer)
> +{
> +	struct kstat stat;
> +	int error;
> +
> +	error = xstat_get_params(mask, buffer, &stat);
> +	if (error != 0)
> +		return error;
> +	error = vfs_xstat(dfd, filename, flags, &stat);
> +	if (error)
> +		return error;
> +	return xstat_set_result(&stat, buffer);
> +}
> +
> +/*
> + * System call to get extended stats by file descriptor
> + */
> +SYSCALL_DEFINE4(fxstat, unsigned int, fd, unsigned int, flags,
> +		unsigned int, mask, struct xstat __user *, buffer)
> +{
> +	struct kstat stat;
> +	int error;
> +
> +	error = xstat_get_params(mask, buffer, &stat);
> +	if (error < 0)
> +		return error;
> +	stat.query_flags = flags;
> +	error = vfs_fxstat(fd, &stat);
> +	if (error)
> +		return error;
> +	return xstat_set_result(&stat, buffer);
> +}
> +
>  /* Caller is here responsible for sufficient locking (ie. inode->i_lock) */
>  void __inode_add_bytes(struct inode *inode, loff_t bytes)
>  {
> diff --git a/include/linux/fcntl.h b/include/linux/fcntl.h
> index f550f89..faa9e5d 100644
> --- a/include/linux/fcntl.h
> +++ b/include/linux/fcntl.h
> @@ -47,6 +47,7 @@
>  #define AT_SYMLINK_FOLLOW	0x400   /* Follow symbolic links.  */
>  #define AT_NO_AUTOMOUNT		0x800	/* Suppress terminal automount traversal */
>  #define AT_EMPTY_PATH		0x1000	/* Allow empty relative pathname */
> +#define AT_FORCE_ATTR_SYNC	0x2000	/* Force the attributes to be sync'd with the server */
>  
>  #ifdef __KERNEL__
>  
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 8de6755..ec6c62e 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1467,6 +1467,7 @@ struct super_block {
>  
>  	char s_id[32];				/* Informational name */
>  	u8 s_uuid[16];				/* UUID */
> +	unsigned char		s_volume_id[16]; /* Volume identifier */
>  
>  	void 			*s_fs_info;	/* Filesystem private info */
>  	unsigned int		s_max_links;
> @@ -2470,6 +2471,7 @@ extern const struct inode_operations page_symlink_inode_operations;
>  extern int generic_readlink(struct dentry *, char __user *, int);
>  extern void generic_fillattr(struct inode *, struct kstat *);
>  extern int vfs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
> +extern int vfs_xgetattr(struct vfsmount *, struct dentry *, struct kstat *);
>  void __inode_add_bytes(struct inode *inode, loff_t bytes);
>  void inode_add_bytes(struct inode *inode, loff_t bytes);
>  void inode_sub_bytes(struct inode *inode, loff_t bytes);
> @@ -2482,6 +2484,8 @@ extern int vfs_stat(const char __user *, struct kstat *);
>  extern int vfs_lstat(const char __user *, struct kstat *);
>  extern int vfs_fstat(unsigned int, struct kstat *);
>  extern int vfs_fstatat(int , const char __user *, struct kstat *, int);
> +extern int vfs_xstat(int, const char __user *, int, struct kstat *);
> +extern int vfs_xfstat(unsigned int, struct kstat *);
>  
>  extern int do_vfs_ioctl(struct file *filp, unsigned int fd, unsigned int cmd,
>  		    unsigned long arg);
> diff --git a/include/linux/stat.h b/include/linux/stat.h
> index 611c398..0ff561a 100644
> --- a/include/linux/stat.h
> +++ b/include/linux/stat.h
> @@ -3,6 +3,7 @@
>  
>  #ifdef __KERNEL__
>  
> +#include <linux/types.h>
>  #include <asm/stat.h>
>  
>  #endif
> @@ -46,6 +47,117 @@
>  
>  #endif
>  
> +/*
> + * Query request/result mask
> + *
> + * Bits should be set in request_mask to request particular items when calling
> + * xstat() or fxstat().
> + *
> + * The bits in st_mask may or may not be set upon return, in part depending on
> + * what was set in the mask argument:
> + *
> + * - if not available at all, the bit will be cleared before returning and the
> + *   field will be cleared; otherwise,
> + *
> + * - if AT_FORCE_ATTR_SYNC is set, then the datum will be synchronised to the
> + *   server and the field and bit will be set on return; otherwise,
> + *
> + * - if explicitly requested, the datum will be synchronised to a server or
> + *   other medium if out of date before being returned, and the bit will be set
> + *   on return; otherwise,
> + *
> + * - if not requested, but available in approximate form without any effort, it
> + *   will be filled in anyway, and the bit will be set upon return (it might
> + *   not be up to date, however, and no attempt will be made to synchronise the
> + *   internal state first); otherwise,
> + *
> + * - the field and the bit will be cleared before returning.
> + *
> + * Items in XSTAT_BASIC_STATS may be marked unavailable on return, but they
> + * will have a value installed for compatibility purposes so that stat() and
> + * co. can be emulated in userspace.
> + */
> +#define XSTAT_MODE		0x00000001U	/* want/got st_mode */
> +#define XSTAT_NLINK		0x00000002U	/* want/got st_nlink */
> +#define XSTAT_UID		0x00000004U	/* want/got st_uid */
> +#define XSTAT_GID		0x00000008U	/* want/got st_gid */
> +#define XSTAT_RDEV		0x00000010U	/* want/got st_rdev */
> +#define XSTAT_ATIME		0x00000020U	/* want/got st_atime */
> +#define XSTAT_MTIME		0x00000040U	/* want/got st_mtime */
> +#define XSTAT_CTIME		0x00000080U	/* want/got st_ctime */
> +#define XSTAT_INO		0x00000100U	/* want/got st_ino */
> +#define XSTAT_SIZE		0x00000200U	/* want/got st_size */
> +#define XSTAT_BLOCKS		0x00000400U	/* want/got st_blocks */
> +#define XSTAT_BASIC_STATS	0x000007ffU	/* the stuff in the normal stat struct */
> +#define XSTAT_IOC_FLAGS		0x00000800U	/* want/got FS_IOC_GETFLAGS */
> +#define XSTAT_BTIME		0x00001000U	/* want/got st_btime */
> +#define XSTAT_GEN		0x00002000U	/* want/got st_gen */
> +#define XSTAT_VERSION		0x00004000U	/* want/got st_version */
> +#define XSTAT_VOLUME_ID		0x00008000U	/* want/got st_volume_id */
> +#define XSTAT_ALL_STATS		0x0000ffffU	/* all supported stats */
> +
> +/*
> + * Extended stat structures
> + */
> +struct xstat_dev {
> +	uint32_t		major, minor;
> +};
> +
> +struct xstat_time {
> +	int64_t			tv_sec;
> +	uint32_t		tv_nsec;
> +	uint32_t		tv_granularity;	/* time granularity (in nS) */
> +};
> +
> +struct xstat {
> +	uint32_t		st_mask;	/* what results were written */
> +	uint32_t		st_mode;	/* file mode */
> +	uint32_t		st_nlink;	/* number of hard links */
> +	uint32_t		st_uid;		/* user ID of owner */
> +	uint32_t		st_gid;		/* group ID of owner */
> +	uint32_t		st_information;	/* information about the file */
> +	uint32_t		st_ioc_flags;	/* as FS_IOC_GETFLAGS */
> +	uint32_t		st_blksize;	/* optimal size for filesystem I/O */
> +	struct xstat_dev	st_rdev;	/* device ID of special file */
> +	struct xstat_dev	st_dev;		/* ID of device containing file */
> +	struct xstat_time	st_atime;	/* last access time */
> +	struct xstat_time	st_btime;	/* file creation time */
> +	struct xstat_time	st_ctime;	/* last attribute change time */
> +	struct xstat_time	st_mtime;	/* last data modification time */
> +	uint64_t		st_ino;		/* inode number */
> +	uint64_t		st_size;	/* file size */
> +	uint64_t		st_blocks;	/* number of 512-byte blocks allocated */
> +	uint64_t		st_gen;		/* inode generation number */
> +	uint64_t		st_version;	/* data version number */
> +	uint8_t			st_volume_id[16]; /* volume identifier */
> +	uint64_t		__spares[11];	/* spare space for future expansion */
> +};
> +
> +/*
> + * Flags to be found in st_information
> + *
> + * These give information about the features or the state of a file that might
> + * be of use to ordinary userspace programs such as GUIs or ls rather than
> + * specialised tools.
> + *
> + * Additional information may be found in st_ioc_flags and we try not to
> + * overlap with it.
> + */
> +#define XSTAT_INFO_ENCRYPTED		0x00000001U /* File is encrypted */
> +#define XSTAT_INFO_TEMPORARY		0x00000002U /* File is temporary (NTFS/CIFS) */
> +#define XSTAT_INFO_FABRICATED		0x00000004U /* File was made up by filesystem */
> +#define XSTAT_INFO_KERNEL_API		0x00000008U /* File is kernel API (eg: procfs/sysfs) */
> +#define XSTAT_INFO_REMOTE		0x00000010U /* File is remote */
> +#define XSTAT_INFO_OFFLINE		0x00000020U /* File is offline (CIFS) */
> +#define XSTAT_INFO_AUTOMOUNT		0x00000040U /* Dir is automount trigger */
> +#define XSTAT_INFO_AUTODIR		0x00000080U /* Dir provides unlisted automounts */
> +#define XSTAT_INFO_NONSYSTEM_OWNERSHIP	0x00000100U /* File has non-system ownership details */
> +#define XSTAT_INFO_HAS_ACL		0x00000200U /* File has an ACL of some sort */
> +#define XSTAT_INFO_REPARSE_POINT	0x00000400U /* File is reparse point (NTFS/CIFS) */
> +#define XSTAT_INFO_HIDDEN		0x00000800U /* File is marked hidden (DOS+) */
> +#define XSTAT_INFO_SYSTEM		0x00001000U /* File is marked system (DOS+) */
> +#define XSTAT_INFO_ARCHIVE		0x00002000U /* File is marked archive (DOS+) */
> +
>  #ifdef __KERNEL__
>  #define S_IRWXUGO	(S_IRWXU|S_IRWXG|S_IRWXO)
>  #define S_IALLUGO	(S_ISUID|S_ISGID|S_ISVTX|S_IRWXUGO)
> @@ -60,6 +172,12 @@
>  #include <linux/time.h>
>  
>  struct kstat {
> +	u32		query_flags;		/* operational flags */
> +#define KSTAT_QUERY_FLAGS (AT_FORCE_ATTR_SYNC)
> +	u32		request_mask;		/* what fields the user asked for */
> +	u32		result_mask;		/* what fields the user got */
> +	u32		information;
> +	u32		ioc_flags;		/* inode flags (FS_IOC_GETFLAGS) */
>  	u64		ino;
>  	dev_t		dev;
>  	umode_t		mode;
> @@ -67,14 +185,18 @@ struct kstat {
>  	uid_t		uid;
>  	gid_t		gid;
>  	dev_t		rdev;
> +	unsigned int	tv_granularity;		/* granularity of times (in nS) */
>  	loff_t		size;
> -	struct timespec  atime;
> +	struct timespec	atime;
>  	struct timespec	mtime;
>  	struct timespec	ctime;
> +	struct timespec	btime;			/* file creation time */
>  	unsigned long	blksize;
>  	unsigned long long	blocks;
> +	u64		gen;			/* inode generation */
> +	u64		version;		/* data version */
> +	unsigned char	volume_id[16];		/* volume identifier */
>  };
>  
>  #endif
> -
>  #endif
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index 3de3acb..ff9f8d9 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -45,6 +45,8 @@ struct shmid_ds;
>  struct sockaddr;
>  struct stat;
>  struct stat64;
> +struct xstat_parameters;
> +struct xstat;
>  struct statfs;
>  struct statfs64;
>  struct __sysctl_args;
> @@ -858,4 +860,9 @@ asmlinkage long sys_process_vm_writev(pid_t pid,
>  				      unsigned long riovcnt,
>  				      unsigned long flags);
>  
> +asmlinkage long sys_xstat(int dfd, const char __user *path, unsigned flags,
> +			  unsigned mask, struct xstat __user *buffer);
> +asmlinkage long sys_fxstat(unsigned fd, unsigned flags,
> +			   unsigned mask, struct xstat __user *buffer);
> +
>  #endif
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
