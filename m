Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60665 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751190AbdDCCQE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 2 Apr 2017 22:16:04 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Mon, 03 Apr 2017 12:15:55 +1000
Cc: Jason Yan <yanaijie@huawei.com>, jlayton@poochiereds.net,
        linux-nfs@vger.kernel.org, miaoxie@huawei.com,
        zhaohongjiang@huawei.com
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] nfsd: make strdup_if_nonnull static
In-Reply-To: <20170331200909.GC8487@fieldses.org>
References: <1490259456-15858-1-git-send-email-yanaijie@huawei.com> <20170329215132.GC29934@fieldses.org> <874lyb5kc8.fsf@notabene.neil.brown.name> <20170331200909.GC8487@fieldses.org>
Message-ID: <87lgridyn8.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 31 2017, J. Bruce Fields wrote:

> On Thu, Mar 30, 2017 at 05:50:47PM +1100, NeilBrown wrote:
>> On Wed, Mar 29 2017, J. Bruce Fields wrote:
>>=20
>> > Thanks, applying for 4.12.--b.
>>=20
>> Ugh... does strdup_if_nonnull() actually help readability at all?
>> kstrdup() already handles NULL fine, which is what the name seems to
>> suggest is happening.
>> I would think kstrdup_report_error() is a name that better reflects the
>> function.
>>=20
>> Or just discard it:
>
> Yes, what was I thinking?  Just didn't read kstrdup(), I guess.
> Applying as follows.


Thanks.
Feel free to add
  Signed-off-by: NeilBrown <neilb@suse.com>

I probably should have stuck that in there in the first place, just in
case.

Thanks,
NeilBrown


>
> --b.
>
> commit 3c14417a48da
> Author: NeilBrown <neilb@suse.com>
> Date:   Thu Mar 23 16:57:36 2017 +0800
>
>     nfsd4: remove pointless strdup_if_nonnull
>=20=20=20=20=20
>     kstrdup() already checks for NULL.
>=20=20=20=20=20
>     (Brought to our attention by Jason Yann noticing (from sparse output)
>     that it should have been declared static.)
>=20=20=20=20=20
>     Reported-by: Jason Yan <yanaijie@huawei.com>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index e9ef50addddb..78ff82123a1a 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1912,28 +1912,17 @@ static void copy_clid(struct nfs4_client *target,=
 struct nfs4_client *source)
>  	target->cl_clientid.cl_id =3D source->cl_clientid.cl_id;=20
>  }
>=20=20
> -int strdup_if_nonnull(char **target, char *source)
> -{
> -	if (source) {
> -		*target =3D kstrdup(source, GFP_KERNEL);
> -		if (!*target)
> -			return -ENOMEM;
> -	} else
> -		*target =3D NULL;
> -	return 0;
> -}
> -
>  static int copy_cred(struct svc_cred *target, struct svc_cred *source)
>  {
>  	int ret;
>=20=20
> -	ret =3D strdup_if_nonnull(&target->cr_principal, source->cr_principal);
> -	if (ret)
> -		return ret;
> -	ret =3D strdup_if_nonnull(&target->cr_raw_principal,
> -					source->cr_raw_principal);
> -	if (ret)
> -		return ret;
> +	target->cr_principal =3D kstrdup(source->cr_principal, GFP_KERNEL);
> +	target->cr_raw_principal =3D kstrdup(source->cr_raw_principal,
> +								GFP_KERNEL);
> +	if ((source->cr_principal && ! target->cr_principal) ||
> +	    (source->cr_raw_principal && ! target->cr_raw_principal))
> +		return -ENOMEM;
> +
>  	target->cr_flavor =3D source->cr_flavor;
>  	target->cr_uid =3D source->cr_uid;
>  	target->cr_gid =3D source->cr_gid;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljhsFsACgkQOeye3VZi
gbl4dA/9GD3yxBhT4SqDBtrN2bj0dJvGzpvNVdghad9MoYnL1ko24vLhJGehiGwb
SIVDErZDabkfRJTS1RP32FYVTclaiIf9cHnGxjfUKz+OzHg6ieCOtTAdeP6HDy7D
fZKhj1TgT8rh0pZgjDiGwUSTq8ukxNBOYvtFIqzHyLbNVAcAsg4Uv75xo7ZkkVGS
B71HRp2GWJbXCvhksqq3Sxs8j+OYjoPMQAIVzL+RGX7I+uO4y5DzZTNN/PpgrjlD
V3c0HGiSv4ziKfrMf99/P/WHIAyFKt266MmFIxYp9vx91b4xOrQXdx3DJOCQhVgw
/tXdF0UvuQqnckdL79mmmpetIBZrBu0Gpt6rNIyrFBbxEblPzmlq9ZnxzecnMS3+
du6MHODlV4emW+mQbNZHpqWBllWsJuzEmE7bX6d5hA+kLm84kSxbbGLHCUwzlZWL
jJKzQYEUJC5TArRorlaJh82M3XNkoDmufcZlUGxl6BobUL0K0wIHy3w77+qUcORJ
oYIkhZhdxWmasFHaTS99GR+wFGEHqUdaQbjpNxXg2+u1mzoIbNziV0vkKc6L6JaU
yC86G3gse0x9Qhg+AbjPXlaACbWQUbRiMspMeqOnGPRYfVF0+DIHmKdq07ld9jGV
xuM+roBYhqb7HKox0ded3o9t5MjbKvmAhAMstMmmTbrLTHB7vEI=
=UBHG
-----END PGP SIGNATURE-----
--=-=-=--
