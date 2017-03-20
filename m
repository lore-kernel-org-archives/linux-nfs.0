Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52836 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751261AbdCTFII (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Mar 2017 01:08:08 -0400
From: NeilBrown <neilb@suse.com>
To: Daniel Pocock <daniel@pocock.pro>,
        Niels Thykier <niels@thykier.net>, linux-nfs@vger.kernel.org,
        852395@bugs.debian.org, Robbie Harwood <rharwood@club.cc.cmu.edu>
Date: Mon, 20 Mar 2017 16:07:40 +1100
Cc: Debian kernel team <debian-kernel@lists.debian.org>
Subject: Re: Bug#852395: unblock: gssproxy/0.5.1-2
In-Reply-To: <f4e3252f-0115-954d-5749-c330c6905b75@pocock.pro>
References: <148524180980.26332.422684345851896222.reportbug@kirtar> <8ed20c71-d7e2-72e1-a8ce-c913f8e0fffd@thykier.net> <17e5fbd0-9bb1-d7fa-6056-8adbda8a1f4d@pocock.pro> <e157cdda-35b6-8643-7d9f-da79faec56f7@thykier.net> <e157cdda-35b6-8643-7d9f-da79faec56f7@thykier.net> <5df78805-b791-0a5e-3dcb-99792d78c3bd@thykier.net> <f4e3252f-0115-954d-5749-c330c6905b75@pocock.pro>
Message-ID: <87o9wwcz8j.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Sun, Mar 05 2017, Daniel Pocock wrote:

> On 05/03/17 19:42, Niels Thykier wrote:
>> On Sat, 04 Feb 2017 09:58:00 +0000 Niels Thykier <niels@thykier.net> wrote:
>>> Daniel Pocock:
>>>> [...]
>>>>
>>>> Upstream is not really supporting rpc.svcgssd any more, they actually
>>>> disabled it in the build so people can still have it as a transitional
>>>> measure in stretch.
>>>>
>>>> People shouldn't be using it in any new installations.  Offering them
>>>> gssproxy is a very sensible thing to do.
>>>>
>>>> Regards,
>>>>
>>>> Daniel
>>>>
>>> Debian kernel team <debian-kernel@lists.debian.org>
>>> Ok, follow up questions:
>>>
>>>  * Do you have an upstream reference to the state of rpc.svcgssd?
>
>
> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=commit;h=24b5d60d7f0a514310df810e3eb27b72f665febf
>
> "svcgssd: Disable support for the rpcsec_gss server by default
>
> At this point the gssproxy is better option than the
> svcgssd so the support is off by default.
>
> Use --enable-svcgss to re-enable the support"
>
> but it looks like it may not be completely abandoned, there have been
> other commits that mention gssd recently.
>
>
>>>
>>>  * Can we provide both rpc.svcgssd and gssproxy in Debian (with the
>>>    admin choosing) or is it an "xor"?
>>>
>
> I think there are two questions:
>
> a) can they both exist in different packages that conflict with each
> other?  I'm guessing that will probably be yes.
>
> b) can they both be installed simultaneously?  Possibly not (can anybody
> on the linux-nfs list answer?)

Yes, they can.
The systemd unit files are designed so that svcgssd will only be started
if gssproxy didn't start - and gssproxy is tried first.

If you use something other than systemd, similar logic would be needed.

NeilBrown


>
>
>>>  * If this package is unblocked, are there any changes needed in
>>>    nfs-common needed to support gssproxy?  (source upload, binNMU or
>>>    "just works with no further changes")
>>>
>
> I don't have time to investigate that right now, if anybody else has
> time to look more closely that would be great.
>
> Regards,
>
> Daniel
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljPY50ACgkQOeye3VZi
gbnNNA/9HBVdo5HtOfI5gLSfvIYwf8LdNDUDsUNs47qn2/aqxEsmVPr2yAzRaUzM
wNl/J4soS202XnsyqzhACeZufFMGshQjCGY1opX4Af4jocJeItIx0MsHbPmDUq5S
a5XZbO4ch3D8KpQnYexB36CrkpLPDtHfNvsaNK81+2NRzY/9LY1PRxizQUj+xe7x
MyLfNlmvpA7WvwkgDnFymwQST+1XoIQWVuNcPiBthzCWMcSo5wRy7eIWXET7ld9c
hk0bL//aa240tzCfFNwqs/wkT/mo31eq+A+4g+jilptC2+6yB1Xj3Y1z1PChSWkP
RpXtwWCxWJXUR00jJ985liKgqcO5FgPQAZgMBuEcUeKp+XucY1MX64ri2oz8bgrJ
fwdmu6bQFlmMdzRrxD5tHB7lazpJsIX6TY55HE1ww3iTWe5nuEqpN4EO+fPBosXQ
b8oWyWPELTRNwxt42GL93CiJLe1AWiRfi8jy+19vlJuno6v1SP6SG9ct5Ltynlc8
gkvA8z+FvYaazO5VCFtZ+jldwgQWX2yGhLxynWpX6kSyXR2bIX5KaF0d0IQUCPF2
VHAJ9DXrZoct0W0D8M4ALQUPmEjeAShtGa7QFdlCzouVld8824NESMrGsDWF8LRm
DyNy0C+ldY294sKryImsUnRLc9clsrgTuju4oX3yvy3Lj93BLuo=
=DJyF
-----END PGP SIGNATURE-----
--=-=-=--
