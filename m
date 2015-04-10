Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36852 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751620AbbDJSSJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Apr 2015 14:18:09 -0400
Message-ID: <1428689840.2980.375.camel@redhat.com>
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback
 query_transport() for each HW
From: Doug Ledford <dledford@redhat.com>
To: Tom Talpey <tom@talpey.com>
Cc: "ira.weiny" <ira.weiny@intel.com>,
        Michael Wang <yun.wang@profitbricks.com>,
        Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Tom Tucker <tom@opengridcomputing.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
        Christoph Raisch <raisch@de.ibm.com>,
        Mike Marciniszyn <infinipath@intel.com>, Eli Cohen <eli@mellanox.com>,
        Faisal Latif <faisal.latif@intel.com>,
        Upinder Malhi <umalhi@cisco.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
        Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Haggai Eran <haggaie@mellanox.com>,
        Ilya Nelkenbaum <ilyan@mellanox.com>,
        Yann Droneaud <ydroneaud@opteya.com>,
        Bart Van Assche <bvanassche@acm.org>,
        Shachar Raindel <raindel@mellanox.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        Devesh Sharma <devesh.sharma@emulex.com>,
        Matan Barak <matanb@mellanox.com>, Moni Shoua <monis@mellanox.com>,
        Jiri Kosina <jkosina@suse.cz>,
        Selvin Xavier <selvin.xavier@emulex.com>,
        Mitesh Ahuja <mitesh.ahuja@emulex.com>,
        Li RongQing <roy.qing.li@gmail.com>,
        Rasmus Villemoes <linux@rasmusvillemoes.dk>,
        Alex Estrin <alex.estrin@intel.com>,
        Eric Dumazet <edumazet@google.com>, Erez Shitrit <erezsh@mellanox.com>,
        Tom Gundersen <teg@jklm.no>, Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 10 Apr 2015 14:17:20 -0400
In-Reply-To: <55280D51.20402@talpey.com>
References: <5523CCD5.6030401@profitbricks.com>
		 <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com>
		 <20150410074805.GA11855@phlsvsds.ph.intel.com>
	 <1428685843.2980.353.camel@redhat.com> <55280D51.20402@talpey.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-4C6quO/3JxIasEeMQ+Xu"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-4C6quO/3JxIasEeMQ+Xu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-04-10 at 13:50 -0400, Tom Talpey wrote:
> On 4/10/2015 1:10 PM, Doug Ledford wrote:
> > As per my above statement, rdma_transport* tests were testing the high
> > level transport type, rdma_port* types were testing link layers.  iWARP
> > has an Eth link layer, so technically port_is_iwarp makes no sense.  Bu=
t
> > since all the other types had a check too, I included port_is_iwarp jus=
t
> > to be complete, and if you are going to ask if a specific port is iwarp
> > as a link layer, it makes sense to say yes if the transport is iwarp,
> > not if the link layer is eth.
>=20
> Not wanting to split hairs, but I would not rule out the possibility
> of a future device supporting iWARP on one port and another RDMA
> protocol on another. One could also imagine softiWARP and softROCE
> co-existing atop a single ethernet NIC.
>=20
> So, I disagree that port_is_iwarp() is a nonsequitur.

Agreed, but that wasn't what I was calling non-sense.  I was referring
to the fact that in my quick little write up, the rdma_port* functions
were all intended to test link layers, not high level transports.  There
is no such thing as an iWARP link layer.  It was still a port specific
test, and would work in all the situations you described, it's just that
asking if a port's link layer is iWARP makes no sense, so I returned
true if the transport was iWARP regardless of what the link layer
actually was.


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--=-4C6quO/3JxIasEeMQ+Xu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVKBOwAAoJELgmozMOVy/dGqYP/jn0V35kY+zkBjlX6yghcjUF
qpSa2iZvrJuuJ/VSaA7UZzT7BaD/W7iVT2WKN8i020LfIImmRetW7nTaJiedyGCN
Csk3l8NU6yWcUnopx99RQBko+My+xGxs88rdyY2ffvvYmQEclN3UDoGIPo3D80du
VEO8mRFSZP9QA20sM4Uzp54xuCJfvVwydPpbuubvrQsXdvgflJ84Gqtng7Yy0/Qx
1INqAYGbS134GJMVZrumU+ZpB5Q2QWAO8SrdF8mmDM58LwFS0lqQ1qrPYKHEkLX6
0s/4Uvzv7UBwosYmJMvvI5ZWHNUDKHSod3DqiUTyKLmTv3aXGKKiaAXY1InPdJQS
ssMxCf61rT+3HukNCpS206fNpgdRvM6nlFnEl3AoWnPaJ2xfU43r3p2u07snmiNo
IlQO7FcdC7rHfwI9tpe1cgOV0QR8Gyde7+wd6yqNdiAJ4rtxxqyIWmz3LicaKYvv
yWMQGqkG61u0Y1iHi1S0e7wb1KkjhmY2n+XK0uDJUnRdFmYCAOAKV4KByDccX2hU
U+P0ZKz/vVj1JgTL5Qr5HoEhe2crcuL5lPdPeu019xhPdLZABE0uG4cr4auNtwBR
4Hv3EAezWmk+uEFs5edPSNzo1cEOnRwBgVNyKqsaaxo0kJCEj8IcBojpZqQUn1hk
1+QgA70ZHvO2AvhU9Qrj
=FLya
-----END PGP SIGNATURE-----

--=-4C6quO/3JxIasEeMQ+Xu--

