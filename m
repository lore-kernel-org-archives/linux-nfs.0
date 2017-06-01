Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56542 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751028AbdFAA2B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 May 2017 20:28:01 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@RedHat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Thu, 01 Jun 2017 10:27:53 +1000
Subject: Re: [PATCH 1/2] mount.nfs: v4 mounts should fail when -o flag is used.
In-Reply-To: <10eb706b-2f8b-24ad-d572-eb38abdb331d@RedHat.com>
References: <20170519222510.31205-1-steved@redhat.com> <87inktk2yg.fsf@notabene.neil.brown.name> <5a0d2640-ec93-279b-9113-228994283923@RedHat.com> <877f18jsx5.fsf@notabene.neil.brown.name> <10eb706b-2f8b-24ad-d572-eb38abdb331d@RedHat.com>
Message-ID: <87h900eely.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, May 31 2017, Steve Dickson wrote:

> Sorry for the delayed response... that damn=20
> flux capacitor broke... again! ;-)=20

That's what you get for buying it on e-bay??


>>=20
>> According to the extra comments you have added for the modes:
>>=20
>>>>> +	V_GENERAL,     /* single digit =3D> 4 */
>>>>> +	V_SPECIFIC,    /* single digit < 4 or decimal included */
>>=20
>> And it seems to me that "v4" should be V_GENERAL, not V_SPECIFIC.
>> So I think the current code is correct.
> Personally I don't see a needed for V_GENERAL v_mode type
> I guess it has to do with the specifying minor version or not
> but if any thing is specified on the command line or=20
> nfsmount.conf then it is V_SPECIFIC... IMHO.

Maybe V_GENERAL should be V_MAJOR or V_SPECIFIC_MAJOR.
The v4 code assumes that if V_SPECIFIC is set, then
the version option provided to the mount command
can be passed unchanged to the kernel.
So it sometimes means V_NO_NEGOTIATE.

>> I haven't even compile-tested of course :-)
> I have and it does compile and work... Would you
> mind reposting the patch in the proper format?
> You can added Tested-by: Steve Dickson <steved@redhat.com>

Done.

>
> Note: The second patch should probably use V_GENERAL as well.

Yes, definitely.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlkvX4sACgkQOeye3VZi
gblPrw/+JWVLaq575kJQ5gAilWMqbk7cmWeT8U0ZQGy7rGHlRgsp9I+pmaaHMy2s
wj9ay8dlY+4sFepzVNyQWOeosizuzuwsf1MOCPxKCMl/L0XTwxEG4aEix4z1Uf7d
ZgfloP8XI+VfemY+CE9ZF3NHGwZrUudMxy1KbBnnC7lmHZ3GIUmi7+yNzSebhwGC
9YHcBKC5g45ozwGF+Aek4eSkvf7tgJvVup68Pmfq6/n4fI892i6dxkstpZC2wtuq
/XrMk+gxjPewr0nDGup2o9zeUCuq0nE89LzxGr+JIQiRpBQe16N0ovr+7rFg1kAl
TM8HQ+E9gPTLAogULPdTo/klEpoaWyIszhtaqC6JUzT5CaQl/Ix3pI4v8tlPqxzO
8dgJt3FtCATN27c7xfeqPcDXUoCKjVGuLOoEQZUsVXC33cU1EFA87pzmikAlSq4H
3TyoEr7wetIMIK1uJYIVaKLeWHp3aEe9iWrrZE0GxIxAEWMG3s+j4Y2+WKEdqlwI
HhTP1BUJiDqg/jabMkCMMT3MGnArbacHJsZt5RFdK7ALxjYyGfepDLUxmxzDcYsb
ZfOWxcBBTJniSqAvlu+NlsbgITFQ/h0a5g2+7uVJ+pE0bPY28fo2aIZv0FQoM0Iq
8OzYNwo/5ugyZHYqO/UgYPmxRXolvDMczKC46bcniClywT9GqPw=
=dNPB
-----END PGP SIGNATURE-----
--=-=-=--
