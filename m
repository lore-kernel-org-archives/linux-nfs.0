Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55250 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750864AbdGYKFP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Jul 2017 06:05:15 -0400
Date: Tue, 25 Jul 2017 11:05:13 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
Message-ID: <20170725100513.GA5073@stefanha-x1.localdomain>
References: <20170630132120.31578-1-stefanha@redhat.com>
 <20170630132120.31578-6-stefanha@redhat.com>
 <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com>
 <87wp7lvst9.fsf@notabene.neil.brown.name>
 <87tw2ox4st.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="huq684BweRXVnRxX"
In-Reply-To: <87tw2ox4st.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 07, 2017 at 02:13:38PM +1000, NeilBrown wrote:
> On Fri, Jul 07 2017, NeilBrown wrote:
>=20
> > On Fri, Jun 30 2017, Chuck Lever wrote:
> >>
> >> Wouldn't it be nicer if it worked like this:
> >>
> >> (guest)$ cat /etc/hosts
> >> 129.0.0.2  localhyper
> >> (guest)$ mount.nfs localhyper:/export /mnt
> >>
> >> And the result was a working NFS mount of the
> >> local hypervisor, using whatever NFS version the
> >> two both support, with no changes needed to the
> >> NFS implementation or the understanding of the
> >> system administrator?
> >
> > Yes. Yes. Definitely Yes.
> > Though I suspect you mean "127.0.0.2", not "129..."??
> >
> > There must be some way to redirect TCP connections to some address
> > transparently through to the vsock protocol.
> > The "sshuttle" program does this to transparently forward TCP connectio=
ns
> > over an ssh connection.  Using a similar technique to forward
> > connections over vsock shouldn't be hard.
> >
> > Or is performance really critical, and you get too much copying when you
> > try forwarding connections?  I suspect that is fixable, but it would be
> > a little less straight forward.
> >
> > I would really *not* like to see vsock support being bolted into one
> > network tool after another.
>=20
> I've been digging into this a big more.  I came across
>   https://vmsplice.net/~stefan/stefanha-kvm-forum-2015.pdf
>=20
> which (on page 7) lists some reasons not to use TCP/IP between guest
> and host.
>=20
>  . Adding & configuring guest interfaces is invasive
>=20
> That is possibly true.  But adding support for a new address family to
> NFS, NFSD, and nfs-utils is also very invasive.  You would need to
> install this software on the guest.  I suggest you install different
> software on the guest which solves the problem better.

Two different types of "invasive":
1. Requiring guest configuration changes that are likely to cause
   conflicts.
2. Requiring changes to the software stack.  Once installed there are no
   conflicts.

I'm interested and open to a different solution but it must avoid
invasive configuration changes, especially inside the guest.

>  . Prone to break due to config changes inside guest
>=20
> This is, I suspect, a key issue.  With vsock, the address of the
> guest-side interface is defined by options passed to qemu.  With
> normal IP addressing, the guest has to configure the address.
>=20
> However I think that IPv6 autoconfig makes this work well without vsock.
> If I create a bridge interface on the host, run
>   ip -6 addr  add fe80::1 dev br0
> then run a guest with
>    -net nic,macaddr=3DCh:oo:se:an:ad:dr \
>    -net bridge,br=3Dbr0 \
>=20
> then the client can
>   mount [fe80::1%interfacename]:/path /mountpoint
>=20
> and the host will see a connection from
>    fe80::ch:oo:se:an:ad:dr
>=20
> So from the guest side, I have achieved zero-config NFS mounts from the
> host.

It is not zero-configuration since [fe80::1%interfacename] contains a
variable, "interfacename", whose value is unknown ahead of time.  This
will make documentation as well as ability to share configuration
between VMs more difficult.  In other words, we're back to something
that requires per-guest configuration and doesn't just work everywhere.

> I don't think the server can filter connections based on which interface
> a link-local address came from.  If that was a problem that someone
> wanted to be fixed, I'm sure we can fix it.
>=20
> If you need to be sure that clients don't fake their IPv6 address, I'm
> sure netfilter is up to the task.

Yes, it's common to prevent spoofing on the host using netfilter and I
think it wouldn't be a problem.

>  . Creates network interfaces on host that must be managed
>=20
> What vsock does is effectively create a hidden interface on the host that=
 only the
> kernel knows about and so the sysadmin cannot break it.  The only
> difference between this and an explicit interface on the host is that
> the latter requires a competent sysadmin.
>=20
> If you have other reasons for preferring the use of vsock for NFS, I'd be
> happy to hear them.  So far I'm not convinced.

Before working on AF_VSOCK I originally proposed adding dedicated
network interfaces to guests, similar to what you've suggested, but
there was resistance for additional reasons that weren't covered in the
presentation:

Using AF_INET exposes the host's network stack to guests, and through
accidental misconfiguration even external traffic could reach the host's
network stack.  AF_VSOCK doesn't do routing or forwarding so we can be
sure that any activity is intentional.

Some virtualization use cases run guests without any network interfaces
as a matter of security policy.  One could argue that AF_VSOCK is just
another network channel, but due to it's restricted usage, the attack
surface is much smaller than an AF_INET network interface.

--huq684BweRXVnRxX
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZdxfZAAoJEJykq7OBq3PIPuoH/19NeBQ8Gjfg6y0tqcgojovP
xpQCbyaCGK/TqTzV+E6D+1bt7i5IZh0HtKxNLTzFFrucHZ0ON2t5zzwGJahvE1YI
dHvaM15oOrtw50pPeyORnjm5TsmDe89p4lUXB+cfP8UNxVs3rsk3fP6BEGrQKi4O
EW076mEAhhyJpXwz9PQfK7yq82fxHYipN0bbABbezFn89M6ayZzXDIe7QdAxobjd
/t27sm8W5huVzj37uorDud4mwATA3qLIK2wX9dsHqQLcctN7xF/o8PkKzaVxLBtd
+N/0J7fP4WV6bKgaVrR+k/mCdnzjCjGeieJaBjqmSjldaSLHvkJE/VRrENSC51Q=
=IVHF
-----END PGP SIGNATURE-----

--huq684BweRXVnRxX--
