From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 03/10] mac80211: Use rcu_barrier() on unload.
Date: Wed, 24 Jun 2009 12:21:02 +0200
Message-ID: <1245838862.21314.48.camel@johannes.local>
References: <20090623150330.22490.87327.stgit@localhost>
	 <20090623150409.22490.99106.stgit@localhost>
	 <1245770155.21314.38.camel@johannes.local>
	 <1245837965.6695.45.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-pZJIqGJkvSCF73OGmZi0"
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
Return-path: <linux-ext4-owner@vger.kernel.org>
In-Reply-To: <1245837965.6695.45.camel@localhost.localdomain>
Sender: linux-ext4-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-pZJIqGJkvSCF73OGmZi0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-06-24 at 12:06 +0200, Jesper Dangaard Brouer wrote:
> On Tue, 2009-06-23 at 17:15 +0200, Johannes Berg wrote:
> > On Tue, 2009-06-23 at 17:04 +0200, Jesper Dangaard Brouer wrote:
> > > The mac80211 module uses rcu_call() thus it should use rcu_barrier()
> > > on module unload.
> > >=20
> > > I'm having a hardtime verifying that no more call_rcu() callbacks can
> > > be schedules in the module unload path.  Could a maintainer please
> > > look into this?
> > >=20
> > > Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
> > > ---
> > >=20
> > >  net/mac80211/main.c |    2 ++
> > >  1 files changed, 2 insertions(+), 0 deletions(-)
> > >=20
> > > diff --git a/net/mac80211/main.c b/net/mac80211/main.c
> > > index 092a017..e9f70ce 100644
> > > --- a/net/mac80211/main.c
> > > +++ b/net/mac80211/main.c
> > > @@ -1100,6 +1100,8 @@ static void __exit ieee80211_exit(void)
> > >  		ieee80211s_stop();
> > > =20
> > >  	ieee80211_debugfs_netdev_exit();
> > > +
> > > +	rcu_barrier(); /* Wait for completion of call_rcu()'s */
> > >  }
> >=20
> > I don't think this is correct at all -- note that call_rcu() is done in
> > some of the mesh code, so I would think you need to do this in
> > ieee80211_stop() since the call_rcu() code requires the interface to
> > still be around. And when it's stopped everything should be idle.
>=20
> Should it then not be in mesh.c ieee80211_stop_mesh().  We can replace
> the synchronize_rcu() in this function with a rcu_barrier().

Yes, this seems correct.

johannes

--=-pZJIqGJkvSCF73OGmZi0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKQf4JAAoJEODzc/N7+QmayVkP/j1S2XEXRYf5Yd3tTJcNqNkB
3C4YvnUxNNwO6Uk17Y6NCkZ7SblzrIpxHKh5588Vtfcq8GE+aeKzS1F64kDqw+az
846Y++wS2liZTJ67PfoDc33HGBQBtFSnTZOpC86j2RCGv4fDV0T5VQkVSupA6UdW
H5FpuBHlKPgkvkHoa62gth3FNUGSG7MFDqpUwk/WiOigewb3e2W57C6i6qzNL5Iz
nt7eqLeSnQX59e2w9w+inwtflU/bu5OGqQGekMBj4wZKYinLzp2UOEfxW5KENG+a
ANOEznwgo5UvOOXQj+pwQaF+ZvHh3BttfjR4tKmMAc494QcvrDab8TvGNUKwHOFE
xomJZYO6iTifankWA5/1q6yYnf2wPHBia9ov0oysIAI4G0XP7S8hkAswg+/uQMMe
TFP96Z75XDn3eBbHi7h1TcycKt5Vtd+G7Wqg/aZ6W8h5PLBCeOo1OAz654bRyIGB
VbVg50O2WQeD/2MTLfnf6XKLYN7YaBvB9SFURpeJnVHaO4aQ+ziPNPBO8KQi4yD1
5kSpVez9ZoftOWf62Xz12xjdtgahmAqeugQR9ziNyv5XjnbpE7sQWiABtiF9F62N
y0QjtstgnOSM6CGiIEVb2eZehIp6w3AK78RLMeb5/3KU+/6m6N6oGptZTyXxib+d
yl4FzVQ1fHXT6uqZ4PhE
=8doT
-----END PGP SIGNATURE-----

--=-pZJIqGJkvSCF73OGmZi0--

