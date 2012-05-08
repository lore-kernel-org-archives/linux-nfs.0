Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61309 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756883Ab2EHUUd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 May 2012 16:20:33 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
To: adilger@dilger.ca, david@fromorbit.com, bfields@fieldses.org,
        smfrench@gmail.com, ben@decadent.org.uk, Trond.Myklebust@netapp.com,
        roland@hack.frob.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Extended file stat: Splitting file- and fs-specific info?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Date: Tue, 08 May 2012 21:19:42 +0100
Message-ID: <16281.1336508382@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Should I split the file-specific info and the fs-specific info and make the
second optional?  What I'm thinking of is something like this:

Have a file information structure:

struct statx {
	/* 0x00 */
	uint32_t	st_mask;	/* What results were written */
	uint32_t	st_information;	/* Information about the file */
	uint16_t	st_mode;	/* File mode */
	uint16_t	__spare0[3];
	/* 0x10 */
	uint32_t	st_uid;		/* User ID of owner */
	uint32_t	st_gid;		/* Group ID of owner */
	uint32_t	st_nlink;	/* Number of hard links */
	uint32_t	st_blksize;	/* Optimal size for filesystem I/O */
	/* 0x20 */
	struct statx_dev st_rdev;	/* Device ID of special file */
	struct statx_dev st_dev;	/* ID of device containing file */
	/* 0x30 */
	int32_t		st_atime_ns;	/* Last access time (ns part) */
	int32_t		st_btime_ns;	/* File creation time (ns part) */
	int32_t		st_ctime_ns;	/* Last attribute change time (ns part) */
	int32_t		st_mtime_ns;	/* Last data modification time (ns part) */
	/* 0x40 */
	int64_t		st_atime;	/* Last access time */
	int64_t		st_btime;	/* File creation time */
	int64_t		st_ctime;	/* Last attribute change time */
	int64_t		st_mtime;	/* Last data modification time */
	/* 0x60 */
	uint64_t	st_ino;		/* Inode number */
	uint64_t	st_size;	/* File size */
	uint64_t	st_blocks;	/* Number of 512-byte blocks allocated */
	uint64_t	st_gen;		/* Inode generation number */
	uint64_t	st_version;	/* Data version number */
	uint64_t	st_ioc_flags;	/* As FS_IOC_GETFLAGS */
	/* 0x90 */
	uint64_t	__spare1[13];	/* Spare space for future expansion */
	/* 0x100 */
};

And an fs information structure for less commonly needed data:

struct statx_fsinfo {
	/* 0x00 - General info */
	uint32_t	st_mask;	/* What optional fields are filled in */
	uint32_t	st_type;	/* Filesystem type from linux/magic.h */

	/* 0x08 - file timestamp granularity info */
	uint16_t	st_atime_gran_mantissa;	/* gran(secs) = mant * 10^exp */
	uint16_t	st_btime_gran_mantissa;
	uint16_t	st_ctime_gran_mantissa;
	uint16_t	st_mtime_gran_mantissa;
	/* 0x10 */
	int8_t		st_atime_gran_exponent;
	int8_t		st_btime_gran_exponent;
	int8_t		st_ctime_gran_exponent;
	int8_t		st_mtime_gran_exponent;

	/* 0x14 - I/O parameters */
	uint32_t	st_blksize;	  /* File block size */
	uint32_t	st_alloc_blksize; /* Allocation block size/alignment */
	uint32_t	st_small_io_size; /* IO size/alignment that avoids fs/page cache RMW */
	uint32_t	st_pref_io_size;  /* Preferred IO size for general usage */
	uint32_t	st_large_io_size; /* IO size/alignment for high bandwidth sequential IO */

	/* 0x28 - Restrictions on struct statx contents */
	uint64_t	st_supported_ioc_flags; /* FS_IOC_GETFLAGS flags supported  */

	/* 0x30 - Volume/filesystem information */
	uint64_t	st_fsid;	/* Short 64-bit Filesystem ID (as statfs) */
	uint64_t	__spare0[3];
	/* 0x50 */
	uint8_t		st_volume_id[16]; /* Volume/fs identifier */
	uint8_t		st_volume_uuid[16]; /* Volume/fs UUID */
	/* 0x80 */
	uint64_t	__spare1[8];
	/* 0xc0 */
	uint8_t		st_volume_name[64]; /* Volume name (up to 64 chars) */
	/* 0x100 */
	uint8_t		st_domain_name[256]; /* Domain/cell/workgroup name (up to 256 chars) */
	/* 0x200 */
};

One could argue a bit over what goes in which, should we go for this.  This
may be better split between multiple syscalls though (with the race that that
implies) and potentially merging with statfs.


The statxat() syscall [née xstat] could then use the 6th parameter thusly:

asmlinkage long sys_statxat(int dfd, const char __user *path, unsigned flags,
			    unsigned mask, struct statx __user *buffer,
			    struct statx_fsinfo __user *fsinfo);


letting fsinfo be NULL to indicate a lack of interest.  I'm not sure we want
to do that, though.


Also, do Dave Chinner's ideas for indicating five I/O parameters want to be
32-bit numbers?  Larger?  Smaller?  Can they be log2?

Note also, that I've suggested that we represent the timestamp granularity
information as a decimal float (which requires 3 bytes per timestamp) and that
we provide separate granularities for each timestamp.

David
