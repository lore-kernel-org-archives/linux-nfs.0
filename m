From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 03/10] mac80211: Use rcu_barrier() on unload.
Date: Tue, 23 Jun 2009 17:15:55 +0200
Message-ID: <1245770155.21314.38.camel@johannes.local>
References: <20090623150330.22490.87327.stgit@localhost>
	 <20090623150409.22490.99106.stgit@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-4pWj/zfZZMHnV2anu3HO"
Cc: "David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dougthompson@xmission.com, bluesmoke-devel@lists.sourceforge.net,
	axboe@kernel.dk, Patrick McHardy <kaber@trash.net>,
	christine.caulfield@googlemail.com, Trond.Myklebust@netapp.com,
	linux-wireless@vger.kernel.org, yoshfuji@linux-ipv6.org,
	shemminger@linux-foundation.org, linux-nfs@vger.kernel.org,
	bfields@fieldses.org, neilb@suse.de, linux-ext4@vger.kernel.org,
	tytso@mit.edu, adilger@sun.com, netfilter-devel@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20090623150409.22490.99106.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-4pWj/zfZZMHnV2anu3HO
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-06-23 at 17:04 +0200, Jesper Dangaard Brouer wrote:
> The mac80211 module uses rcu_call() thus it should use rcu_barrier()
> on module unload.
>=20
> I'm having a hardtime verifying that no more call_rcu() callbacks can
> be schedules in the module unload path.  Could a maintainer please
> look into this?
>=20
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
> ---
>=20
>  net/mac80211/main.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/mac80211/main.c b/net/mac80211/main.c
> index 092a017..e9f70ce 100644
> --- a/net/mac80211/main.c
> +++ b/net/mac80211/main.c
> @@ -1100,6 +1100,8 @@ static void __exit ieee80211_exit(void)
>  		ieee80211s_stop();
> =20
>  	ieee80211_debugfs_netdev_exit();
> +
> +	rcu_barrier(); /* Wait for completion of call_rcu()'s */
>  }

I don't think this is correct at all -- note that call_rcu() is done in
some of the mesh code, so I would think you need to do this in
ieee80211_stop() since the call_rcu() code requires the interface to
still be around. And when it's stopped everything should be idle.

I can fix it later, but I'm deep in some other stuff right now.

johannes

--=-4pWj/zfZZMHnV2anu3HO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKQPGoAAoJEODzc/N7+QmazPkP/juLnaNnvhYosQYGZ2G0lzA2
O1JQP2Hp4TpyxHI8dGDHq+gO1BCAbKQp7zA/PKH3u346AYgp3uvedhNAWqzvdRPS
TGO/cY0ZmgUJbzk/v4rB9SinMsuYiL7DgSaK11Fv0KZBqcKxMLO8K39yOdn/TAfi
xGEqIUkDFUJvxuXEINxt2OPInpzSHEDYQCf3EU4TkZ9hziahx0Gj8dNzzJcp+zSu
3EGnm8H7+WkT7qWyS7ur7C9JFp/7ySsN2cW6DGs594vKSHM6kHOrtjIH2eOc3pQM
uqr5YnTefT88ZvuqMSSmAi0BzmlH77atuegwUBXpAtKb1cdJG7R+h2URNWrC5APm
YDv3w7UvmyDXcRotygdsug6gstMmAfoIgzfCPoJYFGJ7ZYmuyUejH7QMlzsuvc22
7fvWQZPKqeAvOhMn7/kdTZEA2KMntRvcEf+QX8PoeEn0Zpw/zY42FBNXG7d+RQf6
SqLzdV/DQGzPbtzXVXPYbq9vWCF98887mItGXhK5Q3ah/Qn330i3TRWLoXhGMbTM
TScPV5FZDkBOL8ohzQVdJ/CDjwDQTYE3sqb0yJ9Qnmr+M0JwxPXFiKemRtywSntf
fJVDsKgVSjW6/XWZRgGGHGXFWV1kTdumKAvKZDbW5TzTCv2VqUojw8tiNp3yplYR
7jBVLeH6bZqk/962Kn/0
=4r0R
-----END PGP SIGNATURE-----

--=-4pWj/zfZZMHnV2anu3HO--

