Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59341 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752253AbdHDWgD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 4 Aug 2017 18:36:03 -0400
From: NeilBrown <neilb@suse.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Date: Sat, 05 Aug 2017 08:35:52 +1000
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
In-Reply-To: <20170804155657.GH14565@stefanha-x1.localdomain>
References: <20170630132120.31578-6-stefanha@redhat.com> <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com> <87wp7lvst9.fsf@notabene.neil.brown.name> <87tw2ox4st.fsf@notabene.neil.brown.name> <20170725100513.GA5073@stefanha-x1.localdomain> <87eft2wjfy.fsf@notabene.neil.brown.name> <20170727105835.GF10129@stefanha-x1.localdomain> <8760edwk4l.fsf@notabene.neil.brown.name> <20170803152446.GA24890@stefanha-x1.localdomain> <87tw1otjf1.fsf@notabene.neil.brown.name> <20170804155657.GH14565@stefanha-x1.localdomain>
Message-ID: <87d18bt0zb.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 04 2017, Stefan Hajnoczi wrote:

> On Fri, Aug 04, 2017 at 07:45:22AM +1000, NeilBrown wrote:
>> On Thu, Aug 03 2017, Stefan Hajnoczi wrote:
>> > On Fri, Jul 28, 2017 at 09:11:22AM +1000, NeilBrown wrote:
>> >> On Thu, Jul 27 2017, Stefan Hajnoczi wrote:
>> >> > On Thu, Jul 27, 2017 at 03:13:53PM +1000, NeilBrown wrote:
>> >> >> On Tue, Jul 25 2017, Stefan Hajnoczi wrote:
>> >> >> > On Fri, Jul 07, 2017 at 02:13:38PM +1000, NeilBrown wrote:
>> >> >> >> On Fri, Jul 07 2017, NeilBrown wrote:
>> >> >> >> > On Fri, Jun 30 2017, Chuck Lever wrote:
>> > I still see these as blockers preventing guest<->host file system
>> > sharing.  Users can already manually add a NIC and configure NFS today,
>> > but the goal here is to offer this as a feature that works in an
>> > automated way (useful both for GUI-style virtual machine management and
>> > for OpenStack clouds where guest configuration must be simple and
>> > scale).
>> >
>> > In contrast, AF_VSOCK works as long as the driver is loaded.  There is
>> > no configuration.
>>=20
>> I think we all agree that providing something that "just works" is a
>> worth goal.  In only question is about how much new code can be
>> justified, and where it should be put.
>>=20
>> Given that almost everything you need already exists, it seems best to
>> just tie those pieces together.
>
> Neil,
> You said downthread you're losing interest but there's a point that I
> hope you have time to consider because it's key:
>
> Even if the NFS transport can be set up automatically without
> conflicting with the user's system configuration, it needs to stay
> available going forward.  A network interface is prone to user
> configuration changes through network management tools, firewalls, and
> other utilities.  The risk of it breakage is significant.

I've already addressed this issue.  I wrote:

	  True, the admin might delete the link-local address themselves.  They
	  might also delete /sbin/mount.nfs.  Maybe they could even "rm -rf /".
	  A rogue admin can always shoot themselves in the foot.  Trying to
	  prevent this is pointless.


>
> That's not really a technical problem - it will be caused by some user
> action - but using the existing Linux AF_VSOCK feature that whole class
> of issues can be eliminated.

I suggest you look up the proverb about making things fool-proof and
learn to apply it.

Meanwhile I have another issue.  Is it possible for tcpdump, or some
other tool, to capture all the packets flowing over a vsock?  If it
isn't possible to analyse the traffic with wireshark, it will be much
harder to diagnose issues that customers have.

NeilBrown


>
> Stefan

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmE9soACgkQOeye3VZi
gbnlHA/+LoNeOpY6WeOBmwppucTWk/spLjgDfB1feUjlMiwbKd3ckp+1RgxUu2qZ
PBDR+UbdaM7Ti333R6cKrlZnGxQiBLYoWGaZyBLP6wnhwFLMSf5wI3/w+1u+yGJ7
xqHFa9s12WPLTfqJnKt4p+lh876Bp4MGic3hc8ceMRv6nMoWum7rfUzIl6NdKVz+
3iKC0XA4Lr5FbuXbVyk+dWIaFwTqIv+lAJPNQ23k8K75BHVm2oir/ciVqV+Bv4D0
0dBPi6505Nx8/9yYGrx/feJUw28qR8Ep+slFBAJM7xRNf+vOc7UCFQ+ZVwoA2uM/
TQxEbVC/wtJXfRoUYICX2IdKvv1SZ3K04e6LS3cuhJtYsLjSM6pAEFg/nwyrgBal
Ow1M0pdYbMvn2rJm/7H6HKXmyjDv4+rdTZcF9U+NIKUUL05bG2fxuRAr0QcgSlFJ
vNfl87Lh/noR51B0LjdzDyEJGp5qe7lNAeOW/yIs2XvFJKaYJlEkVZ6n2+RrlVeD
JY3e+ChYCv01x7rkgGBUNNS8KxLF/+zqxaKnOdD0+YVqkv1L0APW12BIerdJqHMc
lXRBNCmL/IAp5Ctd+PacoyxgrLLOQz1fYANmjtJ3CdDr1RzY1xJQj8RlxqsWW0DO
HCzzsMSFinWnH4eRS6wCSyckC89EhuUqP926+wc6DTM9QSQXk7M=
=hme/
-----END PGP SIGNATURE-----
--=-=-=--
