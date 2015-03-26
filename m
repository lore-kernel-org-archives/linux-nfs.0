Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56352 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752372AbbCZOJt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Mar 2015 10:09:49 -0400
Message-ID: <1427378940.21101.100.camel@redhat.com>
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
Date: Thu, 26 Mar 2015 10:09:00 -0400
In-Reply-To: <5512CFB0.1050108@profitbricks.com>
References: <5512CFB0.1050108@profitbricks.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-/Ql6gYk8G0P7tUSi+MWG"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-/Ql6gYk8G0P7tUSi+MWG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-03-25 at 16:09 +0100, Michael Wang wrote:
> My sincerely apologies for the corrupted mails, and thanks for Dan's kind=
ly
> remind :-)
>=20
> There are too many lengthy code to check the transport type of IB device,
> or the link layer type of it's port, this patch set try to use some helpe=
r to
> refine and save us some code.
>=20
> TODO:
>     Currently we inferred from the transport type and link layer type to =
identify
>     the way of management, it will be better if we can directly get the i=
ndicator
>     from vendor.
>=20
>     Sean proposed one suggestion:
>         https://www.mail-archive.com/linux-rdma@vger.kernel.org/msg23339.=
html
>=20
>     It may need a big work to adapt current implementation to utilize
>     these flags elegantly.
>=20
>     Also the performance concern on query_port() need to be addressed, ma=
y be
>     some new callback like query_mgmt() could works.
>=20
> Michael Wang (2):
>     [PATCH 1/2] IB/Verbs: Use helpers to check transport and link layer
>     [PATCH 2/2] IB/Verbs: Use helpers to check IBoE technology
>=20
> ---
>  drivers/infiniband/core/agent.c           |    2 -
>  drivers/infiniband/core/cm.c              |    2 -
>  drivers/infiniband/core/cma.c             |   33 ++++++++++++-----------=
-------
>  drivers/infiniband/core/mad.c             |    6 ++---
>  drivers/infiniband/core/multicast.c       |   11 +++-------
>  drivers/infiniband/core/sa_query.c        |   14 ++++++------
>  drivers/infiniband/core/ucm.c             |    3 --
>  drivers/infiniband/core/user_mad.c        |    2 -
>  drivers/infiniband/core/verbs.c           |    5 +---
>  drivers/infiniband/hw/mlx4/ah.c           |    2 -
>  drivers/infiniband/hw/mlx4/cq.c           |    4 ---
>  drivers/infiniband/hw/mlx4/mad.c          |   14 +++---------
>  drivers/infiniband/hw/mlx4/main.c         |    8 ++-----
>  drivers/infiniband/hw/mlx4/mlx4_ib.h      |    2 -
>  drivers/infiniband/hw/mlx4/qp.c           |   21 ++++++-------------
>  drivers/infiniband/hw/mlx4/sysfs.c        |    6 +----
>  drivers/infiniband/ulp/ipoib/ipoib_main.c |    6 ++---
>  include/rdma/ib_verbs.h                   |   30 +++++++++++++++++++++++=
++++
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c   |    3 --
>  19 files changed, 87 insertions(+), 87 deletions(-)
>=20

I think this is a step in the right direction.  However, as I brought up
in a different thread, I think it would be best if we start to clear up
some of the funny things in this space, such as calling iWARP link layer
InfiniBand.

One thing we didn't discuss before is that, even if changing these items
around in user space would break user space, changing them around in the
kernel won't break anything except maybe Lustre (which we can inform the
authors about the change so they can anticipate it and do the right
thing in their code) because we can fix up our return values we pass to
user space with no impact to them as it's not on a hot path.  We can
then emulate the old way of setting all these variables to user space
while fixing them up in kernel space.

So, I would suggest that we fix things up thusly:

enum transport {
	TRANSPORT_IB=3D1,
	TRANSPORT_IWARP=3D2,
	TRANSPORT_ROCE=3D4,
	TRANSPORT_OPA=3D8,
	TRANSPORT_USNIC=3D10,
};

#define HAS_SA(ibdev) ((ibdev)->transport & (TRANSPORT_IB|TRANSPORT_OPA))
#define HAS_JUMBO_SA(ibdev) ((ibdev)->transport & TRANSPORT_OPA))

or possibly

static bool ib_dev_has_sa(struct ibv_device *ibdev)
{
	return ibdev->transport & (TRANSPORT_IB | TRANSPORT_OPA);
}

If we do this, then the only thing we have to fix up to preserve ABI
with user space is to make sure that any time we export an ibv_device
struct and any time we import the same, we convert from our new internal
representation to the old representation that user space expects.  And
we also need to make a few changes in the sysfs code to display the
properties as things expect.  But, that would allow us to fix up what I
see as a problem right now, which is that we hide the information we
need to know what sort of device we are working on in two different
fields: the transport and the link layer.  Instead, just use one field
with enough variants that we can store all of the relevant information
we need in that one field.  This has the benefit that any comparisons
that happen in hot paths will now always be a single bitwise comparison
and will no longer need to hit two separate variables for two separate
compares.



--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--=-/Ql6gYk8G0P7tUSi+MWG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVFBL8AAoJELgmozMOVy/dtc4P/3R67xJKqEwzXUK+oX+R7H3E
6BNtV9xkB8fVXHseL188/iFCE0mP4WO2WaMt88/iwVU+LChZX1bRClehjue4nl3B
qrDoiW+5r+xKkBGjPj6Y593kwVSZKsKBkC50+gekxtTdzbff8HIk3JW+OVIBXVUp
IwWSX7cwAqws1e/Y4ldFcNMKXkkvqr8QyEQsUGDvZNt+tph28YKxbpk/ZYF294tW
JuWqVV0cYa0ZTkNDBbLqAnBSaFSCkYFkY6DA470Y3FzUaiEf8YWHxUrie7BlJ4Qd
r/TW0T8N5rklmn14JK7K85j+DuWy7ad2bEFhDQP6tikUosn0XMXpg82sv2Wcl/TP
o+GsXixfrUOBd9Y5/MRBpVx5zTWjD4Uq8LrYBf76qphtqUInTc6GcCwZsh+o1yi8
znhFBwl/vU4qCrzcplIu103stQMXgI00A0byzjwsaKY6+GATxgtRU/ehm3BMh0bS
uSWQxbGrGZBgVb7jb4pFpSdp3+PUv/t5BwJSq7YoXsQCdxlPXWbTuTk1/Sws9OzZ
Y3gkxLA2w/Til58wXlW2zYIAH7/8RkcmYZBNH5uIqdxmEScn3neGnWUo3uoNdVcq
+hC+mQEgI34fg0k9SvRv4cchkXo3QCF2bdhLIbVLVZ03zMoqJbwveCuAIhK0wYtM
K5tAbB0u2AqUqyTtq+DD
=oFE4
-----END PGP SIGNATURE-----

--=-/Ql6gYk8G0P7tUSi+MWG--

