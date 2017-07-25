Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52169 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750897AbdGYWUj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Jul 2017 18:20:39 -0400
From: NeilBrown <neilb@suse.com>
To: Scott Mayhew <smayhew@redhat.com>, steved@redhat.com
Date: Wed, 26 Jul 2017 08:20:29 +1000
Cc: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH] systemd: add a blurb about masking rpc-gssd to the man page
In-Reply-To: <20170725151920.21760-1-smayhew@redhat.com>
References: <87a83wyi00.fsf@notabene.neil.brown.name> <20170725151920.21760-1-smayhew@redhat.com>
Message-ID: <87mv7sw442.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 25 2017, Scott Mayhew wrote:

> This is helpful for users that have a krb5.keytab but do not want to use
> secure NFS.  Also fixed a typo that appears earlier on the page.
>
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>


 Reviewed-by: NeilBrown <neilb@suse.com>

Thanks,
NeilBrown

> ---
>  systemd/nfs.systemd.man | 18 ++++++++++++++----
>  1 file changed, 14 insertions(+), 4 deletions(-)
>
> diff --git a/systemd/nfs.systemd.man b/systemd/nfs.systemd.man
> index 01801eb..46b476a 100644
> --- a/systemd/nfs.systemd.man
> +++ b/systemd/nfs.systemd.man
> @@ -79,7 +79,7 @@ unit should be enabled.
>  Several other units which might be considered to be optional, such as
>  .I rpc-gssd.service
>  are careful to only start if the required configuration file exists.
> -.I rpc-gsdd.service
> +.I rpc-gssd.service
>  will not start if the
>  .I krb5.keytab
>  file does not exist (typically in
> @@ -120,10 +120,11 @@ be needed to reduce system load to an absolute mini=
mum, or to reduce
>  attack surface by not running daemons that are not absolutely
>  required.
>  .PP
> -Two particular services which this can apply to are
> -.I rpcbind
> +Three particular services which this can apply to are
> +.IR rpcbind ,
> +.IR idmapd ,
>  and
> -.IR idmapd .
> +.IR rpc-gssd .
>  .I rpcbind
>  is not part of the
>  .I nfs-utils
> @@ -155,6 +156,15 @@ is not needed and not wanted, it can be masked with
>  .RS
>  .B systemctl mask idmapd
>  .RE
> +.I rpc-gssd
> +is assumed to be needed if the
> +.I krb5.keytab
> +file is present.  If a site needs this file present but does not want
> +.I rpc-gssd
> +running, it can be masked with
> +.RS
> +.B systemctl mask rpc-gssd
> +.RE
>  .SH FILES
>  /etc/nfs.conf
>  .br
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

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAll3xC4ACgkQOeye3VZi
gbnJzQ/+OoQHtw4XFw0EevE99zS3zp27epJOSdn+z39iVI6MwfRe4WTQ+NPJyCwh
FVLnZbdWbJV4hC6gDqf/1m9aT1cRSa5EFLa9obt325+Ec97acgf91bI7x7iPjJtf
rXmDcj06qb7DBpnE2DwKzqPZCrxzl8h7bJlJEQ5LNtiemyuCSZOzi+rYBor0MB8n
d7YjDO5jt+vpQeDpdSvyZBAEHDKala1kx0BSimD6pgMvGAXdyjxqCGeV/Wy9V5Gn
8K0YBy6Jq5kvgWPRRgV1RL0BoQTwQ8mFS6uGYacpBuAroPdViY+SrNkEG1YbYChN
xZgOb5vAxsALl/HjOwqFYKBgbVD10QvJvWxY7yP0zxlK27Lui7mXztfQF5bHBptP
UP9fbM7crw991W/f/FAbJUnOG0+5fwAPjgrnezWf9LaNGrXl1YkMN7b8SxdVllba
1D4OQvABYeZu6d7RpLef/guWzUKac0zP043oyZ6uGUv2ytZvuO7jroVMqHS3rjYn
8BWlInar4aOfElRwtZQ9e9hQEdgoccZUkl44dQuTYHOPWZxAOQBgHzkEURGkOkQO
OBa9GxHqIWpPmRWHcSqUEAnuzTzr6sl0a9aYRsoo73XcmDLnK+k/1PV0DOOpU//1
petkJxZkRnrZy33QMSTk4rsu+RvQhc2pWB3hVGJ6LTqhSIbNkCQ=
=V42P
-----END PGP SIGNATURE-----
--=-=-=--
