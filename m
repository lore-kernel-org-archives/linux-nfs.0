From: Garrick Staples <garrick@usc.edu>
Subject: Re: mountd segfault on itanium2
Date: Fri, 30 Apr 2004 17:24:53 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040501002453.GR22498@polop.usc.edu>
References: <20040430212414.GF22498@polop.usc.edu> <20040430234327.GM22498@polop.usc.edu> <20040501001535.GA23498@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="kAOhhqH5290wydqT"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJiMf-00077x-3H
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 17:28:21 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BJiMe-00022z-L8
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 17:28:20 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i410Orlv023215
	for <nfs@lists.sourceforge.net>; Fri, 30 Apr 2004 17:24:53 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i410OroG023213
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 17:24:53 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040501001535.GA23498@fieldses.org>
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


--kAOhhqH5290wydqT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 30, 2004 at 08:15:35PM -0400, J. Bruce Fields alleged:
> On Fri, Apr 30, 2004 at 04:43:27PM -0700, Garrick Staples wrote:
> > I just spotted a pattern.  After collecting several strace samples, it =
always
> > segfaults after read() or write() to fd 5.  And fd 5 is always:
> >=20
> >    open("/proc/net/rpc/nfsd.fh/channel", O_RDWR) =3D 5
>=20
> Any interesting messages from the kernel (in /var/log/messages)?

Nope, nothing in dmesg either.

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--kAOhhqH5290wydqT
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAku5V0SBUxJbm9HMRAmkgAJ9KaPMCFt1U3mcBVjMLy2Jo0JKfcQCeIzIE
wafaZZ+90/0mfo4JvWXP190=
=BidB
-----END PGP SIGNATURE-----

--kAOhhqH5290wydqT--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
