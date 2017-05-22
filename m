Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59920 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932273AbdEVDDn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 21 May 2017 23:03:43 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Mon, 22 May 2017 13:03:35 +1000
Subject: Re: [PATCH 1/2] mount.nfs: v4 mounts should fail when -o flag is used.
In-Reply-To: <20170519222510.31205-1-steved@redhat.com>
References: <20170519222510.31205-1-steved@redhat.com>
Message-ID: <87inktk2yg.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, May 19 2017, Steve Dickson wrote:

> When the pseudo root is set with fsid=3D0, explicit
> v4 mounts (via the -o flag) should fail when
> the incorrect export is tried instead of rolling
> back to v3.

Hi Steve,
 I think this patch makes sense, but the above description doesn't.
 Where does fsid=3D0 fit in anywhere here?

I think you want to say

  When the protocol is set with "-t nfs4", we should behave just like
  with do with "-o vers=3D4" and not fall back to v3.

Is that what you were really trying to say?

Thanks,
NeilBrown


>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/mount/network.c | 3 ++-
>  utils/mount/network.h | 8 ++++----
>  2 files changed, 6 insertions(+), 5 deletions(-)
>
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 281e935..e39263e 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -1299,7 +1299,8 @@ nfs_nfs_version(struct mount_options *options, stru=
ct nfs_version *version)
>  		if (!(version->minor =3D strtol(version_val, &cptr, 10)) && cptr =3D=
=3D version_val)
>  			goto ret_error;
>  		version->v_mode =3D V_SPECIFIC;
> -	} else if (version->major > 3 && *cptr =3D=3D '\0')
> +	} else if (version->major > 3 && *cptr =3D=3D '\0' &&
> +			version->v_mode =3D=3D V_DEFAULT) /* v_mode has not been set */
>  		version->v_mode =3D V_GENERAL;
>=20=20
>  	if (*cptr !=3D '\0')
> diff --git a/utils/mount/network.h b/utils/mount/network.h
> index 9cc5dec..45e2b24 100644
> --- a/utils/mount/network.h
> +++ b/utils/mount/network.h
> @@ -58,10 +58,10 @@ int clnt_ping(struct sockaddr_in *, const unsigned lo=
ng,
>  struct mount_options;
>=20=20
>  enum {
> -	V_DEFAULT =3D 0,
> -	V_GENERAL,
> -	V_SPECIFIC,
> -	V_PARSE_ERR,
> +	V_DEFAULT =3D 0, /* not set */
> +	V_GENERAL,     /* single digit =3D> 4 */
> +	V_SPECIFIC,    /* single digit < 4 or decimal included */
> +	V_PARSE_ERR,   /* miss all others */
>  };
>=20=20
>  struct nfs_version {
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

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlkiVQcACgkQOeye3VZi
gblISA/+LNAJ8ukZgwaYyyuBBALN8yfMtHClUDpWzGG4NbsjMlXNXc6wVcqjWYdF
IehM3F0c1VAvEmbFQrEdQshdHI/iQeO4Bf2xHfLj4e13upgI8FjOyagMZodNh9CX
xw72GZYyud7UJqdXxiONuae+D4G59sGZejsiTnNS+S2f3q6Hgbgu0MqZfmwviyvn
FYxoUnXtrKhz8Ju1e0SMAYG1klEughlLRag8VkW2cW/KYx27rI0vz3L8+yIPzzUI
IV0Khk6dOY4tWeiqo0ocDeRRgK+nu8DgPp1cB3gtCYgSnkOjZ8N/kVLEDsxZvzcy
YB54i/0Y62WPstVk8wamumlQtsw8Hq6kDFsYrlrD58hVsMtQ5OXEQVA8ltzOkaoU
VoepHkRiSrgzXGcbLq0RnfBSarAL2YkPQcGGey4FybRbc//rWixp0Ey52QFQP1gn
2c4fh+mO38wwkXSwyXc6cgK7dpycUWsw7kFKsqcaYOh2GSPhlVeRxEFf3fSl70EY
WPBD5cHhES18qNmyhPZjkilMdZbrAm+wlKqJ4mvlEA1x0B2iFv2vaPHetUT44sL8
affqBw1RM0vVU35bNkHqBdkeLck8YsHdIS64uRg4+BtQNXhTc5beELkrv0IGSryb
uVw9/wuHRl/Ifdug3+tiY3Rv0QIx9ipVQFOZUJOeMdgpB2xsgsI=
=961F
-----END PGP SIGNATURE-----
--=-=-=--
