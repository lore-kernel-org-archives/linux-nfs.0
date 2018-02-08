Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:33850 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750736AbeBHANo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Feb 2018 19:13:44 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH 0/1] Remote calls don't need to use privilege ports
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <87mv0kmlv6.fsf@notabene.neil.brown.name>
Date: Wed, 7 Feb 2018 19:13:36 -0500
Cc: Tom Talpey <tom@talpey.com>, Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <50CA2D98-813A-4150-B58E-E81B678AA558@oracle.com>
References: <20180205163647.15822-1-steved@redhat.com>
 <16CF8126-7229-4963-B5D1-2AC16BFC000A@oracle.com>
 <cc08d8f9-795d-d49c-6354-f5fdbeb85a44@talpey.com>
 <87eflxo1qp.fsf@notabene.neil.brown.name>
 <4F3A3FBC-FFA9-4CDA-A38A-73AD07A62A27@oracle.com>
 <87y3k4mrf8.fsf@notabene.neil.brown.name>
 <AFF64139-7DD6-4606-9142-B974FDA9C287@oracle.com>
 <87mv0kmlv6.fsf@notabene.neil.brown.name>
To: NeilBrown <neilb@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Feb 7, 2018, at 6:16 PM, NeilBrown <neilb@suse.com> wrote:
>=20
> On Wed, Feb 07 2018, Chuck Lever wrote:
>=20
>>> On Feb 7, 2018, at 4:16 PM, NeilBrown <neilb@suse.com> wrote:
>>>=20
>>> On Wed, Feb 07 2018, Chuck Lever wrote:
>>>=20
>>>>> On Feb 6, 2018, at 11:35 PM, NeilBrown <neilb@suse.com> wrote:
>>>>>=20
>>>>> On Mon, Feb 05 2018, Tom Talpey wrote:
>>>>>=20
>>>>>> On 2/5/2018 12:02 PM, Chuck Lever wrote:
>>>>>>> Heya Steve-
>>>>>>>=20
>>>>>>>> On Feb 5, 2018, at 11:36 AM, Steve Dickson <steved@redhat.com> =
wrote:
>>>>>>>>=20
>>>>>>>> Over the weekend I did some experimenting with
>>>>>>>> the remote call code in rpcbind. The code does
>>>>>>>> functionally work but is very antiquated when
>>>>>>>> it comes to the latest NFS versions.
>>>>>>>>=20
>>>>>>>> Since only UDP sockets are used to do remote calls
>>>>>>>> using the documented interfaces pmap_rmtcall() and callrpc()
>>>>>>>> calls to NFS will fail (actual times out) since UDP is no
>>>>>>>> longer supported.
>>>>>>>>=20
>>>>>>>> The undocumented interface rpc_call() can be used to
>>>>>>>> call into NFS since the protocol can specified, which
>>>>>>>> also means the PMAPPROC_CALLIT protocol is not used.
>>>>>>>>=20
>>>>>>>> It turns out privilege port are not needed to make
>>>>>>>> remote calls, at least with my testing.
>>>>>>>=20
>>>>>>> It's not quite clear what you are claiming here, but
>>>>>>> I'm guessing that what you demonstrated is that the
>>>>>>> CALLIT _listener_ does not have to be privileged?
>>>>>=20
>>>>> rpcbind listens for CALLIT on port 111.
>>>>=20
>>>> Right, my bad. CALLIT is an RPC procedure, not an RPC
>>>> program.
>>>>=20
>>>>=20
>>>>> Listening on some other port wouldn't ever get the messges...
>>>>=20
>>>> Then we still do not understand why rpcbind is opening
>>>> and registering a second listener port. I can't think of
>>>> any reason it should do this other than that there is a
>>>> bug.
>>>=20
>>> This is a port on which it forwards CALLIT messages and listens for
>>> replies, which it then sends back to the originator.  In order to be
>>> able to handle CALLIT asynchronously with other requests, it needs =
to
>>> register the port with the internal listening framework.
>>=20
>> Sorry, this is still not making sense to me. Can you create a
>> ladder diagram that shows the exchange of Call and Reply messages?
>=20
> Firstly, portmap binds 2 sockets (ignoring tcp for now), one on port =
111
> and one on an ephemeral port (EP).  It registers both of these =
internally so
> incoming packets get noticed.

So we have:

1 listener bound to 111. This is the main rpcbind service, and it
is "registered" with the rpcbind service so that it is advertised
to other RPC clients.

1 ephemeral port bound to N. This is an RPC client. This socket
should be completely invisible to remote systems; ie. it is not
"registered" with the rpcbind service, it is not a passive listener.

I don't understand what you mean by "registers both of these
internally."

What was reported (in another email thread) is that there appears
to be a second rpcbind registration on another port visible in the
rpcinfo listing. I'm trying to understand what that port is for
(and secondarily why it is using a port < 1024).

https://marc.info/?l=3Dlinux-nfs&m=3D151705744428289&w=3D2

I still don't see the point of the listener on port 831. I don't
expect that ephemeral "client" socket to be visible in the rpcinfo
listing, for example.


> If it receives SET or UNSET or GETADDR etc on 111, it replies =
directly.
> CALLIT is a bit more complete.
>=20
> remote-client                rpcbind               local-service
>                   111
> send CALLIT(XX) ------>rpcbproc_callit_com()  EP
>                        unwrap/send XX ----------------->handle
>                                             EP
>                  111    handle_reply()<----------------send reply
>  receive reply<-------wrap-and-send
>=20
>=20
> does that help?  The callit request/reply to/from port 111 has
> some other request/reply embeded in it.
> This embedded request/reply is sent/received unwrapped on the =
ephemeral
> port.

That aligns with my understanding of how CALLIT works. The second
socket is not a listener, as I understand it, unless you're
suggesting that rpcbind sets up the second socket as a listener
to receive only replies to forwarded CALLIT requests?

The bug, then, would be that the second socket shouldn't be
registered with the official rpcbind service, so that it will not
be displayed in rpcinfo output.

Clients have "port 111" nailed in as the portmapper, so I can't
see what use a second rpcbind registration would provide.


> NeilBrown
>=20
>=20
>=20
>>=20
>>> For comparison, portmap handles CALLIT asynchronously by forking.
>>>=20
>>> Thanks,
>>> NeilBrown
>>=20
>> --
>> Chuck Lever

--
Chuck Lever



