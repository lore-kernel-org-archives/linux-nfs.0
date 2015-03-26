Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41534 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751402AbbCZQ2Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Mar 2015 12:28:16 -0400
Message-ID: <1427387258.21101.124.camel@redhat.com>
Subject: Re: [PATCH 0/2 RESEND] IB/Verbs: Use helpers to refine the checking
 on transport and link layer
From: Doug Ledford <dledford@redhat.com>
To: Michael Wang <yun.wang@profitbricks.com>
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Ira Weiny <ira.weiny@intel.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Moni Shoua <monis@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>,
        Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Yan Burman <yanb@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Bart Van Assche <bvanassche@acm.org>,
        Yann Droneaud <ydroneaud@opteya.com>,
        Colin Ian King <colin.king@canonical.com>,
        Jiri Kosina <jkosina@suse.cz>, Matan Barak <matanb@mellanox.com>,
        Majd Dibbiny <majd@mellanox.com>,
        Dan Carpenter <dan.carpenter@oracle.com>, Mel Gorman <mgorman@suse.de>,
        Alex Estrin <alex.estrin@intel.com>,
        Eric Dumazet <edumazet@google.com>, Erez Shitrit <erezsh@mellanox.com>,
        Sagi Grimberg <sagig@mellanox.com>, Haggai Eran <haggaie@mellanox.com>,
        Shachar Raindel <raindel@mellanox.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>, Tom Tucker <tom@ogc.us>,
        Chuck Lever <chuck.lever@oracle.com>
Date: Thu, 26 Mar 2015 12:27:38 -0400
In-Reply-To: <55142DFD.2060100@profitbricks.com>
References: <5512CFB0.1050108@profitbricks.com>
	 <1427378940.21101.100.camel@redhat.com> <55142DFD.2060100@profitbricks.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-J/Y4N0HcTdODZ8Wk9AOY"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-J/Y4N0HcTdODZ8Wk9AOY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-03-26 at 17:04 +0100, Michael Wang wrote:
> Hi, Doug
>=20
> Thanks for the excellent comments :-)
>=20
> On 03/26/2015 03:09 PM, Doug Ledford wrote:
> > On Wed, 2015-03-25 at 16:09 +0100, Michael Wang wrote:
> >> [snip]
> >>
> > [snip]
> >
> > So, I would suggest that we fix things up thusly:
> >
> > enum transport {
> > 	TRANSPORT_IB=3D1,
> > 	TRANSPORT_IWARP=3D2,
> > 	TRANSPORT_ROCE=3D4,
> > 	TRANSPORT_OPA=3D8,
> > 	TRANSPORT_USNIC=3D10,
> > };
> >
> > #define HAS_SA(ibdev) ((ibdev)->transport & (TRANSPORT_IB|TRANSPORT_OPA=
))
> > #define HAS_JUMBO_SA(ibdev) ((ibdev)->transport & TRANSPORT_OPA))
> >
> > or possibly
> >
> > static bool ib_dev_has_sa(struct ibv_device *ibdev)
> > {
> > 	return ibdev->transport & (TRANSPORT_IB | TRANSPORT_OPA);
> > }
>=20
> The idea sounds interesting, and here my silly questions come :-P
>=20
> So are you suggesting that we add a new bitmask 'transport' into 'struct =
ib_device'
> in kernel, and setup it at very beginning?
>=20
> Few more questions here is:
> 1. when to setup? (maybe inside ib_register_device() before doing client-=
>add() callback?)

I don't think "we" can set it up here.  The driver's have to set it up.
After all, the mlx4 driver will have to decide for itself what the port
transport is and tell us, we can't tell it.

> 2. how to setup? (still infer from the transport and link layer like we c=
urrently do?)

Find each point in each driver where they currently set the link layer
and transport fields today, and replace that with setting the new
transport bitmask instead.

> 3. in case if a device has ports with different link layer type (please c=
orrect
>     me if this will never happen), then only one bitmask may not be enoug=
h to
>     present the transport of all the ports? (maybe create a bitmask per p=
ort?)

Correct, a bitmask per port.  And we can remove the existing transport
and link layer elements of the struct and replace it with just the new
transport.  Then, whenever we need to copy a struct to user space, we
have a helper that looks something like this:

static void inline ib_set_user_transport(struct ib_device *ibdev,
					 struct user_ibv_device *uibdev)
{
	switch(ibdev->port[port]->transport) {
	case TRANSPORT_IB:
	case TRANSPORT_OPA:
		uibdev->port[port]->link_layer =3D INFINIBAND;
		uibdev->port[port]->transport =3D INFINIBAND;
		break;
	case TRANSPORT_IWARP:
		uibdev->port[port]->link_layer =3D INFINIBAND;
		uibdev->port[port]->transport =3D IWARP;
		break;
	case TRANSPORT_ROCE:
		uibdev->port[port]->link_layer =3D ETHERNET;
		uibdev->port[port]->transport =3D INFINIBAND;
		break;
	case TRANSPORT_USNIC:
		uibdev->port[port]->link_layer =3D ETHERNET;
		uibdev->port[port]->transport =3D <whatever USNIC uses today>;
		break;
	default:
		pr_err(ibdev, "unknown transport type %x\n",
		       ibdev->port[port]->transport);
	}
}

That preserves the user space ABI and all user programs keep working,
while we update to an internal representation that makes more sense for
how things have evolved.

> Regards,
> Michael Wang
>=20
> >
> > If we do this, then the only thing we have to fix up to preserve ABI
> > with user space is to make sure that any time we export an ibv_device
> > struct and any time we import the same, we convert from our new interna=
l
> > representation to the old representation that user space expects.  And
> > we also need to make a few changes in the sysfs code to display the
> > properties as things expect.  But, that would allow us to fix up what I
> > see as a problem right now, which is that we hide the information we
> > need to know what sort of device we are working on in two different
> > fields: the transport and the link layer.  Instead, just use one field
> > with enough variants that we can store all of the relevant information
> > we need in that one field.  This has the benefit that any comparisons
> > that happen in hot paths will now always be a single bitwise comparison
> > and will no longer need to hit two separate variables for two separate
> > compares.
> >
> >
> >
>=20


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--=-J/Y4N0HcTdODZ8Wk9AOY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVFDN6AAoJELgmozMOVy/d9q8QAIT8viYhax0bYOOcoCIek2lf
hjtQ06I1eYd6IZTO57587qSKOxuuV7Yvd0Y+f5/sDyPzWmhsLRlyYTrJZGC1WYx1
LGOdsX8UZEvuYuQpNedbnT79vb64NSqA8BOl3wcZNLtd0ViGVsa0KWzTOdjGGimg
lZx18WYfeLS3NJfcagt22/3NuyWsCiuxwyLKmz0248Euc3W+9MFyoXv25zFElfPr
Vq6LaTC+iwvnRJh3S7czA4MEUdyiBelgv2y2UMBcKrASKjyd7Is+0rwUhAvPAAeZ
HdeALg8aLI4YLWLjtF+n2ZTondYr0GXU+ZsDGR5kZsEkvdlU//v1mwd77OabTPiy
SjAuLr04GYKZ5Vc5wp7K9QbgpKgjhGyjq/MJHMG9lGaA4nfvpqsRPM8BU+/XwPUK
cgZ92FSHiEFsU/wuQCIPRgCSo2zfJLQVywCyj8ROk2OJqDGXJs+F403tMUcfkNOT
LAEFR7E8ngrWiT+lZG7WSB8iAD9wgG17MG8VELiz6yK9CnlTfPVRaMr5R7K9xyqV
ugtUyCfq6W+UzKmFsWr6sJoIKZr9pMPaL1TK9HVixEHVlMflu65tl7c2E/Hels8n
kMy0T5xKT5SkqyRkLq/5QjD25fJYaqbHOhNth6QtFJ8+Ix/WCIDx5BtazR0UTrE+
tQNfXFEEGrDo+lmW93j1
=R0Bs
-----END PGP SIGNATURE-----

--=-J/Y4N0HcTdODZ8Wk9AOY--

