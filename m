From: Garrick Staples <garrick@usc.edu>
Subject: Re: mountd segfault on itanium2
Date: Mon, 3 May 2004 11:24:01 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040503182401.GP23287@polop.usc.edu>
References: <20040430212414.GF22498@polop.usc.edu> <20040430234327.GM22498@polop.usc.edu> <20040501030730.GE23287@polop.usc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9pS2hy4/DrI8BQlq"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BKiAe-0007zA-TJ
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 11:28:04 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BKiAA-0003xx-Jy
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 11:27:34 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i43IO1lv012857
	for <nfs@lists.sourceforge.net>; Mon, 3 May 2004 11:24:01 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i43IO1Zo012855
	for nfs@lists.sourceforge.net; Mon, 3 May 2004 11:24:01 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040501030730.GE23287@polop.usc.edu>
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


--9pS2hy4/DrI8BQlq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 30, 2004 at 08:07:30PM -0700, Garrick Staples alleged:
> On Fri, Apr 30, 2004 at 04:43:27PM -0700, Garrick Staples alleged:
> > I just spotted a pattern.  After collecting several strace samples, it =
always
> > segfaults after read() or write() to fd 5.  And fd 5 is always:
> >=20
> >    open("/proc/net/rpc/nfsd.fh/channel", O_RDWR) =3D 5

I was able to insert some printf()'s after the write() to fd 5, which means=
 it
is segfaulting after that file.

The segfault is inside svc_getreqset() in utils/mountd/svc_run.c:
                switch (selret) {
                case -1:
                        if (errno =3D=3D EINTR || errno =3D=3D ECONNREFUSED
                         || errno =3D=3D ENETUNREACH || errno =3D=3D EHOSTU=
NREACH)
                                continue;
                        xlog(L_ERROR, "my_svc_run() - select: %m");
                        return;

                default:
                        selret -=3D cache_process_req(&readfds);
                        if (selret)
                                svc_getreqset(&readfds);
                }

Either glibc has a bug or the kernel is doing something fugly to the readfd=
s?

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--9pS2hy4/DrI8BQlq
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAlo5B0SBUxJbm9HMRAg4eAJ4/kN5ZuQ9lzhRMqpa+4MYemr+zogCfTQf+
ZJ6xRtuUwH2B/UlV16xb/GI=
=of6T
-----END PGP SIGNATURE-----

--9pS2hy4/DrI8BQlq--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
