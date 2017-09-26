Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47874 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934681AbdIZCIT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Sep 2017 22:08:19 -0400
From: NeilBrown <neilb@suse.com>
To: "Daniel P. Berrange" <berrange@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>
Date: Tue, 26 Sep 2017 12:08:07 +1000
Cc: Steven Whitehouse <swhiteho@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        Justin Mitchell <jumitche@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
In-Reply-To: <20170922115524.GN12725@redhat.com>
References: <20170918180927.GD12759@stefanha-x1.localdomain> <20170919093140.GF9536@redhat.com> <67608054-B771-44F4-8B2F-5F7FDC506CDD@oracle.com> <20170919151051.GS9536@redhat.com> <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com> <20170919164427.GV9536@redhat.com> <20170919172452.GB29104@fieldses.org> <20170921170017.GK32364@stefanha-x1.localdomain> <d760ecdc-988d-8145-f816-6faf8f2abf03@redhat.com> <E5B4D2FF-0DB4-417D-998A-6BBFC36C35C5@oracle.com> <20170922115524.GN12725@redhat.com>
Message-ID: <87efqu6wl4.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 22 2017, Daniel P. Berrange wrote:

> On Fri, Sep 22, 2017 at 07:43:39AM -0400, Chuck Lever wrote:
>>=20
>> > On Sep 22, 2017, at 5:55 AM, Steven Whitehouse <swhiteho@redhat.com> w=
rote:
>> >=20
>> > Hi,
>> >=20
>> >=20
>> > On 21/09/17 18:00, Stefan Hajnoczi wrote:
>> >> On Tue, Sep 19, 2017 at 01:24:52PM -0400, J. Bruce Fields wrote:
>> >>> On Tue, Sep 19, 2017 at 05:44:27PM +0100, Daniel P. Berrange wrote:
>> >>>> On Tue, Sep 19, 2017 at 11:48:10AM -0400, Chuck Lever wrote:
>> >>>>>> On Sep 19, 2017, at 11:10 AM, Daniel P. Berrange <berrange@redhat=
.com> wrote:
>> >>>>>> VSOCK requires no guest configuration, it won't be broken acciden=
tally
>> >>>>>> by NetworkManager (or equivalent), it won't be mistakenly blocked=
 by
>> >>>>>> guest admin/OS adding "deny all" default firewall policy. Similar
>> >>>>>> applies on the host side, and since there's separation from IP ne=
tworking,
>> >>>>>> there is no possibility of the guest ever getting a channel out t=
o the
>> >>>>>> LAN, even if the host is mis-configurated.
>> >>>>> We don't seem to have configuration fragility problems with other
>> >>>>> deployments that scale horizontally.
>> >>>>>=20
>> >>>>> IMO you should focus on making IP reliable rather than trying to
>> >>>>> move familiar IP-based services to other network fabrics.
>> >>>> I don't see that ever happening, except in a scenario where a single
>> >>>> org is in tight control of the whole stack (host & guest), which is
>> >>>> not the case for cloud in general - only some on-site clouds.
>> >>> Can you elaborate?
>> >>>=20
>> >>> I think we're having trouble understanding why you can't just say "d=
on't
>> >>> do that" to someone whose guest configuration is interfering with the
>> >>> network interface they need for NFS.
>> >> Dan can add more information on the OpenStack use case, but your
>> >> question is equally relevant to the other use case I mentioned - easy
>> >> file sharing between host and guest.
>> >>=20
>> >> Management tools like virt-manager (https://virt-manager.org/) should
>> >> support a "share directory with VM" feature.  The user chooses a
>> >> directory on the host, a mount point inside the guest, and then clicks
>> >> OK.  The directory should appear inside the guest.
>> >>=20
>> >> VMware, VirtualBox, etc have had file sharing for a long time.  It's a
>> >> standard feature.
>> >>=20
>> >> Here is how to implement it using AF_VSOCK:
>> >> 1. Check presence of virtio-vsock device in VM or hotplug it.
>> >> 2. Export directory from host NFS server (nfs-ganesha, nfsd, etc).
>> >> 3. Send qemu-guest-agent command to (optionally) add /etc/fstab entry
>> >>    and then mount.
>> >>=20
>> >> The user does not need to take any action inside the guest.
>> >> Non-technical users can share files without even knowing what NFS is.
>> >>=20
>> >> There are too many scenarios where guest administrator action is
>> >> required with NFS over TCP/IP.  We can't tell them "don't do that"
>> >> because it makes this feature unreliable.
>> >>=20
>> >> Today we ask users to set up NFS or CIFS themselves.  In many cases t=
hat
>> >> is inconvenient and an easy file sharing feature would be much better.
>> >>=20
>> >> Stefan
>> >>=20
>> >=20
>> > I don't think we should give up on making NFS easy to use with TCP/IP =
in such situations. With IPv6 we could have (for example) a device with a w=
ell known link-local address at the host end, and an automatically allocate=
d link-local address at the guest end. In other words the same as VSOCK, bu=
t with IPv6 rather than VSOCK addresses. At that point the remainder of the=
 NFS config steps would be identical to those you've outlined with VSOCK ab=
ove.
>> >=20
>> > Creating a (virtual) network device which is restricted to host/guest =
communication and automatically configures itself should be a lot less work=
 than adding a whole new protocol to NFS I think. It could also be used for=
 many other use cases too, as well as giving the choice between NFS and CIF=
S. So it is much more flexible, and should be quicker to implement too,
>>=20
>> I agree. IMO mechanisms already exist to handle a self-configuring
>> NFS mount. Use IPv6 link-local and the automounter and an entry in
>> /etc/hosts. Done, and no-one even had to type "mount".
>>=20
>> If firewall configuration is a chronic problem, let's address that.
>
> This just isn't practical in the general case. Even on a single Linux OS
> distro there are multiple ways to manage firewalls (Fedora as a static
> init script, or firewalld, and many users invent their own personal way
> of doing it). There are countless other OS, many closed source with 3rd
> party firewall products in use. And then there are the firewall policies
> defined by organization's IT departments that mandate particular ways of
> doing things with layers of approval to go through to get changes made.
>
> IOW, while improving firewall configuraiton is a worthy goal, it isn't
> a substitute for host<->guest file system sharing over a non-network
> based transport.=20

I don't find this argument at all convincing.

The main selling point for VSOCK seems to be that it bypassed all
firewalls.  i.e. traffic through a VSOCK is immune to any netfilter
settings.

If "traffic immune to any netfilter settings" is a useful thing (and I'm
quite willing to believe that it is), then let's focus on that goal.  It
might be useful well beyond NFS and VMs.

How about a flag for a network interface which says "disable netfilter"??

I really don't know enough about netfilter to have any idea of this is
possible.  If it is, then it seems like a good path to a general
solution.
If it isn't, then understanding why might help us move forward some
other way.

Rather than a flag, it might work to use network namespaces.
Very early in the init sequence the filesystem gets mounted using the
IPv6 link-local address on a client->host interface, and then a new
network namespace is created which does not include that interface, and
which everything else including firewall code runs in.  Maybe.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlnJtokACgkQOeye3VZi
gbkJ0Q/9GwZ/zWiudTjoSt7pVB9E+iqEAkaS4RUuBadRErr9EbhKg6Y5pKCte8Y+
mag8li9mxzmjFyk7MZlHjX57ZBAps50TLxsM4B4D+gfOzOop0B7WkIPcVmHtDHSY
q/BQIqwn4Ov8VeU8ynrX8XP7EQMuADcRxOuBCrXtUpey59HAnIvwyJoCGqf9OZ3I
irZWlXRRjlKCQ6VAS7c7dtYjjYHcThBzhPZYiUYhHJ9Ny2E9t7xaaJ3vqhn4MMH0
9gMSV1nRB6VxYyUBFaWf+j/MOWLucGHSsq6THuT6Yo9m+aiQJOG1uk47zXWt08le
XRSjPAI+cBcsxcZqGuTCibJjZMxalHF0ijFfo0MwZLEuAHVA7VTQKpV02rAT7Y6/
pQOewBm5JWLOgE77p9pB1pctqAYCE3cIRps/FBK5wKAKGNl7mTe/EBACHTHBg6za
C2iHxXhomvtf9Huk5UCmUMH8DHOkNtwGvkRznvvQw3zWegEmCpUmjjh/kW/93mdO
xKNrrJ0/C7kmt9qmVZwZu9aTe1l2gr2Th+ZbblhYadpXMXLlWsFVLasaF3IhS/S1
mM/q/wjIMTs01jAB6g0JCDQ3ljzYMKHyFscDV2wN1nd43mfFu1TCOh8y2Y8ONZSZ
+BoRT8Gy1lQUFiu/xj2twezp0gBRfO2+3GnhZ+kZk1irJH7OGPw=
=EIkz
-----END PGP SIGNATURE-----
--=-=-=--
