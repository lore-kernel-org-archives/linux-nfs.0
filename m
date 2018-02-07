Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:36550 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754166AbeBGQO3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Feb 2018 11:14:29 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH 0/1] Remote calls don't need to use privilege ports
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <87eflxo1qp.fsf@notabene.neil.brown.name>
Date: Wed, 7 Feb 2018 11:09:21 -0500
Cc: Tom Talpey <tom@talpey.com>, Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <4F3A3FBC-FFA9-4CDA-A38A-73AD07A62A27@oracle.com>
References: <20180205163647.15822-1-steved@redhat.com>
 <16CF8126-7229-4963-B5D1-2AC16BFC000A@oracle.com>
 <cc08d8f9-795d-d49c-6354-f5fdbeb85a44@talpey.com>
 <87eflxo1qp.fsf@notabene.neil.brown.name>
To: NeilBrown <neilb@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Feb 6, 2018, at 11:35 PM, NeilBrown <neilb@suse.com> wrote:
>=20
> On Mon, Feb 05 2018, Tom Talpey wrote:
>=20
>> On 2/5/2018 12:02 PM, Chuck Lever wrote:
>>> Heya Steve-
>>>=20
>>>> On Feb 5, 2018, at 11:36 AM, Steve Dickson <steved@redhat.com> =
wrote:
>>>>=20
>>>> Over the weekend I did some experimenting with
>>>> the remote call code in rpcbind. The code does
>>>> functionally work but is very antiquated when
>>>> it comes to the latest NFS versions.
>>>>=20
>>>> Since only UDP sockets are used to do remote calls
>>>> using the documented interfaces pmap_rmtcall() and callrpc()
>>>> calls to NFS will fail (actual times out) since UDP is no
>>>> longer supported.
>>>>=20
>>>> The undocumented interface rpc_call() can be used to
>>>> call into NFS since the protocol can specified, which
>>>> also means the PMAPPROC_CALLIT protocol is not used.
>>>>=20
>>>> It turns out privilege port are not needed to make
>>>> remote calls, at least with my testing.
>>>=20
>>> It's not quite clear what you are claiming here, but
>>> I'm guessing that what you demonstrated is that the
>>> CALLIT _listener_ does not have to be privileged?
>=20
> rpcbind listens for CALLIT on port 111.

Right, my bad. CALLIT is an RPC procedure, not an RPC
program.


> Listening on some other port wouldn't ever get the messges...

Then we still do not understand why rpcbind is opening
and registering a second listener port. I can't think of
any reason it should do this other than that there is a
bug.


>>>=20
>>> I claim that is true for all RPC listeners.
>>=20
>>=20
>> Why in the world is the remote-call interface even still supported?
>> It is and was a mammoth security hole allowing machine impersonation,
>> and to my knowledge no actual services or applications depends on
>> it. Why not bury it under some compatibility option, default=3Doff??
>=20
> Is "ybind --broadcast" still used?
> Even it is it, the port that rpcbind uses to forward the request =
doesn't
> need to be privileged.
>=20
> NeilBrown
>=20
>=20
>>=20
>> Tom.
>>=20
>>=20
>>>=20
>>>> I'm thinking
>>>> the only reason privilege ports were being uses was
>>>> a side effect of create_rmtcall_fd() calling
>>>> svc_tli_create() with an unbound socket.
>>>=20
>>> Privileged listener ports are being created because
>>> svc_tli_create is using bindresvport when the passed
>>> in socket is not already bound.
>>>=20
>>> svc_tli_create should use bind instead, and it needs
>>> to choose a port higher than 49151.
>>>=20
>>> =
https://www.iana.org/assignments/service-names-port-numbers/service-names-=
port-numbers.xhtml
>>>=20
>>>=20
>>>> So the following patch simply binds the socket
>>>> before calling svc_tli_create() which means a
>>>> non-privilege port will be reserved for remote
>>>> calls.
>>>>=20
>>>> I'm thinking this is the simplest way to
>>>> not pollute the privilege port space.
>>>=20
>>> This is going in the right direction, but the problem
>>> needs to be addressed in svc_tli_create, not in each
>>> application that calls svc_tli_create.
>>>=20
>>> This is the same issue that Guillem Jover was trying to
>>> address by making bindresvport skip well-known ports.
>>>=20
>>> In other words: this code in src/svc_generic.c is wrong:
>>>=20
>>> 218         /*
>>> 219          * If the fd is unbound, try to bind it.
>>> 220          */
>>> 221         if (madefd || !__rpc_sockisbound(fd)) {
>>> 222                 if (bindaddr =3D=3D NULL) {
>>> 223                         if (bindresvport(fd, NULL) < 0) {
>>>                                 ^^^^^^^^^^^^
>>>=20
>>> 224                                 memset(&ss, 0, sizeof ss);
>>> 225                                 ss.ss_family =3D si.si_af;
>>> 226                                 if (bind(fd, (struct sockaddr =
*)(void *)&ss,
>>> 227                                     (socklen_t)si.si_alen) < 0) =
{
>>> 228                                         warnx(
>>> 229                         "svc_tli_create: could not bind to =
anonymous port");
>>> 230                                         goto freedata;
>>> 231                                 }
>>> 232                         }
>>> 233                         listen(fd, SOMAXCONN);
>>> 234                 } else {
>>> 235                         if (bind(fd,
>>> 236                             (struct sockaddr =
*)bindaddr->addr.buf,
>>> 237                             (socklen_t)si.si_alen) < 0) {
>>> 238                                 warnx(
>>> 239                 "svc_tli_create: could not bind to requested =
address");
>>> 240                                 goto freedata;
>>> 241                         }
>>> 242                         listen(fd, (int)bindaddr->qlen);
>>> 243                 }
>>> 244
>>> 245         }
>>>=20
>>>=20
>>>> Steve Dickson (1):
>>>>  rmtcalls: Don't use privileged ports for remote calls.
>>>>=20
>>>> src/rpcb_svc_com.c | 19 ++++++++++++++++++-
>>>> 1 file changed, 18 insertions(+), 1 deletion(-)
>>>=20
>>>=20
>>> --
>>> Chuck Lever
>>>=20
>>>=20
>>>=20
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>=20
>>>=20
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



