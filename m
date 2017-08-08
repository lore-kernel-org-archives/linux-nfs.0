Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37354 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752104AbdHHOHm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 8 Aug 2017 10:07:42 -0400
Date: Tue, 8 Aug 2017 15:07:38 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
Message-ID: <20170808140738.GQ16801@stefanha-x1.localdomain>
References: <87wp7lvst9.fsf@notabene.neil.brown.name>
 <87tw2ox4st.fsf@notabene.neil.brown.name>
 <20170725100513.GA5073@stefanha-x1.localdomain>
 <87eft2wjfy.fsf@notabene.neil.brown.name>
 <20170727105835.GF10129@stefanha-x1.localdomain>
 <8760edwk4l.fsf@notabene.neil.brown.name>
 <20170803152446.GA24890@stefanha-x1.localdomain>
 <87tw1otjf1.fsf@notabene.neil.brown.name>
 <20170804155657.GH14565@stefanha-x1.localdomain>
 <87d18bt0zb.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="pwWdILMQNxDD/Cps"
In-Reply-To: <87d18bt0zb.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--pwWdILMQNxDD/Cps
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Aug 05, 2017 at 08:35:52AM +1000, NeilBrown wrote:
> On Fri, Aug 04 2017, Stefan Hajnoczi wrote:
>=20
> > On Fri, Aug 04, 2017 at 07:45:22AM +1000, NeilBrown wrote:
> >> On Thu, Aug 03 2017, Stefan Hajnoczi wrote:
> >> > On Fri, Jul 28, 2017 at 09:11:22AM +1000, NeilBrown wrote:
> >> >> On Thu, Jul 27 2017, Stefan Hajnoczi wrote:
> >> >> > On Thu, Jul 27, 2017 at 03:13:53PM +1000, NeilBrown wrote:
> >> >> >> On Tue, Jul 25 2017, Stefan Hajnoczi wrote:
> >> >> >> > On Fri, Jul 07, 2017 at 02:13:38PM +1000, NeilBrown wrote:
> >> >> >> >> On Fri, Jul 07 2017, NeilBrown wrote:
> >> >> >> >> > On Fri, Jun 30 2017, Chuck Lever wrote:
> >> > I still see these as blockers preventing guest<->host file system
> >> > sharing.  Users can already manually add a NIC and configure NFS tod=
ay,
> >> > but the goal here is to offer this as a feature that works in an
> >> > automated way (useful both for GUI-style virtual machine management =
and
> >> > for OpenStack clouds where guest configuration must be simple and
> >> > scale).
> >> >
> >> > In contrast, AF_VSOCK works as long as the driver is loaded.  There =
is
> >> > no configuration.
> >>=20
> >> I think we all agree that providing something that "just works" is a
> >> worth goal.  In only question is about how much new code can be
> >> justified, and where it should be put.
> >>=20
> >> Given that almost everything you need already exists, it seems best to
> >> just tie those pieces together.
> >
> > Neil,
> > You said downthread you're losing interest but there's a point that I
> > hope you have time to consider because it's key:
> >
> > Even if the NFS transport can be set up automatically without
> > conflicting with the user's system configuration, it needs to stay
> > available going forward.  A network interface is prone to user
> > configuration changes through network management tools, firewalls, and
> > other utilities.  The risk of it breakage is significant.
>=20
> I've already addressed this issue.  I wrote:
>=20
> 	  True, the admin might delete the link-local address themselves.  They
> 	  might also delete /sbin/mount.nfs.  Maybe they could even "rm -rf /".
> 	  A rogue admin can always shoot themselves in the foot.  Trying to
> 	  prevent this is pointless.

These are not things that I'm worried about.  I agree that it's
pointless trying to prevent them.

The issue is genuine configuration changes either by the user or by
software they are running that simply interfere with the host<->guest
interface.  For example, a default DROP iptables policy.

> Meanwhile I have another issue.  Is it possible for tcpdump, or some
> other tool, to capture all the packets flowing over a vsock?  If it
> isn't possible to analyse the traffic with wireshark, it will be much
> harder to diagnose issues that customers have.

Yes, packet capture is possible.  The vsockmon driver was added in Linux
4.11.  Wireshark has a dissector for AF_VSOCK.

Stefan

--pwWdILMQNxDD/Cps
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZicWqAAoJEJykq7OBq3PIsgQIAL8WfVYUF1B02UJ55foL5z5D
J+UpkHs+mfqvKurRhbJelpoaJ5ygMKEEPXvBUx8l2JFNtSKjGLjfFlYiU2+7nkwg
PYFoCNbxbcA4reKofvmqziSq7RosvjZO0gf8nLeRstiVRUbljJL7NpLsxb8ra+sU
cFyjtNsKJujebzEef7UEXcqNk5E8Kkk70FMHSJOkjY0NV5qXd9snboMcRoJ9ukuq
Wwe3yc2NSNznvfx+JD3PLuyIaaMf3ypwiyauDPI8dkcxjufQLcouRUvghE9YWUOU
iMb5TBq1uFcYydc0csflpTuzPA7DzSBONzWsbvtlIAIaXLySemzhbbggiuFYGvI=
=MJJ6
-----END PGP SIGNATURE-----

--pwWdILMQNxDD/Cps--
