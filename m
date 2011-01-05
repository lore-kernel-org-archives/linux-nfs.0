Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33855 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216Ab1AEPBj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 10:01:39 -0500
Message-ID: <4D2487CA.5040501@pengutronix.de>
Date: Wed, 05 Jan 2011 16:01:30 +0100
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: =?UTF-8?B?VXdlIEtsZWluZS1Lw7ZuaWc=?=
	<u.kleine-koenig@pengutronix.de>,
        Russell King - ARM Linux <linux@arm.linux.org.uk>,
        linux-nfs@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
References: <20101230171453.GA5787@pengutronix.de>	 <1293731992.4919.5.camel@heimdal.trondhjem.org>	 <20101230191846.GB14221@pengutronix.de>	 <20110103213850.GC25121@pengutronix.de>	 <1294100558.25100.8.camel@heimdal.trondhjem.org>	 <20110105084014.GN25121@pengutronix.de>	 <20110105110517.GQ25121@pengutronix.de>	 <20110105112701.GA8638@n2100.arm.linux.org.uk>	 <20110105134045.GS25121@pengutronix.de> <1294239193.3014.9.camel@heimdal.trondhjem.org>
In-Reply-To: <1294239193.3014.9.camel@heimdal.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig25D519CC34284BF7105FB8D9"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------enig25D519CC34284BF7105FB8D9
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/05/2011 03:53 PM, Trond Myklebust wrote:
> On Wed, 2011-01-05 at 14:40 +0100, Uwe Kleine-K=C3=B6nig wrote:=20
>> Hi Russell,
>>
>> On Wed, Jan 05, 2011 at 11:27:01AM +0000, Russell King - ARM Linux wro=
te:
>>> On Wed, Jan 05, 2011 at 12:05:17PM +0100, Uwe Kleine-K=C3=B6nig wrote=
:
>>>> Hello Trond,
>>>>
>>>> On Wed, Jan 05, 2011 at 09:40:14AM +0100, Uwe Kleine-K=C3=B6nig wrot=
e:
>>>>> On Mon, Jan 03, 2011 at 07:22:38PM -0500, Trond Myklebust wrote:
>>>>>> The question is whether this is something happening on the server =
or the
>>>>>> client. Does an older client kernel boot without any trouble?
>>>>> I will set up a boot test with 2.6.37 (for statistics) and 2.6.36 t=
o
>>>>> compare with.  If you don't consider .36 to be old enough let me no=
w.
>>>>> Once the setup is done it should be easy to test .35 (say), too.
>>>>>
>>>> Marc (cc'd) saw similar[1] problems with .37, when using .36.2 the
>>>> problems didn't occur.  This was more reliable to trigger and he was=
 so
>>>> kind to bisect the problem.
>>>>
>>>> When testing v2.6.36-rc3-51-gafa8ccc init hanged.
>>>> (babddc72a9468884ce1a23db3c3d54b0afa299f0 is the first bad commit wi=
th
>>>> this hang.)  Commit 56e4ebf877b6043c289bda32a5a7385b80c17dee makes t=
he
>>>> "init hangs" problem the "fileid changed on tab" problem.
>>>>
>>>> I could only reproduce that on armv5 machines (imx27, imx28 and at91=
)
>>>> but not on armv6 (imx35).
>>>
>>> FYI, I've seen the "fileid changed" problem, and it looked like a 32-=
bit
>>> truncation of the fileid.  It occurred several times on successive
>>> reboots, so I tried to capture a tcpdump trace off the server (Linux
>>> 2.6.23-rc8-ga64314e6 - its ancient because I've had issues with buggy=

>>> IDE drivers trying to move it forward.)  However, for the last couple=

>>> of weeks I've been unable to reproduce it.
>>>
>>> The client was based on 2.6.37-rc6.
>>>
>>> The "fileid changed" messages popped up after mounting an export with=

>>> 'nolock,intr,rsize=3D4096,soft', and then trying to use bash completi=
on
>>> and 'ls' in a few subdirectories - and entries were missing from the
>>> directory lists without 'ls' reporting any errors (which I think is b=
ad
>>> behaviour in itself.)
>> There was a bug in at least -rc5[1] that was considered already fixed =
in
>> -rc4[2]. The later announcements didn't mention it anymore.=20
>>
>>> I don't know why it's stopped producing the errors, although once it
>>> went I never investigated it any further (was far too busy trying to
>>> get AMBA DMA support working.)
>> It seems it was fixed for most users though. Trond?
>=20
> As I said, I can't reproduce it.
>=20
> I'm seeing a lot of mention of ARM above. Is anyone seeing this bug on
> x86, or does it appear to be architecture-specific?

It _seems_ to be ARMv5 specific[1]. Uwe did some tests and figured out
that disabling dcache on ARMv5 "fixes" the problem, but
CONFIG_CPU_DCACHE_WRITETHROUGH isn't enough.

[1] Uwe fails to reproduce it on ARMv6. The ARMv6 has a L2 cache and
uses IIRC different instructions to flush the L1 caches. (please correct
me, if I'm wrong, ARM guys :)

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig25D519CC34284BF7105FB8D9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk0kh84ACgkQjTAFq1RaXHPZYACeIwsQIuLez7XieANUchHvhM3N
KxQAn07ibbpviIzvnlidOnf7bUKH7uAB
=1+YD
-----END PGP SIGNATURE-----

--------------enig25D519CC34284BF7105FB8D9--
