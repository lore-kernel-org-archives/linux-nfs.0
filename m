Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:59570 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751853AbeBETuS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Feb 2018 14:50:18 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH 0/1] Remote calls don't need to use privilege ports
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <6bd33601-2c59-3d19-ece2-878b885c2940@RedHat.com>
Date: Mon, 5 Feb 2018 14:47:00 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <C44A49E5-FEA5-482F-B945-BD967841F2FF@oracle.com>
References: <20180205163647.15822-1-steved@redhat.com>
 <16CF8126-7229-4963-B5D1-2AC16BFC000A@oracle.com>
 <6bd33601-2c59-3d19-ece2-878b885c2940@RedHat.com>
To: Steve Dickson <SteveD@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

> On Feb 5, 2018, at 2:21 PM, Steve Dickson <SteveD@RedHat.com> wrote:
>=20
>=20
>=20
> On 02/05/2018 12:02 PM, Chuck Lever wrote:
>> Heya Steve-
>>=20
>>> On Feb 5, 2018, at 11:36 AM, Steve Dickson <steved@redhat.com> =
wrote:
>>>=20
>>> Over the weekend I did some experimenting with
>>> the remote call code in rpcbind. The code does=20
>>> functionally work but is very antiquated when
>>> it comes to the latest NFS versions.=20
>>>=20
>>> Since only UDP sockets are used to do remote calls
>>> using the documented interfaces pmap_rmtcall() and callrpc()
>>> calls to NFS will fail (actual times out) since UDP is no=20
>>> longer supported.=20
>>>=20
>>> The undocumented interface rpc_call() can be used to=20
>>> call into NFS since the protocol can specified, which=20
>>> also means the PMAPPROC_CALLIT protocol is not used.
>>>=20
>>> It turns out privilege port are not needed to make
>>> remote calls, at least with my testing.
>>=20
>> It's not quite clear what you are claiming here, but
>> I'm guessing that what you demonstrated is that the
>> CALLIT _listener_ does not have to be privileged?
> Right...=20
>>=20
>> I claim that is true for all RPC listeners.
> It could be true..

"privileged port" always means a source port, never a
listener. There is no extra privilege given to a listener
port that is below 1024.

svc_tli_create is simply wrong to use bindresvport.


>>> I'm thinking=20
>>> the only reason privilege ports were being uses was=20
>>> a side effect of create_rmtcall_fd() calling=20
>>> svc_tli_create() with an unbound socket.
>>=20
>> Privileged listener ports are being created because
>> svc_tli_create is using bindresvport when the passed
>> in socket is not already bound.
> Right... So handing svc_tli_create a bound socket will
> cause the bindresvport not to happen.

True, and your patch corrects the behavior of rpcbind.

But I argue that is a workaround: svc_tli_create is
still doing the wrong thing for any other RPC server
that does not hand in a pre-bound socket. Fix it there
and all RPC servers that use libtirpc are fixed.


>> svc_tli_create should use bind instead, and it needs
>> to choose a port higher than 49151.Actual it does when a t_bind =
structure is passed in.=20
> But more to the point, I thought about changing=20
> svc_tli_create but that would effect all the callers
> of the routine which I didn't think was a good idea=20
> for code that is basically not used.

I'm not sure what you mean by "code that is basically
not used."

svc_tli_create is the bottom of the RPC stack. It is the
libtirpc API that is used every time an RPC server starts
a listener. mountd and statd call svc_tli_create
directly for example, from support/nfs/svc_create.c.

Thus this is the right place to fix it for all RPC server
applications.


> Also, now that libtirpc is the only Linux RPC implementation
> (the RPC code has been removed from glibc) I'm a bit
> sensitive to changing functionality unless its a=20
> clear bug or security issue.=20

This is a clear bug.

- The library should not be allowed to choose ports that
interfere with well-known services.

- The library should choose service ports based on well-
established standards, such as the IANA service names to
port numbers standard.


>> =
https://www.iana.org/assignments/service-names-port-numbers/service-names-=
port-numbers.xhtml
> Hmm... I have been conveniently ignoring Thorsten's blacklist patch.
> Maybe we should take another look at that.
>=20
>>=20
>>=20
>>> So the following patch simply binds the socket
>>> before calling svc_tli_create() which means a
>>> non-privilege port will be reserved for remote
>>> calls.=20
>>>=20
>>> I'm thinking this is the simplest way to
>>> not pollute the privilege port space.=20
>>=20
>> This is going in the right direction, but the problem
>> needs to be addressed in svc_tli_create, not in each
>> application that calls svc_tli_create.
>>=20
>> This is the same issue that Guillem Jover was trying to
>> address by making bindresvport skip well-known ports.
>>=20
>> In other words: this code in src/svc_generic.c is wrong:
> It could be... but the API allows for the bindresvport (or any bind)=20=

> to not happen... So changing how it is called I think is=20
> appropriate... Plus its been working this way for a long to so=20
> I'm very resistant to change functionality basically for no reason.=20
>=20
> But I do think we should look into bindresvport using a black list
> since it is already established in SuSE

IMO a bindresvport blacklist is absolutely the wrong approach.
We have standards organizations that have explained exactly how
this needs to work, and we want it to work without installing
extra files or giving admins more knobs that they really don't
need.

This is exactly the problem with distros applying patches
without upstream review. SuSE fixed this and let their fix sit
for years without any public bug report or review. IMO SuSE
should be prepared to take this hit, it should not constrain
upstream to choose a non-optimal long-term solution. I don't
see any compelling reason in this particular case that we need
to be constrained.

Fixing svc_tli_create to use ports higher than 49151 should be
completely compatible with any reasonable blacklist, and it
MUST be compatible with /etc/services, which is based on the
IANA publication (no well-known fixed ports above 49151).


> steved.
>=20
>>=20
>> 218         /*
>> 219          * If the fd is unbound, try to bind it.
>> 220          */
>> 221         if (madefd || !__rpc_sockisbound(fd)) {
>> 222                 if (bindaddr =3D=3D NULL) {
>> 223                         if (bindresvport(fd, NULL) < 0) {
>>                                ^^^^^^^^^^^^
>>=20
>> 224                                 memset(&ss, 0, sizeof ss);
>> 225                                 ss.ss_family =3D si.si_af;
>> 226                                 if (bind(fd, (struct sockaddr =
*)(void *)&ss,
>> 227                                     (socklen_t)si.si_alen) < 0) {
>> 228                                         warnx(
>> 229                         "svc_tli_create: could not bind to =
anonymous port");
>> 230                                         goto freedata;
>> 231                                 }
>> 232                         }
>> 233                         listen(fd, SOMAXCONN);
>> 234                 } else {
>> 235                         if (bind(fd,
>> 236                             (struct sockaddr =
*)bindaddr->addr.buf,
>> 237                             (socklen_t)si.si_alen) < 0) {
>> 238                                 warnx(
>> 239                 "svc_tli_create: could not bind to requested =
address");
>> 240                                 goto freedata;
>> 241                         }
>> 242                         listen(fd, (int)bindaddr->qlen);
>> 243                 }
>> 244=20
>> 245         }
>>=20
>>=20
>>> Steve Dickson (1):
>>> rmtcalls: Don't use privileged ports for remote calls.
>>>=20
>>> src/rpcb_svc_com.c | 19 ++++++++++++++++++-
>>> 1 file changed, 18 insertions(+), 1 deletion(-)
>>=20
>>=20
>> --
>> Chuck Lever

--
Chuck Lever



