Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:46048 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965632AbeFNOV5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jun 2018 10:21:57 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.4 \(3445.8.2\))
Subject: Re: [PATCH] Reallow AUTH_NULL on v4 mounts.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180614135201.GB24594@fieldses.org>
Date: Thu, 14 Jun 2018 10:21:39 -0400
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Message-Id: <012E671E-A2DE-4A3D-8BCD-C83BC8D73783@oracle.com>
References: <20180614135201.GB24594@fieldses.org>
To: Bruce Fields <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jun 14, 2018, at 9:52 AM, bfields@fieldses.org wrote:
>=20
> From: "J. Bruce Fields" <bfields@redhat.com>
>=20
> Kinglong Mee noted that the loop in seicnfo_addflavor (which sets the
> security flavors allowed on the v4 pseudoroot) was adding flavors 1 =
and
> 0 twice; this is because flav_map ends with these entries:
>=20
> 	{ "unix",       AUTH_UNIX               },
>        { "sys",        AUTH_SYS                },
>        { "null",       AUTH_NULL               },
>        { "none",       AUTH_NONE               },
>=20
> where AUTH_UNIX =3D=3D AUTH_SYS =3D=3D 1 and AUTH_NULL =3D=3D =
AUTH_NONE =3D=3D 1.

Hi Bruce, patch description may be incorrect: NULL and NONE should be 0.

> We
> need to allow two names for each of those two security flavors for
> historical reasons.
>=20
> The patch correctly fixed this by fixing the check for a duplicate
> flavor number in secinfo_addflavor().  However it also went one step
> further and rejected the flavor number 0.  This is unnecessary and
> causes the kernel to fail any NFSv4 mounts using AUTH_NULL.
>=20
> The fact that we've apparently gone a few years without anyone =
noticing
> this suggests AUTH_NULL isn't used very much!  Still, this should be
> fixed....
>=20
> Fixes: e69eaaf93626
> Cc: Kinglong Mee <kinglongmee@gmail.com>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
> utils/mountd/v4root.c | 3 ---
> 1 file changed, 3 deletions(-)
>=20
> diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
> index d735dbfe192d..c93bd4db51c8 100644
> --- a/utils/mountd/v4root.c
> +++ b/utils/mountd/v4root.c
> @@ -69,9 +69,6 @@ set_pseudofs_security(struct exportent *pseudo, int =
flags)
> 	for (flav =3D flav_map; flav < flav_map + flav_map_size; flav++) =
{
> 		struct sec_entry *new;
>=20
> -		if (!flav->fnum)
> -			continue;
> -
> 		i =3D secinfo_addflavor(flav, pseudo);
> 		new =3D &pseudo->e_secinfo[i];
>=20
> --=20
> 2.17.1
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



