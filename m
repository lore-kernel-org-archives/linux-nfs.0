Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47913 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752370AbdI0WWB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Sep 2017 18:22:01 -0400
From: NeilBrown <neilb@suse.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Date: Thu, 28 Sep 2017 08:21:48 +1000
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "Daniel P. Berrange" <berrange@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steven Whitehouse <swhiteho@redhat.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        Justin Mitchell <jumitche@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
In-Reply-To: <20170927130523.GD14579@stefanha-x1.localdomain>
References: <20170919164427.GV9536@redhat.com> <20170919172452.GB29104@fieldses.org> <20170921170017.GK32364@stefanha-x1.localdomain> <d760ecdc-988d-8145-f816-6faf8f2abf03@redhat.com> <E5B4D2FF-0DB4-417D-998A-6BBFC36C35C5@oracle.com> <20170922115524.GN12725@redhat.com> <87efqu6wl4.fsf@notabene.neil.brown.name> <20170926034026.GA19283@fieldses.org> <20170926105626.GH16834@stefanha-x1.localdomain> <87bmlx6kbm.fsf@notabene.neil.brown.name> <20170927130523.GD14579@stefanha-x1.localdomain>
Message-ID: <8760c37pfn.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 27 2017, Stefan Hajnoczi wrote:

> On Wed, Sep 27, 2017 at 10:45:17AM +1000, NeilBrown wrote:
>> On Tue, Sep 26 2017, Stefan Hajnoczi wrote:
>>=20
>> > On Mon, Sep 25, 2017 at 11:40:26PM -0400, J. Bruce Fields wrote:
>> >> On Tue, Sep 26, 2017 at 12:08:07PM +1000, NeilBrown wrote:
>> >> > On Fri, Sep 22 2017, Daniel P. Berrange wrote:
>> >> > Rather than a flag, it might work to use network namespaces.
>> >> > Very early in the init sequence the filesystem gets mounted using t=
he
>> >> > IPv6 link-local address on a client->host interface, and then a new
>> >> > network namespace is created which does not include that interface,=
 and
>> >> > which everything else including firewall code runs in.  Maybe.
>> >>=20
>> >> That seems closer, since it allows you to hide the interface from most
>> >> of the guest while letting some special software--qemu guest agent?--
>> >> still work with it.  That agent would also need to be the one to do t=
he
>> >> mount, and would need to be able to make that mount usable to the rest
>> >> of the guest.
>> >>=20
>> >> Sounds doable to me?
>> >>=20
>> >> There's still the problem of the paranoid security bureaucracy.
>> >>=20
>> >> It should be pretty easy to demonstrate that the host only allows
>> >> point-to-point traffic on these interfaces.  I'd hope that that, plus
>> >> the appeal of the feature, would be enough to win out in the end.  Th=
is
>> >> is not a class of problem that I have experience dealing with, though!
>> >
>> > Programs wishing to use host<->guest networking might still need the
>> > main network namespace for UNIX domain sockets and other
>> > communication.
>>=20
>> Did I miss something.... the whole premise of this work seems to be that
>> programs (nfs in particular) cannot rely on host<->guest networking
>> because some rogue firewall might interfere with it, but now you say
>> that some programs might rely on it....
>
> Programs rely on IPC (e.g. UNIX domain sockets) and that's affected by
> network namespace isolation.  This is what I was interested in.
>
> But I've checked that UNIX domain socket connect(2) works across network
> namespaces for pathname sockets.  The path to the socket file just needs
> to be accessible via the file system.
>
>> However I think you missed the important point - maybe I didn't explain
>> it clearly.
>>=20
>> My idea is that the "root" network namespace is only available in early
>> boot.  An NFS mount happens then (and possibly a daemon hangs around in
>> this network namespace to refresh the NFS mount).  A new network
>> namespace is created and *everthing*else* runs in that subordinate
>> namespace.
>>=20
>> If you want host<->guest networking in this subordinate namespace you
>> are quite welcome to configure that - maybe a vethX interface which
>> bridges out to the host interface.
>> But the important point is that any iptables rules configured in the
>> subordinate namespace will not affect the primary namespace and so will
>> not hurt the NFS mount. They will be entirely local.
>
> Using the "root" (initial) network namespace is invasive.  Hotplugged
> NICs appear in the initial network netspace and interfaces move there if
> a subordinate namespace is destroyed.  Were you thinking of this
> approach because it could share a single NIC (you mentioned bridging)?

I was thinking of this approach because you appear to want isolation to
protect the NFS mount from random firewalls, and the general approach of
namespaces is to place the thing you want to contain (the firewall etc)
in a subordinate namespace.

However, if a different arrangement works better then a different
arrangement should be pursued.  I knew nothing about network namespaces
until a couple of days ago, so I'm largely guessing.

The problem I assumed you would have with putting NFS in a subordinate
namespace is that the root namespace could still get in and mess it up,
whereas once you are in a subordinate namespace, I assume you cannot
get out (I assume that is part of the point).  But maybe you can stop
processes from the root namespace getting in, or maybe you can choose
that that is not part of the threat scenario.

>
> Maybe it's best to leave the initial network namespace alone and instead
> create a host<->guest namespace with a dedicated virtio-net NIC.  That
> way hotplug and network management continues to work as usual except
> there is another namespace that contains a dedicated virtio-net NIC for
> NFS and other host<->guest activity.

That probably makes sense.

>
>> There should be no need to move between namespaces once they have been
>> set up.
>
> If the namespace approach is better than AF_VSOCK, then it should work
> for more use cases than just NFS.  The QEMU Guest Agent was mentioned,
> for example.

It appears that you have "trustworthy" services, such as NFS, which you
are confident will not break other services on the host, and
"untrustworthy" services, such as a firewall or network manager, which
might interfere negatively.

It makes sense to put all the trustworthy services in one network
namespace, and all the untrustworthy in the other.
Exactly how you arrange that depends on specific requirements.  I
imagine you would start all the trustworthy services early, and then
close off their namespace from further access.  Other arrangements are
certainly possible.  Stepping back and forth between two namespaces
doesn't seem like the most elegant solution.

>
> The guest agent needs to see the guest's network interfaces so it can
> report the guest IP address.  Therefore it needs access to both network
> namespaces and I wondered what the cleanest way to do that was.

There are several options.  I cannot say which is the "cleanest", partly
because that is a subjective assessment.
Based on fairly shallow understanding of what the guest agent must do, I
would probably explore putting the main guest agent in the untrusted
namespace, with some sort of forwarding service in the trusted
namespace.  The agent would talk to the forwarding service using
unix-domain sockets - possibly created with socketpair() very early so
they don't depend on any shared filesystem namespace (just incase that
gets broken).
I assume the guest agent doesn't require low-latency/high-bandwidth,
and so will not be adversely affected by a forwarding agent.

>
> Stefan

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlnMJH4ACgkQOeye3VZi
gbl+BQ/8C77Eirq3ww3GC1TIlwYVzFJHzMxf8HqeDlL5Pxqr5mr9CtwqeqBXYemm
sMJvfebV4PGYeHj8djH9JL12sUmwXcWheoUkVeQ+l6jE/MRN0ZhZf2BfoSzBCjq5
jHie4/A7LBpfvDvdlxw+on0xep+oKK2ByVGi3wP1UUkQgVCo+juzuhTITo1HX4hi
/97s2kG7Fp78YvWG+aqIaCXMrSBYSki7G0/jUWlJNnbPBxkzVlz8sx+h7gU88mZF
ZYi/mJoN6q5XdMmb6ZO4HOkjJ9zvV/JYgWgZiifymPyM/3SXvW1xiL22qE0eGzuz
fwKTQjoKYc7skYd0NptpZj/OVk5mevhfsDQ7rjvUq+MoKfanBh7isXPh/4Fj9en2
SBpGDHL2JcP9yRfzQqqa/mpeP3NaJlslnLpzVIPCEeCn6suhe52NqQ8me5lJ9kPj
X1dtql9mlW0L/UzxIC0/QRg5l/hOdQT960SSSUTyT6FzpdcZ9ETn2qExXG6sQEWR
CreVs5ZA1P2lc1pvRdmVrjTLEZ5jp8KEGuuJzaeW8NBDPAvTxlsoC810kyc2ap+6
Fq5Sx9hYLghbAL/gl0f+CC90tXG5qWYhCtF9+KN/Q+fjUj9cj2ye8IjI/brHexF4
cJEfzLdcYxfvce5fBwzoJIWCIkfHhg0UFfEsdJfXYpfR3XpD/I0=
=n744
-----END PGP SIGNATURE-----
--=-=-=--
