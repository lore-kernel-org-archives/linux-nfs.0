Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35598 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756333AbbDIVTR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Apr 2015 17:19:17 -0400
Message-ID: <1428614348.2980.287.camel@redhat.com>
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback
 query_transport() for each HW
From: Doug Ledford <dledford@redhat.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Michael Wang <yun.wang@profitbricks.com>,
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
        Ira Weiny <ira.weiny@intel.com>,
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
Date: Thu, 09 Apr 2015 17:19:08 -0400
In-Reply-To: <20150409160123.GA31353@obsidianresearch.com>
References: <5523CCD5.6030401@profitbricks.com>
	 <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com>
	 <20150408201015.GB28666@obsidianresearch.com>
	 <1428590070.2980.190.camel@redhat.com>
	 <20150409160123.GA31353@obsidianresearch.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-F54YLA5QHQfaO4OMd8BL"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-F54YLA5QHQfaO4OMd8BL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-04-09 at 10:01 -0600, Jason Gunthorpe wrote:
> On Thu, Apr 09, 2015 at 10:34:30AM -0400, Doug Ledford wrote:
>=20
> > These are exactly the tests I proposed Jason.  I'm not sure I see your
> > point here.  I guess my point is that although the scenario of all the
> > different items seems complex, it really does boil down to needing only
> > exactly what I proposed earlier to fulfill the entire test matrix.
>=20
> I have no problem with minimizing a bitmap, but I want the accessors
> to make sense first.
>=20
> My specific problem with your suggestion was combining cap_ib_mad,
> cap_ib_sa, and cap_ib_smi into rdma_port_ib_fabric_mgmt.
>=20
> Not only do the three cap things not return the same value for all
> situations, the documentary knowledge is lost by the reduction.
>=20
> I'd prefer we look at this from a 'what do the call sites need' view,
> not a 'how do we minimize' view.
>=20
> I've written this before: The mess here is that it is too hard to know
> what the call sites are actually checking for when it is some baroque
> conditional.

The two goals: being specific about what the test is returning and
minimizing the bitmap footprint; are not necessarily opposed.  One can
do both at the same time.

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--=-F54YLA5QHQfaO4OMd8BL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVJuzMAAoJELgmozMOVy/dnrwQAL/QOAmf0x/HpGD4S7csBX7p
enjQRlFAedSrAXXEme14kP4gqJ44QGsdlzQCRwxGszc5hx+g/H8/LeAXTA0FokL1
Cm3Zi80oN8Ru/Cctdz4+MSUQfTHKul59rZG1iwfvEXrY5wmM1CQsCCV6yixbu0lN
jwonILGfwb+S6JFcFVchw92rYKItmCplKKw0CjQzqDyvHlP6iBbLXOz77jy2gIc+
OWqaAw3hp4lmgcu1PEMQ9iRx6fICBagj98LiY7UmgvHXU2QWCTGjt3Zqww2U0ZSz
Vxzlso6KnRZiwKZzxzYWR0HhdliBaV2tPGkt8DBmqb79czHEmkV/q3O/uzA8B53w
ouKViWbv0QsIGUsu7ROcAcTO7ix4a2/YRCJAJNVOsX+i5g5Dg/KPjoReV7mD3LU3
sMO6Tuk0tXp8RWQdF4DWrH1oqHN3XboZI0L3pyHJGn/XWFmiZGQQerec3+Z9gyGH
iPW8Fs6BtPrSizPE63YtKRPmTHhXTmP/5TKkRzM23azUK6dpSw2+LKSrI4I6Z3bF
1VRRffP6Rm89RRnmbs3S5/ca0yr13OQzoCe38k5dqh/tulkPPbk1+xmZ69YJluVs
l4d+DHJ/UyAbdV1g3IzPCKDG7GdkwctrUbw1MVD7U9dFS4sGK8Yz9chk5oUKYnEF
W7b512XsPvioVNfR0EBl
=l7rL
-----END PGP SIGNATURE-----

--=-F54YLA5QHQfaO4OMd8BL--

