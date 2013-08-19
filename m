Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zak.futurequest.net ([69.5.6.152]:51818 "HELO
	zak.futurequest.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750826Ab3HSVWo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Aug 2013 17:22:44 -0400
Date: Mon, 19 Aug 2013 15:16:01 -0600
From: Bruce Guenter <bruce@untroubled.org>
To: linux-nfs@vger.kernel.org
Subject: Re: nfs client: Now you see it, now you don't (aka spurious ESTALE
 errors)
Message-ID: <20130819211601.GA25826@untroubled.org>
References: <20130725134515.67af44e2@cs3.al.itld>
 <20130725101143.6a22cb81@corrin.poochiereds.net>
 <20130725170526.6e54c7db@cs3.al.itld>
 <20130726145937.GB30651@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VbJkn9YxBvnuCH5J"
In-Reply-To: <20130726145937.GB30651@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 26, 2013 at 10:59:37AM -0400, J. Bruce Fields wrote:
> On Thu, Jul 25, 2013 at 05:05:26PM +0000, Larry Keegan wrote:
> > On Thu, 25 Jul 2013 10:11:43 -0400
> > Jeff Layton <jlayton@redhat.com> wrote:
> > > On Thu, 25 Jul 2013 13:45:15 +0000
> > > Larry Keegan <lk@pfw.demon.co.uk> wrote:
> > >=20
> > > > The problem I am seeing is that for the past month or so, on and
> > > > off, one NFS client starts reporting stale NFS file handles on some
> > > > part of the directory tree exported by the NFS server. During the
> > > > outage the other parts of the same export remain unaffected.
>=20
> And the problem affects just that one directory?  Ohter files and
> directories on the same filesystem continue to be accessible?

FWIW I have also experienced the same problem. Randomly, some part of a
NFS (v4) mounted directory tree start return ESTALE, while the rest of
the tree remains accessable.

I am currently running linux 3.9.7 on the server, and have experienced
the problem on clients running linux 3.8.11 and 3.10. The underlying
filesystem is ext4 on dm-crypt.

Unlike the OP, I have not seen the behavior go away after a period of
time, although perhaps I didn't wait long enough. The only fix I found
is to unmount and re-mount (which gets to be a nuisance when ones' home
directory is NFS mounted).

FWIW During the most recent failure, I straced ls and noticed that the
stat on the failing directory works, but opening it failed. I don't know
if that's significant, but I didn't see it mentioned before.

--=20
Bruce Guenter <bruce@untroubled.org>                http://untroubled.org/

--VbJkn9YxBvnuCH5J
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBAgAGBQJSEosRAAoJEFFRvcnBTTxn7e8QAKaqnR+zGYwec4gxkYQoLbkI
CnULWSixsk6WjKg99fv+/1v8gpqpiSWsl8WcPvtJisGIY3kFP6IDYX2051mSXBSL
prCUdDMzSbntfuppt+b0lf57E0CTMNNaoMeCsIHloIXJu6uwijGJ033hFUTY3O0S
8dPGR3neHmG8zEG7ARr0yumg/K6rUqNZOJ4eBvaVWKteAH92bMGb2a83M1AhVhOG
ddLcsvESjbt0jNL1ZZuk3QNJstG4ZpA8HSm+mFTigYR0EuJY11uRQnAf9B1AqGxc
mxXlcnVVptYiVVkC+seyLCokJZUV+fYtQ6XHwLfjBbuF2rRSnqtUgP9q8iPcdDPd
zr2x04SWnM2qFZBxaNhbBPzdkkgTI5WEaahRN6gBWtF+go8BW72GF7xqSqDJf+Dk
AvbwYpZBwDqAABuU/CsH28CvXY2/CNCE2sPWTQpdaU9jwYxGCdhxlwcim5FCXidv
WwsmPMLxCfAfId2p3LhzYehSO1vsh6NiG0qBtLOFKRlR4O1YxbX9Cc4pGf0WJHXl
R608F/tyXdo9UoEeQg5gZOrIOvfqnztJ5neod/ALtebCzD0w6TKRVQTggylxZuTK
FF0jdcQNz0xOPOEc4OimYwo4WSCbI1o6GE1D8wcbYs59v1yFywXADfAk3QXb2I7C
M1dDup+hh2yprw0DPUtC
=Gsd+
-----END PGP SIGNATURE-----

--VbJkn9YxBvnuCH5J--
