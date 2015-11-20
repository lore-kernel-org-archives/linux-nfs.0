Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53986 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760338AbbKTOyl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2015 09:54:41 -0500
Subject: [PATCH 01/12] Ext4: Fix extended timestamp encoding and decoding
From: David Howells <dhowells@redhat.com>
To: arnd@arndb.de
Cc: linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Date: Fri, 20 Nov 2015 14:54:35 +0000
Message-ID: <20151120145434.18930.89755.stgit@warthog.procyon.org.uk>
In-Reply-To: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The handling of extended timestamps in Ext4 is broken as can be seen in the
output of the test program attached below:

time     extra   bad decode        good decode         bad encode  good encode
======== =====   ================= =================   =========== ===========
ffffffff     0 >  ffffffffffffffff  ffffffffffffffff > *ffffffff 3  ffffffff 0
80000000     0 >  ffffffff80000000  ffffffff80000000 > *80000000 3  80000000 0
00000000     0 >                 0                 0 >  00000000 0  00000000 0
7fffffff     0 >          7fffffff          7fffffff >  7fffffff 0  7fffffff 0
80000000     1 > *ffffffff80000000          80000000 > *80000000 0  80000000 1
ffffffff     1 > *ffffffffffffffff          ffffffff > *ffffffff 0  ffffffff 1
00000000     1 >         100000000         100000000 >  00000000 1  00000000 1
7fffffff     1 >         17fffffff         17fffffff >  7fffffff 1  7fffffff 1
80000000     2 > *ffffffff80000000         180000000 > *80000000 1  80000000 2
ffffffff     2 > *ffffffffffffffff         1ffffffff > *ffffffff 1  ffffffff 2
00000000     2 >         200000000         200000000 >  00000000 2  00000000 2
7fffffff     2 >         27fffffff         27fffffff >  7fffffff 2  7fffffff 2
80000000     3 > *ffffffff80000000         280000000 > *80000000 2  80000000 3
ffffffff     3 > *ffffffffffffffff         2ffffffff > *ffffffff 2  ffffffff 3
00000000     3 >         300000000         300000000 >  00000000 3  00000000 3
7fffffff     3 >         37fffffff         37fffffff >  7fffffff 3  7fffffff 3

The values marked with asterisks are wrong.

The problem is that with a 64-bit time, in ext4_decode_extra_time() the
epoch value is just OR'd with the sign-extended time - which, if negative,
has all of the upper 32 bits set anyway.  We need to add the epoch instead
of OR'ing it.  In ext4_encode_extra_time(), the reverse operation needs to
take place as the 32-bit part of the number of seconds needs to be
subtracted from the 64-bit value before the epoch is shifted down.

Since the epoch is presumably unsigned, this has the slightly strange
effect of, for epochs > 0, putting the 0x80000000-0xffffffff range before
the 0x00000000-0x7fffffff range.

This affects all kernels from v2.6.23-rc1 onwards.

The test program:

	#include <stdio.h>

	#define EXT4_FITS_IN_INODE(x, y, z) 1
	#define EXT4_EPOCH_BITS 2
	#define EXT4_EPOCH_MASK ((1 << EXT4_EPOCH_BITS) - 1)
	#define EXT4_NSEC_MASK  (~0UL << EXT4_EPOCH_BITS)

	#define le32_to_cpu(x) (x)
	#define cpu_to_le32(x) (x)
	typedef unsigned int __le32;
	typedef unsigned int u32;
	typedef signed int s32;
	typedef unsigned long long __u64;
	typedef signed long long s64;

	struct timespec {
		long long	tv_sec;			/* seconds */
		long		tv_nsec;		/* nanoseconds */
	};

	struct ext4_inode_info {
		struct timespec i_crtime;
	};

	struct ext4_inode {
		__le32  i_crtime;       /* File Creation time */
		__le32  i_crtime_extra; /* extra FileCreationtime (nsec << 2 | epoch) */
	};

	/* Incorrect implementation */
	static inline void ext4_decode_extra_time_bad(struct timespec *time, __le32 extra)
	{
	       if (sizeof(time->tv_sec) > 4)
		       time->tv_sec |= (__u64)(le32_to_cpu(extra) & EXT4_EPOCH_MASK)
				       << 32;
	       time->tv_nsec = (le32_to_cpu(extra) & EXT4_NSEC_MASK) >> EXT4_EPOCH_BITS;
	}

	static inline __le32 ext4_encode_extra_time_bad(struct timespec *time)
	{
	       return cpu_to_le32((sizeof(time->tv_sec) > 4 ?
				   (time->tv_sec >> 32) & EXT4_EPOCH_MASK : 0) |
				  ((time->tv_nsec << EXT4_EPOCH_BITS) & EXT4_NSEC_MASK));
	}

	/* Fixed implementation */
	static inline void ext4_decode_extra_time_good(struct timespec *time, __le32 _extra)
	{
		u32 extra = le32_to_cpu(_extra);
		u32 epoch = extra & EXT4_EPOCH_MASK;

		time->tv_sec = (s32)time->tv_sec + ((s64)epoch  << 32);
		time->tv_nsec = (extra & EXT4_NSEC_MASK) >> EXT4_EPOCH_BITS;
	}

	static inline __le32 ext4_encode_extra_time_good(struct timespec *time)
	{
		u32 extra;
		s64 epoch = time->tv_sec - (s32)time->tv_sec;

		extra = (epoch >> 32) & EXT4_EPOCH_MASK;
		extra |= (time->tv_nsec << EXT4_EPOCH_BITS) & EXT4_NSEC_MASK;
		return cpu_to_le32(extra);
	}

	#define EXT4_INODE_GET_XTIME_BAD(xtime, inode, raw_inode)		\
	do {									       \
		(inode)->xtime.tv_sec = (signed)le32_to_cpu((raw_inode)->xtime);       \
		if (EXT4_FITS_IN_INODE(raw_inode, EXT4_I(inode), xtime ## _extra))     \
			ext4_decode_extra_time_bad(&(inode)->xtime,		\
						   raw_inode->xtime ## _extra);	\
		else								       \
			(inode)->xtime.tv_nsec = 0;				       \
	} while (0)

	#define EXT4_INODE_SET_XTIME_BAD(xtime, inode, raw_inode)		\
	do {									       \
		(raw_inode)->xtime = cpu_to_le32((inode)->xtime.tv_sec);	       \
		if (EXT4_FITS_IN_INODE(raw_inode, EXT4_I(inode), xtime ## _extra))     \
			(raw_inode)->xtime ## _extra =				       \
				ext4_encode_extra_time_bad(&(inode)->xtime);	\
	} while (0)

	#define EXT4_INODE_GET_XTIME_GOOD(xtime, inode, raw_inode)		\
	do {									       \
		(inode)->xtime.tv_sec = (signed)le32_to_cpu((raw_inode)->xtime);       \
		if (EXT4_FITS_IN_INODE(raw_inode, EXT4_I(inode), xtime ## _extra))     \
			ext4_decode_extra_time_good(&(inode)->xtime,			       \
					       raw_inode->xtime ## _extra);	\
		else								       \
			(inode)->xtime.tv_nsec = 0;				       \
	} while (0)

	#define EXT4_INODE_SET_XTIME_GOOD(xtime, inode, raw_inode)		\
	do {									       \
		(raw_inode)->xtime = cpu_to_le32((inode)->xtime.tv_sec);	       \
		if (EXT4_FITS_IN_INODE(raw_inode, EXT4_I(inode), xtime ## _extra))     \
			(raw_inode)->xtime ## _extra =				       \
				ext4_encode_extra_time_good(&(inode)->xtime);	\
	} while (0)

	static const struct test {
		unsigned crtime;
		unsigned extra;
		long long sec;
		int nsec;
	} tests[] = {
		// crtime	extra		tv_sec			tv_nsec
		0xffffffff,	0x00000000,	0xffffffffffffffff,	0,
		0x80000000,	0x00000000,	0xffffffff80000000,	0,
		0x00000000,	0x00000000,	0x0000000000000000,	0,
		0x7fffffff,	0x00000000,	0x000000007fffffff,	0,
		0x80000000,	0x00000001,	0x0000000080000000,	0,
		0xffffffff,	0x00000001,	0x00000000ffffffff,	0,
		0x00000000,	0x00000001,	0x0000000100000000,	0,
		0x7fffffff,	0x00000001,	0x000000017fffffff,	0,
		0x80000000,	0x00000002,	0x0000000180000000,	0,
		0xffffffff,	0x00000002,	0x00000001ffffffff,	0,
		0x00000000,	0x00000002,	0x0000000200000000,	0,
		0x7fffffff,	0x00000002,	0x000000027fffffff,	0,
		0x80000000,	0x00000003,	0x0000000280000000,	0,
		0xffffffff,	0x00000003,	0x00000002ffffffff,	0,
		0x00000000,	0x00000003,	0x0000000300000000,	0,
		0x7fffffff,	0x00000003,	0x000000037fffffff,	0,
	};

	int main()
	{
		struct ext4_inode_info ii_bad, ii_good;
		struct ext4_inode raw, *praw = &raw;
		struct ext4_inode raw_bad, *praw_bad = &raw_bad;
		struct ext4_inode raw_good, *praw_good = &raw_good;
		const struct test *t;
		int i, ret = 0;

		printf("time     extra   bad decode        good decode         bad encode  good encode\n");
		printf("======== =====   ================= =================   =========== ===========\n");
		for (i = 0; i < sizeof(tests) / sizeof(t[0]); i++) {
			t = &tests[i];
			raw.i_crtime = t->crtime;
			raw.i_crtime_extra = t->extra;
			printf("%08x %5d > ", t->crtime, t->extra);

			EXT4_INODE_GET_XTIME_BAD(i_crtime, &ii_bad, praw);
			EXT4_INODE_GET_XTIME_GOOD(i_crtime, &ii_good, praw);
			if (ii_bad.i_crtime.tv_sec != t->sec ||
			    ii_bad.i_crtime.tv_nsec != t->nsec)
				printf("*");
			else
				printf(" ");
			printf("%16llx", ii_bad.i_crtime.tv_sec);
			printf(" ");
			if (ii_good.i_crtime.tv_sec != t->sec ||
			    ii_good.i_crtime.tv_nsec != t->nsec) {
				printf("*");
				ret = 1;
			} else {
				printf(" ");
			}
			printf("%16llx", ii_good.i_crtime.tv_sec);

			EXT4_INODE_SET_XTIME_BAD(i_crtime, &ii_good, praw_bad);
			EXT4_INODE_SET_XTIME_GOOD(i_crtime, &ii_good, praw_good);

			printf(" > ");
			if (raw_bad.i_crtime != raw.i_crtime ||
			    raw_bad.i_crtime_extra != raw.i_crtime_extra)
				printf("*");
			else
				printf(" ");
			printf("%08llx %d", raw_bad.i_crtime, raw_bad.i_crtime_extra);
			printf(" ");

			if (raw_good.i_crtime != raw.i_crtime ||
			    raw_good.i_crtime_extra != raw.i_crtime_extra) {
				printf("*");
				ret = 1;
			} else {
				printf(" ");
			}
			printf("%08llx %d", raw_good.i_crtime, raw_good.i_crtime_extra);
			printf("\n");
		}

		return ret;
	}

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/ext4/ext4.h |   22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index fd1f28be5296..31efcd78bf51 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -723,19 +723,23 @@ struct move_extent {
 	<= (EXT4_GOOD_OLD_INODE_SIZE +			\
 	    (einode)->i_extra_isize))			\
 
-static inline __le32 ext4_encode_extra_time(struct timespec *time)
+static inline void ext4_decode_extra_time(struct timespec *time, __le32 _extra)
 {
-       return cpu_to_le32((sizeof(time->tv_sec) > 4 ?
-			   (time->tv_sec >> 32) & EXT4_EPOCH_MASK : 0) |
-                          ((time->tv_nsec << EXT4_EPOCH_BITS) & EXT4_NSEC_MASK));
+	u32 extra = le32_to_cpu(_extra);
+	u32 epoch = extra & EXT4_EPOCH_MASK;
+
+	time->tv_sec = (s32)time->tv_sec + ((s64)epoch  << 32);
+	time->tv_nsec = (extra & EXT4_NSEC_MASK) >> EXT4_EPOCH_BITS;
 }
 
-static inline void ext4_decode_extra_time(struct timespec *time, __le32 extra)
+static inline __le32 ext4_encode_extra_time(struct timespec *time)
 {
-       if (sizeof(time->tv_sec) > 4)
-	       time->tv_sec |= (__u64)(le32_to_cpu(extra) & EXT4_EPOCH_MASK)
-			       << 32;
-       time->tv_nsec = (le32_to_cpu(extra) & EXT4_NSEC_MASK) >> EXT4_EPOCH_BITS;
+	u32 extra;
+	s64 epoch = time->tv_sec - (s32)time->tv_sec;
+
+	extra = (epoch >> 32) & EXT4_EPOCH_MASK;
+	extra |= (time->tv_nsec << EXT4_EPOCH_BITS) & EXT4_NSEC_MASK;
+	return cpu_to_le32(extra);
 }
 
 #define EXT4_INODE_SET_XTIME(xtime, inode, raw_inode)			       \

