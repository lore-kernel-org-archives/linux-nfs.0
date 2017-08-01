Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56891 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751591AbdHAFWs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 Aug 2017 01:22:48 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@RedHat.com>,
        Michael Orlitzky <michael@orlitzky.com>,
        linux-nfs@vger.kernel.org
Date: Tue, 01 Aug 2017 15:22:39 +1000
Subject: Re: [PATCH 1/1] autotools: install rpcbind to --sbindir.
In-Reply-To: <ab9fa53d-8301-f6e8-50d5-0ccddd2dccb6@RedHat.com>
References: <20170728135253.24542-1-michael@orlitzky.com> <20170728135253.24542-2-michael@orlitzky.com> <ab9fa53d-8301-f6e8-50d5-0ccddd2dccb6@RedHat.com>
Message-ID: <87efsvvp40.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 31 2017, Steve Dickson wrote:

> On 07/28/2017 09:52 AM, Michael Orlitzky wrote:
>> According to its own man page, the rpcbind program "can only be
>> started by the super-user." On systems where a distinction is made, it
>> therefore makes sense to install rpcbind to the autotools sbindir
>> rather than the regular bindir where it is currently installed. This
>> is accomplished by three small changes:
>>=20
>>   1. Move rpcbind from bin_PROGRAMS to sbin_PROGRAMS in Makefile.am.
>>   2. Change @_bindir@ to @_sbindir@ in the rpcbind systemd service file.
>>   3. Tell configure.ac that it should substitute the value of $sbindir
>>      into @_sbindir@ instead of $bindir$ into @_bindir@.
>>=20
>> The rpcinfo tool remains where it is, in bindir, since unprivileged
>> users are able to usefully run it. This avoids forcing maintainers to
>> choose between two bad options: hiding rpcinfo from unprivileged
>> users, or installing a useless rpcbind for them.
>> ---
>>  Makefile.am                | 3 ++-
>>  configure.ac               | 6 +++---
>>  systemd/rpcbind.service.in | 2 +-
>>  3 files changed, 6 insertions(+), 5 deletions(-)
> A couple things... You are  missing a Signed-off-by line
>
> Also I would like some more input from others about
> changing the default install directory to sbin
>
> Anybody have a problem with this?

In SUSE we run
  ./configure --bindir=3D/sbin .....
for rpcbind.

So: no, we do not have a problem with this.  Nor do I personally.

This came up before in the thread starting
  https://www.spinics.net/lists/linux-nfs/msg60349.html
but didn't quite get resolved for some reason that I don't recall.

Thanks,
NeilBrown

>
> steved.
>>=20
>> diff --git a/Makefile.am b/Makefile.am
>> index 43c2710..c160a95 100644
>> --- a/Makefile.am
>> +++ b/Makefile.am
>> @@ -29,7 +29,8 @@ if LIBWRAP
>>  AM_CPPFLAGS +=3D	-DLIBWRAP
>>  endif
>>=20=20
>> -bin_PROGRAMS =3D rpcbind rpcinfo
>> +bin_PROGRAMS =3D rpcinfo
>> +sbin_PROGRAMS =3D rpcbind
>>=20=20
>>  rpcbind_SOURCES =3D \
>>  	src/check_bound.c \
>> diff --git a/configure.ac b/configure.ac
>> index 3790310..359a418 100644
>> --- a/configure.ac
>> +++ b/configure.ac
>> @@ -61,9 +61,9 @@ AC_SEARCH_LIBS([pthread_create], [pthread])
>>=20=20
>>  AC_CHECK_HEADERS([nss.h rpcsvc/mount.h])
>>=20=20
>> -# make bindir available for substitution in config file
>> +# make sbindir available for substitution in config file
>>  # 2 "evals" needed to expand variable names
>> -AC_SUBST([_bindir])
>> -AC_CONFIG_COMMANDS_PRE([eval eval _bindir=3D$bindir])
>> +AC_SUBST([_sbindir])
>> +AC_CONFIG_COMMANDS_PRE([eval eval _sbindir=3D$sbindir])
>>=20=20
>>  AC_OUTPUT([Makefile systemd/rpcbind.service])
>> diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
>> index 03a9e0b..f8cfa9f 100644
>> --- a/systemd/rpcbind.service.in
>> +++ b/systemd/rpcbind.service.in
>> @@ -12,7 +12,7 @@ After=3Drpcbind.socket
>>  [Service]
>>  Type=3Dnotify
>>  # distro can provide a drop-in adding EnvironmentFile=3D-/??? if needed.
>> -ExecStart=3D@_bindir@/rpcbind $RPCBIND_OPTIONS -w -f
>> +ExecStart=3D@_sbindir@/rpcbind $RPCBIND_OPTIONS -w -f
>>=20=20
>>  [Install]
>>  WantedBy=3Dmulti-user.target
>>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmAECAACgkQOeye3VZi
gbm/YBAAs+jImxdCSddkmHKXwqOX8Xb9ChhG1VGgbNTpkyJwQp2uVHYymOerkZWT
ouz1yqB+ABKkP534Et6MsgwtRyGAsWG/Dr5/IsdMoBP6XAwZKEEMWYnecR2o4hZm
DbsfZdM+zq/IJMj4c3CTwDkKcRNoOKK1kw3UtqG54APyZSFyf3txeUEA3vNUTFYT
n1xXE2zTWv/Mj+WBTlCqiB676u5H/zDxKV5l8gyBLPHQnDFtScp65euNJiznv2Aj
O8YK+NxZ3aLBwYS/qqmecSvAyHa84940J1sOu6gMGPJ/ZWxrofZPMtbdeZzGDoJl
60JIOPDK7CZ95CdzRuAzgoo1/iB3CqWEpLcLVzzRR9dOcjlcAQzGbYi/RktiakqE
qAfDrUjm6Ay76NEFpB/5fOxsLkYl3NS2b2oisClls0nPpS/vQEEtt0xyi3/w10Yn
HRvpI3krxZM6RhaGk9HlB87EMs3K1/epyN2+jF/CPqGpNsZVJQUIzJ8Gd0RFxBfO
KJK9eLeSJrqJSeORJCLAKlr44CBNx+mS3ay3dIIknEJR1FVYwreAjUDJOsnw4wM3
kWdleUgCGc/RGY2uqeiV4dfKwcM3NWzznw7asMSFy7aaqY3FB0PS8IO6r0lN/78/
7+BgxbO9JJaq7pbfUzn/OMDItSdoteonWyQAdeow4YLLXvpJkx8=
=u/FU
-----END PGP SIGNATURE-----
--=-=-=--
