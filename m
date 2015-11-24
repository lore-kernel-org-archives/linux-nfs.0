Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33786 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752615AbbKXRhr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 12:37:47 -0500
Received: by pabfh17 with SMTP id fh17so29452169pab.0
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2015 09:37:46 -0800 (PST)
Subject: Re: [PATCH 01/12] Ext4: Fix extended timestamp encoding and decoding
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: multipart/signed; boundary="Apple-Mail=_F77C77DE-FB45-4F8D-B5F6-DA53FA3D351D"; protocol="application/pgp-signature"; micalg=pgp-sha256
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20151120145434.18930.89755.stgit@warthog.procyon.org.uk>
Date: Tue, 24 Nov 2015 10:37:40 -0700
Cc: Arnd Bergmann <arnd@arndb.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-ext4 <linux-ext4@vger.kernel.org>
Message-Id: <8BBFFEAB-3933-4136-9E39-14E28C65D03E@dilger.ca>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk> <20151120145434.18930.89755.stgit@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>, "Theodore Ts'o" <tytso@mit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_F77C77DE-FB45-4F8D-B5F6-DA53FA3D351D
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Nov 20, 2015, at 7:54 AM, David Howells <dhowells@redhat.com> wrote:
>=20
> The handling of extended timestamps in Ext4 is broken as can be seen =
in the
> output of the test program attached below:
>=20
> time     extra   bad decode        good decode         bad encode  =
good encode
> =3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D   =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =
  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> ffffffff     0 >  ffffffffffffffff  ffffffffffffffff > *ffffffff 3  =
ffffffff 0
> 80000000     0 >  ffffffff80000000  ffffffff80000000 > *80000000 3  =
80000000 0
> 00000000     0 >                 0                 0 >  00000000 0  =
00000000 0
> 7fffffff     0 >          7fffffff          7fffffff >  7fffffff 0  =
7fffffff 0
> 80000000     1 > *ffffffff80000000          80000000 > *80000000 0  =
80000000 1
> ffffffff     1 > *ffffffffffffffff          ffffffff > *ffffffff 0  =
ffffffff 1
> 00000000     1 >         100000000         100000000 >  00000000 1  =
00000000 1
> 7fffffff     1 >         17fffffff         17fffffff >  7fffffff 1  =
7fffffff 1
> 80000000     2 > *ffffffff80000000         180000000 > *80000000 1  =
80000000 2
> ffffffff     2 > *ffffffffffffffff         1ffffffff > *ffffffff 1  =
ffffffff 2
> 00000000     2 >         200000000         200000000 >  00000000 2  =
00000000 2
> 7fffffff     2 >         27fffffff         27fffffff >  7fffffff 2  =
7fffffff 2
> 80000000     3 > *ffffffff80000000         280000000 > *80000000 2  =
80000000 3
> ffffffff     3 > *ffffffffffffffff         2ffffffff > *ffffffff 2  =
ffffffff 3
> 00000000     3 >         300000000         300000000 >  00000000 3  =
00000000 3
> 7fffffff     3 >         37fffffff         37fffffff >  7fffffff 3  =
7fffffff 3
>=20
> The values marked with asterisks are wrong.
>=20
> The problem is that with a 64-bit time, in ext4_decode_extra_time() =
the
> epoch value is just OR'd with the sign-extended time - which, if =
negative,
> has all of the upper 32 bits set anyway.  We need to add the epoch =
instead
> of OR'ing it.  In ext4_encode_extra_time(), the reverse operation =
needs to
> take place as the 32-bit part of the number of seconds needs to be
> subtracted from the 64-bit value before the epoch is shifted down.
>=20
> Since the epoch is presumably unsigned, this has the slightly strange
> effect of, for epochs > 0, putting the 0x80000000-0xffffffff range =
before
> the 0x00000000-0x7fffffff range.
>=20
> This affects all kernels from v2.6.23-rc1 onwards.
>=20
> The test program:
>=20
> 	#include <stdio.h>
>=20
> 	#define EXT4_FITS_IN_INODE(x, y, z) 1
> 	#define EXT4_EPOCH_BITS 2
> 	#define EXT4_EPOCH_MASK ((1 << EXT4_EPOCH_BITS) - 1)
> 	#define EXT4_NSEC_MASK  (~0UL << EXT4_EPOCH_BITS)
>=20
> 	#define le32_to_cpu(x) (x)
> 	#define cpu_to_le32(x) (x)
> 	typedef unsigned int __le32;
> 	typedef unsigned int u32;
> 	typedef signed int s32;
> 	typedef unsigned long long __u64;
> 	typedef signed long long s64;
>=20
> 	struct timespec {
> 		long long	tv_sec;			/* seconds */
> 		long		tv_nsec;		/* nanoseconds =
*/
> 	};
>=20
> 	struct ext4_inode_info {
> 		struct timespec i_crtime;
> 	};
>=20
> 	struct ext4_inode {
> 		__le32  i_crtime;       /* File Creation time */
> 		__le32  i_crtime_extra; /* extra FileCreationtime (nsec =
<< 2 | epoch) */
> 	};
>=20
> 	/* Incorrect implementation */
> 	static inline void ext4_decode_extra_time_bad(struct timespec =
*time, __le32 extra)
> 	{
> 	       if (sizeof(time->tv_sec) > 4)
> 		       time->tv_sec |=3D (__u64)(le32_to_cpu(extra) & =
EXT4_EPOCH_MASK)
> 				       << 32;
> 	       time->tv_nsec =3D (le32_to_cpu(extra) & EXT4_NSEC_MASK) =
>> EXT4_EPOCH_BITS;
> 	}
>=20
> 	static inline __le32 ext4_encode_extra_time_bad(struct timespec =
*time)
> 	{
> 	       return cpu_to_le32((sizeof(time->tv_sec) > 4 ?
> 				   (time->tv_sec >> 32) & =
EXT4_EPOCH_MASK : 0) |
> 				  ((time->tv_nsec << EXT4_EPOCH_BITS) & =
EXT4_NSEC_MASK));
> 	}
>=20
> 	/* Fixed implementation */
> 	static inline void ext4_decode_extra_time_good(struct timespec =
*time, __le32 _extra)
> 	{
> 		u32 extra =3D le32_to_cpu(_extra);
> 		u32 epoch =3D extra & EXT4_EPOCH_MASK;
>=20
> 		time->tv_sec =3D (s32)time->tv_sec + ((s64)epoch  << =
32);
> 		time->tv_nsec =3D (extra & EXT4_NSEC_MASK) >> =
EXT4_EPOCH_BITS;
> 	}
>=20
> 	static inline __le32 ext4_encode_extra_time_good(struct timespec =
*time)
> 	{
> 		u32 extra;
> 		s64 epoch =3D time->tv_sec - (s32)time->tv_sec;
>=20
> 		extra =3D (epoch >> 32) & EXT4_EPOCH_MASK;
> 		extra |=3D (time->tv_nsec << EXT4_EPOCH_BITS) & =
EXT4_NSEC_MASK;
> 		return cpu_to_le32(extra);
> 	}
>=20
> 	#define EXT4_INODE_GET_XTIME_BAD(xtime, inode, raw_inode)		=
\
> 	do {									=
       \
> 		(inode)->xtime.tv_sec =3D =
(signed)le32_to_cpu((raw_inode)->xtime);       \
> 		if (EXT4_FITS_IN_INODE(raw_inode, EXT4_I(inode), xtime =
## _extra))     \
> 			ext4_decode_extra_time_bad(&(inode)->xtime,		=
\
> 						   raw_inode->xtime ## =
_extra);	\
> 		else								=
       \
> 			(inode)->xtime.tv_nsec =3D 0;				=
       \
> 	} while (0)
>=20
> 	#define EXT4_INODE_SET_XTIME_BAD(xtime, inode, raw_inode)		=
\
> 	do {									=
       \
> 		(raw_inode)->xtime =3D =
cpu_to_le32((inode)->xtime.tv_sec);	       \
> 		if (EXT4_FITS_IN_INODE(raw_inode, EXT4_I(inode), xtime =
## _extra))     \
> 			(raw_inode)->xtime ## _extra =3D			=
	       \
> 				=
ext4_encode_extra_time_bad(&(inode)->xtime);	\
> 	} while (0)
>=20
> 	#define EXT4_INODE_GET_XTIME_GOOD(xtime, inode, raw_inode)		=
\
> 	do {									=
       \
> 		(inode)->xtime.tv_sec =3D =
(signed)le32_to_cpu((raw_inode)->xtime);       \
> 		if (EXT4_FITS_IN_INODE(raw_inode, EXT4_I(inode), xtime =
## _extra))     \
> 			ext4_decode_extra_time_good(&(inode)->xtime,		=
	       \
> 					       raw_inode->xtime ## =
_extra);	\
> 		else								=
       \
> 			(inode)->xtime.tv_nsec =3D 0;				=
       \
> 	} while (0)
>=20
> 	#define EXT4_INODE_SET_XTIME_GOOD(xtime, inode, raw_inode)		=
\
> 	do {									=
       \
> 		(raw_inode)->xtime =3D =
cpu_to_le32((inode)->xtime.tv_sec);	       \
> 		if (EXT4_FITS_IN_INODE(raw_inode, EXT4_I(inode), xtime =
## _extra))     \
> 			(raw_inode)->xtime ## _extra =3D			=
	       \
> 				=
ext4_encode_extra_time_good(&(inode)->xtime);	\
> 	} while (0)
>=20
> 	static const struct test {
> 		unsigned crtime;
> 		unsigned extra;
> 		long long sec;
> 		int nsec;
> 	} tests[] =3D {
> 		// crtime	extra		tv_sec			=
tv_nsec
> 		0xffffffff,	0x00000000,	0xffffffffffffffff,	=
0,
> 		0x80000000,	0x00000000,	0xffffffff80000000,	=
0,
> 		0x00000000,	0x00000000,	0x0000000000000000,	=
0,
> 		0x7fffffff,	0x00000000,	0x000000007fffffff,	=
0,
> 		0x80000000,	0x00000001,	0x0000000080000000,	=
0,
> 		0xffffffff,	0x00000001,	0x00000000ffffffff,	=
0,
> 		0x00000000,	0x00000001,	0x0000000100000000,	=
0,
> 		0x7fffffff,	0x00000001,	0x000000017fffffff,	=
0,
> 		0x80000000,	0x00000002,	0x0000000180000000,	=
0,
> 		0xffffffff,	0x00000002,	0x00000001ffffffff,	=
0,
> 		0x00000000,	0x00000002,	0x0000000200000000,	=
0,
> 		0x7fffffff,	0x00000002,	0x000000027fffffff,	=
0,
> 		0x80000000,	0x00000003,	0x0000000280000000,	=
0,
> 		0xffffffff,	0x00000003,	0x00000002ffffffff,	=
0,
> 		0x00000000,	0x00000003,	0x0000000300000000,	=
0,
> 		0x7fffffff,	0x00000003,	0x000000037fffffff,	=
0,
> 	};
>=20
> 	int main()
> 	{
> 		struct ext4_inode_info ii_bad, ii_good;
> 		struct ext4_inode raw, *praw =3D &raw;
> 		struct ext4_inode raw_bad, *praw_bad =3D &raw_bad;
> 		struct ext4_inode raw_good, *praw_good =3D &raw_good;
> 		const struct test *t;
> 		int i, ret =3D 0;
>=20
> 		printf("time     extra   bad decode        good decode   =
      bad encode  good encode\n");
> 		printf("=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D   =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D   =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\n");
> 		for (i =3D 0; i < sizeof(tests) / sizeof(t[0]); i++) {
> 			t =3D &tests[i];
> 			raw.i_crtime =3D t->crtime;
> 			raw.i_crtime_extra =3D t->extra;
> 			printf("%08x %5d > ", t->crtime, t->extra);
>=20
> 			EXT4_INODE_GET_XTIME_BAD(i_crtime, &ii_bad, =
praw);
> 			EXT4_INODE_GET_XTIME_GOOD(i_crtime, &ii_good, =
praw);
> 			if (ii_bad.i_crtime.tv_sec !=3D t->sec ||
> 			    ii_bad.i_crtime.tv_nsec !=3D t->nsec)
> 				printf("*");
> 			else
> 				printf(" ");
> 			printf("%16llx", ii_bad.i_crtime.tv_sec);
> 			printf(" ");
> 			if (ii_good.i_crtime.tv_sec !=3D t->sec ||
> 			    ii_good.i_crtime.tv_nsec !=3D t->nsec) {
> 				printf("*");
> 				ret =3D 1;
> 			} else {
> 				printf(" ");
> 			}
> 			printf("%16llx", ii_good.i_crtime.tv_sec);
>=20
> 			EXT4_INODE_SET_XTIME_BAD(i_crtime, &ii_good, =
praw_bad);
> 			EXT4_INODE_SET_XTIME_GOOD(i_crtime, &ii_good, =
praw_good);
>=20
> 			printf(" > ");
> 			if (raw_bad.i_crtime !=3D raw.i_crtime ||
> 			    raw_bad.i_crtime_extra !=3D =
raw.i_crtime_extra)
> 				printf("*");
> 			else
> 				printf(" ");
> 			printf("%08llx %d", raw_bad.i_crtime, =
raw_bad.i_crtime_extra);
> 			printf(" ");
>=20
> 			if (raw_good.i_crtime !=3D raw.i_crtime ||
> 			    raw_good.i_crtime_extra !=3D =
raw.i_crtime_extra) {
> 				printf("*");
> 				ret =3D 1;
> 			} else {
> 				printf(" ");
> 			}
> 			printf("%08llx %d", raw_good.i_crtime, =
raw_good.i_crtime_extra);
> 			printf("\n");
> 		}
>=20
> 		return ret;
> 	}
>=20
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
>=20
> fs/ext4/ext4.h |   22 +++++++++++++---------
> 1 file changed, 13 insertions(+), 9 deletions(-)
>=20
> diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
> index fd1f28be5296..31efcd78bf51 100644
> --- a/fs/ext4/ext4.h
> +++ b/fs/ext4/ext4.h
> @@ -723,19 +723,23 @@ struct move_extent {
> 	<=3D (EXT4_GOOD_OLD_INODE_SIZE +			\
> 	    (einode)->i_extra_isize))			\
>=20
> -static inline __le32 ext4_encode_extra_time(struct timespec *time)
> +static inline void ext4_decode_extra_time(struct timespec *time, =
__le32 _extra)
> {
> -       return cpu_to_le32((sizeof(time->tv_sec) > 4 ?
> -			   (time->tv_sec >> 32) & EXT4_EPOCH_MASK : 0) |
> -                          ((time->tv_nsec << EXT4_EPOCH_BITS) & =
EXT4_NSEC_MASK));
> +	u32 extra =3D le32_to_cpu(_extra);
> +	u32 epoch =3D extra & EXT4_EPOCH_MASK;
> +
> +	time->tv_sec =3D (s32)time->tv_sec + ((s64)epoch  << 32);

Minor nit - two spaces before "<<".

> +	time->tv_nsec =3D (extra & EXT4_NSEC_MASK) >> EXT4_EPOCH_BITS;
> }
>=20
> -static inline void ext4_decode_extra_time(struct timespec *time, =
__le32 extra)
> +static inline __le32 ext4_encode_extra_time(struct timespec *time)
> {
> -       if (sizeof(time->tv_sec) > 4)
> -	       time->tv_sec |=3D (__u64)(le32_to_cpu(extra) & =
EXT4_EPOCH_MASK)
> -			       << 32;
> -       time->tv_nsec =3D (le32_to_cpu(extra) & EXT4_NSEC_MASK) >> =
EXT4_EPOCH_BITS;
> +	u32 extra;
> +	s64 epoch =3D time->tv_sec - (s32)time->tv_sec;
> +
> +	extra =3D (epoch >> 32) & EXT4_EPOCH_MASK;
> +	extra |=3D (time->tv_nsec << EXT4_EPOCH_BITS) & EXT4_NSEC_MASK;
> +	return cpu_to_le32(extra);
> }

David, thanks for moving this patch forward.

It would have been easier to review if the order of encode and decode
functions had not been reversed... :-)

It would be good to get a comment block in the code describing the =
encoding:

/*
 * We need is an encoding that preserves the times for extra epoch "00":
 *
 * extra                          add to 32-bit
 * epoch                          tv_sec to get
 * bits   decoded 64-bit tv_sec   64-bit value    valid time range
 * 0     -0x80000000..-0x00000001  0x000000000    1901-12-13..1969-12-31
 * 0     0x000000000..0x07fffffff  0x000000000    1970-01-01..2038-01-19
 * 1     0x080000000..0x0ffffffff  0x100000000    2038-01-19..2106-02-07
 * 1     0x100000000..0x17fffffff  0x100000000    2106-02-07..2174-02-25
 * 2     0x180000000..0x1ffffffff  0x200000000    2174-02-25..2242-03-16
 * 2     0x200000000..0x27fffffff  0x200000000    2242-03-16..2310-04-04
 * 3     0x280000000..0x2ffffffff  0x300000000    2310-04-04..2378-04-22
 * 3     0x300000000..0x37fffffff  0x300000000    2378-04-22..2446-05-10
 *
 * Note that previous versions of the kernel on 64-bit systems would
 * incorrectly use extra epoch bits 1,1 for dates between 1901 and 1970.
 * e2fsck will correct this, assuming that it is run on the affected
 * filesystem before 2242.
 */


The only other question is whether you compile tested this on a 32-bit
system?  IIRC, the "sizeof(time->tv_sec)" check was to avoid compiler
warnings due to assigning values too large for the data type, and (to
a lesser extent) avoiding overhead on those systems.

If there is no 32-bit compile warning then I'm fine with this as-is,
since systems with 32-bit tv_sec are going to be broken at that point
in any case.

Cheers, Andreas






--Apple-Mail=_F77C77DE-FB45-4F8D-B5F6-DA53FA3D351D
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBVlSgZnKl2rkXzB/gAQiKkA/+O2EU5vEC88oQdrv/mcBbSKta+p1wP7Ul
OP5BYGn/x4Q3UNTDrwF24mzAncnv34iwJKIuczq+13i1mbMQZHB2VFTDfmfz7lII
Xz3cLI+37vvDfdJ1WRd8qwKyExLB3jzLcoTnC18i2z7kUMLNkkuZGCxd7WV9i5ra
vOalO8wJUrZLsbKIRAI+49uORfIcfHvUlchVbCrWOowMLr6qq6WSRG9r2vzzspT8
Xsgf2ebcqVwmpAlz1NCM0R2xG/DEgZBhD16I24s5dexFg7cS9y0IXCXmPNrxwu90
IG2EEazdOWMLgllRRpVBlCJNdBy/19G2KYBqEnKJ9zVUV3rWHaLtCtP+4Og6Wmzc
WPQFhmEQyqhr65OoVuNdAe0ys3qRDWki475oFwyykkSV8m7PAkt7RtBTz4FMTMGh
Ll+ntjYOWY7TS5T1adsAUcHsYHNx7uV4vWD2TNSMQQjoBa+xJ7MuvxusIaihagd8
wCVmvObdfABNT/Q0p24FEB4iKuhhvinFNMXfiKKxaCwXQSHDDnnuAZlHudjFMMwy
zL5n8bUm5dyT9b/WnSEX3zhdTnjLqZMH+Bk2IjzHbemnFyr9axzlShlohB7Uu6IX
DYEWggBV+A3M1XSYPqVdDZGNgz1AYskc7dnGsQ+xFbZQZPBgFSALWPHB0C13E0Hn
Zswhn+qgkZI=
=psDE
-----END PGP SIGNATURE-----

--Apple-Mail=_F77C77DE-FB45-4F8D-B5F6-DA53FA3D351D--
