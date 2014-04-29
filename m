Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52630 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751778AbaD2NAU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Apr 2014 09:00:20 -0400
Date: Tue, 29 Apr 2014 23:00:10 +1000
From: NeilBrown <neilb@suse.de>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC] SCHED: allow wait_on_bit functions to support a
 timeout.
Message-ID: <20140429230010.32cea174@notabene.brown>
In-Reply-To: <20140429103217.GQ27561@twins.programming.kicks-ass.net>
References: <20140429194406.06c580b8@notabene.brown>
	<20140429103217.GQ27561@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/ZZbuuavzJlC.4y6EOT=wWmp"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ZZbuuavzJlC.4y6EOT=wWmp
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 29 Apr 2014 12:32:17 +0200 Peter Zijlstra <peterz@infradead.org>
wrote:

> On Tue, Apr 29, 2014 at 07:44:06PM +1000, NeilBrown wrote:
> >=20
> >=20
> > It is currently not possible for various wait_on_bit functions to
> > implement a timeout.
> > While the "action" function that is called to do the waiting could
> > certainly use schedule_timeout(), there is no way to carry forward the
> > remaining timeout after a false wake-up.
> > As false-wakeups a clearly possible at least due to possible
> > hash collisions in bit_waitqueue(), this is a real problem.
> >=20
> > The 'action' function is currently passed a pointer to the word
> > containing the bit being waited on.  Of the 27 currently defined
> > action functions, zero of them use this pointer.
> > So changing it to something else will be a little noisy but will have
> > no immediate effect.
> >=20
> > This patch changes the 'action' function to take a pointer to the
> > "struct wait_bit_key", which contains a pointer to the word
> > containing the bit so nothing is really lost.
> >=20
> > It also adds a 'private' field to "struct wait_bit_key", which is
> > initialized to zero.
> >=20
> > An action function can now implement a timeout with something like
> >=20
> > static int timed_out_waiter(struct wait_bit_key *key)
> > {
> > 	unsigned long waited;
> > 	if (key->private =3D=3D 0) {
> > 		key->private =3D jiffies;
> > 		if (key->private =3D=3D 0)
> > 			key->private -=3D 1;
> > 	}
> > 	waited =3D jiffies - key->private;
> > 	if (waited > 10 * HZ)
> > 		return -EAGAIN;
> > 	schedule_timeout(waited - 10 * HZ);
> > 	return 0;
> > }
> >=20
> > If any other need for context in a waiter were found it would be easy
> > to use ->private for some other purpose, or even extend "struct
> > wait_bit_key".
> >=20
> > My particular need is to support timeouts in nfs_release_page() to
> > avoid deadlocks with loopback mounted NFS.
>=20
> So I'm sure I'm not getting it; but why is all the wait_bit crap so
> entirely different from the normal wait stuff?
>=20
> Surely something like:
>=20
> 	wait_event_timeout(&wq, test_bit(bit, word), timeout);
>=20
> Is pretty much the same, no? The only thing that's different is the wake
> function, but surely we can thread that into there somehow without all
> this silly repetition.
>=20
> Furthermore, I count about 23 action functions, of which there appear to
> be only like 4 actual variants. Surely such repetition sucks arse and
> should be avoided?
>=20

Sure, we could replace the interface with something that matches a more
common pattern.
The wait_queue is chosen based on a hash of the bit and the word, and we
sometimes want "test_and_set_bit", and sometimes "test_bit" but we could
probably come up with reasonable definitions for

   wait_bit{,_lock}{,_interruptible,_killable}{,_io}{,_freezable}{,_timeout=
}(
           bit, word [, timeout]);

there are 48 functions there.  We don't need all of them of course.

My particular use case (as currently designed) wouldn't actually be met by
these.  In the 'action' function I current check to see if the connection
that the NFS client has is to the local machine or a remote machine and
adjust the timeout accordingly (and this state can change while waiting).

So I guess we add a "_cmd" set of interfaces too.

I'm not sure it's worth the effort - can we just stick with my idea?
Maybe defined and export action wrappers for

 io_schedule  schedule schedule(interruptible),=20

that covers everything except a couple of NFS/RPC things which which should
probably stay local to NFS/RPC.

NeilBrown


--Sig_/ZZbuuavzJlC.4y6EOT=wWmp
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU1+iWjnsnt1WYoG5AQL8PxAAiJcBGk+7jDHydd5T73CehImRfstDSFLb
CzSevWleX7C0Hu5QB1q/802LOA//qobXeDdkYbngeKISfcVVp+SEbWOEFh5H+Jwq
13bp0dIJWq6bOdjtmyQdVuuA4biRf7G9fH+oEUDEskWyktxcPxOSg5XfL8zlzEjo
Xrra1kD+5W86yRi5JwUSQ1ye0vmI+GqJ3jTW9xpM92nmY9DOUWPpFBT7a6J4Kwwy
8fEAi+h+6Hg1Oc92dKuvnOnxSe8CXoXAsPyUEjGoqlJD9ddWL/HaeYsgQWaZ1KUH
dpZ6s+IecbdcNqFlIipPADF4PNKaixYK6ZuHOSFfePgv5rK7WKErikabkUWSzFkC
BTh7fHs/9xaUkkabZ+1nfKva9tJmTe5Hz3RNZe/2+fgRmShk/Y1sXP6+2anl/XDN
3YR+wkxdLXAnM9wNJdbH5rX4OAaWtbP156lwlsypmKxC1C7If+d1oGyYFVnoKLaC
HVZavqeG7EoM7au+GuWSO3Ie40F1WnzCqNF5qXix6FEUbSxqaBkmrS/TkO1nxwgt
RKrtqOBqvE6c5zZXfwziFADmy2Na6YnfeRFilGKGEKaOaV1DaQzwRkzfirkv9grV
exoqcIZyWsFReGjWzmuSa7XDu5/NZuiWwDsfod9QOoOzx/Lsd8lrIp8KIiWMTCm4
KMdurZgr2P8=
=RlEK
-----END PGP SIGNATURE-----

--Sig_/ZZbuuavzJlC.4y6EOT=wWmp--
