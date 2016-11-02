Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40045 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757186AbcKBVQi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 Nov 2016 17:16:38 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>, Thorsten Kukuk <kukuk@suse.de>
Date: Thu, 03 Nov 2016 08:16:30 +1100
Cc: linux-nfs@vger.kernel.org, libtirpc-devel@lists.sourceforge.net
Subject: Re: [Libtirpc-devel] [PATCH - rpcbind] Provide systemd unit files for rpcbind
In-Reply-To: <34b0c398-c77f-41e3-4719-158f2190661c@RedHat.com>
References: <87oa2q14yc.fsf@notabene.neil.brown.name> <8c1fa65d-9efc-462a-b6c8-7ed518f0dfe4@RedHat.com> <87r36vq85k.fsf@notabene.neil.brown.name> <ff5e0322-2f5e-9102-326f-1f23968cb0a8@RedHat.com> <20161102134902.GA6446@suse.de> <34b0c398-c77f-41e3-4719-158f2190661c@RedHat.com>
Message-ID: <87a8dhr39t.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 03 2016, Steve Dickson wrote:

> On 11/02/2016 09:49 AM, Thorsten Kukuk wrote:
>> On Wed, Nov 02, Steve Dickson wrote:
>>=20
>>> I just took a look and we don't set that... Here is what we
>>> set in Fedora
>>>
>>> RPCBDIR=3D/tmp
>>> %configure CFLAGS=3D"$CFLAGS" LDFLAGS=3D"-pie" \
>>>     --enable-warmstarts \
>>>     --with-statedir=3D"$RPCBDIR" \
>>>     --with-rpcuser=3D"$RPCBUSR" \
>>>     --with-nss-modules=3D"files altfiles" \
>>>     --enable-libwrap \
>>>     --enable-debug
>>=20
>> The rpcbind Makefile has:
>> bin_PROGRAMS =3D rpcbind rpcinfo
>>=20
>> So per default, "make install" should install it into /usr/bin
>> and the patch from Niel with bin is correct.
> You are correct... In  %install does the following
>
> mv -f ${RPM_BUILD_ROOT}%{_bindir}/rpcbind ${RPM_BUILD_ROOT}/sbin
> mv -f ${RPM_BUILD_ROOT}%{_bindir}/rpcinfo ${RPM_BUILD_ROOT}%{_sbindir}
>
> Since rpcbind lives in /usr/sbin in the majority distro
> I'm going to change the Makefile.am so "make install"=20
> will do the right thing... Any objections?

If you do it by changing the default for bindir, or by introducing an
sbindir that can be changed with configure, then no objections from me.
I'm not sure it really needs fixing, but I don't object to be being
fixed.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYGleuAAoJEDnsnt1WYoG5bKcP/2M4oTRLJPvR6vNpQ4wHD1oQ
kvO5NsZN6OA+rSiOfbrmZsdi/mhHRmeXzIdUZM2WU7riL5dPP7mfhx+5NQSYRGAZ
3Fph8y5TJLRsyygbLSfudd4Gz4lpiecoQr3XT+sZ46RdtRNvxWVXxLe7Zk8YqcOq
OBDOSY1HeSIm0/Ca417h7HUvXGUB7izLCySh0fzXc3shypklk4zKm26hJiWBzVWy
RwZnM8A/DYX9bMbkZHJEhfLuUJCakR5zxGwcnaerWCs+yDUQ4dq3MUFc3tWvX6yG
r5EH035OVcVlY2ItZYdYMX666eKTbAod6/vQn7FSrZyhX5GBy/N/EZnwheLSG7YY
NXSTsYMcpn28RwDdoEycK2mP3Z+LiHUNEGS4bN+DqHgznaQKT9TYBcZIyDHNP64n
fDPW3Dr8u2MtOm6X2+vvIZGf4qXixekUZn/sPP1QWfnTSkcbsuCourB9DNFTXwSl
8i6tMxlISdTHZRBLd+WJtfl1qqglkDLMD1nWWzCQtwcuEp2aQmW3L9rUnwZ/gbQj
SLQAdP+BOaSplTPgDcbtpWDexopAt3Si7tr3bC2A98O3luQUtlpn0MuxvpwXS+qg
o2SqF+EKzC4RSlH8Z7/8+iwvOZq4WgOP0Ao5Q3SeA9rIKjkNtVC7uoBzP7gi0hEW
zCD42M57qaoIY1S9/xkr
=zYo3
-----END PGP SIGNATURE-----
--=-=-=--
