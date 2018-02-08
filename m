Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39393 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750736AbeBHApJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Feb 2018 19:45:09 -0500
From: NeilBrown <neilb@suse.com>
To: Chuck Lever <chuck.lever@oracle.com>
Date: Thu, 08 Feb 2018 11:45:01 +1100
Cc: Tom Talpey <tom@talpey.com>, Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/1] Remote calls don't need to use privilege ports
In-Reply-To: <50CA2D98-813A-4150-B58E-E81B678AA558@oracle.com>
References: <20180205163647.15822-1-steved@redhat.com> <16CF8126-7229-4963-B5D1-2AC16BFC000A@oracle.com> <cc08d8f9-795d-d49c-6354-f5fdbeb85a44@talpey.com> <87eflxo1qp.fsf@notabene.neil.brown.name> <4F3A3FBC-FFA9-4CDA-A38A-73AD07A62A27@oracle.com> <87y3k4mrf8.fsf@notabene.neil.brown.name> <AFF64139-7DD6-4606-9142-B974FDA9C287@oracle.com> <87mv0kmlv6.fsf@notabene.neil.brown.name> <50CA2D98-813A-4150-B58E-E81B678AA558@oracle.com>
Message-ID: <87h8qsmhrm.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 07 2018, Chuck Lever wrote:

>> On Feb 7, 2018, at 6:16 PM, NeilBrown <neilb@suse.com> wrote:
>>=20
>> On Wed, Feb 07 2018, Chuck Lever wrote:
>>=20
>>>> On Feb 7, 2018, at 4:16 PM, NeilBrown <neilb@suse.com> wrote:
>>>>=20
>>>> On Wed, Feb 07 2018, Chuck Lever wrote:
>>>>=20
>>>>>> On Feb 6, 2018, at 11:35 PM, NeilBrown <neilb@suse.com> wrote:
>>>>>>=20
>>>>>> On Mon, Feb 05 2018, Tom Talpey wrote:
>>>>>>=20
>>>>>>> On 2/5/2018 12:02 PM, Chuck Lever wrote:
>>>>>>>> Heya Steve-
>>>>>>>>=20
>>>>>>>>> On Feb 5, 2018, at 11:36 AM, Steve Dickson <steved@redhat.com> wr=
ote:
>>>>>>>>>=20
>>>>>>>>> Over the weekend I did some experimenting with
>>>>>>>>> the remote call code in rpcbind. The code does
>>>>>>>>> functionally work but is very antiquated when
>>>>>>>>> it comes to the latest NFS versions.
>>>>>>>>>=20
>>>>>>>>> Since only UDP sockets are used to do remote calls
>>>>>>>>> using the documented interfaces pmap_rmtcall() and callrpc()
>>>>>>>>> calls to NFS will fail (actual times out) since UDP is no
>>>>>>>>> longer supported.
>>>>>>>>>=20
>>>>>>>>> The undocumented interface rpc_call() can be used to
>>>>>>>>> call into NFS since the protocol can specified, which
>>>>>>>>> also means the PMAPPROC_CALLIT protocol is not used.
>>>>>>>>>=20
>>>>>>>>> It turns out privilege port are not needed to make
>>>>>>>>> remote calls, at least with my testing.
>>>>>>>>=20
>>>>>>>> It's not quite clear what you are claiming here, but
>>>>>>>> I'm guessing that what you demonstrated is that the
>>>>>>>> CALLIT _listener_ does not have to be privileged?
>>>>>>=20
>>>>>> rpcbind listens for CALLIT on port 111.
>>>>>=20
>>>>> Right, my bad. CALLIT is an RPC procedure, not an RPC
>>>>> program.
>>>>>=20
>>>>>=20
>>>>>> Listening on some other port wouldn't ever get the messges...
>>>>>=20
>>>>> Then we still do not understand why rpcbind is opening
>>>>> and registering a second listener port. I can't think of
>>>>> any reason it should do this other than that there is a
>>>>> bug.
>>>>=20
>>>> This is a port on which it forwards CALLIT messages and listens for
>>>> replies, which it then sends back to the originator.  In order to be
>>>> able to handle CALLIT asynchronously with other requests, it needs to
>>>> register the port with the internal listening framework.
>>>=20
>>> Sorry, this is still not making sense to me. Can you create a
>>> ladder diagram that shows the exchange of Call and Reply messages?
>>=20
>> Firstly, portmap binds 2 sockets (ignoring tcp for now), one on port 111
>> and one on an ephemeral port (EP).  It registers both of these internall=
y so
>> incoming packets get noticed.
>
> So we have:
>
> 1 listener bound to 111. This is the main rpcbind service, and it
> is "registered" with the rpcbind service so that it is advertised
> to other RPC clients.
>
> 1 ephemeral port bound to N. This is an RPC client. This socket
> should be completely invisible to remote systems; ie. it is not
> "registered" with the rpcbind service, it is not a passive listener.
>
> I don't understand what you mean by "registers both of these
> internally."

Maybe we are using the word "register" a bit differently because .....

>
> What was reported (in another email thread) is that there appears
> to be a second rpcbind registration on another port visible in the
> rpcinfo listing. I'm trying to understand what that port is for
> (and secondarily why it is using a port < 1024).

.... I can see no evidence of what you say.

>
> https://marc.info/?l=3Dlinux-nfs&m=3D151705744428289&w=3D2

the "listing" is this email message is *not* an rpcinfo listing.
"rpcinfo" is not mentioned in the email.
The listing results "when I do netstat".

If I run
   netstat -uanp | grep rpcbind

I see a very similar listing, though only of the non-111 port (702 on my
desktop).
The 111 port is attributed to systemd, which is expected when rpcbind
was started by systemd's socket-activation.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlp7nY0ACgkQOeye3VZi
gblQmQ/9FNPVK0ekGZ4PDf9ih65DWSPoTpkx1vNKy3lgco8UfNki/LmwAROOobur
5SVC296axU9KwYMKFC5MxqGOsC0CYRHcHLCrAMzFwepL7Ww281YyLxNXrgxe+nsB
WUGdD+ieR409pU2uU33QcPxXiiPQ7CdT3l07qQ0fmXFXSUmKmjmSVab3g3+Mjiba
P4jmhhTAl9Y7/HUBZWfQ2Rd8ALQO03yRc7QqDgRJYuHpMGkR4Q7lyUIIyhGb94lJ
3no9opHAV/uPZr7JX5CMN8zYrOTBspYNYGgWArKVT4tLFzs4l3oJuWs7prJtlJkZ
LJ0o95/Gj+wF3SU5qVGVp0l7jnLojen3OCRKlMbon96z7Fwe0oTtNORdvgl4Siaj
FDF6G6QAor1k5aywkq0x02EKV5BMhjKNKohJazwtlbLYDj+zbYN0kJ25JvdJaCep
9+g+AMi6067Hnp5savC3vH6xHDObPNPdMkcbrtocmYFufQVUTHWc+FCKxxQOLt63
OK+hoe0E62vPTDDaieVr7MNRKmsCBzZG4vonGMpsQI3jgyXr2e/Hm8czksJED2em
ErntRIE6LMxtTwKjuFL2t2B/bVC09T6gBS9e9qFhvlcRd+31roQlIzXESzlPXy/G
uzGL/l/96sBSeqPl9XmFKN2/edw/mForVfZV5Z2AR0uPT7YyGT8=
=AQtM
-----END PGP SIGNATURE-----
--=-=-=--
