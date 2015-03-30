Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33568 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752828AbbC3RCK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Mar 2015 13:02:10 -0400
Message-ID: <1427734923.21101.227.camel@redhat.com>
Subject: Re: [RFC PATCH 06/11] IB/Verbs: Use management helper has_sa() and
 cap_sa(), for sa-check
From: Doug Ledford <dledford@redhat.com>
To: Michael Wang <yun.wang@profitbricks.com>
Cc: Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Ira Weiny <ira.weiny@intel.com>, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "David S. Miller" <davem@davemloft.net>,
        Or Gerlitz <ogerlitz@mellanox.com>, Moni Shoua <monis@mellanox.com>,
        PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
        Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
        Yan Burman <yanb@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Bart Van Assche <bvanassche@acm.org>,
        Yann Droneaud <ydroneaud@opteya.com>,
        Colin Ian King <colin.king@canonical.com>,
        Majd Dibbiny <majd@mellanox.com>, Jiri Kosina <jkosina@suse.cz>,
        Matan Barak <matanb@mellanox.com>, Alex Estrin <alex.estrin@intel.com>,
        Eric Dumazet <edumazet@google.com>, Erez Shitrit <erezsh@mellanox.com>,
        Sagi Grimberg <sagig@mellanox.com>, Haggai Eran <haggaie@mellanox.com>,
        Shachar Raindel <raindel@mellanox.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Steve Wise <swise@opengridcomputing.com>, Tom Tucker <tom@ogc.us>,
        Chuck Lever <chuck.lever@oracle.com>
Date: Mon, 30 Mar 2015 13:02:03 -0400
In-Reply-To: <55197CDB.3040105@profitbricks.com>
References: <551579CA.4030901@profitbricks.com>
		 <55157B43.6060507@profitbricks.com>
	 <1427732191.21101.201.camel@redhat.com> <55197CDB.3040105@profitbricks.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-fqhanlu0R7Vl3zOXg+sU"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-fqhanlu0R7Vl3zOXg+sU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-03-30 at 18:42 +0200, Michael Wang wrote:
> On 03/30/2015 06:16 PM, Doug Ledford wrote:
> > On Fri, 2015-03-27 at 16:46 +0100, Michael Wang wrote:
> >> Introduce helper has_sa() and cap_sa() to help us check if an IB devic=
e
> >> or it's port support Subnet Administrator.
> > There's no functional reason to have both rdma_transport_is_ib and
> > rdma_port_ll_is_ib, just use one.  Then there is also no reason for bot=
h
> > has_sa and cap_sa.  Just use one.
> The has_sa() will be eliminated :-)
>=20
> rdma_transport_is_ib and rdma_port_ll_is_ib is actually just rough helper
> to save some code, we can get rid of them when we no longer need them, bu=
t
> currently device driver still using them a lot, I'm not sure if the new
> mechanism could take cover all these cases...

Sure it would.  This is what I had suggested (well, close to this, I
rearranged the order this time around):

enum rdma_transport {
	RDMA_TRANSPORT_IB =3D      0x01,
	RDMA_TRANSPORT_OPA =3D     0x02,
	RDMA_TRANSPORT_IWARP =3D   0x04,
	RDMA_TRANSPORT_ROCE_V1 =3D 0x08,
	RDMA_TRANSPORT_ROCE_V2 =3D 0x10,
};

struct ib_port {
	...
	enum rdma_transport;
	...
};

static inline bool rdma_transport_is_ib(struct ib_port *port)
{
	return port->transport & (RDMA_TRANSPORT_IB | RDMA_TRANSPORT_OPA);
}

static inline bool rdma_transport_is_opa(struct ib_port *port)
{
	return port->transport & RDMA_TRANSPORT_OPA;
}

static inline bool rdma_transport_is_iwarp(struct ib_port *port)
{
	return port->transport & RDMA_TRANSPORT_IWARP;
}

static inline bool rdma_transport_is_roce(struct ib_port *port)
{
	return port->transport & (RDMA_TRANSPORT_ROCE_V1 | RDMA_TRANSPORT_ROCE_V2)=
;
}

static inline bool rdma_ib_mgmt(struct ib_port *port)
{
	return port->transport & (RDMA_TRANSPORT_IB | RDMA_TRANSPORT_OPA);
}

static inline bool rdma_opa_mgmt(struct ib_port *port)
{
	return port->transport & RDMA_TRANSPORT_OPA;
}


If we use something like this, then the above is all you need.  Then
every place in the code that checks for something like has_sa or cap_sa
can be replaced with rdma_ib_mgmt.  When Ira updates his patches for
this, he can check for rdma_opa_mgmt to enable jumbo MAD packets and
whatever else he needs.  Every place that does transport =3D=3D IB and ll =
=3D=3D
Ethernet can become rdma_transport_is_roce.  Every place that does
transport =3D=3D IB and ll =3D=3D INFINIBAND becomes rdma_transport_is_ib. =
 The
code in multicast.c just needs to check rdma_ib_mgmt() (which happens to
make perfect sense anyway as the code in multicast.c that is checking
that we are on an IB interface is doing so because IB requires extra
management of the multicast group joins/leaves).  But, like I said, this
is an all or nothing change, it isn't something we can ease into.

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--=-fqhanlu0R7Vl3zOXg+sU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVGYGLAAoJELgmozMOVy/dbpYP/Rs230S0wBbPl0uzl/L8Ocj9
+PUf0XMZFMNdoJ7OO4MMVcUWnKuF7v96L2Cqf/NjuLtEseD5SW6l5C5EDVUQUc/U
Wmze2dvKiuByPWSnWo0i1gvHOBssTvHwEKQj6JHNae2OuY4xL4uRxC1gKebfMIgs
9V1mAqD7B18yKAjTUWbeVM1Z0ZMmkS/6kEz10BegSUNKjLG0P8IKFpGwHUm7H3Tp
mRuqPTqFCCeAXo6O1M6TcmXfal8FX2BK+Ivonkur1CcU50tBcOJBrizHsdg7KhQ5
fYhS7S5DjlTCHPxa10qbkXPgx0zSw6qAHwHjMXONXc+ej09EAHbT/tjp3YD/LAIv
e2UIFaRjC+xmUDBhLtUKZb1YT/Sqw2bff+yZSgpVZTxzuC1VBmP2YeMzZqEb+qcz
XuM2QLetOIO7D+Gm9VxyrU3mMsSFIrV2kFnVIHQTuIsnVtj5cG/+BqbdvzGOS/LF
jZFdKpCED3MTs5gtMqvF5T1vxlA/zHoTdX+LGhK5YHFFDfngoH63Azst/SRfskP2
IlcSTIIXpQagSZ9wlOcpq54iMYHDJGuyCl58+UzHDIqyRZAfX7w1d8NUP8eJUwgu
6lsoQzsytCQVVbcyaTuXZQTscYGeMDjS0H8PBDbmqQYnvY2FpRvLpeeotcbdDr2w
npAIjOSuyiL/8RK2PG5w
=WiF1
-----END PGP SIGNATURE-----

--=-fqhanlu0R7Vl3zOXg+sU--

