Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47184 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751033AbdGGENy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Jul 2017 00:13:54 -0400
From: NeilBrown <neilb@suse.com>
To: Chuck Lever <chuck.lever@oracle.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Date: Fri, 07 Jul 2017 14:13:38 +1000
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
In-Reply-To: <87wp7lvst9.fsf@notabene.neil.brown.name>
References: <20170630132120.31578-1-stefanha@redhat.com> <20170630132120.31578-6-stefanha@redhat.com> <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com> <87wp7lvst9.fsf@notabene.neil.brown.name>
Message-ID: <87tw2ox4st.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Fri, Jul 07 2017, NeilBrown wrote:

> On Fri, Jun 30 2017, Chuck Lever wrote:
>>
>> Wouldn't it be nicer if it worked like this:
>>
>> (guest)$ cat /etc/hosts
>> 129.0.0.2  localhyper
>> (guest)$ mount.nfs localhyper:/export /mnt
>>
>> And the result was a working NFS mount of the
>> local hypervisor, using whatever NFS version the
>> two both support, with no changes needed to the
>> NFS implementation or the understanding of the
>> system administrator?
>
> Yes. Yes. Definitely Yes.
> Though I suspect you mean "127.0.0.2", not "129..."??
>
> There must be some way to redirect TCP connections to some address
> transparently through to the vsock protocol.
> The "sshuttle" program does this to transparently forward TCP connections
> over an ssh connection.  Using a similar technique to forward
> connections over vsock shouldn't be hard.
>
> Or is performance really critical, and you get too much copying when you
> try forwarding connections?  I suspect that is fixable, but it would be
> a little less straight forward.
>
> I would really *not* like to see vsock support being bolted into one
> network tool after another.

I've been digging into this a big more.  I came across
  https://vmsplice.net/~stefan/stefanha-kvm-forum-2015.pdf

which (on page 7) lists some reasons not to use TCP/IP between guest
and host.

 . Adding & configuring guest interfaces is invasive

That is possibly true.  But adding support for a new address family to
NFS, NFSD, and nfs-utils is also very invasive.  You would need to
install this software on the guest.  I suggest you install different
software on the guest which solves the problem better.

 . Prone to break due to config changes inside guest

This is, I suspect, a key issue.  With vsock, the address of the
guest-side interface is defined by options passed to qemu.  With
normal IP addressing, the guest has to configure the address.

However I think that IPv6 autoconfig makes this work well without vsock.
If I create a bridge interface on the host, run
  ip -6 addr  add fe80::1 dev br0
then run a guest with
   -net nic,macaddr=Ch:oo:se:an:ad:dr \
   -net bridge,br=br0 \

then the client can
  mount [fe80::1%interfacename]:/path /mountpoint

and the host will see a connection from
   fe80::ch:oo:se:an:ad:dr

So from the guest side, I have achieved zero-config NFS mounts from the
host.

I don't think the server can filter connections based on which interface
a link-local address came from.  If that was a problem that someone
wanted to be fixed, I'm sure we can fix it.

If you need to be sure that clients don't fake their IPv6 address, I'm
sure netfilter is up to the task.


 . Creates network interfaces on host that must be managed

What vsock does is effectively create a hidden interface on the host that only the
kernel knows about and so the sysadmin cannot break it.  The only
difference between this and an explicit interface on the host is that
the latter requires a competent sysadmin.

If you have other reasons for preferring the use of vsock for NFS, I'd be
happy to hear them.  So far I'm not convinced.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAllfCnMACgkQOeye3VZi
gbksUg//SwgsQGtsg3pBQlxj0kiCPZos+PCbuoT3LXfc5yl4BoFBd+Co0tcpqAuq
KK0G4JTG4E6oa4cV206jP6UgwtgTxP2ZQjw135qcaH7w7mjHpYkMwDLpMyd4FHw1
fQU9+rZfjmJYNHeeWheuwzCTR9hi7wzMYCck5g1Sgjb6f9awKEX2nJvVGCJEb/rQ
E65s5m2RSB8/H11CP8RxoakWkVov/OflR5BGRBIyvr+MpmUb0IHAR7c023rECB8P
eXL+Hoi/5UvUwAbomB1Nzxucp+raTBM9oOnMTKlaSTaP30l7MFa9x8uHApSD+UWq
Yj3YLfnAlEUF/uqUPzqIcQE9/mbzc1vZhjuD3fiyjGCN5IlKG989l1GNCjfs5akx
jlilVfYn+glYvcKlUW07u/lqB9MhCezj1GYkCeDHZe15uH5dE7OwJT0cqUNt/QtQ
WnwjJirRMtYHkfKodBdf/H1Z/S8gnqgvoLYAGd6pKK82vc6mXLQYUVvY1b4npfSB
mxjQsqF4IsHfq9myDt8fVa6zw57ntYcqWvsXNPpYvm0zc8dcAv6EG3hGUJz6INWk
QxuaM+cE+DJ9759b7N3zLh+SwsnQ6FFIeqKeRf9+P7kYSx0c1OXEOgNXm38hKW6q
k5X5Dnj91bxDgUro4NEPdevyd6o/HuaNpEjuu7K8XllBIgQQT6U=
=yMb+
-----END PGP SIGNATURE-----
--=-=-=--
