Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38679 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751491AbdGVWzE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 22 Jul 2017 18:55:04 -0400
From: NeilBrown <neilb@suse.com>
To: Scott Mayhew <smayhew@redhat.com>
Date: Sun, 23 Jul 2017 08:54:53 +1000
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH v4] systemd: add instructions for disabling gssd to nfs.systemd.man
In-Reply-To: <20170722162540.aonaowrupf555trn@tonberry.usersys.redhat.com>
References: <20170720202422.14153-1-smayhew@redhat.com> <87a83wyi00.fsf@notabene.neil.brown.name> <20170722162540.aonaowrupf555trn@tonberry.usersys.redhat.com>
Message-ID: <874lu4xete.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, Jul 22 2017, Scott Mayhew wrote:

> On Sat, 22 Jul 2017, NeilBrown wrote:
>
>> On Thu, Jul 20 2017, Scott Mayhew wrote:
>>=20
>> > We've had several users complain about gssd automatically starting.  N=
ot
>> > everyone who has a krb5.keytab want to use secure NFS; the instructions
>> > for disabling gssd ought to be on the man page in addition to the READ=
ME
>> > (which may not even be included in a distro's nfs-utils package).
>> >
>> > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
>> > ---
>> >  systemd/nfs.systemd.man | 17 ++++++++++++++++-
>> >  1 file changed, 16 insertions(+), 1 deletion(-)
>> >
>> > diff --git a/systemd/nfs.systemd.man b/systemd/nfs.systemd.man
>> > index 01801eb..7675320 100644
>> > --- a/systemd/nfs.systemd.man
>> > +++ b/systemd/nfs.systemd.man
>> > @@ -79,11 +79,26 @@ unit should be enabled.
>> >  Several other units which might be considered to be optional, such as
>> >  .I rpc-gssd.service
>> >  are careful to only start if the required configuration file exists.
>> > -.I rpc-gsdd.service
>> > +.I rpc-gssd.service
>> >  will not start if the
>> >  .I krb5.keytab
>> >  file does not exist (typically in
>> >  .IR /etc ).
>> > +.B rpc.gssd
>> > +is assumed to be needed if the
>> > +.I krb5.keytab
>> > +file is present.  If a site needs this file present but does not want
>> > +.B rpc.gssd
>> > +running, it should create
>> > +.B /etc/systemd/system/rpc-gssd.service.d/01-disable.conf
>>=20
>> A substantially simpler approach would be to recommend
>>=20
>>   systemctl mask rpc-gssd.service
>
> Thanks, Neil.  I had actually tried that a while back, but it doesn't seem
> to work in RHEL.  It works fine for rpcbind, so I thought that maybe the
> Condition clause in the unit file took precedence over masking or
> something.  I see now that masking rpc-gssd works in Fedora, so I'll go
> digging in systemd to see if there's a bug fix that might need to be
> backported to RHEL.
>
> Anyways, any objection to listing both methods in the man page?

It depends on why "mask" doesn't work in RHEL.
If the reason is specific to RHEL, then I don't think it should be
documented in upstream nfs-utils.
If the reason is specific to some version(s) of systemd, then
Maybe document it as "use using systemd prior to XXXX, do this instead".

NeilBrown


>
> -Scott
>>=20
>> "mask" is also useful for disabling rpcbind if you use NFSv4 only and
>> don't want the extra service.
>>=20
>> NeilBrown
>>=20
>>=20
>> > +containing
>> > +.RS
>> > +.nf
>> > +[Unit]
>> > +ConditionNull=3Dfalse
>> > +.fi
>> > +.RE
>> > +
>> >  .SS Restarting NFS services
>> >  Most NFS daemons can be restarted at any time.  They will reload any
>> >  state that they need, and continue servicing requests.  This is rarely
>> > --=20
>> > 2.9.4
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

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAllz178ACgkQOeye3VZi
gbnHfg//cw4E0IO/RXkkTmqAIi14s1zW1pe0X2XI8X3lT3G1vNaPz6in1w83nqcp
gjPE0pDMGy0prOAQsbe3ndhoTK95wLD1/jx69mAssX7nWSSMTCq5iVeQtD76l57s
8fQN8iLp3grNdHHklwX9QKF1a5LlLOwOcHXI3Zcw+VfileeQHgLzsZQPfZuskLU9
xFAFgFyYrmTf6AM40rVjVjyKdmOTYFmLZrb3dTlVfWQMGx3/sfGLviA8WSgC/FRj
1c6mkcC6JUP8WzUe25+PEPM4I2GVGL0/hgKFoEzgpe+GlKh0v9uAZ/SwVatwNynO
+B1z3MQB3yMPmh7/Hs2x6J2pt52TcQ1BwLvLJqNDyf0rIiyXEc0ByvYEeC2nNbVP
Ut9ftdAIMlw4SBqdejTTBxLCI9SAfatWDyp+1U9nGdX3fEEPlO8KusTJ6hp2Dcor
eSe5ho0UYYByW2WLY1Ia961W+2oPARfXlkzhBu101BiLGT8aU6/7FU3BzIww0ysJ
caCPJhigH1fuevDRQmS6mK1zUo6fPnON5PurghQATZZ2G4WTWdEAJPwxWG64hgTM
1VvsvqvFiwEeBlMKbIG/WL9qMMH3Rd5oUF5K9Kc++KIIi2MDF8h0GRuEkxr4GdM4
1LWM4hiLMBKeAOUnGEWO+fRcVqoXdVaMKHb0B60Ac6WurwMQfvE=
=+GUT
-----END PGP SIGNATURE-----
--=-=-=--
