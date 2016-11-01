Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45619 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754085AbcKAT53 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 Nov 2016 15:57:29 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 02 Nov 2016 06:57:22 +1100
Cc: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [PATCH - rpcbind] Provide systemd unit files for rpcbind
In-Reply-To: <8c1fa65d-9efc-462a-b6c8-7ed518f0dfe4@RedHat.com>
References: <87oa2q14yc.fsf@notabene.neil.brown.name> <8c1fa65d-9efc-462a-b6c8-7ed518f0dfe4@RedHat.com>
Message-ID: <87twbrq8gt.fsf@notabene.neil.brown.name>
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
> My apologies for not getting to this sooner...=20
> A rough a couple of weeks...=20
> On 10/12/2016 02:01 AM, NeilBrown wrote:
>>=20
>>=20
>> To encourage uniformity across distributions, provide
>> systemd unit files.
>>=20
>> If extra arguments are wanted for rpcbind, a drop-in should be used
>> to set the Environment=3D or read and EnvironmentFile=3D
>>=20
>> As the "run" directory could be /run or /var/run we RequiresMountsFor
>> both of these.
> Talking with the systemd folks they strongly sugguest we just
> use /run (not /var/run) and drop the RequiresMountsFor.

I'm fine with that.  While maybe not everyone has /run, everyone running
systemd does.  I assume you'll just fix this rather than me
resubmitting?

Thanks,
NeilBrown


>
>>=20
>> rpcbind.service pulls in rpcbind.socket so that the listening sockets
>> chosen there will always be used.
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  .gitignore                 |  1 +
>>  Makefile.am                |  4 ++++
>>  configure.ac               |  7 ++++++-
>>  systemd/rpcbind.service.in | 17 +++++++++++++++++
>>  systemd/rpcbind.socket     | 19 +++++++++++++++++++
>>  5 files changed, 47 insertions(+), 1 deletion(-)
>>  create mode 100644 systemd/rpcbind.service.in
>>  create mode 100644 systemd/rpcbind.socket
>>=20
>> hi,
>>  these are based on the unit files in use a SUSE, though I have made a
>>  few "improvements".
>>  If anyone has differences in their distros that you think we should
>>  have in mainline, I'd love to hear about it.
>>=20
>> Thanks,
>> NeilBrown
>>=20
>>=20
>> diff --git a/.gitignore b/.gitignore
>> index 321dff64a57d..a8f1fed2acb6 100644
>> --- a/.gitignore
>> +++ b/.gitignore
>> @@ -27,3 +27,4 @@ rpcbind
>>  rpcinfo
>>  # cscope database files
>>  cscope.*
>> +systemd/rpcbind.service
>> diff --git a/Makefile.am b/Makefile.am
>> index 5ec8cd66b689..43c27100ceae 100644
>> --- a/Makefile.am
>> +++ b/Makefile.am
>> @@ -50,6 +50,10 @@ if SYSTEMD
>>  AM_CPPFLAGS +=3D $(SYSTEMD_CFLAGS) -DSYSTEMD
>>=20=20
>>  rpcbind_LDADD +=3D $(SYSTEMD_LIBS)
>> +
>> +systemdsystemunit_DATA =3D \
>> +	systemd/rpcbind.service \
>> +	systemd/rpcbind.socket
>>  endif
>>=20=20
>>  rpcinfo_SOURCES =3D       src/rpcinfo.c
>> diff --git a/configure.ac b/configure.ac
>> index af4b74b31c9a..0892d8246a12 100644
>> --- a/configure.ac
>> +++ b/configure.ac
>> @@ -61,4 +61,9 @@ AC_SEARCH_LIBS([pthread_create], [pthread])
>>=20=20
>>  AC_CHECK_HEADERS([nss.h rpcsvc/mount.h])
>>=20=20
>> -AC_OUTPUT([Makefile])
>> +# make bindir available for substitution in config file
>> +# 2 "evals" needed to expand variable names
>> +AC_SUBST([_bindir])
>> +AC_CONFIG_COMMANDS_PRE([eval eval _bindir=3D$bindir])
>> +
>> +AC_OUTPUT([Makefile systemd/rpcbind.service])
>> diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
>> new file mode 100644
>> index 000000000000..4706b5a77abf
>> --- /dev/null
>> +++ b/systemd/rpcbind.service.in
>> @@ -0,0 +1,17 @@
>> +[Unit]
>> +Description=3DRPC Bind
>> +Documentation=3Dman:rpcbind(8)
>> +DefaultDependencies=3Dno
>> +RequiresMountsFor=3D/var/run /run
>> +# Make sure we use the IP addresses listed for
>> +# rpcbind.socket, no matter how this unit is started.
>> +Wants=3Drpcbind.socket
>> +After=3Drpcbind.socket
>> +
>> +[Service]
>> +Type=3Dnotify
>> +# distro can provide a drop-in adding EnvironmentFile=3D-/??? if needed.
>> +ExecStart=3D@_bindir@/rpcbind $RPCBIND_OPTIONS -w -f
> This macro puts rpcbind in /usr/bin, but in the Red Hat
> distros rpcbind lives /usr/sbin. I could easily patch
> it to do the right thing... but is this a typo or does=20
> rpcbind live in /usr/bin in other distros?=20
>
> steved.
>
>
>> +
>> +[Install]
>> +WantedBy=3Dmulti-user.target
>> diff --git a/systemd/rpcbind.socket b/systemd/rpcbind.socket
>> new file mode 100644
>> index 000000000000..7204c97efa6f
>> --- /dev/null
>> +++ b/systemd/rpcbind.socket
>> @@ -0,0 +1,19 @@
>> +[Unit]
>> +Description=3DRPCbind Server Activation Socket
>> +DefaultDependencies=3Dno
>> +RequiresMountsFor=3D/var/run /run
>> +Wants=3Drpcbind.target
>> +Before=3Drpcbind.target
>> +
>> +[Socket]
>> +ListenStream=3D/var/run/rpcbind.sock
>> +
>> +# RPC netconfig can't handle ipv6/ipv4 dual sockets
>> +BindIPv6Only=3Dipv6-only
>> +ListenStream=3D0.0.0.0:111
>> +ListenDatagram=3D0.0.0.0:111
>> +ListenStream=3D[::]:111
>> +ListenDatagram=3D[::]:111
>> +
>> +[Install]
>> +WantedBy=3Dsockets.target
>>=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYGPOiAAoJEDnsnt1WYoG5diMQAKVfbOAf/nsMUBQXrxKbB1D6
RR1rAl6lxEkz/CZz0/+AXqBUEoKQieR8FTWvptie/ahJqF9rfFEgPewTSKhe1Hw8
GSw7DqHwInogmUJSkQqz16AhIaQHizFZ+wd4535o3Nf/rKRqOjd1V9Aq6x+Eb/6S
5wiTZKPG4lApuvWyvfsA2XHGyOyZgk+o7C6Vl5D5nu1wx73Ac7dwgvW2908WvlW0
VWf2UZLQZVSptdounGNDdwUJXAM4mMaYFOKgcRrnhE7VmIvbr1J9Rs4bqDMdvsXJ
6f6kUBGunJ+uTOFkoGt6KjfYjFuJ1EsFzlUlECk7y0lTm7rNoRox3iNr45/BRKmG
pu4iiGOTHhJuC6nxdN4zA3z5BolBcnJ2BAsxMuoeGy/QqWeE5T4qhYxqknosVI38
J6eSmwLk7EePf61uFOcHWuQT/LZ9jCI8ctBnfcnFQXmmk3JOLJ/tQ1L263D5XhWr
YEnUy+Mu0TkePVfalAKHILcnwqo/sUluNUMfgPH6TPpe7RLzGycWCGtQgpSrnK2y
Q28HpGs5i1W8mFOPKb4FzEIsmaj28CC+kIsNaTFDfWaOb+3p4eVvkFpHWXA9UYWJ
d7h/w0ZUuhek7GydEah98PcHGpEW5DFzjgz+Mzq8e3/P9bied6d3Zi9OaCxBluls
RqTE5DL/kRSwmegQZ+hc
=7O53
-----END PGP SIGNATURE-----
--=-=-=--
