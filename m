Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45370 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754531AbcKATzk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 Nov 2016 15:55:40 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 02 Nov 2016 06:55:30 +1100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH nfs-utils] nfs-server-generator: avoid using external services.
In-Reply-To: <4a004767-e7cd-d427-706e-4e144b7bdbbb@RedHat.com>
References: <8737k0215d.fsf@notabene.neil.brown.name> <4a004767-e7cd-d427-706e-4e144b7bdbbb@RedHat.com>
Message-ID: <87wpgnq8jx.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 02 2016, Steve Dickson wrote:

> Hello,
>
> On 10/13/2016 02:50 AM, NeilBrown wrote:
>>=20
>> nfs-server-generator is run very early when a lot of services
>> are not yet started, so it mustn't depend on them.
>> Currently it can try to use hostname lookup and syslog.
>>=20
>> Hostname-lookup is not needed, as we don't use the host issue,
>> and sending message to stderr is sufficient for the generator.
>>=20
>> Disabling syslog is easy - call a function that sets a static variable.
>>=20
>> Disabling hostname lookup isn't quite so easy, so add a static variable
>> which can be set to disable it.
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>=20
>> hi,
>>  I contemplated passing another arg to export_read() and export_d_read()
>>  to resolve this, but it didn't seem worth it.
>>=20
>>  Is this approach OK to people?
> It's not the most eloquent interface I've=20
> ever seen... ;-)=20
>
> What are the failures this is fixing? When a
> hostname lookup is done what happens? Failure
> hangs stopping the server from coming up?

 I never actually reproduced it myself, but I think that when hostname
 lookup failed (possibly after a timeout) it tried to log an error via
 syslog and writing to syslog blocked indefinitely.
 The systemd.generator manpage explicitly rules out trying to talk to
 syslog.


>
>=20=20
>>=20
>> Thanks,
>> NeilBrown
>>=20
>>=20
>>  support/export/export.c        | 12 ++++++++++--
>>  support/include/exportfs.h     |  1 +
>>  systemd/nfs-server-generator.c |  4 ++++
>>  3 files changed, 15 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/support/export/export.c b/support/export/export.c
>> index 0b8a858c2c74..c65dc8807a4e 100644
>> --- a/support/export/export.c
>> +++ b/support/export/export.c
>> @@ -67,6 +67,14 @@ static void warn_duplicated_exports(nfs_export *exp, =
struct exportent *eep)
>>  	}
>>  }
> If we do have to stay with this approach,=20
> I definitely think comment explaining
> why its needed and what it does.

That's sensible.  I'll resend with some nice friendly comments.

>
> Finally, on an unrelated issue I'm seeing=20
> SELinux preventing nfs-server-generator from=20
> accessing nfs-server.service.d/order-with-mounts.conf
> because of a labeling issue. I guess the label
> should be nfsd_unit_file_t not systemd_unit_file_t

I wouldn't know about that :-(

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIbBAEBCAAGBQJYGPMzAAoJEDnsnt1WYoG5OogP+MBSBwfwOJV+XDB5ypjelG4c
BpkURvzdiKpKXGk6vrrHNFcdxmmI7tEbiXlaJA5DR2aT+ydRD99BjQqIW2iAvZMe
AkbGoacogVI9BZQSdGJf8W5CXGbMNFIgygbFuSO+I8J4fEkqfU6P88Gbtk5A0PaN
atETsNmniT2NzA6V2rxn58+GMuaFqmg00I5NX2kKIjuiSOfyw/i2/NCseWbYalz6
WoXrS+tFk7PZfrkLeDzEZufQfGP6v1MBZVQcic4fmemxyaMWk2lafBQ82SwC0f4y
VG4AOaA91fA0dOO/QfMy2q71Y25wLRicj+bOGcsTaxebdHdluyDQn9HPRHwglQ4b
KauaKPbIMApD5ZI1v6nEY1jkxMVwV6/jZatDbE+hLEqqPjJXXOvWD4kU18BXN41G
m2bRCGo4gFcvOEjw2UmvC8QGT4WyKP1Gtz8Op9z9A99/WoVjfQd4/e2WHvLpyrtN
R+8tbUKqO94WMosJdMLkTuQabR7NkKT6CPn93K4bjt3s0rVe8Eu3WPut2v2ja3vT
FHQmYBRzMK6NnKagbUmR58QmErzFRyuaUaqf5xFoBVzrpeP0vGaoxPcAJLODNZ1S
JGduTOqCGiQ7NDBHPMiKDne/fVG2PFa+lwq2v9FWpXoTEuNiJ6M3fZ6pJK/4Gtl2
FXfXyALceOyXCg1f1q0=
=lvUT
-----END PGP SIGNATURE-----
--=-=-=--
