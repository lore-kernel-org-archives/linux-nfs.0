Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35820 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754528AbdEZT6k (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 May 2017 15:58:40 -0400
Received: by mail-it0-f67.google.com with SMTP id 67so2396097itx.2
        for <linux-nfs@vger.kernel.org>; Fri, 26 May 2017 12:58:40 -0700 (PDT)
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <9E1EC8DB-1864-4ABA-8BEB-79C3EA9C4EBF@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_C4D7C509-FC52-48AF-A0D7-E8D8E853614C";
 protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: fsetxattr(2) for ACL on nfs
Date: Fri, 26 May 2017 13:58:33 -0600
In-Reply-To: <27179.1495751869@jrobl>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: "J. R. Okajima" <hooanon05g@gmail.com>
References: <27179.1495751869@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_C4D7C509-FC52-48AF-A0D7-E8D8E853614C
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On May 25, 2017, at 4:37 PM, J. R. Okajima <hooanon05g@gmail.com> wrote:
>=20
> Since v4.12-rc1, I see an error on NFS3.
>=20
> $ stat -f .
>  File: "."
>    ID: 0        Namelen: 255     Type: nfs
> Block size: 32768      Fundamental block size: 32768
> Blocks: Total: 248        Free: 247        Available: 234
> Inodes: Total: 2048       Free: 2020
> $ cp ../ro/f_src .
> $ rm f_src
> rm: remove regular file 'f_src'? y
> $ cp -p ../ro/f_src .
> cp: preserving permissions for './f_src': Permission denied
>=20
> (from "cp --help")
>  -p                           same as =
--preserve=3Dmode,ownership,timestamps
>      --preserve[=3DATTR_LIST]   preserve the specified attributes =
(default:
>                                 mode,ownership,timestamps), if =
possible
>                                 additional attributes: context, links, =
xattr,
>                                 all
>=20
> By strace, I see fsetxattr(2) for ACL returned the error.
> Is this an intentional behaviour?
>=20
> (from strace)
> open("../ro/f_src", O_RDONLY)           =3D 3
> fstat(3, {st_mode=3DS_IFREG|0644, st_size=3D2, ...}) =3D 0
> open("./f_src", O_WRONLY|O_CREAT|O_EXCL, 0600) =3D 4
> fstat(4, {st_mode=3DS_IFREG|0600, st_size=3D0, ...}) =3D 0
> fadvise64(3, 0, 0, POSIX_FADV_SEQUENTIAL) =3D 0
> mmap(NULL, 139264, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, =
-1, 0) =3D 0x7fcb293f8000
> read(3, "f\n", 131072)                  =3D 2
> write(4, "f\n", 2)                      =3D 2
> read(3, "", 131072)                     =3D 0
> utimensat(4, NULL, {{1495750885, 0}, {1495750885, 0}}, 0) =3D 0
> fgetxattr(3, "system.posix_acl_access", 0x7ffed40196d0, 132) =3D -1 =
ENODATA (No data available)
> fstat(3, {st_mode=3DS_IFREG|0644, st_size=3D2, ...}) =3D 0
> fsetxattr(4, "system.posix_acl_access", =
"\x02\x00\x00\x00\x01\x00\x06\x00\xff\xff\xff\xff\x04\x00\x04\x00\xff\xff\=
xff\xff \x00\x04\x00\xff\xff\xff\xff", 28, 0) =3D -1 EACCES (Permission =
denied)

To me this looks like "cp" is broken.  If it gets no POSIX ACL xattr =
from the
kernel (ENODATA) for this file, why is it trying to save a POSIX ACL to =
the
copy?  That just adds needless overhead, either at the syscall level, or =
also
on disk if it is storing ACLs on files that don't need them...

Cheers, Andreas

> fchmod(4, 0100644)                      =3D 0
> open("/usr/lib/charset.alias", O_RDONLY|O_NOFOLLOW) =3D -1 ENOENT (No =
such file or directory)
> write(2, "cp: ", 4)                     =3D 4
> write(2, "preserving permissions for './f_"..., 36) =3D 36
> write(2, ": Permission denied", 19)     =3D 19
> write(2, "\n", 1)                       =3D 1
>=20
> Additonally, after this error, the shutdown process stops saying
> 	nfs: server localhost not responding, still trying
>=20
> Does anyone know which commit causes these problems?
>=20
>=20
> J. R. Okajima


Cheers, Andreas






--Apple-Mail=_C4D7C509-FC52-48AF-A0D7-E8D8E853614C
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iD8DBQFZKIjppIg59Q01vtYRAstVAKCdRXvQW+eMyGM5bY23EeW/eR40tgCg0Udn
IrU1+EJcyggYdDIyCLQB330=
=CUPI
-----END PGP SIGNATURE-----

--Apple-Mail=_C4D7C509-FC52-48AF-A0D7-E8D8E853614C--
