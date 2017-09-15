Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53570 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751213AbdIOX3w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Sep 2017 19:29:52 -0400
From: NeilBrown <neilb@suse.com>
To: "J . Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>
Date: Sat, 16 Sep 2017 09:29:38 +1000
Cc: Stefan Hajnoczi <stefanha@redhat.com>, linux-nfs@vger.kernel.org,
        Matt Benjamin <mbenjami@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <SteveD@RedHat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
In-Reply-To: <20170915151755.GD23557@fieldses.org>
References: <20170913102650.10377-1-stefanha@redhat.com> <9adfce4d-dbd7-55a9-eb73-7389dbf900ac@RedHat.com> <0a5452ff-6cb9-4336-779b-ae65cfe156b8@RedHat.com> <20170914173730.GD4673@fieldses.org> <1505473626.4781.9.camel@redhat.com> <20170915151755.GD23557@fieldses.org>
Message-ID: <874ls38rrx.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 15 2017, J . Bruce Fields wrote:

> On Fri, Sep 15, 2017 at 07:07:06AM -0400, Jeff Layton wrote:
>> On Thu, 2017-09-14 at 13:37 -0400, J . Bruce Fields wrote:
>> > On Thu, Sep 14, 2017 at 11:55:51AM -0400, Steve Dickson wrote:
>> > >=20
>> > >=20
>> > > On 09/14/2017 11:39 AM, Steve Dickson wrote:
>> > > > Hello
>> > > >=20
>> > > > On 09/13/2017 06:26 AM, Stefan Hajnoczi wrote:
>> > > > > v3:
>> > > > >  * Documented vsock syntax in exports.man, nfs.man, and nfsd.man
>> > > > >  * Added clientaddr autodetection in mount.nfs(8)
>> > > > >  * Replaced #ifdefs with a single vsock.h header file
>> > > > >  * Tested nfsd serving both IPv4 and vsock at the same time
>> > > >=20
>> > > > Just curious as to the status of the kernel patches... Are
>> > > > they slated for any particular release?
>> > >=20
>> > > Maybe I should have read the thread before replying ;-)=20
>> > >=20
>> > > I now see the status of the patches... not good!  8-)
>> >=20
>> > To be specific, the code itself is probably fine, it's just that nobody
>> > on the NFS side seems convinced that NFS/VSOCK is necessary.
>> >=20
>>=20
>> ...and to be even more clear, the problem you've outlined (having a zero
>> config network between an HV and guest) is a valid one. The issue here
>> is that the solution in these patches is horribly invasive and will
>> create an ongoing maintenance burden.
>>=20
>> What would be much cleaner (IMNSHO) is a new type of virtual network
>> interface driver that has similar communication characteristics (only
>> allowing HV<->guest communication) and that autoconfigures itself when
>> plugged in (or only does so with minimal setup).
>>=20
>> Then you could achieve the same result without having to completely
>> rework all of this code. That's also something potentially backportable
>> to earlier kernels, which is a nice bonus.
>
> We're talking about NFS/VSOCK here, but everything you've said would
> apply to any protocol over VSOCK.
>
> And yet, we have VSOCK.  So I still feel like we must be missing
> some perspective.

Being in the kernel doesn't prove much.  devfs was in the kernel, so was
the tux http service.  configfs is still in the kernel ! :-)

Possibly some perspective is missing.  A charitable reading of the
situation is that the proponents of VSOCK aren't very good at
communicating their requirements and vision.  A less charitable
interpretation is that they have too much invested in VSOCK to be able
to conceive an alternative.

The thing we hear about is "zero-conf" and that is obviously a good
idea, but can be done without VSOCK.  What we hear less about is
"fool-proof" which is hard to define and hard to sell, yet it seems to
be an important part of their agenda.

>
> I wonder if part of the problem is that we're imagining that the typical
> VM has a sysadmin.  Isn't it more likely that you build the VM
> automatically from some root image that you don't even maintain
> yourself?  So fixing it to not, say, block all network traffic on every
> interface, isn't something you can automate--you've no idea where the
> iptables configuration lives in the image.

You are describing a situation where someone builds an important part of
their infrastructure from something they don't understand and cannot
maintain.  Obviously that happens, but when it does I would expect there
to be someone who does understand.  A vendor or support organization
probably.  If the end result doesn't fit the customer's needs, then that
creates a market opportunity for someone to fill.

It does seem that the unpredictability of network filtering is part of
the goal of VSOCK, though creating a new network path that cannot be
filtered doesn't seem to me like the cleverest idea in the long term.
There seems to be more though.  There was a suggestion that some people
don't want any network interface at all (but still want to use a
networked file system).  This sounds like superstition, but was not
backed up with data so I cannot be sure.

It does seem justifiable to want a simple and reliable way to ensure
that traffic from the NFS client to the host is not filtered.  My
feeling is that talking to network/firewall people is the best way to
achieve that.  The approach that has been taken looks like an end-run
around exactly the people who are in the best position to help.

How do network namespaces work?  Does each namespace get separate
iptables?  Could we perform an NFS mount in an unfiltered namespace,
then make everything else run with filters in place?

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlm8YmQACgkQOeye3VZi
gbnG8A/9ESxXl3vUhdViJMGya8cWLgqVNhAejrZ7zfH7fCYQjFmN5sZhXjgkwQR8
TGHAAHFnezlNZQMXGoyO9hMX0N4Nkkvj0ztrpxbkFfIMNWg76LoH9d1Uq1b2dD0F
P0oX8wZGbuusDPlzD2aDMPbpdO5UQ+BtFLh4/N2vpIEZ20GdZN2+TunYh7tIz1Bu
Re2yu4+cSIiFPQxO3j80OwXWR9fYvAQcrQ4JtdBb4gnxDZ3chjv7GEkIsPSEcb5G
NfzFed98ODK8RsaHGCqt1He9C9Fv2GTcRoA4eBTWl+WwHEkuD5RTTsGMWe0tzoaA
B0PXbGScN9Mlcs7WivOB6F8agAcRCaTj55xurRkLyl0aLzMJzq/SgTyzSD5z5uek
ooSLwgVT26/FlDF4/b/oUZ8Ig44qTOSjFVtjrbrRtsTmU8tY6LDaQthpr3ktUnJQ
0g/KXnLwyu1igyOvP5Qjha8gi9d1XIX/xMx3t8vdOyoFLGC6bWr6Y8mRZTdC7RC8
6mswsYOrZWZZbeLie7uI7h8G/zVgRG0InJWOSkFp8koUmBxqW11sejtyPiuAiC1f
oN+B+a5m6+/4h4eMspzGbbyoY49+3YvvGueQR2mJOzGpqIu1SFedzOhdoJ42aeW2
4wn2nv3n6rYhLDsSlFlEQHsiQKtd01cERAHwnhTB9X2yK18QqBI=
=+7X2
-----END PGP SIGNATURE-----
--=-=-=--
