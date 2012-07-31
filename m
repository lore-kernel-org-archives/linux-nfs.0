Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56740 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755256Ab2GaFIQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 01:08:16 -0400
Date: Tue, 31 Jul 2012 15:08:01 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "ZUIDAM, Hans" <Hans.Zuidam@philips.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "DE WITTE, PETER" <PETER.DE.WITTE@philips.com>
Subject: Re: Linux NFS and cached properties
Message-ID: <20120731150801.0a4b557b@notabene.brown>
In-Reply-To: <20120726223607.GA28982@fieldses.org>
References: <D307B3AC0BCD4C419E6B8FA6A2720A9C0C3B2F@011-DB3MPN1-001.MGDPHG.emi.philips.com>
	<20120724143748.GC8570@fieldses.org>
	<D307B3AC0BCD4C419E6B8FA6A2720A9C18ABBA@011-DB3MPN1-001.MGDPHG.emi.philips.com>
	<20120726223607.GA28982@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/XwVPX.tsEzHv8MZHZZgfoo7"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/XwVPX.tsEzHv8MZHZZgfoo7
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 26 Jul 2012 18:36:07 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Tue, Jul 24, 2012 at 05:28:02PM +0000, ZUIDAM, Hans wrote:
> > Hi Bruce,
> >=20
> > Thanks for the clarification.
> >=20
> > (I'm repeating a lot of my original mail because of the Cc: list.)
> >=20
> > > J. Bruce Fields
> > > I think that's right, though I'm curious how you're managing to hit
> > > that case reliably every time.  Or is this an intermittent failure?
> > It's an intermittent failure, but with the procedure shown below it is
> > fairly easy to reproduce.    The actual problem we see in our product
> > is because of the way external storage media are handled in user-land.
> >=20
> >         192.168.1.10# mount -t xfs /dev/sdcr/sda1 /mnt
> >         192.168.1.10# exportfs 192.168.1.11:/mnt
> >=20
> >         192.168.1.11# mount 192.168.1.10:/mnt /mnt
> >         192.168.1.11# umount /mnt
> >=20
> >         192.168.1.10# exportfs -u 192.168.1.11:/mnt
> >         192.168.1.10# umount /mnt
> >         umount: can't umount /media/recdisk: Device or resource busy
> >=20
> > What I actually do is the mount/unmount on the client via ssh.  That
> > is a good way to trigger the problem.
> >=20
> > We see that during the un-export the NFS caches are not flushed
> > properly which is why the final unmount fails.
> >=20
> > In net/sunrpc/cache.c the cache times (last_refresh, expiry_time,
> > flush_time) are measured in seconds.  If I understand the code somewhat
> > then during an NFS un-export the is done by setting the flush_time to
> > the current time.  The cache_flush() is called.  If in that same second
> > last_refresh is set to the current time then the cached item is not
> > flushed.  This will subsequently cause un-mount to fail because there
> > is still a reference to the mount point.
> >=20
> > > J. Bruce Fields
> > > I ran across that recently while reviewing the code to fix a related
> > > problem.  I'm not sure what the best fix would be.
> > >
> > > Previously raised here:
> > >
> > >       http://marc.info/?l=3Dlinux-nfs&m=3D133514319408283&w=3D2
> >=20
> > The description in your mail does indeed looks the same as the problem
> > that we see.
> >=20
> > >From reading the code in net/sunrpc/cache.c I get the impression that =
it is
> > not really possible to reliably flush the caches for an un-exportfs such
> > that after flushing they will not accept entries for the un-exported IP=
/mount
> > point combination.
>=20
> Right.  So, possible ideas, from that previous message:
>=20
> 	- As Neil suggests, modify exportfs to wait a second between
> 	  updating etab and flushing the cache.  At that point any
> 	  entries still using the old information are at least a second
> 	  old.  That may be adequate for your case, but if someone out
> 	  there is sensitive to the time required to unexport then that
> 	  will annoy them.  It also leaves the small possibility of
> 	  races where an in-progress rpc may still be using an export at
> 	  the time you try to flush.
> 	- Implement some new interface that you can use to flush the
> 	  cache and that doesn't return until in-progress rpc's
> 	  complete.  Since it waits for rpc's it's not purely a "cache"
> 	  layer interface any more.  So maybe something like
> 	  /proc/fs/nfsd/flush_exports.
> 	- As a workaround requiring no code changes: unexport, then shut
> 	  down the server entirely and restart it.  Clients will see
> 	  that as a reboot recovery event and recover automatically, but
> 	  applications may see delays while that happens.  Kind of a big
> 	  hammer, but if unexporting while other exports are in use is
> 	  rare maybe it would be adequate for your case.

That's a shame...
I had originally intended "rpc.nfsd 0" to simple stop all threads and nothi=
ng
else.  Then you would be able to:
   rpc.nfsd 0
   exportfs -f
   unmount
   rpc.nfsd 16

and have a nice fast race-free unmount.
But commit e096bbc6488d3e49d476bf986d33752709361277 'fixed' that :-(

I wonder if it can be resurrected ... maybe not worth the effort.


The idea of a new interface to synchronise with all threads has potential a=
nd
doesn't need to be at the nfsd level - it could be in sunrpc.  Maybe it cou=
ld
be built into the current 'flush' interface.
1/ iterate through all no-sleeping threads setting a flag an increasing a
counter.
2/ when a thread completes current request, if test_and_clear the flag, it
atomic_dec_and_test the counter and then wakes up some wait_queue_head.
3/ 'flush'ing thread waits on the waut_queue_head for the counter to be 0.

If you don't hate it I could possibly even provide some code.

NeilBrown


--Sig_/XwVPX.tsEzHv8MZHZZgfoo7
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUBdoMTnsnt1WYoG5AQJ24Q//aByfzlxQCbfmS8OaBefcV5ZiDx5ed4Kf
hlhYdYXB31ivHjBMnAoSoqTmL2A/XOciwWL97XFQrpSf8r+aKqFyOyDP2GaXx9C9
EeX6FO69IFG9GbDlWRkvihUxDcBbQX8CT7F7Posdvj1szg4FZxe81lH4plSrVOA9
+wCBFNCz+UtadDSB5Zkum5WG8bjHWLzPI0DI23q8zdt6tI7Y5QVBFRfnfLLrK8vQ
SNup23bjWrSa4IpK9M8+CI11+dKCTZwTQ75hFkcRi7EmnilkCxMpf1SJ1I5FT0ze
0CdmUvQqwehjB7nAPUzlxeqrF3eAZ1s4wHCSW682M4uCyFk36y3TdJv/DKitgrrZ
3nqDZwul9U6k33ETND7rtnkwaseYkQBjoxppbHk/nz+s7ijHWT6QAa4k7F/KGvoN
iXTb5Ba0OB341tgaEVbjJfw0yHOF9qELUqVZfTqFi9/l/hvkKFmTAy+r+Y6coUrt
uGGkb28zMoNQmZuAzPQ5NF5+vPrRNTfvWYycGYyJjuTLKG9JnkLamYFUDS+YfbpT
jnPtEQ0xUVnFinsRspttUaKWSSr7gYJKugbSEgtNKDOMS5srvzENmso9rYEdX0Wr
0/SV2dZ2vq8ij+oFey4321w1W9uAA5ksorwybT9y+GTUE/zr088ZVujjkYbEQ+SB
5v+kdK/8x4A=
=shcP
-----END PGP SIGNATURE-----

--Sig_/XwVPX.tsEzHv8MZHZZgfoo7--
