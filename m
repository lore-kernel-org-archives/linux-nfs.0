Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55833 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754281AbeBGVQm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Feb 2018 16:16:42 -0500
From: NeilBrown <neilb@suse.com>
To: Chuck Lever <chuck.lever@oracle.com>
Date: Thu, 08 Feb 2018 08:16:27 +1100
Cc: Tom Talpey <tom@talpey.com>, Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/1] Remote calls don't need to use privilege ports
In-Reply-To: <4F3A3FBC-FFA9-4CDA-A38A-73AD07A62A27@oracle.com>
References: <20180205163647.15822-1-steved@redhat.com> <16CF8126-7229-4963-B5D1-2AC16BFC000A@oracle.com> <cc08d8f9-795d-d49c-6354-f5fdbeb85a44@talpey.com> <87eflxo1qp.fsf@notabene.neil.brown.name> <4F3A3FBC-FFA9-4CDA-A38A-73AD07A62A27@oracle.com>
Message-ID: <87y3k4mrf8.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 07 2018, Chuck Lever wrote:

>> On Feb 6, 2018, at 11:35 PM, NeilBrown <neilb@suse.com> wrote:
>>=20
>> On Mon, Feb 05 2018, Tom Talpey wrote:
>>=20
>>> On 2/5/2018 12:02 PM, Chuck Lever wrote:
>>>> Heya Steve-
>>>>=20
>>>>> On Feb 5, 2018, at 11:36 AM, Steve Dickson <steved@redhat.com> wrote:
>>>>>=20
>>>>> Over the weekend I did some experimenting with
>>>>> the remote call code in rpcbind. The code does
>>>>> functionally work but is very antiquated when
>>>>> it comes to the latest NFS versions.
>>>>>=20
>>>>> Since only UDP sockets are used to do remote calls
>>>>> using the documented interfaces pmap_rmtcall() and callrpc()
>>>>> calls to NFS will fail (actual times out) since UDP is no
>>>>> longer supported.
>>>>>=20
>>>>> The undocumented interface rpc_call() can be used to
>>>>> call into NFS since the protocol can specified, which
>>>>> also means the PMAPPROC_CALLIT protocol is not used.
>>>>>=20
>>>>> It turns out privilege port are not needed to make
>>>>> remote calls, at least with my testing.
>>>>=20
>>>> It's not quite clear what you are claiming here, but
>>>> I'm guessing that what you demonstrated is that the
>>>> CALLIT _listener_ does not have to be privileged?
>>=20
>> rpcbind listens for CALLIT on port 111.
>
> Right, my bad. CALLIT is an RPC procedure, not an RPC
> program.
>
>
>> Listening on some other port wouldn't ever get the messges...
>
> Then we still do not understand why rpcbind is opening
> and registering a second listener port. I can't think of
> any reason it should do this other than that there is a
> bug.

This is a port on which it forwards CALLIT messages and listens for
replies, which it then sends back to the originator.  In order to be
able to handle CALLIT asynchronously with other requests, it needs to
register the port with the internal listening framework.
For comparison, portmap handles CALLIT asynchronously by forking.

Thanks,
NeilBrown


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlp7bKsACgkQOeye3VZi
gbnPRg/+Of/6Mg7BclHQNbtNEgLEAgnuoIk0fZdJFjuQjf9c37356BYGGwf5iIGu
2Ozknmp12mxypvOUuyCTNh6B5IXffEryrL6b18kP+5cEQC7102KCCj0noX/lh301
c+fTf+VifLrNIsfitF2TvgU5uZwx9+/lQNm+0ucpDnG/dvGA9Fruz7p2A/68LmTi
AD22dXBy+Hr1WdoS3LqvaFscdRKnVqJIeTNVh1OaftBy9rR5k9+3USJqvPQGUCZ/
cw9eKzfK1GHLl/VwzoGIO6s7fwFOp7QkjrtolphlAJpqvPUeuSi7skNsyDQG9Met
Jl1EX1lrR6F36lOyNx5uLCB5G9qeNLRt2b5eGib5nEtHbbUp0s1wF+Gf4MuoX4ll
V9p08qdPYZgD7Vgcx0cYpaqGcsxwQBlzZ6CvRM3WNoc8gsQ2enh5IoKojLoSy8E/
1sEQ+XMo0srOeevf5g7zHBKv87srjobNLn31h1hIejxMHCX9p8Vwn2lLBPXqz1My
/P5Tr3rhewyjODX/emxlC3AQm8SBbp7b2ekA/BnpgecsJMMRRo4t2shq9KVoJzxc
q4GfkG4QH4cCgmsMOfVmfc8vuJIfLmJHm/Oa68QpCURQYdcXPQEaqH7J705jFGBd
EaIJjLGsdNObLWakHNOBbq2xZVoTI49xHKg/KbSOGubu1hSbnQo=
=C52Q
-----END PGP SIGNATURE-----
--=-=-=--
