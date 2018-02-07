Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34783 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750729AbeBGXQk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Feb 2018 18:16:40 -0500
From: NeilBrown <neilb@suse.com>
To: Chuck Lever <chuck.lever@oracle.com>
Date: Thu, 08 Feb 2018 10:16:29 +1100
Cc: Tom Talpey <tom@talpey.com>, Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/1] Remote calls don't need to use privilege ports
In-Reply-To: <AFF64139-7DD6-4606-9142-B974FDA9C287@oracle.com>
References: <20180205163647.15822-1-steved@redhat.com> <16CF8126-7229-4963-B5D1-2AC16BFC000A@oracle.com> <cc08d8f9-795d-d49c-6354-f5fdbeb85a44@talpey.com> <87eflxo1qp.fsf@notabene.neil.brown.name> <4F3A3FBC-FFA9-4CDA-A38A-73AD07A62A27@oracle.com> <87y3k4mrf8.fsf@notabene.neil.brown.name> <AFF64139-7DD6-4606-9142-B974FDA9C287@oracle.com>
Message-ID: <87mv0kmlv6.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 07 2018, Chuck Lever wrote:

>> On Feb 7, 2018, at 4:16 PM, NeilBrown <neilb@suse.com> wrote:
>>=20
>> On Wed, Feb 07 2018, Chuck Lever wrote:
>>=20
>>>> On Feb 6, 2018, at 11:35 PM, NeilBrown <neilb@suse.com> wrote:
>>>>=20
>>>> On Mon, Feb 05 2018, Tom Talpey wrote:
>>>>=20
>>>>> On 2/5/2018 12:02 PM, Chuck Lever wrote:
>>>>>> Heya Steve-
>>>>>>=20
>>>>>>> On Feb 5, 2018, at 11:36 AM, Steve Dickson <steved@redhat.com> wrot=
e:
>>>>>>>=20
>>>>>>> Over the weekend I did some experimenting with
>>>>>>> the remote call code in rpcbind. The code does
>>>>>>> functionally work but is very antiquated when
>>>>>>> it comes to the latest NFS versions.
>>>>>>>=20
>>>>>>> Since only UDP sockets are used to do remote calls
>>>>>>> using the documented interfaces pmap_rmtcall() and callrpc()
>>>>>>> calls to NFS will fail (actual times out) since UDP is no
>>>>>>> longer supported.
>>>>>>>=20
>>>>>>> The undocumented interface rpc_call() can be used to
>>>>>>> call into NFS since the protocol can specified, which
>>>>>>> also means the PMAPPROC_CALLIT protocol is not used.
>>>>>>>=20
>>>>>>> It turns out privilege port are not needed to make
>>>>>>> remote calls, at least with my testing.
>>>>>>=20
>>>>>> It's not quite clear what you are claiming here, but
>>>>>> I'm guessing that what you demonstrated is that the
>>>>>> CALLIT _listener_ does not have to be privileged?
>>>>=20
>>>> rpcbind listens for CALLIT on port 111.
>>>=20
>>> Right, my bad. CALLIT is an RPC procedure, not an RPC
>>> program.
>>>=20
>>>=20
>>>> Listening on some other port wouldn't ever get the messges...
>>>=20
>>> Then we still do not understand why rpcbind is opening
>>> and registering a second listener port. I can't think of
>>> any reason it should do this other than that there is a
>>> bug.
>>=20
>> This is a port on which it forwards CALLIT messages and listens for
>> replies, which it then sends back to the originator.  In order to be
>> able to handle CALLIT asynchronously with other requests, it needs to
>> register the port with the internal listening framework.
>
> Sorry, this is still not making sense to me. Can you create a
> ladder diagram that shows the exchange of Call and Reply messages?

Firstly, portmap binds 2 sockets (ignoring tcp for now), one on port 111
and one on an ephemeral port (EP).  It registers both of these internally so
incoming packets get noticed.
If it receives SET or UNSET or GETADDR etc on 111, it replies directly.
CALLIT is a bit more complete.

remote-client                rpcbind               local-service
                   111
 send CALLIT(XX) ------>rpcbproc_callit_com()  EP
                        unwrap/send XX ----------------->handle
                                             EP
                  111    handle_reply()<----------------send reply
  receive reply<-------wrap-and-send


does that help?  The callit request/reply to/from port 111 has
some other request/reply embeded in it.
This embedded request/reply is sent/received unwrapped on the ephemeral
port.

NeilBrown



>
>> For comparison, portmap handles CALLIT asynchronously by forking.
>>=20
>> Thanks,
>> NeilBrown
>
> --
> Chuck Lever

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlp7iM4ACgkQOeye3VZi
gbl92BAArOppbFIMvi+50NDE+MNRDNrf0A3D7+udY+7/lsWSQ4LwByERGO45HWBE
Cm24nLfgPc45k5IYjxOs2yMwkpEdmtKozK54lJjvf9MNy1TlMXjkIkT4VI7NLDwu
ljQYxoxedjmC0MJqBFARI/akjvsANPgm/8iV8XlQs4abGC/t29gaKRHDCvB6wcjk
VJYFHWJisIvJ4hcM8wy8D9D8sKSu5Bmp6PrcKCwqp/rOLHeF54aiRky4mFD0V6Xq
8n9KAGnpVgD4o2BZn7FhDJoSc8uOD6BfKgrXCouZ7gOqrN3H+FbAw/0+Q+8FoJhn
zyRg+IHW83mYg+Sr+ukzt31095O3xEUtUArECnBQuf0Vrp5VPN0Ejm1OaCTNP1uf
llApF+uODaR0FECvCHAR6TwSXVLeRyL871ewIzP/zDTt1OzPCkBvr5cAj2Z0T9t5
HBnfHZrZR5y+7kQRr/6PtImNmj0sNwxO/lFkUgxHHT+6d9FT1V5wJlv0UUBLlIxB
5RRW0c46b00xcny/eLxCAoRotZewJAhuI4RV6e/1qMQboxwNXXrJYOb0kkIm19FC
X8+YTsRkEOMc8uHwnORszjkz8I4U0KPyVbExrG5V3dswzVhnPU+3pSu6M8VVgRD3
aEa2lj1TxObXRVUcLYygPDSLOXQPDQ8wFVKxTePGBVzfP5/uwYA=
=ixGq
-----END PGP SIGNATURE-----
--=-=-=--
