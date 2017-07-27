Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34869 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750965AbdG0FOE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 27 Jul 2017 01:14:04 -0400
From: NeilBrown <neilb@suse.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Date: Thu, 27 Jul 2017 15:13:53 +1000
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
In-Reply-To: <20170725100513.GA5073@stefanha-x1.localdomain>
References: <20170630132120.31578-1-stefanha@redhat.com> <20170630132120.31578-6-stefanha@redhat.com> <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com> <87wp7lvst9.fsf@notabene.neil.brown.name> <87tw2ox4st.fsf@notabene.neil.brown.name> <20170725100513.GA5073@stefanha-x1.localdomain>
Message-ID: <87eft2wjfy.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 25 2017, Stefan Hajnoczi wrote:

> On Fri, Jul 07, 2017 at 02:13:38PM +1000, NeilBrown wrote:
>> On Fri, Jul 07 2017, NeilBrown wrote:
>>=20
>> > On Fri, Jun 30 2017, Chuck Lever wrote:
>> >>
>> >> Wouldn't it be nicer if it worked like this:
>> >>
>> >> (guest)$ cat /etc/hosts
>> >> 129.0.0.2  localhyper
>> >> (guest)$ mount.nfs localhyper:/export /mnt
>> >>
>> >> And the result was a working NFS mount of the
>> >> local hypervisor, using whatever NFS version the
>> >> two both support, with no changes needed to the
>> >> NFS implementation or the understanding of the
>> >> system administrator?
>> >
>> > Yes. Yes. Definitely Yes.
>> > Though I suspect you mean "127.0.0.2", not "129..."??
>> >
>> > There must be some way to redirect TCP connections to some address
>> > transparently through to the vsock protocol.
>> > The "sshuttle" program does this to transparently forward TCP connecti=
ons
>> > over an ssh connection.  Using a similar technique to forward
>> > connections over vsock shouldn't be hard.
>> >
>> > Or is performance really critical, and you get too much copying when y=
ou
>> > try forwarding connections?  I suspect that is fixable, but it would be
>> > a little less straight forward.
>> >
>> > I would really *not* like to see vsock support being bolted into one
>> > network tool after another.
>>=20
>> I've been digging into this a big more.  I came across
>>   https://vmsplice.net/~stefan/stefanha-kvm-forum-2015.pdf
>>=20
>> which (on page 7) lists some reasons not to use TCP/IP between guest
>> and host.
>>=20
>>  . Adding & configuring guest interfaces is invasive
>>=20
>> That is possibly true.  But adding support for a new address family to
>> NFS, NFSD, and nfs-utils is also very invasive.  You would need to
>> install this software on the guest.  I suggest you install different
>> software on the guest which solves the problem better.
>
> Two different types of "invasive":
> 1. Requiring guest configuration changes that are likely to cause
>    conflicts.
> 2. Requiring changes to the software stack.  Once installed there are no
>    conflicts.
>
> I'm interested and open to a different solution but it must avoid
> invasive configuration changes, especially inside the guest.

Sounds fair.


>
>>  . Prone to break due to config changes inside guest
>>=20
>> This is, I suspect, a key issue.  With vsock, the address of the
>> guest-side interface is defined by options passed to qemu.  With
>> normal IP addressing, the guest has to configure the address.
>>=20
>> However I think that IPv6 autoconfig makes this work well without vsock.
>> If I create a bridge interface on the host, run
>>   ip -6 addr  add fe80::1 dev br0
>> then run a guest with
>>    -net nic,macaddr=3DCh:oo:se:an:ad:dr \
>>    -net bridge,br=3Dbr0 \
>>=20
>> then the client can
>>   mount [fe80::1%interfacename]:/path /mountpoint
>>=20
>> and the host will see a connection from
>>    fe80::ch:oo:se:an:ad:dr
>>=20
>> So from the guest side, I have achieved zero-config NFS mounts from the
>> host.
>
> It is not zero-configuration since [fe80::1%interfacename] contains a
> variable, "interfacename", whose value is unknown ahead of time.  This
> will make documentation as well as ability to share configuration
> between VMs more difficult.  In other words, we're back to something
> that requires per-guest configuration and doesn't just work everywhere.

Maybe.  Why isn't the interfacename known ahead of time.  Once upon a
time it was always "eth0", but I guess guests can rename it....

You can use a number instead of a name.  %1 would always be lo.
%2 seems to always (often?) be the first physical interface.  Presumably
the order in which you describe interfaces to qemu directly maps to the
order that Linux sees.  Maybe %2 could always work.  Maybe we could make
it so that it always works, even if that requires small changes to Linux
(and/or qemu).

>
>> I don't think the server can filter connections based on which interface
>> a link-local address came from.  If that was a problem that someone
>> wanted to be fixed, I'm sure we can fix it.
>>=20
>> If you need to be sure that clients don't fake their IPv6 address, I'm
>> sure netfilter is up to the task.
>
> Yes, it's common to prevent spoofing on the host using netfilter and I
> think it wouldn't be a problem.
>
>>  . Creates network interfaces on host that must be managed
>>=20
>> What vsock does is effectively create a hidden interface on the host tha=
t only the
>> kernel knows about and so the sysadmin cannot break it.  The only
>> difference between this and an explicit interface on the host is that
>> the latter requires a competent sysadmin.
>>=20
>> If you have other reasons for preferring the use of vsock for NFS, I'd be
>> happy to hear them.  So far I'm not convinced.
>
> Before working on AF_VSOCK I originally proposed adding dedicated
> network interfaces to guests, similar to what you've suggested, but
> there was resistance for additional reasons that weren't covered in the
> presentation:

I would like to suggest that this is critical information for
understanding the design rationale for AF_VSOCK and should be easily
found from http://wiki.qemu.org/Features/VirtioVsock

>
> Using AF_INET exposes the host's network stack to guests, and through
> accidental misconfiguration even external traffic could reach the host's
> network stack.  AF_VSOCK doesn't do routing or forwarding so we can be
> sure that any activity is intentional.

If I understand this correctly, the suggested configuration has the host
completely isolated from network traffic, and the guests directly
control the physical network interfaces, so the guests see external
traffic, but neither the guests nor the wider network can communicate
with the host.

Except that sometimes the guests do need to communicate with the host so
we create a whole new protocol just for that.

>
> Some virtualization use cases run guests without any network interfaces
> as a matter of security policy.  One could argue that AF_VSOCK is just
> another network channel, but due to it's restricted usage, the attack
> surface is much smaller than an AF_INET network interface.

No network interfaces, but they still want to use NFS.  Does anyone
think that sounds rational?

"due to it's restricted usage, the attack surface is much smaller"
or "due to it's niche use-cache, bug are likely to go undetected for
longer".  I'm not convinced that is sensible security policy.


I think I see where you are coming from now - thanks.  I'm not convinced
though.  It feels like someone is paranoid about possible exploits using
protocols that they think they understand, so they ask you to create a
new protocol that they don't understand (and so cannot be afraid of).

Maybe the NFS server should be run in a guest.  Surely that would
protects the host's network stack.  This would be a rather paranoid
configuration, but it seems to match the paranoia of the requirements.

I'm not against people being paranoid.  I am against major code changes
to well established software, just to placate that paranoia.

To achieve zero-config, I think link-local addresses are by far the best
answer.  To achieve isolation, some targeted filtering seems like the
best approach.

If you really want traffic between guest and host to go over a vsock,
then some sort of packet redirection should be possible.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAll5dpMACgkQOeye3VZi
gbkDwBAAlc3oy/yDeF5b4Q2PCxLPmYCaSr716xPxAy/dqD44rrSwuqad9gMccagA
LXKdnJQoaa8bx0YrnFq3n/ZllJDGoqgttOZz0EEzDFuAexiiFXgRlTBi28b0AYGt
jgdcEotI9VeYcZ++itOUW6t7aXdi5hLKUgXH9r/Dg0wD63UcAUeXscnRrPYDBMYO
H9cHApVJlEe5xIqDTKZmb16C9Z85hmJMs4SRz9V0h9rKRfdEvukDVG0nbakvYV3p
zt6QHZ12lbh/iT3hhAF2MaFFl5maYDNdBT8WnimoR1KurhAwZGGH3HaCO5FU2MC/
5lLcxNfWgmfCM1AjvncUlfj/VRhRmZJfvRXUWJo40O0hxiJDV+CviNxTtsyRHkC0
fGBTmhLAf40QSwkEAXA3zvJavXUx8XeRiltb1vtACgkASKp/GOSzMEcT/1QFOO5O
yT2tR25zkrhL/JF+fNC+cgiOHWdqEMDBksgQRjT3ogH2FMwMys3JCVa+DN9Gb5pB
dRZKOWqwIcO8KgHbf6gjJ5rdVPfEHE8L8dC2R5cbQOal3DHjeOJ9aqHZ1SMvGI1g
Z1EfiqxdzCclggH2ENbiKEw0dJ3w648V9bS04oWIVsQnS0Mz7a7EBr7iVjadHCrU
M1cLE1fShOfmowv/sbJwB74VNXO5D3nJxq3kJ13SRm0VMfSP3dY=
=J3u0
-----END PGP SIGNATURE-----
--=-=-=--
