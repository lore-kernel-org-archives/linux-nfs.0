Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:40788 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750720Ab2LMGDh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Dec 2012 01:03:37 -0500
Date: Thu, 13 Dec 2012 17:03:22 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] gssd: base the size of the fd array on the
 RLIMIT_NOFILE limit.
Message-ID: <20121213170322.477c10fd@notabene.brown>
In-Reply-To: <20121211161633.GE3336@fieldses.org>
References: <20121128010939.2475.13123.stgit@notabene.brown>
	<20121128011123.2475.13691.stgit@notabene.brown>
	<20121128131054.GB11651@fieldses.org>
	<20121129113051.046bc658@notabene.brown>
	<20121211110228.0159fc4f@notabene.brown>
	<20121211161633.GE3336@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/hiX+U+iF0_t/+APQVIwn=tL"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/hiX+U+iF0_t/+APQVIwn=tL
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 11 Dec 2012 11:16:33 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Tue, Dec 11, 2012 at 11:02:28AM +1100, NeilBrown wrote:
> > On Thu, 29 Nov 2012 11:30:51 +1100 NeilBrown <neilb@suse.de> wrote:
> >=20
> > > On Wed, 28 Nov 2012 08:10:55 -0500 "J. Bruce Fields" <bfields@fieldse=
s.org>
> > > wrote:
> > >=20
> > > > On Wed, Nov 28, 2012 at 12:11:23PM +1100, Neil Brown wrote:
> > > > > We have previously raised the size of the 'pollarray' once (32 ->=
 256)
> > > > > and I have had another request to make it bigger.
> > > > > Rather than changing the hard-coded value, make it depend on
> > > > > RLIMIT_NOFILE.  This is an upper limit on the size of the array
> > > > > that can be passed to poll() anyway.
> > > >=20
> > > > Sounds like a good idea.
> > > >=20
> > > > Just out of curiosity: how does it fail?  I guess mounts just start
> > > > failing at some point--how do people find the workaround?
> > >=20
> > > Error seems to be
> > >=20
> > > rpcsec_gss: gss_init_sec_context: (major) Miscellaneous failure - (mi=
nor) Cannot contact any KDC for requested realm
> > >=20
> > > in rpc.gssd logs.
> > >=20
> > > I guess people could read the source to find the work around .... not=
 ideal
> > > though.  I guess we should get gssd to generate some more helpful mes=
sage.
> > >=20
> > > The seem to be further problems that the customer is experiencing so =
I might
> > > wait until they are completely resolved to ensure I have complete
> > > understanding before I propose a further patch.
> >=20
> > The "further problem" was that krb5 libraries use select() in a way tha=
t does
> > not support file descriptors higher than 1024.  This is fixed in the la=
test
> > krb5 so that is no longer an issue.
> >=20
> > I've been thinking about your question, and about how best to deliver a=
 fix
> > to customers, and I really think it should all "just work".
> > i.e. the array that gssd should be sized dynamically and RLIMIT_NOFILE =
should
> > be increased as needed.
>=20
> Neat-o.
>=20
> > I haven't tested this, but what do people think?   I don't have a probl=
em
> > changing the rlim_cur limit like this, but I wonder if it is OK to
> > dynamically set rlim_max.
>=20
> What would be the concern, that we'd be depriving an admin of the
> ability to set a limit?

My concern in that automagically raising a so-called "hard limit" seems to =
be
subverting the very concept of it being a "limit".

>=20
> We could instead set only the current limit and set set the max to an
> admin-configurable quantity (default very large) when we start gssd.

I really want to avoid any configuration.
The number of fds that will be used is directly connected to the number of
concurrent mounts - as there is no limit on those (I assume), I guess it is
fair that there is no limit on fds used by gssd.

>=20
> But that sounds more complicated, and off hand I can't think of a reason
> an admin would want to do that.

OK, let's just modify the hard limit dynamically ... though I'm about to
disappear for summer holidays so I doubt you'll see anything for some weeks.


thanks,
NeilBrown


--Sig_/hiX+U+iF0_t/+APQVIwn=tL
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUMlvqjnsnt1WYoG5AQJtzQ//W0Xsh2qnFDglZYPyvhfQe1ZpYA7zv2wO
actqbZL1V8SdPgNMKxPukXoK5bqbhDnCnrvi4SZhJAiGedXwkIZNDlFnfK4DaiHm
X8D+yfsTkQnK6+swkK8LVVbZajuhZW//dPa18qdEoFeNEYM+64PGbk+OfOYnOzwE
Tk2yVPTxq/NqSo4LXDiwjwbSfg8yYLPIhKlu2cPqPKlh24bwapUvMLRWhy9eETnJ
l4HaUERVNyO1+BxLuD9EudjhZxqGcPCjsqpOVpmWKVRznP4zBk4fftjEkEfqFxDk
Gjzo/+Wp6lwf1jhWGbhvz4V76e9tPOglP4e/goEL574pCJungNWHOhrPe/z0sk1r
zA4B75ZgCDbZwKLzwK1fTVwmYhp7zO+NPdpLBll3nLdN+sHwODEkemI0cJrO1FdP
GNtnMBxIuQrsYWmVGaZoBJWw20j+2ZDLXQ6ncy7+X49FFVbHuviJBo9HfVMd3EJw
VW3DjgFhaphmdxrDZ/yCX8VXtAcEROOto8EG9VcjGiTR4Ixl5JlUxGsG9S9Vs6Hi
OsRQ+0yO9TiT2ww8Ulrl1jaKahamJ/BtSPeaS/SrpbXkeL0y44gmKcma6iO9wNIf
YGM3AqaMuKuiSmrz8oNq+WkkQ2qCbjMF8fWWSO5wgzDYdJEGIo1Zy0dmADCMijWI
hPxOZtN2h6E=
=Nb97
-----END PGP SIGNATURE-----

--Sig_/hiX+U+iF0_t/+APQVIwn=tL--
