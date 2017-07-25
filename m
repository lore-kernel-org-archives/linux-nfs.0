Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51668 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750897AbdGYWRE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Jul 2017 18:17:04 -0400
From: NeilBrown <neilb@suse.com>
To: Scott Mayhew <smayhew@redhat.com>
Date: Wed, 26 Jul 2017 08:16:52 +1000
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH v4] systemd: add instructions for disabling gssd to nfs.systemd.man
In-Reply-To: <20170725151858.giqjb6dhogrl4lvj@tonberry.usersys.redhat.com>
References: <20170720202422.14153-1-smayhew@redhat.com> <87a83wyi00.fsf@notabene.neil.brown.name> <20170722162540.aonaowrupf555trn@tonberry.usersys.redhat.com> <874lu4xete.fsf@notabene.neil.brown.name> <20170725151858.giqjb6dhogrl4lvj@tonberry.usersys.redhat.com>
Message-ID: <87pocow4a3.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 25 2017, Scott Mayhew wrote:

> On Sun, 23 Jul 2017, NeilBrown wrote:
>
>> On Sat, Jul 22 2017, Scott Mayhew wrote:
>>=20
>> > On Sat, 22 Jul 2017, NeilBrown wrote:
>> >
>> >> On Thu, Jul 20 2017, Scott Mayhew wrote:
>> >>=20
>> >> > We've had several users complain about gssd automatically starting.=
  Not
>> >> > everyone who has a krb5.keytab want to use secure NFS; the instruct=
ions
>> >> > for disabling gssd ought to be on the man page in addition to the R=
EADME
>> >> > (which may not even be included in a distro's nfs-utils package).
>> >> >
>> >> > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
>> >> > ---
>> >> >  systemd/nfs.systemd.man | 17 ++++++++++++++++-
>> >> >  1 file changed, 16 insertions(+), 1 deletion(-)
>> >> >
>> >> > diff --git a/systemd/nfs.systemd.man b/systemd/nfs.systemd.man
>> >> > index 01801eb..7675320 100644
>> >> > --- a/systemd/nfs.systemd.man
>> >> > +++ b/systemd/nfs.systemd.man
>> >> > @@ -79,11 +79,26 @@ unit should be enabled.
>> >> >  Several other units which might be considered to be optional, such=
 as
>> >> >  .I rpc-gssd.service
>> >> >  are careful to only start if the required configuration file exist=
s.
>> >> > -.I rpc-gsdd.service
>> >> > +.I rpc-gssd.service
>> >> >  will not start if the
>> >> >  .I krb5.keytab
>> >> >  file does not exist (typically in
>> >> >  .IR /etc ).
>> >> > +.B rpc.gssd
>> >> > +is assumed to be needed if the
>> >> > +.I krb5.keytab
>> >> > +file is present.  If a site needs this file present but does not w=
ant
>> >> > +.B rpc.gssd
>> >> > +running, it should create
>> >> > +.B /etc/systemd/system/rpc-gssd.service.d/01-disable.conf
>> >>=20
>> >> A substantially simpler approach would be to recommend
>> >>=20
>> >>   systemctl mask rpc-gssd.service
>> >
>> > Thanks, Neil.  I had actually tried that a while back, but it doesn't =
seem
>> > to work in RHEL.  It works fine for rpcbind, so I thought that maybe t=
he
>> > Condition clause in the unit file took precedence over masking or
>> > something.  I see now that masking rpc-gssd works in Fedora, so I'll go
>> > digging in systemd to see if there's a bug fix that might need to be
>> > backported to RHEL.
>> >
>> > Anyways, any objection to listing both methods in the man page?
>>=20
>> It depends on why "mask" doesn't work in RHEL.
>> If the reason is specific to RHEL, then I don't think it should be
>> documented in upstream nfs-utils.
>> If the reason is specific to some version(s) of systemd, then
>> Maybe document it as "use using systemd prior to XXXX, do this instead".
>
> It turns out that we have rpc-gssd.service symlinked to
> nfs-secure.service in both RHEL and Fedora for backward compatibility
> purposes, so it's necessary to mask both.

That makes sense.  I have a similar sort of hack (different specifics)
in SUSE to try to provide back-compatibility.  It also has problematic
failure modes.

systemd actually has a fairly robust "alias" mechanism that it uses
internally, but it is only available for devices.  Every "/dev/..'
device unit declares that it "Follows" the corresponding
"/sys/devices/..." device unit (which is "Followed-by" the dev units).
I would have loved to have the infrastructure for creating compat
aliases ... but it isn't available :-(

>
> I'll send a patch documenting masking just the rpc-gssd.service.

Thanks,
NeilBrown


>
> -Scott
>>=20
>> NeilBrown
>>=20
>>=20
>> >
>> > -Scott
>> >>=20
>> >> "mask" is also useful for disabling rpcbind if you use NFSv4 only and
>> >> don't want the extra service.
>> >>=20
>> >> NeilBrown
>> >>=20
>> >>=20
>> >> > +containing
>> >> > +.RS
>> >> > +.nf
>> >> > +[Unit]
>> >> > +ConditionNull=3Dfalse
>> >> > +.fi
>> >> > +.RE
>> >> > +
>> >> >  .SS Restarting NFS services
>> >> >  Most NFS daemons can be restarted at any time.  They will reload a=
ny
>> >> >  state that they need, and continue servicing requests.  This is ra=
rely
>> >> > --=20
>> >> > 2.9.4
>> >> >
>> >> > --
>> >> > To unsubscribe from this list: send the line "unsubscribe linux-nfs=
" in
>> >> > the body of a message to majordomo@vger.kernel.org
>> >> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> >
>> >
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAll3w1YACgkQOeye3VZi
gbnKDA//ZHWsIwVm4nBnkinw4MGdJ1STuv//sf8Y9lyv+5rYMv3vceeeC+HHuwkF
QLgf+6FXzjK/YFsn6PHRhOeFsXdjTQbyyf0yQUAW7TVcUJmbFdCKfwnOxD/ghVAY
adogVTD0wdP4cxU390r0D1Ku8GhhaDV72VUm9fIELhHTwr02EmVeKahVfHy10Z84
sTyCRO0NG6wUpA9auF7DowwdZj4YtMZjdr4RkgHl5VGbTT2uUWxiHJggOelDAKmV
LP/tLl/H4Wu1SJka3tHsf/AhQnLx98pOIUyz6jJ82rpavua0xZJJpHF+zgk20mXe
DJ5TfsTlb7HV93ao34FUHDvphS5+5D+/JrIXiTZNP3tEG5lSTng20hT/vNGPU04u
GRNJxtyc4j5BjIAxx/eA5G88tKlU85fw7cCwWSrO0KYQwa1nCl5K0UyiVjC1dJul
CvxsorNcvMHACdy9aDvswR6v2GIQtVE5hgA6NyDvWmzYLk2UFUi+ybPl4Sf4+T77
T82s7vFxRwnssHYRfIHsmORBEODfqsL8CeSEf70J5DLtWwym86T7jUkMBw6U/REw
8z28ghuMDWN1oW8I7Ojd08FwhvpAt79m3Fe4Scz5YkFCKSvZuryhXMOuF3ov8GJz
QSfE445H278SPRJNCgOIau1ZKtxpko7ra0dBMboBYWMgYq2AoRs=
=DYx9
-----END PGP SIGNATURE-----
--=-=-=--
