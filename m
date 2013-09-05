Return-Path: linux-nfs-owner@vger.kernel.org
Received: from the.earth.li ([46.43.34.31]:52288 "EHLO the.earth.li"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752777Ab3IEDlO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Sep 2013 23:41:14 -0400
Date: Wed, 4 Sep 2013 20:40:44 -0700
From: Jonathan McDowell <noodles@earth.li>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: Karl Schmidt <karl@xtronics.com>, Dave Kleikamp <dave.kleikamp@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        jfs-discussion@lists.sourceforge.net, 714974@bugs.debian.org,
        linux-nfs@vger.kernel.org, Christian Kujau <lists@nerdbynature.de>
Subject: Re: Bug#714974: [PATCH] jfs: fix readdir cookie incompatibility with
 NFSv4
Message-ID: <20130905034044.GD17947@earth.li>
References: <alpine.DEB.2.10.1308120113360.7081@trent.utfs.org>
 <alpine.DEB.2.10.1308120122500.7081@trent.utfs.org>
 <20130812162924.GB2395@fieldses.org>
 <520C50F7.3010209@oracle.com>
 <alpine.DEB.2.10.1308142122550.7081@trent.utfs.org>
 <alpine.DEB.2.10.1308150001530.7081@trent.utfs.org>
 <520D3EA7.1010109@oracle.com>
 <alpine.DEB.2.10.1308151420140.7081@trent.utfs.org>
 <1376769691.2544.4.camel@deadeye.wl.decadent.org.uk>
 <20130829224803.GO29286@earth.li>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="82I3+IH0IqGh5yIs"
In-Reply-To: <20130829224803.GO29286@earth.li>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 29, 2013 at 03:48:03PM -0700, Jonathan McDowell wrote:
> On Sat, Aug 17, 2013 at 10:01:31PM +0200, Ben Hutchings wrote:
> > On Thu, 2013-08-15 at 14:26 -0700, Christian Kujau wrote:
> > > On Thu, 15 Aug 2013 at 15:48, Dave Kleikamp wrote:
> > > > This patch replaces the one I posted yesterday. I like this
> > > > better since it doesn't require fixing existing on-disk cookies
> > > > or skipping a position in the in-inode index table.
> > >=20
> > > Thanks. Applied to 3.11-rc5 and tested, no more "readdir loop"
> > > messages and with unique inode numbers, great!
> > >=20
> > >   Tested-by: Christian Kujau <lists@nerdbynature.de>
> >=20
> > Karl and Jonathan, could you test the attached backport to 3.2?
>=20
> I finally managed to be able to schedule some downtime yesterday for
> one of the machines I've been seeing this issue with. So far since the
> reboot to this kernel (3.2.46-1 + the patch) I haven't seen a
> recurrence of the problem; will update if I see anything.

I see the patch hit 3.11, but just to confirm the 3.2 backport on top of
the Debian 3.2.46-1 kernel has seen no recurrence or issues in the past
week (with a set of JFS filesystems that are fairly extensively used
over NFS).

J.

--=20
Web [  Aunt Em: Hate Kansas. Hate you. Taking dog. Bye. Dorothy.   ]
site: http:// [                                          ]       Made by
www.earth.li/~noodles/  [                      ]         HuggieTag 0.0.24

--82I3+IH0IqGh5yIs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJSJ/08AAoJEP8WL8XPP7rRf28QAKDVJj3Wtz4H4+VmRSuD1sbp
5CQtUtZW/GJUXeg9q7hSam+MsDI5uuo7EUJFKdI9K4U0fpy+++LphsfHyHwLxz2r
Sgxhhz3ou/58QyxwCFBY2pUZfAEx/9CaG7I4zNxCvdVGVU8gfkwV/WxE+vEIGLdt
aZSCSQww+VUPDQDQAqvocv4waXKDAGfIbX0TXFHcoXP4XWGAGqrC+pMT+BW8n2SE
2VEku5CFFf7bLuR/Z/j9XSjKBidTTX8E45rGkGWvrHMtf07iWiddLOo4qVCPrm4g
P1WTKs+Z10oUane/GvOqsysnombb1qASiFkS/6Sgqk/dA+vNcljqQHCpXk5ynTrR
0NYl1B4VYBiwLbMFo8SpVIcuXj2uYiRKkCew1QMld6+89qw/G/1bBGCBwfXgMy+r
CrsiXk87rIG8G/bpSApd11Wk8ovCQ2Ztb7VbjLTFJaWRiqrGCfPuZWEHjHrjRvJF
7N0CD8IjxXQGsE+9Q0jrqGenbIWfmvFHqcnoiXpwGK+EtGw3JRbNbMXdjph0thIs
Q/QpMteVroO8K2psm6cZWaCd80THiMcJhIXAhtUlcNNd6L42Dku8bgrzGfLtUiaf
7gfvV1NflRq2ivwBlUe+/Z8QtjUJkhFu/2zvvTpP/q7iLn07DHO71Ay9lWLIuQ1w
RZtlk5VCXt76DJSgQjoy
=zNAp
-----END PGP SIGNATURE-----

--82I3+IH0IqGh5yIs--
