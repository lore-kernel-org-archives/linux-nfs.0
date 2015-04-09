Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751830AbbDIOfv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Apr 2015 10:35:51 -0400
Message-ID: <1428590070.2980.190.camel@redhat.com>
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
Date: Thu, 09 Apr 2015 10:34:30 -0400
In-Reply-To: <20150408201015.GB28666@obsidianresearch.com>
References: <5523CCD5.6030401@profitbricks.com>
	 <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com>
	 <20150408201015.GB28666@obsidianresearch.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-yD3TmG85+KLgjTU68du8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-yD3TmG85+KLgjTU68du8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-04-08 at 14:10 -0600, Jason Gunthorpe wrote:
> On Wed, Apr 08, 2015 at 02:29:46PM -0400, Doug Ledford wrote:
>=20
> > To straighten all this out, lets break management out into the two
> > distinct types:
> >=20
> > rdma_port_ib_fabric_mgmt() <- fabric specific management tasks: MAD, SM=
,
> > multicast.  The proper test for this with my bitmap above is a simple
> > transport & RDMA_MGMT_IB test.  If will be true for IB and OPA fabrics.
>=20
> > rdma_port_conn_mgmt() <- connection management, which we currently
> > support everything except USNIC (correct Sean?), so a test would be
> > something like !(transport & RDMA_TRANSPORT_USNIC).  This is then split
> > out into two subgroups, IB style and iWARP stype connection management
> > (aka, rdma_port_iw_conn_mgmt() and rdma_port_ib_conn_mgmt()).  In my
> > above bitmap, since I didn't give IBOE its own transport type, these
> > subgroups still boil down to the simple tests transport & iWARP and
> > transport & IB like they do today.
>=20
> There is a lot more variation here than just these two tests, and those
> two tests won't scale to include OPA.
>=20
>         IB ROCEE OPA
> SMI     Y  N     Y    (though the OPA smi looked a bit different)
> IB SMP  Y  N     N
> OPA SMP N  N     Y
> GMP     Y  Y     Y
> SA      Y  N     Y
> PM      Y  Y     Y    (? guessing for OPA)
> CM      Y  Y     Y
> GMP needs GRH N Y N
>=20

You can still break this down to a manageable bitmap.

SMI, SMP, and SA are all essentially the same and can be combined to one
bitmap that is

IB_SM  0x1
OPA_SM 0x2

and the defines are such that IB devices define IB_SM, and OPA devices
define IB_SM and OPA_SM.  Any minor differences between OPA and IB can
be handled by testing just the OPA_SM bit.  This will exclude all IBOE
devices and iWARP devices.

GMP, PM, and CM are all the same, and are all identical to transport =3D=3D
INFINIBAND.

GMP needs GRH happens to be precisely the same as ib_dev_is_iboe.

These are exactly the tests I proposed Jason.  I'm not sure I see your
point here.  I guess my point is that although the scenario of all the
different items seems complex, it really does boil down to needing only
exactly what I proposed earlier to fulfill the entire test matrix.


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--=-yD3TmG85+KLgjTU68du8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVJo32AAoJELgmozMOVy/dlukQALS6YyqoYPml5Wu0bEWQpztE
96KW4ri0NTAzw75KmUGgPZ8dPbG70+xTtfXAPqaZm+MbjNUttiXCAWBrObFlhA7B
blWaei82NS43rAlljUcjj8ECt6XbvrFKS+GOcXt3VH14P+LMPnayJkSHE3ToGzcM
cULMP5x0ilc+nHLdp1dGS2HXr4d/Cbfh/LqWRY6IM7W+30o3pVWKIdR/QptXTdM4
/G+s4rpmS23Ee+ijd4ukZK2Qg4EdOZuy8psspZJjlYPRKl07fRsAa6wxiaamqQ8u
iAbQ0XKsXnkFH917wsI0U3RuXPk8dEif46yzsSnjKdmPa6cFSIITzsI0LjHljDQ7
kRTRLrISebNt1+xxj2erii67T06MDO5AFdNOI5cz/ZJ9qmOpZDNDgMjAYkueZN2Z
jOLDvka9OH0N4oCRxNOChrKvKbDr83KikPbqlj5tUPv5sqti/TS6sJjceEXRlQ0w
MFN10CpKc1oJRaCGJoIcod79ofaXNRG18k4oFkrnZyjnsz3WswZFCaHUoO+kamAJ
tnEo3O5880bafXGx2sF8clik7CW0lcYoRetxjsw4Q1MFbveDZCRKHjcawzVgPMhJ
OXtMrALKjKBmQwoBrm2QSWNFFsqj1Yge/74x0uAdC0C6HQwf9uGh/GuhkS9eJhYa
vfqRItlePICJjQMfMnqm
=uL/g
-----END PGP SIGNATURE-----

--=-yD3TmG85+KLgjTU68du8--

