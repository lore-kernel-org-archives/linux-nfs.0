From: Garrick Staples <garrick@usc.edu>
Subject: Re: mountd segfault on itanium2
Date: Fri, 30 Apr 2004 16:43:27 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040430234327.GM22498@polop.usc.edu>
References: <20040430212414.GF22498@polop.usc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="sMkrXc3gAYLRVOjR"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJhgN-00067r-F8
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 16:44:39 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BJhgN-0005f2-5R
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 16:44:39 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i3UNhRlv023126
	for <nfs@lists.sourceforge.net>; Fri, 30 Apr 2004 16:43:27 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i3UNhRCR023124
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 16:43:27 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040430212414.GF22498@polop.usc.edu>
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


--sMkrXc3gAYLRVOjR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 30, 2004 at 02:24:14PM -0700, Garrick Staples alleged:
> Hi all,
>    I'm having a terrible time with mountd segfaulting on two Itanium boxe=
s.  I
> can't find a specific trigger, but I can generally trigger it within a few
> minutes by just calling mount/umount a few hundred times.
>=20
> I'm using glibc 2.3.2 and nfs-utils 1.0.6 from RHE.
>=20
> In the tests below, I have a single directory exported to 10.125.0.0/16. =
 Since
> I know name resolution was a recent problem, I've made sure all clients a=
re in
> /etc/hosts.  I'm using NIS, but files is before dns and nis in nsswitch.c=
onf.
> I've also tested with and without nscd running.

> select(1024, [3 4 5 6 7], NULL, NULL, NULL) =3D 2 (in [5 6])
> read(5, "", 0)                          =3D 0
> --- SIGSEGV (Segmentation fault) @ 20000008002c19d0 (63742f3132353111) ---

> write(5, "10.125.0.0/16 0 \\x00080011020000"..., 62) =3D 62
> --- SIGSEGV (Segmentation fault) @ 20000000002899d0 (7064752f35343639) ---


I just spotted a pattern.  After collecting several strace samples, it alwa=
ys
segfaults after read() or write() to fd 5.  And fd 5 is always:

   open("/proc/net/rpc/nfsd.fh/channel", O_RDWR) =3D 5

I have no idea what the file is for, but grep'ing my straces shows that mou=
ntd
doesn't normally use it.  It can handle hundreds of mount/umount requests
without ever touching fd 5.  Then at some point it reads once:

   read(5, "10.125.0.0/16 0 \\x00080011020000"..., 128) =3D 35

If it doesn't segfault on the read(), it might segfault on a write() very s=
oon
after:

   write(5, "10.125.0.0/16 0 \\x00080011020000"..., 62) =3D 62


Thanks in advance to anyone that knows what's going on.

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--sMkrXc3gAYLRVOjR
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAkuSf0SBUxJbm9HMRAlvLAKCUIABHdovu2l9MqPFeDb02+Nc69wCgkmdy
QU1PIHK6p0YzdJzz5M2YEhU=
=wj+a
-----END PGP SIGNATURE-----

--sMkrXc3gAYLRVOjR--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
