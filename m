From: Garrick Staples <garrick@usc.edu>
Subject: Re: nfsd, rmtab, failover, and stale filehandles
Date: Tue, 11 May 2004 11:26:35 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040511182635.GI30964@polop.usc.edu>
References: <20040506185603.GM23287@polop.usc.edu> <20040506191351.GP23287@polop.usc.edu> <20040506215311.GA26968@polop.usc.edu> <20040506222455.GP18964@fieldses.org> <20040506230055.GC26968@polop.usc.edu> <20040507182543.GA27341@fieldses.org> <20040507213811.GL30964@polop.usc.edu> <20040507223414.GQ30964@polop.usc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zlx9VeIOwFZpCeUB"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BNc1L-0006lR-V0
	for nfs@lists.sourceforge.net; Tue, 11 May 2004 11:30:27 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BNc1L-0005Nn-L1
	for nfs@lists.sourceforge.net; Tue, 11 May 2004 11:30:27 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i4BIQZlv026393
	for <nfs@lists.sourceforge.net>; Tue, 11 May 2004 11:26:35 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i4BIQZCs026391
	for nfs@lists.sourceforge.net; Tue, 11 May 2004 11:26:35 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040507223414.GQ30964@polop.usc.edu>
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


--zlx9VeIOwFZpCeUB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I just wanted to mention that failover has been rock solid with those two
patches.  Thank you very much for your help!

Does the patch below look ok?


On Fri, May 07, 2004 at 03:34:15PM -0700, Garrick Staples alleged:
> On Fri, May 07, 2004 at 02:38:12PM -0700, Garrick Staples alleged:
> > But now I've just noticed something else that is odd.  Something that I=
'm
> > surprised I haven't come across before...  I have to unexport filesyste=
ms
> > twice before I can unmount them.
>=20
> I'm looking at exportfs.c to see if I can add in a call to flush the cach=
ing
> when unmounting, does the following seem reasonable?
>=20
> Force a cache flush if unexporting, and don't reread rmtab if we're using=
 the
> new cache.
>=20
> --- exportfs.c_orig     2004-05-07 15:32:22.423905760 -0700
> +++ exportfs.c  2004-05-07 15:33:33.669998637 -0700
> @@ -127,10 +127,13 @@
>                  */
>                 if (!f_reexport)
>                         xtab_export_read();
> -               if (!f_export)
> +               if (!f_export) {
> +                       force_flush=3D1;
>                         for (i =3D optind ; i < argc ; i++)
>                                 unexportfs(argv[i], f_verbose);
> -               rmtab_read();
> +               }
> +               if (!new_cache)
> +                       rmtab_read();
>         }
>         if (!new_cache) {
>                 xtab_mount_read();
>=20
>=20
> --=20
> Garrick Staples, Linux/HPCC Administrator
> University of Southern California



--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--zlx9VeIOwFZpCeUB
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAoRrb0SBUxJbm9HMRAl7uAJ9l0hXOoOCLI9E/ofafK+ki6KhqNACeMVTa
v0y8Mt6QYPGpUNTMPEcQsso=
=mIeK
-----END PGP SIGNATURE-----

--zlx9VeIOwFZpCeUB--


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
