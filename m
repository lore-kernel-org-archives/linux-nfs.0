Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39079 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751158AbdHCPYr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Aug 2017 11:24:47 -0400
Date: Thu, 3 Aug 2017 16:24:46 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
Message-ID: <20170803152446.GA24890@stefanha-x1.localdomain>
References: <20170630132120.31578-1-stefanha@redhat.com>
 <20170630132120.31578-6-stefanha@redhat.com>
 <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com>
 <87wp7lvst9.fsf@notabene.neil.brown.name>
 <87tw2ox4st.fsf@notabene.neil.brown.name>
 <20170725100513.GA5073@stefanha-x1.localdomain>
 <87eft2wjfy.fsf@notabene.neil.brown.name>
 <20170727105835.GF10129@stefanha-x1.localdomain>
 <8760edwk4l.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="u3/rZRmxL6MmkK24"
In-Reply-To: <8760edwk4l.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 28, 2017 at 09:11:22AM +1000, NeilBrown wrote:
> On Thu, Jul 27 2017, Stefan Hajnoczi wrote:
> > On Thu, Jul 27, 2017 at 03:13:53PM +1000, NeilBrown wrote:
> >> On Tue, Jul 25 2017, Stefan Hajnoczi wrote:
> >> > On Fri, Jul 07, 2017 at 02:13:38PM +1000, NeilBrown wrote:
> >> >> On Fri, Jul 07 2017, NeilBrown wrote:
> >> >> > On Fri, Jun 30 2017, Chuck Lever wrote:
> >> To achieve zero-config, I think link-local addresses are by far the be=
st
> >> answer.  To achieve isolation, some targeted filtering seems like the
> >> best approach.
> >>=20
> >> If you really want traffic between guest and host to go over a vsock,
> >> then some sort of packet redirection should be possible.
> >
> > The issue we seem to hit with designs using AF_INET and network
> > interfaces is that they cannot meet the "it must avoid invasive
> > configuration changes, especially inside the guest" requirement.  It's
> > very hard to autoconfigure in a way that doesn't conflict with the
> > user's network configuration inside the guest.
> >
> > One thought about solving the interface naming problem: if the dedicated
> > NIC uses a well-known OUI dedicated for this purpose then udev could
> > assign a persistent name (e.g. "virtguestif").  This gets us one step
> > closer to non-invasive automatic configuration.
>=20
> I think this is well worth pursuing.  As you say, an OUI allows the
> guest to reliably detect the right interface to use a link-local address
> on.

IPv6 link-local addressing with a well-known MAC address range solves
address collisions.  The presence of a network interface still has the
following issues:

1. Network management tools (e.g. NetworkManager) inside the guest
   detect the interface and may auto-configure it (e.g. DHCP).  Guest
   administrators are confronted with a new interface - this opens up
   the possibility that they change its configuration.

2. Default drop firewall policies conflict with the interface.  The
   guest administrator would have to manually configure exceptions for
   their firewall.

3. udev is a Linux-only solution and other OSes do not offer a
   configurable interface naming scheme.  Manual configuration would
   be required.

I still see these as blockers preventing guest<->host file system
sharing.  Users can already manually add a NIC and configure NFS today,
but the goal here is to offer this as a feature that works in an
automated way (useful both for GUI-style virtual machine management and
for OpenStack clouds where guest configuration must be simple and
scale).

In contrast, AF_VSOCK works as long as the driver is loaded.  There is
no configuration.

The changes required to Linux and nfs-utils are related to the sunrpc
transport and configuration.  They do not introduce risks to core NFS or
TCP/IP.  I would really like to get patches merged because I currently
have to direct interested users to building Linux and nfs-utils from
source to try this out.

Stefan

--u3/rZRmxL6MmkK24
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZg0A+AAoJEJykq7OBq3PIJ5sIALpVz9NzQZxF9voSE/PGsEU1
ZmG7jRK5R2sGiQq/uvR3TLexQOxhzuCsiY9DFY3J9CipWX+RIJ1YA7BG/r1Lapv/
DlYhhZ9qSavZ4M8mZJyjdd/hMvoGXr3zc24hf4n8kds5zfJGVpe5yYHFeUSj4csh
nKzKuVvvMIvbsVGHKJZPURiHs0QvZ4JmjIt7g67HeBEnVlY7OuHfXvQiouoM/I2J
rgjThb9jSgJlQFYeuET5U94imAcZ9YBSo8iiOyCzyZGxCl0UWJgqPu/v7AB4JMAj
ltXR1y/86OMt5TS3iRKn9zvJNYDnhQ5N5bRo/m6pK29/ixnWCUCAcVvjzTJghhI=
=QEpx
-----END PGP SIGNATURE-----

--u3/rZRmxL6MmkK24--
