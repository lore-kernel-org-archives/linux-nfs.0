From: Garrick Staples <garrick@usc.edu>
Subject: Re: mountd segfault on itanium2
Date: Fri, 30 Apr 2004 20:07:30 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040501030730.GE23287@polop.usc.edu>
References: <20040430212414.GF22498@polop.usc.edu> <20040430234327.GM22498@polop.usc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pY3vCvL1qV+PayAL"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJkrr-0005ZN-6n
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 20:08:43 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BJkrq-0002Id-SI
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 20:08:42 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i4137Ulv023492
	for <nfs@lists.sourceforge.net>; Fri, 30 Apr 2004 20:07:30 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i4137U3b023490
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 20:07:30 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040430234327.GM22498@polop.usc.edu>
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


--pY3vCvL1qV+PayAL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 30, 2004 at 04:43:27PM -0700, Garrick Staples alleged:
> I just spotted a pattern.  After collecting several strace samples, it al=
ways
> segfaults after read() or write() to fd 5.  And fd 5 is always:
>=20
>    open("/proc/net/rpc/nfsd.fh/channel", O_RDWR) =3D 5

I have an ugly work-around that seems to be working.  It seems that 2.6 has=
 a
new nfs interface for userspace.  By forcing mountd to use the older 2.4
interface, it doesn't segfault anymore.  So something in the new code paths=
 is
broken.

In support/nfs/cachio.c:
int
check_new_cache(void)
{
        struct stat stb;

        return 0;  /* DISABLE NEW 2.6 INTERFACE */

        return  (stat("/proc/fs/nfs/filehandle", &stb) =3D=3D 0) ||
                (stat("/proc/fs/nfsd/filehandle", &stb) =3D=3D 0);
}

Am I losing any functionality by doing this?  I can't actually find any
problems.

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--pY3vCvL1qV+PayAL
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAkxRy0SBUxJbm9HMRAiD5AJ9qoGSueQ7NmvN408+qXd6Q3SryfgCbBvrA
FY+mPoGfOBKmgTZnL2Z8Xuw=
=zefR
-----END PGP SIGNATURE-----

--pY3vCvL1qV+PayAL--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
