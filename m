From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 03/10] mac80211: Use rcu_barrier() on unload.
Date: Wed, 24 Jun 2009 13:39:00 +0200
Message-ID: <1245843540.21314.49.camel@johannes.local>
References: <20090623150330.22490.87327.stgit@localhost>
	 <20090623150409.22490.99106.stgit@localhost>
	 <1245770155.21314.38.camel@johannes.local>
	 <1245837965.6695.45.camel@localhost.localdomain>
	 <1245838862.21314.48.camel@johannes.local>
	 <1245843137.6695.48.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-YEzT/e4ratx/XQsl9Mjj"
Cc: "David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dougthompson@xmission.com, axboe@kernel.dk,
	Patrick McHardy <kaber@trash.net>,
	christine.caulfield@googlemail.com, Trond.Myklebust@netapp.com,
	linux-wireless@vger.kernel.org, yoshfuji@linux-ipv6.org,
	shemminger@linux-foundation.org, linux-nfs@vger.kernel.org,
	bfields@fieldses.org, neilb@suse.de, linux-ext4@vger.kernel.org,
	tytso@mit.edu, adilger@sun.com, netfilter-devel@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1245843137.6695.48.camel@localhost.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-YEzT/e4ratx/XQsl9Mjj
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-06-24 at 13:32 +0200, Jesper Dangaard Brouer wrote:

> > > Should it then not be in mesh.c ieee80211_stop_mesh().  We can replac=
e
> > > the synchronize_rcu() in this function with a rcu_barrier().
> >=20
> > Yes, this seems correct.
> >=20
> > johannes
>=20
> Can I consider this a:
>=20
> Acked-by: Johannes Berg <johannes@sipsolutions.net>

Yeah,=20
Acked-by: Johannes Berg <johannes@sipsolutions.net>

johannes

--=-YEzT/e4ratx/XQsl9Mjj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKQhBQAAoJEODzc/N7+QmaApEQAKY+MQjzru+Kp3Gn0d62KnpL
0xKxjQpcEFiqF6OlOjJgDoP7I1f1k5jtYm9DwaL4ptM5DAIH0zTD0Y5slIAu5Bgq
WmtIWfvrhRhLTkZ9iflySejABl8QCS6hDQlP3Kd9gB8/v+X81iLIJ6VA3q0sC3Pb
zjEPp3fWp95p9/bJtL08GtgFNYxXBrJqlQmn28QsRG26zQjnaNfioAK/G0U8pO9S
mW599dxHFZAPC1W88BSVaP5ZkzMibaLREEGR19JGZ8pSeqEz6a9j4PY9A4R0QX72
odsIovpX6ZftFe1UA3WZrfyLBOXtfPb5F4g92ZTCedde0hU2Y70TUjAojY0PUD0p
4UvljPCb03r7bBe9ZRcWJ593iWvS5q5FXOZKFBGf/5rtINiRGQ7djrBhRvwyQgMp
uEpWk6FdZIQIu4kS+oZG3Ipos5ruAbEKgG/Qo3d/B4J2T3/14r2CgpSYLQAlt6/I
BKub/jT+EYW2z4tMRAKtgLgYo5xNSwT0nMaY2zQ2nFIsX4nKHvippQ5HXFoeg1qB
sMoR04kHl9oJfpvAqBAD+A1bJUpmIR07YdSb/c1519gQIYIF7TbTAr3VvkR4W3TP
Mc7pMAu9BWg70RaOccRPD7t0rxzTXlCJ9BGjvtLTw4/AWAPFQ4e5T+MtQZdW6/0l
n/rDXKSU3b07r4JONNy9
=grWI
-----END PGP SIGNATURE-----

--=-YEzT/e4ratx/XQsl9Mjj--

