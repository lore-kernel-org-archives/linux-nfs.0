From: Garrick Staples <garrick@usc.edu>
Subject: Re: nfsd, rmtab, failover, and stale filehandles
Date: Thu, 13 May 2004 14:37:13 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040513213713.GB1559@polop.usc.edu>
References: <20040506185603.GM23287@polop.usc.edu> <20040506191351.GP23287@polop.usc.edu> <20040506215311.GA26968@polop.usc.edu> <20040506222455.GP18964@fieldses.org> <20040506230055.GC26968@polop.usc.edu> <20040507182543.GA27341@fieldses.org> <20040507213811.GL30964@polop.usc.edu> <20040507223414.GQ30964@polop.usc.edu> <20040513210045.GF20649@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="z6Eq5LdranGa6ru8"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BONvu-0001DB-Dx
	for nfs@lists.sourceforge.net; Thu, 13 May 2004 14:40:02 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BONvu-0002Ds-8w
	for nfs@lists.sourceforge.net; Thu, 13 May 2004 14:40:02 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id i4DLbDbw001959
	for <nfs@lists.sourceforge.net>; Thu, 13 May 2004 14:37:13 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id i4DLbDtl001957
	for nfs@lists.sourceforge.net; Thu, 13 May 2004 14:37:13 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040513210045.GF20649@fieldses.org>
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


--z6Eq5LdranGa6ru8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 13, 2004 at 05:00:45PM -0400, J. Bruce Fields alleged:
> On Fri, May 07, 2004 at 03:34:15PM -0700, Garrick Staples wrote:
> > I'm looking at exportfs.c to see if I can add in a call to flush the ca=
ching
> > when unmounting, does the following seem reasonable?
>=20
> Small note--I think your mailer must be messing up your patches--the
> patch you appended e.g. has all tabs changed to spaces, and doesn't
> apply.

That's odd.  I use mutt with vi.  IRCC, I used'd vi's read function to read=
 the
patch into the email.  I can't imagine where any conversion would have taken
place.

Perhaps I copy/pasted from 'less', but I don't think so.


--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--z6Eq5LdranGa6ru8
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAo+qJ0SBUxJbm9HMRAjw5AJ46SdZb1Q78MCwreiKiFvTxvJjrJgCgkPgj
jfyyPn944umjuKo6Iv2ppnQ=
=Z9Wc
-----END PGP SIGNATURE-----

--z6Eq5LdranGa6ru8--


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
