From: Garrick Staples <garrick@usc.edu>
Subject: Re: nfsd threads locked, 2.6.7 & ia64
Date: Sun, 27 Jun 2004 17:46:03 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040628004602.GU10560@polop.usc.edu>
References: <20040627051129.GS10560@polop.usc.edu> <20040627193314.GE3491@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pEAjBjStGYT6H+Py"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BekIK-0001sv-UV
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 17:46:48 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BekIK-000578-Je
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 17:46:48 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id i5S0k3XA006572
	for <nfs@lists.sourceforge.net>; Sun, 27 Jun 2004 17:46:03 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id i5S0k3Xd006570
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 17:46:03 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040627193314.GE3491@fieldses.org>
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


--pEAjBjStGYT6H+Py
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jun 27, 2004 at 03:33:14PM -0400, J. Bruce Fields alleged:
> On Sat, Jun 26, 2004 at 10:11:29PM -0700, Garrick Staples wrote:
> > Well here's something I've not seen yet.  All 512 nfsd threads are stuc=
k in IO
> > wait (state D in ps).  All clients are hung on that mount.  The actual
> > filesystem on the server seems fine.
> >=20
> > It start at 8am with no messages at all.
> >=20
> > Jun 26 08:06:58 hpc-master nagios: SERVICE ALERT: hpc-fs3;nfs;CRITICAL;=
SOFT;1;CRITICAL: RPC program nfs  version 3 udp is not running
> > Jun 26 08:07:21 hpc934-e0 kernel: nfs: server hpc-fs3 not responding, s=
till trying
> > Jun 26 08:09:12 hpc972-e0 kernel: nfs: server hpc-fs3 not responding, s=
till trying
> > Jun 26 08:09:13 hpc941-e0 kernel: nfs: server hpc-fs3 not responding, s=
till trying
> > ...
> >=20
> > I can't find anything otherwise wrong with the machine at all, just tha=
t nfsd
> > threads are stuck.  rpcinfo and showmount still work fine.  Nothing in =
dmesg or
> > messages.  I'm stuck too.
>=20
> Does Sysrq-T give you any idea where they're stuck?

I won't know until I get into the machine room tomorrow.  Any info I can gi=
ve
you from a remote shell?

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--pEAjBjStGYT6H+Py
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFA32pK0SBUxJbm9HMRAtLCAJ9JONUMu4FloBhvrjZSGUv6+XeDqACeMf0+
qf4hnRO7dgYyP5Y2EJKuDxo=
=S1Vn
-----END PGP SIGNATURE-----

--pEAjBjStGYT6H+Py--


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
