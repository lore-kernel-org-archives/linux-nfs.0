Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:36268 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751439AbcCUUTb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Mar 2016 16:19:31 -0400
Subject: Re: Making an interface for alternative data streams
To: linux-nfs@vger.kernel.org
References: <56F03945.40208@gentoo.org>
Cc: linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
From: Richard Yao <ryao@gentoo.org>
Message-ID: <56F05745.50204@gentoo.org>
Date: Mon, 21 Mar 2016 16:19:17 -0400
MIME-Version: 1.0
In-Reply-To: <56F03945.40208@gentoo.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="m32snPoH62SbS1t6cgrcUvdD7BhFNl8tS"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--m32snPoH62SbS1t6cgrcUvdD7BhFNl8tS
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 03/21/2016 02:11 PM, Richard Yao wrote:
> I am thinking of implementing Solaris-style alternative data streams in=

> the ZFSOnLinux driver via an ioctl and writing a compatibility shim so
> that software written to use O_XATTR can be trivially adapted to use th=
e
> interface.
>=20
> I sketched out the fine details on github:
>=20
> https://github.com/zfsonlinux/zfs/issues/4437
>=20
> I would be much happier if the VFS gave filesystem drivers the ability
> to implement O_XATTR. That would avoid the need to (ab)use an ioctl for=

> this and eliminate the risk of using a bit that would be defined to mea=
n
> something else. The former risks permissions checks becoming stale whil=
e
> the latter is a situation that I would be happy to avoid.
>=20
> Since this sort of interface is applicable to NFS too, I wanted to ask
> what various mainline developers think about it before I tried doing an=

> initial implementation.
>=20

Maybe I should clarify that the idea is to allow read/write/list of
extended attributes via read/write/readdir so that those that want
extended attributes that are alternative data streams can have them. I
do not want to see extended attributes and alternative data streams be
different things. Alternative data streams are in the NFSv4
specification, so I thought that the developers of the NFS client driver
would want something like this.

If it went into the VFS, then existing in-tree filesystems could have it
mapped to the existing interface, which would allow it to work
everywhere extended attributes are implemented. If they are not
interested, then I could go ahead with my ioctl idea. I just wanted to
try to implement this in a way everyone who can use it would like so
that we can avoid a XKCD #927 situation in the future:

https://xkcd.com/927/


--m32snPoH62SbS1t6cgrcUvdD7BhFNl8tS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW8FdLAAoJECDuEZm+6ExkOD4QAKGfnMhxHQJI7s864hcxDavd
+7Yw5XAuHwxqOTPNBAFtfr6TI2bspu2hkn/mdz4ocVX/3L0Gn/+MH25kXZ7Tp5EN
RNAMubaJKVVKzY2SMdocgk+5YrF63UY/bFRbUmcE69UXsoncg3KgUg44bmKIEZ6Z
yjJPJeawZ5vwfZcvCxlNPnRf48y6f0GokDFXp/Ss5SJjoSyPeFLuRsC0Wxpkk6X7
ELh1g+HvG2OPk2yUY70la1t3Npp3hhI5VPvCRxCzd50GMjje5mDxfi+dWulJmH5w
dmLsVqgISuglXvfXjAIKo06YDd4B9jN+JUTp5ZS3HUF2zhw+ohzm0swaNpOLKNW1
N8ELxnr1y/wyV1mmmZXcMTXGMchxLI3gmlPbq42qUMQYDA6tCdL1H2gPTvre+sI8
0gAk4q7DxQv+sigHyBTTCqxLrP6ajArWDnNDO1v5GJ7cdX++5DcNdEW1I2hpzVSS
KxMTP6KLS/Tw9Cq9mp+/Qlq/e8UYCb9/V9tecJN9obE8ty8EoMujplILNzhnproF
nJ7DU+y2M71uQ52LCtMDdY21qsT1KsCIUB9+lT8R7Grp1Zd/bxgTAfRzuK6cIlQh
O54s4RzEcaYxjKHYOWxYTMAD6rrA6BKRKYrmexOJr9UGGac0Gi+LXmVZvFMs8ZSO
8+c0MhJHLhZdXc7+aX3k
=2GOk
-----END PGP SIGNATURE-----

--m32snPoH62SbS1t6cgrcUvdD7BhFNl8tS--
