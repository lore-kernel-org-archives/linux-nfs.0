Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53632 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756313AbbDJRti (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Apr 2015 13:49:38 -0400
Message-ID: <1428688172.2980.372.camel@redhat.com>
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback
 query_transport() for each HW
From: Doug Ledford <dledford@redhat.com>
To: "ira.weiny" <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
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
Date: Fri, 10 Apr 2015 13:49:32 -0400
In-Reply-To: <20150410173836.GE10675@phlsvsds.ph.intel.com>
References: <5523CCD5.6030401@profitbricks.com>
	 <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com>
	 <20150408201015.GB28666@obsidianresearch.com>
	 <20150410061610.GA26288@phlsvsds.ph.intel.com>
	 <20150410161551.GA26419@obsidianresearch.com>
	 <20150410173836.GE10675@phlsvsds.ph.intel.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-FligigEY4GhT/2s4xGUs"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-FligigEY4GhT/2s4xGUs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-04-10 at 13:38 -0400, ira.weiny wrote:

> Isn't ocrdma an iWarp device?

No, it's roce.  It and mlx4 roce devices currently interoperate.

> > I think if we look closely we'll find that IPoIB today has a hard
> > requirement on cap_sa being true, so lets use that?
>=20
> I don't think that is appropriate.  You have been advocating that the che=
cks
> be clear as to what support we need.  While currently the IPoIB layer doe=
s (for
> IB and OPA) require an SA I think those checks are only appropriate when =
it is
> attempting an SA query.
>=20
> The choice to run IPoIB at all is a different matter.

Appropriately named or not, Jason's choice of words "has a hard
requirement" is correct ;-)  For IPoIB, the broadcast group of the fake
Ethernet fabric is a very specific IB multicast group per the IPoIB
spec.

> >=20
> > In fact any ULP that unconditionally uses the SA can use that.
>=20
> They _can_ use that but the point of this exercise (and additional checks=
 going
> forward) is that we don't "hide" meaning like this.
>=20
> IPoIB should restrict itself to running on IB link layers.  Should additi=
onal
> link layers be added which IPoIB works on then we add that check.

I think your right that checking the link layer is the right thing, and
for now, there is no need to check cap_sa because the link layer check
enforces it.  In the future, if there is a new link layer we want to use
this on, and it doesn't have an sa, then we have to enable sa checks and
alternate methods at that time.

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--=-FligigEY4GhT/2s4xGUs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVKA0sAAoJELgmozMOVy/dV1oQAJ+0Js2sblg3omRqPYWJjhfp
8b0J50Jzf0+RdzEf9D79+cGhqu0WPPMi61sjh4RU0NjVQVO2/04gwqr3nq/TZnqd
e/a/OOSARM9efLoHCRFAtZYCzqBFEQ6GribT2vJkQioK1D6pTt+qY+y3Zmt+K52S
E5OGGHHwPcUcGvEc0rc/1oUN9qjXK9Zbff4c9Ek6OSPljfyFbJ511N64hzWSQDcD
WgQo1N+aMD3/tGqHsHG/JV6StXQMpOSgt8Pl9TGT862dBQQWYgIDE+JjGnzDIFba
Ag6EOzdSL6We4MaB3ExRVtv/ZKkyMKRyLcy/y9IQuN05Gt4ytEB2t8iGCxIBBTOK
vmKB5nVBXqTHWn1AI49oOGIdhs2RL/MdQ1wWpyK6dOmr+mlziQesBAMgalBjn1sA
J8lqkWYyeYVTr1g1JoWsHBFwMBv6yd/jIu0accMBe5+PP1sjFm6c6EpdRDsW+h5O
JZS0WRKIwrWYU2oCcnFrbhVxIp0MrsNUqhzNVPsuMooLFox3e0J15ntAB2rxHnkR
bo/422I9IzSOjORkCn4b5RZ8JMMiXODKmWh5PkZxTxxqE4/Ha+2qa9jWAxm1O4yd
EKWgSwhZ6hH5Wjb71Tvi3/dyldRmr40a/0uyx912otSOHYdhHp1+BdD6PGBojMcE
syZAMgVl3SMDtzCgV0wP
=Pwp5
-----END PGP SIGNATURE-----

--=-FligigEY4GhT/2s4xGUs--

