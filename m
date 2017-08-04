Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59610 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752177AbdHDP47 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 4 Aug 2017 11:56:59 -0400
Date: Fri, 4 Aug 2017 16:56:57 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
Message-ID: <20170804155657.GH14565@stefanha-x1.localdomain>
References: <20170630132120.31578-6-stefanha@redhat.com>
 <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com>
 <87wp7lvst9.fsf@notabene.neil.brown.name>
 <87tw2ox4st.fsf@notabene.neil.brown.name>
 <20170725100513.GA5073@stefanha-x1.localdomain>
 <87eft2wjfy.fsf@notabene.neil.brown.name>
 <20170727105835.GF10129@stefanha-x1.localdomain>
 <8760edwk4l.fsf@notabene.neil.brown.name>
 <20170803152446.GA24890@stefanha-x1.localdomain>
 <87tw1otjf1.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="vtJ+CqYNzKB4ukR4"
In-Reply-To: <87tw1otjf1.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--vtJ+CqYNzKB4ukR4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 04, 2017 at 07:45:22AM +1000, NeilBrown wrote:
> On Thu, Aug 03 2017, Stefan Hajnoczi wrote:
> > On Fri, Jul 28, 2017 at 09:11:22AM +1000, NeilBrown wrote:
> >> On Thu, Jul 27 2017, Stefan Hajnoczi wrote:
> >> > On Thu, Jul 27, 2017 at 03:13:53PM +1000, NeilBrown wrote:
> >> >> On Tue, Jul 25 2017, Stefan Hajnoczi wrote:
> >> >> > On Fri, Jul 07, 2017 at 02:13:38PM +1000, NeilBrown wrote:
> >> >> >> On Fri, Jul 07 2017, NeilBrown wrote:
> >> >> >> > On Fri, Jun 30 2017, Chuck Lever wrote:
> > I still see these as blockers preventing guest<->host file system
> > sharing.  Users can already manually add a NIC and configure NFS today,
> > but the goal here is to offer this as a feature that works in an
> > automated way (useful both for GUI-style virtual machine management and
> > for OpenStack clouds where guest configuration must be simple and
> > scale).
> >
> > In contrast, AF_VSOCK works as long as the driver is loaded.  There is
> > no configuration.
>=20
> I think we all agree that providing something that "just works" is a
> worth goal.  In only question is about how much new code can be
> justified, and where it should be put.
>=20
> Given that almost everything you need already exists, it seems best to
> just tie those pieces together.

Neil,
You said downthread you're losing interest but there's a point that I
hope you have time to consider because it's key:

Even if the NFS transport can be set up automatically without
conflicting with the user's system configuration, it needs to stay
available going forward.  A network interface is prone to user
configuration changes through network management tools, firewalls, and
other utilities.  The risk of it breakage is significant.

That's not really a technical problem - it will be caused by some user
action - but using the existing Linux AF_VSOCK feature that whole class
of issues can be eliminated.

Stefan

--vtJ+CqYNzKB4ukR4
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZhJlJAAoJEJykq7OBq3PIK/UH/1BdvSNXfzl5gbRvhFSzU/V0
DshXEwIp2jcpHanGTKCw+J9bKr6odYQNrVqWRRIGHFCUZhM5jg5cX2ppJw0KCNCB
9wsa3hH3RqQ76wJU6kD6avm/LtqWCQWhx/ZOPHNAS72mmHLIktcP8GZxwnaPiLOx
1mqbZZ+AFJ8PA64Go8po2roF2DmWnQzmp7yYRETz08HJwQ4n7Ljwi94x7+5AoFVL
iaps3K+tIESFgxmGD+w69I05JLq7xJsTZQFyrTgyOKI0Z8gPKfnHTReFc8eNcvjj
5LzQXSTqHJdGc9KNB0TDxk5wZgfkTe10DAKeETfe9+TJXkpKWjjvJqko0iYUxxA=
=ZJ/T
-----END PGP SIGNATURE-----

--vtJ+CqYNzKB4ukR4--
