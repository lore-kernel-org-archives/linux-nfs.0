From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: x86_64: 32bit emulation problems
Date: Mon, 28 Feb 2005 16:47:00 -0800
Message-ID: <1109638020.31821.95.camel@seki.nac.uci.edu>
References: <200502282208.29263.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-3F/+ctWL48ROhU1KDGM7"
Cc: strombrg@dcs.nac.uci.edu, nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D5vXU-0007Jw-Fd
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 16:47:04 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D5vXS-0001sp-W5
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 16:47:04 -0800
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200502282208.29263.bernd-schubert@web.de>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--=-3F/+ctWL48ROhU1KDGM7
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Sounds like a good time to try out Xen or similar:

http://dcs.nac.uci.edu/~strombrg/multios.html

On Mon, 2005-02-28 at 22:08 +0100, Bernd Schubert wrote:
> Sorry, I'm sending it here again, since my first mail, in which I CCed LK=
ML=20
> and  Andi Kleen was refused by the listserver.
>=20
>=20
> Hi,
>=20
> I'm just looking into a very strange problem. Some of our systems have=20
> athlon64 CPUs. Due to our diskless nfs environment we currently still pre=
fer=20
> a 32bit userspace environment, but would like to be able to use a 64-bit=20
> chroot environment.
>=20
> Well, currently there seems to be a stat64()  NFS problem when a x86_64 k=
ernel=20
> is booted and stat64() comes from a 32bit libc.
>=20
> Here's just an example:
>=20
> hitchcock:/home/bernd/src/tests# ./test_stat64 /mnt/test/yp
> stat() works fine.
>=20
>=20
> hitchcock:/home/bernd/src/tests# ./test_stat32 /mnt/test/yp
> stat for /mnt/test/yp failed=20
>=20
>=20
> The test program looks rather simple:
>=20
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <unistd.h>
> #include <stdio.h>
> #include <errno.h>
> #include <string.h>
> #include <stdlib.h>
>=20
>=20
> int main(int argc, char **argv)
> {
>         char *dir;
>         struct stat buf;
>=20
>         dir =3D argv[1];
>=20
>         if (stat (dir, &buf) =3D=3D -1)
>                 fprintf(stderr, "stat for %s failed \n", dir);
>         else
>                 fprintf(stderr, "stat() works fine.\n");
>         return (0);
> }
>=20
>=20
> Here are the strace outputs:
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> 32bit:
> ------
> hitchcock:/home/bernd/src/tests# strace32 ./test_stat32 /mnt/test/yp
> execve("./test_stat32", ["./test_stat32", "/mnt/test/yp"], [/* 39 vars */=
]) =3D=20
> 0
> uname({sys=3D"Linux", node=3D"hitchcock", ...}) =3D 0
> brk(0)                                  =3D 0x80ad000
> brk(0x80ce000)                          =3D 0x80ce000
> stat64("/mnt/test/yp", {st_mode=3DS_IFDIR|0755, st_size=3D2704, ...}) =3D=
 0
> write(2, "stat for /mnt/test/yp failed \n", 30stat for /mnt/test/yp faile=
d=20
> ) =3D 30
> exit_group(0)                           =3D ?
>=20
> 64bit:
> -------
> hitchcock:/home/bernd/src/tests# strace ./test_stat64 /mnt/test/yp
> execve("./test_stat64", ["./test_stat64", "/mnt/test/yp"], [/* 39 vars */=
]) =3D=20
> 0
> uname({sys=3D"Linux", node=3D"hitchcock", ...}) =3D 0
> brk(0)                                  =3D 0x572000
> brk(0x593000)                           =3D 0x593000
> stat("/mnt/test/yp", {st_mode=3DS_IFDIR|0755, st_size=3D2704, ...}) =3D 0
> write(2, "stat() works fine.\n", 19stat() works fine.
> )    =3D 19
> _exit(0)                                =3D ?
>=20
>=20
>=20
> Anyone having an idea whats going on? The ethereal capture also looks pre=
tty=20
> normal. The kernel of this system is 2.6.9, but it also happens on anothe=
r=20
> system with 2.6.11-rc5.
> As usual we are using unfs3 for /etc and /var, but for me that looks like=
 a=20
> client problem. I'm now also pretty sure that its not a problem for a loc=
al=20
> mount point (so a local disk).
>=20
>=20
> Thanks in advance,
>  Bernd
>=20
>=20
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_id=3D6595&alloc_id=3D14396&op=3Dclick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20

--=-3F/+ctWL48ROhU1KDGM7
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCI7uEo0feVm00f/8RAuNpAKCNFPWHxwoi8/sEYB2RGWvJabrmOQCfVGGp
vbGwbe0unXKYRuYRGijL8pQ=
=aky5
-----END PGP SIGNATURE-----

--=-3F/+ctWL48ROhU1KDGM7--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
