Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45816 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932231AbdC3GvG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 30 Mar 2017 02:51:06 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jason Yan <yanaijie@huawei.com>
Date: Thu, 30 Mar 2017 17:50:47 +1100
Cc: jlayton@poochiereds.net, linux-nfs@vger.kernel.org,
        miaoxie@huawei.com, zhaohongjiang@huawei.com
Subject: Re: [PATCH] nfsd: make strdup_if_nonnull static
In-Reply-To: <20170329215132.GC29934@fieldses.org>
References: <1490259456-15858-1-git-send-email-yanaijie@huawei.com> <20170329215132.GC29934@fieldses.org>
Message-ID: <874lyb5kc8.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 29 2017, J. Bruce Fields wrote:

> Thanks, applying for 4.12.--b.

Ugh... does strdup_if_nonnull() actually help readability at all?
kstrdup() already handles NULL fine, which is what the name seems to
suggest is happening.
I would think kstrdup_report_error() is a name that better reflects the
function.

Or just discard it:

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e9ef50addddb..cf28d1056e70 100644
=2D-- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1912,28 +1912,14 @@ static void copy_clid(struct nfs4_client *target, s=
truct nfs4_client *source)
 	target->cl_clientid.cl_id =3D source->cl_clientid.cl_id;=20
 }
=20
=2Dint strdup_if_nonnull(char **target, char *source)
=2D{
=2D	if (source) {
=2D		*target =3D kstrdup(source, GFP_KERNEL);
=2D		if (!*target)
=2D			return -ENOMEM;
=2D	} else
=2D		*target =3D NULL;
=2D	return 0;
=2D}
=2D
 static int copy_cred(struct svc_cred *target, struct svc_cred *source)
 {
=2D	int ret;
+	target->cr_principal =3D kstrdup(source->cr_principal, GFP_KERNEL);
+	target->cr_raw_principal =3D kstrdup(source->cr_raw_principal, GFP_KERNEL=
);
+	if ((source->cr_principal && ! target->cr_principal) ||
+	    (source->cr_raw_principal && ! target->cr_raw_principal))
+		return -ENOMEM;
=20
=2D	ret =3D strdup_if_nonnull(&target->cr_principal, source->cr_principal);
=2D	if (ret)
=2D		return ret;
=2D	ret =3D strdup_if_nonnull(&target->cr_raw_principal,
=2D					source->cr_raw_principal);
=2D	if (ret)
=2D		return ret;
 	target->cr_flavor =3D source->cr_flavor;
 	target->cr_uid =3D source->cr_uid;
 	target->cr_gid =3D source->cr_gid;


NeilBrown

>
> On Thu, Mar 23, 2017 at 04:57:36PM +0800, Jason Yan wrote:
>> Fixes the following sparse warning:
>>=20
>> fs/nfsd/nfs4state.c:1915:5: warning: symbol 'strdup_if_nonnull' was not
>> declared. Should it be static?
>>=20
>> Signed-off-by: Jason Yan <yanaijie@huawei.com>
>> ---
>>  fs/nfsd/nfs4state.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>=20
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index e9ef50a..59a9e30 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -1912,7 +1912,7 @@ static void copy_clid(struct nfs4_client *target, =
struct nfs4_client *source)
>>  	target->cl_clientid.cl_id =3D source->cl_clientid.cl_id;=20
>>  }
>>=20=20
>> -int strdup_if_nonnull(char **target, char *source)
>> +static int strdup_if_nonnull(char **target, char *source)
>>  {
>>  	if (source) {
>>  		*target =3D kstrdup(source, GFP_KERNEL);
>> --=20
>> 2.5.0
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljcqscACgkQOeye3VZi
gbky6hAApq9M46rMWrCX1B7rWG0nxOOwh0gi1nWT1N8aKLaCP6M6grbfYYXlyFKG
55OX+c0xqNGJaZvhUUt0BsLga+7C45M+E9pKeBvJe9xwFrFnEUVl7YF6z6FUrCF8
TmdH3OXES81daaV5ZbiL0YM366TT6GPaMXz638k7IDqd3IE3gO9zthcDQyzNjNlf
RbT+NvXcc4GMxrOQgbqQFR0p9ga/N4XQtL73sWU+bx+lN2G88Blrs1eALK11cWp7
uQHPwu47PnvkDK8YceHhjJqJ5bVknJKo6n4dQqPL2Fxdsb9N9sf0vx1SN9+1smtp
XYchRN8AusKvqihJPNX7O1sLrJrjhiXShzKINdSNbY2h2tyWrO6ywkpYGE9rHl9u
Gg1C1p1yfcYKx/St9xjqCAgLLilZESvlQtdtExba7Nh7Vbe55SbNgEuetAQt031I
jcKsUw30ZnxCrn7OmgpgoLbyvQgAMXEGhduAtp1DIPhEiY4zwToKHahPW8FB2B3H
3L5XPj+w7ZNUvYUUUARijQmwskqn9q87U2utMwnrHuBlD3WJ91nI6HF3HW50xP0d
HtGW+1ToqjK1mE8gERi/btPbDtmQ9pUzsL+wvhYfC5VH13hTX0TdZ8FlWXAD+6up
CRWa5lnd/V/0HKviZozD0vshYtbB5wHU7ekzNbG9l79Ywp9DpwE=
=SwsV
-----END PGP SIGNATURE-----
--=-=-=--
