Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f181.google.com ([209.85.192.181]:64437 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757280Ab3KLWnz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 17:43:55 -0500
Received: by mail-pd0-f181.google.com with SMTP id p10so3043491pdj.12
        for <linux-nfs@vger.kernel.org>; Tue, 12 Nov 2013 14:43:54 -0800 (PST)
Content-Type: multipart/signed; boundary="Apple-Mail=_CD9BD5F7-5EF7-463E-AD51-F78D530DD055"; protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1822\))
Subject: Re: [PATCH 2/3] statxat: Add a system call to make extended file stats available [ver #2]
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20131112184142.2880.21338.stgit@warthog.procyon.org.uk>
Date: Tue, 12 Nov 2013 15:43:49 -0700
Cc: viro@ZenIV.linux.org.uk, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, libc-alpha@sourceware.org,
        linux-api@vger.kernel.org, andreas.gruenbacher@gmail.com,
        samba-technical@lists.samba.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Message-Id: <20D5CDB6-88B4-4343-BFC5-0CD0FDCC0574@dilger.ca>
References: <20131112184127.2880.24025.stgit@warthog.procyon.org.uk> <20131112184142.2880.21338.stgit@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_CD9BD5F7-5EF7-463E-AD51-F78D530DD055
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Nov 12, 2013, at 11:41 AM, David Howells <dhowells@redhat.com> wrote:

> Add a system call to make extended file stats available, including =
file
> creation time, inode version and data version where available through =
the
> underlying filesystem.

[snip]

> The defined bits in st_ioc_flags are the usual FS_xxx_FL, plus some =
extra flags
> that might be supplied by the filesystem.  Note that Ext4 returns =
flags outside
> of {EXT4,FS}_FL_USER_VISIBLE in response to FS_IOC_GETFLAGS.  Should
> {EXT4,FS}_FL_USER_VISIBLE be extended to cover them?  Or should the =
extra flags
> be suppressed?

This is a bug in the ext4 code.  EXT4_FL_USER_VISIBLE should be extended =
to cover
all of the flags that are useful to userspace.

> diff --git a/fs/stat.c b/fs/stat.c
> index d0ea7ef75e26..a5e603753bd3 100644
> --- a/fs/stat.c
> +++ b/fs/stat.c
> +/**
> + * vfs_fstatx - Get the enhanced basic attributes by file descriptor
> + * @fd: The file descriptor refering to the file of interest
> + * @stat: The result structure to fill in.
> + *
> + * This function is a wrapper around vfs_xgetattr().  The main =
difference is
> + * that it uses a file descriptor to determine the file location.
> + *
> + * The caller must have preset stat->query_flags, stat->request_mask =
and
> + * stat->auxinfo as for vfs_xgetattr().
> + *
> + * 0 will be returned on success, and a -ve error code if =
unsuccessful.
> + */
> +int vfs_fstatx(unsigned int fd, struct kstat *stat)
> {
> 	struct fd f =3D fdget_raw(fd);
> 	int error =3D -EBADF;
>=20
> 	if (f.file) {
> -		error =3D vfs_getattr(&f.file->f_path, stat);
> +		error =3D vfs_xgetattr(&f.file->f_path, stat);
> 		fdput(f);
> 	}
> 	return error;
> }
> +EXPORT_SYMBOL(vfs_fstatx);
> +
> +/**
> + * vfs_fstat - Get basic attributes by file descriptor
> + * @fd: The file descriptor refering to the file of interest
> + * @stat: The result structure to fill in.
> + *
> + * This function is a wrapper around vfs_getattr().  The main =
difference is

Typo above - vfs_fstat() is a wrapper around vfs_fstatx().

> + * that it uses a file descriptor to determine the file location.
> + *
> + * 0 will be returned on success, and a -ve error code if =
unsuccessful.
> + */
> +int vfs_fstat(unsigned int fd, struct kstat *stat)
> +{
> +	stat->query_flags =3D 0;
> +	stat->request_mask =3D STATX_BASIC_STATS;
> +	stat->auxinfo =3D NULL;
> +	return vfs_fstatx(fd, stat);
> +}
> EXPORT_SYMBOL(vfs_fstat);

[snip]

> +/*
> + * Flags to be st_mask
> + *
> + * Query request/result mask for statxat() and struct statx::st_mask.
> + *
> + * These bits should be set in the mask argument of statxat() to =
request
> + * particular items when calling statxat().
> + */
> +#define STATX_MODE		0x00000001U	/* Want/got st_mode */
> +#define STATX_NLINK		0x00000002U	/* Want/got st_nlink */
> +#define STATX_UID		0x00000004U	/* Want/got st_uid */
> +#define STATX_GID		0x00000008U	/* Want/got st_gid */
> +#define STATX_RDEV		0x00000010U	/* Want/got st_rdev */
> +#define STATX_ATIME		0x00000020U	/* Want/got st_atime */
> +#define STATX_MTIME		0x00000040U	/* Want/got st_mtime */
> +#define STATX_CTIME		0x00000080U	/* Want/got st_ctime */
> +#define STATX_INO		0x00000100U	/* Want/got st_ino */
> +#define STATX_SIZE		0x00000200U	/* Want/got st_size */
> +#define STATX_BLOCKS		0x00000400U	/* Want/got st_blocks */
> +#define STATX_ALLOC_BLKSIZE	0x00000800U	/* Want/got =
st_alloc_blksize */
> +#define STATX_IO_PARAMS		0x00000800U	/* Want/got I/O =
parameters */
> +#define STATX_BASIC_STATS	0x00000fffU	/* The stuff in the =
normal stat struct */

Does it make sense for code clarity to #define STATX_BASIC_STATS =
explicitly in terms
of the symbolic STATX_* fields, instead of just the numeric value?

> +#define STATX_BTIME		0x00001000U	/* Want/got st_btime */
> +#define STATX_VERSION		0x00002000U	/* Want/got =
st_version */
> +#define STATX_IOC_FLAGS		0x00004000U	/* Want/got =
FS_IOC_GETFLAGS */
> +#define STATX_ALL_STATS		0x00007fffU	/* All supported =
stats */

This could be #defined in terms of STATX_BASIC_STATS | STATX_{other =
flags} to make
it easier to see what is in the basic flags, and what is extra.

Cheers, Andreas






--Apple-Mail=_CD9BD5F7-5EF7-463E-AD51-F78D530DD055
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQEVAwUBUoKvJes+FW+tNA/TAQLqVgf7BCGvUw2hE9VtbaoN7EC8dz1FJ4WsK8Ee
oMTqZ7dA3sHqH3wLrVVRYvL6omz//ckkaovb+QlCGba1/9h1qhrPgjoVIhN1vIeD
X1gWTyhrRhUbIDLJ58o/CVTRddGdGNbV/uHHZwmbnfwS2FvUsVYbqpgiMbUUm8Nm
takkVVRjBOYgFJMr7faYVaoeBLwu9t2gSbKP5RuWCzfL2GLDuf6RPEOfcWOuf0GO
CUwAg71CtoH1cxRZfq7Ppc36Yf16TsLCtRLX2BAPcBcEryMpIfW7o7PgS22QGOpG
aqTg2PcHpQvPlsrsxhXJkvEt25Nl+WK2gHAU4wfF5SZtu58pSyKx8Q==
=t2rX
-----END PGP SIGNATURE-----

--Apple-Mail=_CD9BD5F7-5EF7-463E-AD51-F78D530DD055--
