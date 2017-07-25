Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47916 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751730AbdGYM3f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Jul 2017 08:29:35 -0400
Date: Tue, 25 Jul 2017 13:29:33 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
Message-ID: <20170725122933.GB5073@stefanha-x1.localdomain>
References: <20170630132120.31578-1-stefanha@redhat.com>
 <20170630132120.31578-6-stefanha@redhat.com>
 <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com>
 <87wp7lvst9.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="XOIedfhf+7KOe/yw"
In-Reply-To: <87wp7lvst9.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--XOIedfhf+7KOe/yw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 07, 2017 at 01:17:54PM +1000, NeilBrown wrote:
> On Fri, Jun 30 2017, Chuck Lever wrote:
> >
> > Wouldn't it be nicer if it worked like this:
> >
> > (guest)$ cat /etc/hosts
> > 129.0.0.2  localhyper
> > (guest)$ mount.nfs localhyper:/export /mnt
> >
> > And the result was a working NFS mount of the
> > local hypervisor, using whatever NFS version the
> > two both support, with no changes needed to the
> > NFS implementation or the understanding of the
> > system administrator?
>=20
> Yes. Yes. Definitely Yes.
> Though I suspect you mean "127.0.0.2", not "129..."??
>=20
> There must be some way to redirect TCP connections to some address
> transparently through to the vsock protocol.
> The "sshuttle" program does this to transparently forward TCP connections
> over an ssh connection.  Using a similar technique to forward
> connections over vsock shouldn't be hard.

Thanks for the sshuttle reference.  I've taken a look at it and the
underlying iptables extensions.

sshuttle does not have the ability to accept incoming connections but
that can be achieved by adding the IP to the loopback device.

Here is how bi-directional TCP connections can be tunnelled without
network interfaces:

  host           <-> vsock transport <-> guest
  129.0.0.2 (lo)                         129.0.0.2 (lo)
  129.0.0.3 (lo)                         129.0.0.3 (lo)

iptables REDIRECT is used to catch 129.0.0.2->.3 connections on the host
and 129.0.0.3->.2 connections in the guest.  A "connect" command is then
sent across the tunnel to establish a new TCP connection on the other
side.

Note that this isn't NAT since both sides see the correct IP addresses.

Unlike using a network interface (even tun/tap) this tunnelling approach
is restricted to TCP connections.  It doesn't have UDP, etc.

Issues:

1. Adding IPs to dev lo has side effects.  For example, firewall rules
   on dev lo will affect the traffic.  This alone probably prevents the
   approach from working without conflicts on existing guests.

2. Is there a safe address range to use?  Using IPv6 link-local
   addresses as suggested in this thread might work, especially when
   using an OUI so we can be sure there are no address collisions.

3. Performance has already been mentioned since a userspace process
   tunnels from loopback TCP to the vsock transport.  splice(2) can
   probably be used.

Stefan

--XOIedfhf+7KOe/yw
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZdzmtAAoJEJykq7OBq3PI9t4IAIamC+2KBid1zAZ6QOPKctWY
Uave3TSl/tTReu4LrLQ0InujDEQLkyAZ0I8o3gJAGTbkKk1u4u226X6d4AhS0ev1
VwWF+kP2SEQxIK2ypOJ/CISJRok7/5IawjcuERcKzmHULodg4GIsy5ixeyR8Cs72
ackxsI9vG0aH6x+o/hqo5sADCHZ7ZCafBXU4jWdFeq4HFpzwkparHxwM54PWh3Ib
rwrc8FmOnfRU0BUeIkykoat7lxapBIL2PTw9SYgYgiTJCYfx//sAJ1I6lIQh2cq5
NdZcrfILFjsPRz4N7lfbfuOsWQ+e22BvA44wV6j4JV7fhO6/EbQCQrWtaDPwHmg=
=M3Fm
-----END PGP SIGNATURE-----

--XOIedfhf+7KOe/yw--
