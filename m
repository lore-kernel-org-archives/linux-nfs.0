Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f41.google.com ([209.85.220.41]:44030 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757035Ab3KLW0G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 17:26:06 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so1680799pab.14
        for <linux-nfs@vger.kernel.org>; Tue, 12 Nov 2013 14:26:05 -0800 (PST)
Content-Type: multipart/signed; boundary="Apple-Mail=_7BB3274A-F127-4463-BD8E-8C85026E53B9"; protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1822\))
Subject: Re: [PATCH 1/3] statxat: Provide IOC flags for Windows fs attributes
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20131112173526.25813.85546.stgit@warthog.procyon.org.uk>
Date: Tue, 12 Nov 2013 15:25:57 -0700
Cc: viro@ZenIV.linux.org.uk, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, libc-alpha@sourceware.org,
        linux-api@vger.kernel.org, andreas.gruenbacher@gmail.com,
        samba-technical@lists.samba.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Message-Id: <6626143A-0910-4C8A-8F49-96896B6AA715@dilger.ca>
References: <20131112173518.25813.67568.stgit@warthog.procyon.org.uk> <20131112173526.25813.85546.stgit@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>, "Theodore Ts'o" <tytso@mit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_7BB3274A-F127-4463-BD8E-8C85026E53B9
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

On Nov 12, 2013, at 10:35 AM, David Howells <dhowells@redhat.com> wrote:
> Provide IOC flags for Windows fs attributes so that they can be =
retrieved (or
> even altered) using the FS_IOC_[GS]ETFLAGS ioctl and read using =
statxat().
>=20
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
>=20
> include/uapi/linux/fs.h |    7 +++++--
> 1 file changed, 5 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
> index 6c28b61bb690..8b966f48dd41 100644
> --- a/include/uapi/linux/fs.h
> +++ b/include/uapi/linux/fs.h
> @@ -191,10 +191,13 @@ struct inodes_stat_t {
> #define FS_EXTENT_FL			0x00080000 /* Extents */
> #define FS_DIRECTIO_FL			0x00100000 /* Use direct =
i/o */
> #define FS_NOCOW_FL			0x00800000 /* Do not cow file */
> +#define FS_HIDDEN_FL			0x10000000 /* Windows hidden =
file attribute */

The 0x10000000 flag is used by ext4 as EXT4_INLINE_DATA_FL.  This would =
basically fill
up all of the inode flags for ext2/3/4, and while there isn=92t a =
guarantee that there
will not be any conflicts between FS_*_FL and EXT4_*_FL, it is a lot =
easier if they
are the same.

One option is to move FS_HIDDEN_FL over to use 0x04000000, which is =
currently used as
EXT4_SNAPFILE_DELETED_FL, but that is IMHO an ext4-internal flag that it =
isn=92t in
common use anywhere, and isn=92t so bad to have a conflict with.

Ted, any thoughts on this?

Cheers, Andreas

> +#define FS_SYSTEM_FL			0x20000000 /* Windows system =
file attribute */
> +#define FS_ARCHIVE_FL			0x40000000 /* Windows =
archive file attribute */
> #define FS_RESERVED_FL			0x80000000 /* reserved =
for ext2 lib */
>=20
> -#define FS_FL_USER_VISIBLE		0x0003DFFF /* User visible flags =
*/
> -#define FS_FL_USER_MODIFIABLE		0x000380FF /* User =
modifiable flags */
> +#define FS_FL_USER_VISIBLE		0x7003DFFF /* User visible flags =
*/
> +#define FS_FL_USER_MODIFIABLE		0x700380FF /* User =
modifiable flags */
>=20
>=20
> #define SYNC_FILE_RANGE_WAIT_BEFORE	1
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe =
linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Cheers, Andreas






--Apple-Mail=_7BB3274A-F127-4463-BD8E-8C85026E53B9
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQEVAwUBUoKq9es+FW+tNA/TAQLgQgf/YQoPccXrnK5ctxXO1Ow/CQFqmXz912Xs
BzMIV86/wGFUdrg1CGD9yeqz0D2eS4Y6sx12iW0dCLqkhx+X1A9oORZA5YBV3wz+
mVhlIjCNK/sdPzKz/4yt1FS6vIgCsoTEfQ5EcY4hnvvI1Pu0BOksWXEju8r8DAMW
wY5EeprKTrvjkpNvXvbW4TfypRec/oKfvq0mSLFkPtPamB9O/k+W1v/ISYauk4mM
qZ6pirO/J00S8DmrEr0sg5Pq8qXYPRIkJigjstMmm9Qpq4eVL8bYDA2yx3vH8xCR
cTf8TtbiBtssa5Fvh8+HJDXA/hWxvzLzTHxImx66AzsWPTap9BlAtg==
=FHfZ
-----END PGP SIGNATURE-----

--Apple-Mail=_7BB3274A-F127-4463-BD8E-8C85026E53B9--
