Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50073 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754956AbdGVIsl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 22 Jul 2017 04:48:41 -0400
From: NeilBrown <neilb@suse.com>
To: Scott Mayhew <smayhew@redhat.com>, steved@redhat.com
Date: Sat, 22 Jul 2017 18:48:31 +1000
Cc: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH v4] systemd: add instructions for disabling gssd to nfs.systemd.man
In-Reply-To: <20170720202422.14153-1-smayhew@redhat.com>
References: <20170720202422.14153-1-smayhew@redhat.com>
Message-ID: <87a83wyi00.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 20 2017, Scott Mayhew wrote:

> We've had several users complain about gssd automatically starting.  Not
> everyone who has a krb5.keytab want to use secure NFS; the instructions
> for disabling gssd ought to be on the man page in addition to the README
> (which may not even be included in a distro's nfs-utils package).
>
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  systemd/nfs.systemd.man | 17 ++++++++++++++++-
>  1 file changed, 16 insertions(+), 1 deletion(-)
>
> diff --git a/systemd/nfs.systemd.man b/systemd/nfs.systemd.man
> index 01801eb..7675320 100644
> --- a/systemd/nfs.systemd.man
> +++ b/systemd/nfs.systemd.man
> @@ -79,11 +79,26 @@ unit should be enabled.
>  Several other units which might be considered to be optional, such as
>  .I rpc-gssd.service
>  are careful to only start if the required configuration file exists.
> -.I rpc-gsdd.service
> +.I rpc-gssd.service
>  will not start if the
>  .I krb5.keytab
>  file does not exist (typically in
>  .IR /etc ).
> +.B rpc.gssd
> +is assumed to be needed if the
> +.I krb5.keytab
> +file is present.  If a site needs this file present but does not want
> +.B rpc.gssd
> +running, it should create
> +.B /etc/systemd/system/rpc-gssd.service.d/01-disable.conf

A substantially simpler approach would be to recommend

  systemctl mask rpc-gssd.service

"mask" is also useful for disabling rpcbind if you use NFSv4 only and
don't want the extra service.

NeilBrown


> +containing
> +.RS
> +.nf
> +[Unit]
> +ConditionNull=3Dfalse
> +.fi
> +.RE
> +
>  .SS Restarting NFS services
>  Most NFS daemons can be restarted at any time.  They will reload any
>  state that they need, and continue servicing requests.  This is rarely
> --=20
> 2.9.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAllzEWEACgkQOeye3VZi
gblOig//Xa6nOu+cf6bRXOuYatF6Oh8nBbOocCNuJee6a/X4g0SL/6LtDti0JP4W
Skex24xUnmHc8tscYSpYwulCc2qWYNC9F7uG23KSQydjbTuHNa1f2RvjPgOU5hvO
EMAsKXLXfLMImWrJpdEjMpVscRvRLWwPgEQmxl/lV1HW9gWQFGfywmEeSrNwvDlC
aGJto1U1V5strd9yKxPrDmnEsL6CrkX1qm/p8Hqxff+BAyUj3DtSmpdxKIh8/S7i
3826L50YY1tTa4oT8HJBqGGKuHRk6HLREV3lKNu+ygA/YvF7x45zzHoqnwUzplzl
YU1Ee8Ja2r1GSDq25iSMM4isY8PjemxWWgNoMguaU6mVqffIUj2fmK2OJEzv6s7R
Uy4Qr8yJ1JGdO3ksH6Ae6xIxemK4orin+135iq9RnoHEXMHIsWUQWglrFXppupwz
VU0vJ37NIg1v74TOFB2VrUQPhEOWiKXzuCzw3oYBy0R/IzNGA/MIDAD79RH9VWuF
kQ1dqYPGj/4RMJAliWoHielrotceN2rzy/ScRQ8HIc7kWOG3FXNnvU7YCZuf+I4r
PedJHeWHUj1T0Xhs14yp6qEV4O0V32jcgKtb7siV5RXz+BK6UQYI1KM6+wiQ5EkD
zbDrlEYsqILQQTQZetP/j1CfDsQgGbh+6ApEkRQhkNxmDYRanLc=
=3RCP
-----END PGP SIGNATURE-----
--=-=-=--
