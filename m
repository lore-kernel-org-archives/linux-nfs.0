Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:50942 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964998AbeALTM5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jan 2018 14:12:57 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH] Do not bind to reserved ports registered in /etc/services
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180112180528.GA9479@thunder.hadrons.org>
Date: Fri, 12 Jan 2018 14:12:35 -0500
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BB34439C-4BC6-46AE-B2E8-45E5F7396F21@oracle.com>
References: <20180110004920.11100-1-gjover@sipwise.com>
 <49E44F63-42CF-4BF8-91E0-F89945D7CFE6@oracle.com>
 <20180112180528.GA9479@thunder.hadrons.org>
To: Guillem Jover <gjover@sipwise.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jan 12, 2018, at 1:05 PM, Guillem Jover <gjover@sipwise.com> wrote:
>=20
> Hi!
>=20
> On Thu, 2018-01-11 at 10:50:14 -0500, Chuck Lever wrote:
>> On Jan 9, 2018, at 7:49 PM, Guillem Jover <gjover@sipwise.com> wrote:
>>> When using the bindresvport() function a privileged port will be =
looked
>>> for and bound to a socket. The problem is that any service using a =
static
>>> privileged port registered in the /etc/services file, can get its =
port
>>> taken over by libtirpc users, making the other service fail to =
start.
>>>=20
>>> Starting the other service before libtircp users is not an option as
>>> this does not cover restart situations, for example during package
>>> upgrades or HA switchovers and similar.
>>>=20
>>> In addition honoring the /etc/services registry is already done for
>>> example by rpc.statd, so it seems obvious to make libtirpc follow =
this
>>> same pattern too.
>>=20
>> Does the glibc version of bindresvport(3) skip ports? I ask because
>> this hasn't been a noted problem before. Which service exactly is
>> causing the difficulty?
>=20
> So, this is all a bit of a mess, and apparently it has been known in
> some quarters for quite some time. :(
>=20
> This was reported to glibc a long time ago [B] but at the time =
upstream
> bogusly rejected the idea of using /etc/services (or similar). Instead
> someone had to create a workaround to overcome this [P], a daemon =
which
> binds to a port, until the other service requests the port to be =
released
> so that it can itself bind to it, which is still obviously prone to =
races
> during restarts and complicates things.
>=20
> [B] <https://sourceware.org/bugzilla/show_bug.cgi?id=3D1014>
>    <https://bugzilla.redhat.com/show_bug.cgi?id=3D103401>
>    <https://bugzilla.novell.com/show_bug.cgi?id=3D262341>
>    <https://bugs.debian.org/638322>
> [P] <http://cyberelk.net/tim/software/portreserve/>
>=20
> Then some distributions instead patched their glibc to honor a new
> /etc/bindresvport.blacklist file in the bindresvport() function; =
OpenSUSE
> at least, and apparently Debian too [F] (although this is not =
documented
> anywhere). In addition nfs-utils upstream (where an rpc.statd comes =
from)
> already honors /etc/services. To complicate things, rpcbind and other
> SunRPC clients using libtirpc do not honor neither /etc/services nor
> /etc/bindresvport.blacklist, because libtirpc has its own =
bindrecvport()
> implementation.

Hi Guillem-

rpc.statd was a local fix to acquire a single port for one long
lived socket. It's not a solution intended to be a generic API
for all RPC applications on the system. Using /etc/services is
completely adequate for this purpose.

If bindresvport(3) is changed to avoid well-known ports,
rpc.statd could easily be converted to use it, for example.


> [F] =
<https://sources.debian.org/src/glibc/2.26-3/debian/patches/any/local-bind=
resvport_blacklist.diff/>
>=20
> On the above Debian bug report, it was proposed to make libtirpc =
switch
> to use the libc bindresvport() implementation so that at least on =
those
> distributions where it is locally patched it would honor the
> /etc/bindresvport.blacklist file. The problem with this, is of course
> that it does not help any upstream code on any other non-patched =
system.

The community issue here is that there have evolved, over time,
multiple RPC libraries with divergent capabilities. The only way
to truly address this confusion is to eliminate all but one of
them, which is far outside the scope of your bug fix. For now we
have to live with it.


> So I decided against using the undocumented =
/etc/bindresvport.blacklist,
> because that requires filling it up with ports that are already =
present
> in /etc/services, which seems pointless.

It's not pointless if the two sets of ports are typically not
entirely conjunct.


> It does not support a fragments
> style directory such as /etc/bindresvport.blacklist.d/ anyway which
> makes "registering" the ports from each package too difficult.

That would be simple enough to add. Again, not really a reason
not to go with a black list. And /etc/services has the same
issue.


> And
> because nfs-utils' rpc.statd will honor /etc/services on any system
> regardless of the libc implementation, which is not the case for
> /etc/bindresvport.blacklist.

As above, rpc.statd can be converted to use a bindresvport(3)
that avoids well-known ports quite easily.


> But at this point, if you disagree and prefer some other solution, I'm
> happy to oblige, because I'd rather have anything at all. :)

I agree there's an issue that needs a solution.


>> Usually applications that grab a privileged port are short-lived.
>> statd is careful to avoid ports in /etc/services because it allocates
>> one socket with a privileged port for contacting the kernel, and =
keeps
>> it in place.
>=20
> The other long-lived libtirpc instance that is causing problems for
> us is rpcbind. And fixing this at the root seemed better than patching
> just rpcbind.

Perhaps. Callers that need only a short-lived socket can work
without any restrictions. The issue is those one or two users
that create a long-lived socket with a privileged port and then
drop privileges. Perhaps a better solution for them is to retain
CAP_NET_BIND_SERVICE and use short-lived sockets instead.


>>> diff --git a/src/bindresvport.c b/src/bindresvport.c
>>> index 2d8f2bc..98e5f40 100644
>>> --- a/src/bindresvport.c
>>> +++ b/src/bindresvport.c
>>> @@ -125,6 +129,25 @@ bindresvport_sa(sd, sa)
>>>        }
>>>        sa->sa_family =3D af;
>>>=20
>>> +        so_proto_len =3D sizeof(so_proto);
>>> +        if (getsockopt(sd, SOL_SOCKET, SO_PROTOCOL, &so_proto, =
&so_proto_len) =3D=3D -1) {
>>> +                mutex_unlock(&port_lock);
>>> +                return -1;      /* errno is correctly set */
>>> +        }
>>> +        switch (so_proto) {
>>> +        case IPPROTO_UDP:
>>> +        case IPPROTO_UDPLITE:
>>=20
>> What is UDPLITE?
>=20
> <http://man7.org/linux/man-pages/man7/udplite.7.html>. I was trying to
> make this as generic as possible, but checking again now, I guess this
> might deserve a new protocol name in /etc/services anyway.
>=20
>> Would it require a separate netid
>> or other infrastructure? IMO it's not correct to add
>> this transport protocol in this patch. If you resend,
>> please remove this line.
>=20
> Yeah, will drop it. The one not being handled because I was not sure
> how, that does appear for example on /etc/services on a Debian system
> is "ddp", but given that the library is for SunRPC there's not much
> point in trying to handle that case here anyway.
>=20
> Thanks,
> Guillem

--
Chuck Lever



