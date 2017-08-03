Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47865 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751958AbdHCVpe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Aug 2017 17:45:34 -0400
From: NeilBrown <neilb@suse.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Date: Fri, 04 Aug 2017 07:45:22 +1000
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
In-Reply-To: <20170803152446.GA24890@stefanha-x1.localdomain>
References: <20170630132120.31578-1-stefanha@redhat.com> <20170630132120.31578-6-stefanha@redhat.com> <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com> <87wp7lvst9.fsf@notabene.neil.brown.name> <87tw2ox4st.fsf@notabene.neil.brown.name> <20170725100513.GA5073@stefanha-x1.localdomain> <87eft2wjfy.fsf@notabene.neil.brown.name> <20170727105835.GF10129@stefanha-x1.localdomain> <8760edwk4l.fsf@notabene.neil.brown.name> <20170803152446.GA24890@stefanha-x1.localdomain>
Message-ID: <87tw1otjf1.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 03 2017, Stefan Hajnoczi wrote:

> On Fri, Jul 28, 2017 at 09:11:22AM +1000, NeilBrown wrote:
>> On Thu, Jul 27 2017, Stefan Hajnoczi wrote:
>> > On Thu, Jul 27, 2017 at 03:13:53PM +1000, NeilBrown wrote:
>> >> On Tue, Jul 25 2017, Stefan Hajnoczi wrote:
>> >> > On Fri, Jul 07, 2017 at 02:13:38PM +1000, NeilBrown wrote:
>> >> >> On Fri, Jul 07 2017, NeilBrown wrote:
>> >> >> > On Fri, Jun 30 2017, Chuck Lever wrote:
>> >> To achieve zero-config, I think link-local addresses are by far the b=
est
>> >> answer.  To achieve isolation, some targeted filtering seems like the
>> >> best approach.
>> >>=20
>> >> If you really want traffic between guest and host to go over a vsock,
>> >> then some sort of packet redirection should be possible.
>> >
>> > The issue we seem to hit with designs using AF_INET and network
>> > interfaces is that they cannot meet the "it must avoid invasive
>> > configuration changes, especially inside the guest" requirement.  It's
>> > very hard to autoconfigure in a way that doesn't conflict with the
>> > user's network configuration inside the guest.
>> >
>> > One thought about solving the interface naming problem: if the dedicat=
ed
>> > NIC uses a well-known OUI dedicated for this purpose then udev could
>> > assign a persistent name (e.g. "virtguestif").  This gets us one step
>> > closer to non-invasive automatic configuration.
>>=20
>> I think this is well worth pursuing.  As you say, an OUI allows the
>> guest to reliably detect the right interface to use a link-local address
>> on.
>
> IPv6 link-local addressing with a well-known MAC address range solves
> address collisions.  The presence of a network interface still has the
> following issues:
>
> 1. Network management tools (e.g. NetworkManager) inside the guest
>    detect the interface and may auto-configure it (e.g. DHCP).

Why would this matter?  Auto-configuring may add addresses to the
interface, but will not remove the link-local address.

>                                                                 Guest
>    administrators are confronted with a new interface - this opens up
>    the possibility that they change its configuration.

True, the admin might delete the link-local address themselves.  They
might also delete /sbin/mount.nfs.  Maybe they could even "rm -rf /".
A rogue admin can always shoot themselves in the foot.  Trying to
prevent this is pointless.

>
> 2. Default drop firewall policies conflict with the interface.  The
>    guest administrator would have to manually configure exceptions for
>    their firewall.

This gets back to my original point.  You are willing to stick
required-configuration in the kernel and in nfs-utils, but you are not
willing to require some fixed configuration which actually addresses
your problem.  If you want an easy way to punch a firewall hole for a
particular port on a particular interface, then resolve that by talking
with people who understand firewalls.  Not by creating a new protocol
which cannot be firewalled.

>
> 3. udev is a Linux-only solution and other OSes do not offer a
>    configurable interface naming scheme.  Manual configuration would
>    be required.

Not my problem.
If some other OS is lacking important functionality, you do fix it by
adding rubbish to Linux.  You fix it by fixing those OSes.
For example, is Linux didn't have udev or anything like it, I might be
open to enhancing mount.nfs so that an address syntax like:
  fe80::1%*:xx:yy:xx:*
would mean the that glob pattern should be matched again the MAC address
of each interface and the first such interface used.  This would be a
focused change addressed at fixing a specific issue.  I might not
actually like it, but if it was the best/simplest mechanism to achieve
the goal, I doubt I would fight it.  Fortunately I don't need decide
as we already have udev.
If some of OS doesn't have a way to find the interface for a particular
MAC address, maybe you need to create one.

>
> I still see these as blockers preventing guest<->host file system
> sharing.  Users can already manually add a NIC and configure NFS today,
> but the goal here is to offer this as a feature that works in an
> automated way (useful both for GUI-style virtual machine management and
> for OpenStack clouds where guest configuration must be simple and
> scale).
>
> In contrast, AF_VSOCK works as long as the driver is loaded.  There is
> no configuration.

I think we all agree that providing something that "just works" is a
worth goal.  In only question is about how much new code can be
justified, and where it should be put.

Given that almost everything you need already exists, it seems best to
just tie those pieces together.

NeilBrown


>
> The changes required to Linux and nfs-utils are related to the sunrpc
> transport and configuration.  They do not introduce risks to core NFS or
> TCP/IP.  I would really like to get patches merged because I currently
> have to direct interested users to building Linux and nfs-utils from
> source to try this out.
>
> Stefan

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmDmXQACgkQOeye3VZi
gbnZ1hAAhpXByvjArf0rdKcBVBoBAcAIysZhjphxtl5cyIHMxGwoUNdFXEf7mZLY
5VT/0ZbwFQm4oP31H/4SbMUjtyth9xuW+Tlh87pA0/CVxP1IhHrIsaoLpioA9Ae9
24x2XdSRI1Qq0eGgOIvRVHbiPpzfZj3rp/bvQa8vsynL7i8XjD0+YXxeJQlUl6pw
Tv1ntMnqT2LoAHkgIzucoNUYDofFmAMSkQSkX6f0sWabMweolLaGHf7MkSy1QX1o
3tok+nTIAn6i3y6DtL7hZYKP8mKEAr3Ik7ww94KI56Ab3x0h0Oh+FWh/ISpoSHeT
27SuGjRNTHgMsqTzd5AuNT9LI0yc7zfVfrqjiBr2iDMR7wHLHmDyjooBsZvXPxza
EygrZOVkY+BJ3WhvNW+DWZWbElPWppd/wfz/NhZZsJH+44RVbp6jQdcdjyVuipvr
/sn9aAxZ6E2d507Zo44RPm/eqTR9XbcSvyUhutInWmQoG6CWOIU19PubMUr6CSuh
1NQQ0qCclbuky4iYTdXpnQz32ZRT/FqAz8+TIABr1waKdOi2fmzyoYE7tsxlXEzQ
FUDqSz0bPF+qAsznQOPpOWihb5tdiJ+X1CUW9AY0+2tHgS0EDnUgAMts4zLkd96t
nH0SfX8/VpGKzgduQEZ9s4Q8p0aq9RTcTykXbNX4qzoHqTTmgjE=
=e77/
-----END PGP SIGNATURE-----
--=-=-=--
