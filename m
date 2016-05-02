Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f193.google.com ([209.85.213.193]:34736 "EHLO
	mail-ig0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755254AbcEBWwR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 18:52:17 -0400
Received: by mail-ig0-f193.google.com with SMTP id qu10so571520igc.1
        for <linux-nfs@vger.kernel.org>; Mon, 02 May 2016 15:52:17 -0700 (PDT)
Subject: Re: [PATCH 5/6] statx: Make windows attributes available for CIFS, NTFS and FAT to use
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: multipart/signed; boundary="Apple-Mail=_DBB7F1D5-A7F9-4A1E-B40E-918CCDED7C1F"; protocol="application/pgp-signature"; micalg=pgp-sha256
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20160429125813.23636.49830.stgit@warthog.procyon.org.uk>
Date: Mon, 2 May 2016 16:52:12 -0600
Cc: linux-fsdevel@vger.kernel.org, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org
Message-Id: <D21EA8F8-0A7A-4275-8D4C-E9CFCC2A7293@dilger.ca>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk> <20160429125813.23636.49830.stgit@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_DBB7F1D5-A7F9-4A1E-B40E-918CCDED7C1F
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Apr 29, 2016, at 6:58 AM, David Howells <dhowells@redhat.com> wrote:
>=20
> Make windows attributes available for CIFS, NTFS and FAT to use in the
> statx struct.  The attribute flags map directly by value to those in =
the
> CIFS PDU flags.  Some of these bits can also be used by JFS, UFS and =
HPFS.
>=20
> The statx struct acquires:
>=20
> 	__u32	st_win_attrs;

It seems some of these flags are duplicated with the st_information =
field,
and some are duplicate with FS_IOC_GETFLAGS values, and returning the =
same
information in multiple ways is confusing.

If these flags are part of the CIFS protocol, and are directly usable by
Samba then I can understand we wouldn't want to change them once in the
kernel and then convert them back in userspace, but I'm a bit reluctant
to have flags only for CIFS/NTFS/FAT that might also be useful for other =
filesystems.  Would we want to be able to get translated st_win_attrs
flags in ext4 attrs when it is being exported by Samba?

> The value in this is present if STATX_WIN_ATTRS is set.
>=20
> The defined flags in this are:
>=20
> 	STATX_WIN_ATTR_READONLY
> 	STATX_WIN_ATTR_HIDDEN
> 	STATX_WIN_ATTR_SYSTEM
> 	STATX_WIN_ATTR_DIRECTORY

How does this differ from (st_mode & S_IFMT) =3D=3D S_IFDIR)?

> 	STATX_WIN_ATTR_ARCHIVE
> 	STATX_WIN_ATTR_NORMAL

How does this differ from (st_mode & S_IFMT) =3D=3D S_IFREG)?

> 	STATX_WIN_ATTR_TEMPORARY

How does this differ from STATX_INFO_TEMPORARY?

> 	STATX_WIN_ATTR_SPARSE_FILE
> 	STATX_WIN_ATTR_REPARSE_POINT
> 	STATX_WIN_ATTR_COMPRESSED
> 	STATX_WIN_ATTR_OFFLINE
> 	STATX_WIN_ATTR_NOT_CONTENT_INDEXED
> 	STATX_WIN_ATTR_ENCRYPTED

How does this differ from STATX_INFO_ENCRYPTED?

Cheers, Andreas

> 	STATX_WIN_ATTR_INTEGRITY_STREAM
> 	STATX_WIN_ATTR_NO_SCRUB_DATA
>=20
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
>=20
> fs/stat.c                  |    5 ++++-
> include/uapi/linux/stat.h  |   30 ++++++++++++++++++++++++++++--
> samples/statx/test-statx.c |   31 +++++++++++++++++++++++++++++++
> 3 files changed, 63 insertions(+), 3 deletions(-)
>=20
> diff --git a/fs/stat.c b/fs/stat.c
> index c2f8370dab13..1552bff154e6 100644
> --- a/fs/stat.c
> +++ b/fs/stat.c
> @@ -83,6 +83,7 @@ int vfs_xgetattr_nosec(struct path *path, struct =
kstat *stat)
>=20
> 	stat->result_mask =3D 0;
> 	stat->information =3D 0;
> +	stat->win_attrs =3D 0;
> 	if (inode->i_op->getattr)
> 		return inode->i_op->getattr(path->mnt, path->dentry, =
stat);
>=20
> @@ -643,7 +644,9 @@ static long statx_set_result(struct kstat *stat, =
struct statx __user *buffer)
> 	    __put_user(stat->blocks,		&buffer->st_blocks	=
) ||
> 	    __put_user(stat->version,		&buffer->st_version	=
) ||
> 	    __put_user(stat->gen,		&buffer->st_gen		=
) ||
> -	    __clear_user(&buffer->__spare1, sizeof(buffer->__spare1)))
> +	    __put_user(stat->win_attrs,		&buffer->st_win_attrs	=
) ||
> +	    __clear_user(&buffer->__spare1,
> +			 sizeof(buffer->__spare1) + =
sizeof(buffer->__spare2)))
> 		return -EFAULT;
>=20
> 	return 0;
> diff --git a/include/uapi/linux/stat.h b/include/uapi/linux/stat.h
> index 55ce6607dab6..64729b0785bf 100644
> --- a/include/uapi/linux/stat.h
> +++ b/include/uapi/linux/stat.h
> @@ -106,7 +106,10 @@ struct statx {
> 	__u32	st_dev_major;	/* ID of device containing file [uncond] =
*/
> 	__u32	st_dev_minor;
> 	/* 0x80 */
> -	__u64	__spare1[16];	/* Spare space for future expansion */
> +	__u32	st_win_attrs;	/* Windows file attributes */
> +	__u32	__spare1[3];
> +	/* 0x90 */
> +	__u64	__spare2[14];	/* Spare space for future expansion */
> 	/* 0x100 */
> };
>=20
> @@ -133,7 +136,8 @@ struct statx {
> #define STATX_BTIME		0x00000800U	/* Want/got st_btime */
> #define STATX_VERSION		0x00001000U	/* Want/got st_version =
*/
> #define STATX_GEN		0x00002000U	/* Want/got st_gen */
> -#define STATX_ALL_STATS		0x00003fffU	/* All supported =
stats */
> +#define STATX_WIN_ATTRS		0x00004000U	/* Want/got =
st_win_attrs */
> +#define STATX_ALL_STATS		0x00007fffU	/* All supported =
stats */
>=20
> /*
>  * Flags to be found in st_information
> @@ -151,4 +155,26 @@ struct statx {
> #define STATX_INFO_AUTODIR		0x00000040U /* Dir provides =
unlisted automounts */
> #define STATX_INFO_NONSYSTEM_OWNERSHIP	0x00000080U /* File has =
non-system ownership details */
>=20
> +/*
> + * Flags to be found in st_win_attrs.
> + *
> + * These give information about the state of a file on a Windows =
filesystem
> + * (such as. FAT, NTFS, CIFS).  These values are borrowed from the =
CIFS fs.
> + */
> +#define STATX_WIN_ATTR_READONLY			0x00000001
> +#define STATX_WIN_ATTR_HIDDEN			0x00000002
> +#define STATX_WIN_ATTR_SYSTEM			0x00000004
> +#define STATX_WIN_ATTR_DIRECTORY		0x00000010
> +#define STATX_WIN_ATTR_ARCHIVE			0x00000020
> +#define STATX_WIN_ATTR_NORMAL			0x00000080
> +#define STATX_WIN_ATTR_TEMPORARY		0x00000100
> +#define STATX_WIN_ATTR_SPARSE_FILE		0x00000200
> +#define STATX_WIN_ATTR_REPARSE_POINT		0x00000400
> +#define STATX_WIN_ATTR_COMPRESSED		0x00000800
> +#define STATX_WIN_ATTR_OFFLINE			0x00001000
> +#define STATX_WIN_ATTR_NOT_CONTENT_INDEXED	0x00002000
> +#define STATX_WIN_ATTR_ENCRYPTED		0x00004000
> +#define STATX_WIN_ATTR_INTEGRITY_STREAM		0x00008000
> +#define STATX_WIN_ATTR_NO_SCRUB_DATA		0x00020000
> +
> #endif /* _UAPI_LINUX_STAT_H */
> diff --git a/samples/statx/test-statx.c b/samples/statx/test-statx.c
> index 38ef23c12e7d..86eac7d16c32 100644
> --- a/samples/statx/test-statx.c
> +++ b/samples/statx/test-statx.c
> @@ -134,6 +134,37 @@ static void dump_statx(struct statx *stx)
> 	if (stx->st_mask & STATX_GEN)
> 		printf("Inode gen   : %xh\n", stx->st_gen);
>=20
> +	if (stx->st_mask & STATX_WIN_ATTRS) {
> +		unsigned char bits;
> +		int loop, byte;
> +
> +		static char wattr_representation[32 + 1] =3D
> +			/* STATX_WIN_ATTR_ flags: */
> +			"????????"	/* 31-24	=
0x00000000-ff000000 */
> +			"??????N?"	/* 23-16	=
0x00000000-00ff0000 */
> +			"ieNocrst"	/* 15- 8	=
0x00000000-0000ff00 */
> +			"n?Ad?SHR"	/*  7- 0	=
0x00000000-000000ff */
> +			;
> +
> +		printf("Win attrs  : %08llx (",
> +		       (unsigned long long)stx->st_win_attrs);
> +		for (byte =3D 32 - 8; byte >=3D 0; byte -=3D 8) {
> +			bits =3D stx->st_win_attrs >> byte;
> +			for (loop =3D 7; loop >=3D 0; loop--) {
> +				int bit =3D byte + loop;
> +
> +				if (bits & 0x80)
> +					putchar(wattr_representation[31 =
- bit]);
> +				else
> +					putchar('-');
> +				bits <<=3D 1;
> +			}
> +			if (byte)
> +				putchar(' ');
> +		}
> +		printf(")\n");
> +	}
> +
> 	if (stx->st_information) {
> 		unsigned char bits;
> 		int loop, byte;
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Cheers, Andreas






--Apple-Mail=_DBB7F1D5-A7F9-4A1E-B40E-918CCDED7C1F
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBVyfaHHKl2rkXzB/gAQjOmg//X8Uk8jcMk6Azbc0W5XItlYzjlrefkhSt
4wfqxBaD8MWBIdfCu+8tKrHf5TEH9rUhooHEyLxDOdcucQwCDgCQ/3F5m8rxVCUH
Yn4twP0SE2tleD/iB/jlnq00QTHqXFA5KVac2+0CSiQplxFa+IKrDH4sRrd+ZI1/
09D0+vvjwFXsFOusP2xFnbVYnL3Ks40Vvhtb5svIkslFP4KnV3NjEyl/s4XrZhEr
uESsuGQC8xdUEDqduLFfxXUyjaeqHVPfYeV7mf0yCTmiJ2hlrZ7+y3BizYAhVJ6E
gx7cuOsIUAZI68SuIDFlw7iQ+KTzhEq6uwfPGEQ1XG4XvlaspwEL6BGUu3oQXoUC
VwAGwBZFuC/Zn2+Vk1nBr//p1Gdtgsc7q2h625PXUjlEiKA+2SNaBTxbebTEERPm
LkAMkaMPwuiBMKlIs1VhNSrHo7ZN7MzygOekm7uCX0OCGLMqOQ1VBYLPMuJWB81J
5eq9gu5ipQseRqTFOVVnBaXUf80CPOIRzyX5J7jOcXWgLmGeT3R/noCQCyMZ9v/z
eia/GccBmzcgiVuxByR2CbBDT0hRfw4UyLOcsgvcC3G2NzQK7exUa0vLUbTCBvXV
itdWIWVOwjjk1LpfwL1fbYaWL24HylPCAtt3rOAh5OfE/IY3buRvkKYJOEUNaqvm
zDNdBYYGSRM=
=D4vw
-----END PGP SIGNATURE-----

--Apple-Mail=_DBB7F1D5-A7F9-4A1E-B40E-918CCDED7C1F--
