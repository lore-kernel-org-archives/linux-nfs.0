Return-Path: <SRS0=2fom=QY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1B02C43381
	for <linux-nfs@archiver.kernel.org>; Sun, 17 Feb 2019 17:40:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A4A9C2089F
	for <linux-nfs@archiver.kernel.org>; Sun, 17 Feb 2019 17:40:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="4/tJMIm1"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726541AbfBQRkR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 17 Feb 2019 12:40:17 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:40448 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725811AbfBQRkR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Feb 2019 12:40:17 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1HHeD4o164252;
        Sun, 17 Feb 2019 17:40:13 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=ko/r9Fo24DJOp0lw+oGhdvZZBEZFoa9fZBAcieJYrPc=;
 b=4/tJMIm1yYcYC6Hnxw7vQ44aqVKsMiDSPik7Kq0Uo/Lr++Q3BywH5Q+w4XNSjBc9L5jh
 dEmyeQA86gRbPe1TiGhigK5fWckKpn2YyBMBlWcXOX7S9HTXNXhdpyjmxuuNF0jrDtHR
 3yP04EnDC4BjzlHUoHeas41kx1Gs6HSGf8ZtoRkuJFOVZRBmQfwcrdaUMYCF1aSfa0Ot
 EnohXEBhM2k0J3Hno0kTW5aFTaivK2T/9/aGqcgpzWKkKRFWBLIvFFV6YzCGft+HtRCm
 wExLZzmHyS/44hU21McUkNIpkDAD5jA2mT1FOep1bh5wMvto9DRnuBF+an3IPWrOVr14 qw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by userp2130.oracle.com with ESMTP id 2qp9xtk7fr-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 17 Feb 2019 17:40:13 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1HHeCFj025307
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 17 Feb 2019 17:40:12 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1HHeBK5008986;
        Sun, 17 Feb 2019 17:40:11 GMT
Received: from [192.168.1.184] (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sun, 17 Feb 2019 17:40:11 +0000
Content-Type: text/plain;
        charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH] nfs-utils: fix addrinfo usage with musl-1.1.21
From:   Chuck Lever <chuck.lever@oracle.com>
X-Mailer: iPad Mail (16D57)
In-Reply-To: <20190217173901.33296254@onion.lan>
Date:   Sun, 17 Feb 2019 12:40:10 -0500
Cc:     linux-nfs@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <1081BBCD-8CA0-49CC-A02C-16F46FF613BF@oracle.com>
References: <20190217173901.33296254@onion.lan>
To:     Peter Wagner <tripolar@gmx.at>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9170 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902170137
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Peter-

> On Feb 17, 2019, at 11:39 AM, Peter Wagner <tripolar@gmx.at> wrote:
>=20
> Afer the update to musl 1.1.21 freeaddrinfo is broken in some places in
> the nfs-utils code because glibc seems to ignore when freeaddrinfo is
> called with a NULL pointer which seems to be not defined in the spec.
>=20
> See: https://www.openwall.com/lists/musl/2019/02/03/4

It might be cleaner to define a local version of freeaddrinfo in
nfs-utils to reduce duplication of code and provide a place
in the code itself to document this issue with a comment.


> The free in support/export/hostname.c is removed too
>=20
> See: https://www.openwall.com/lists/musl/2019/02/17/2

Actually this seems like a separate issue because a distribution
that uses another C library might decide it is pertinent to apply
separately from the other changes here.

Please create a separate patch. It should remove the free(3)
call instead of commenting it out, and the patch description
should have its own copy of Rich=E2=80=99s email comments.

Thanks!


> =46rom 43e27735553b4c1e75964f32b2f887e84398055f Mon Sep 17 00:00:00 2001
> From: Peter Wagner <tripolar@gmx.at>
> Date: Sun, 17 Feb 2019 17:32:08 +0100
> Subject: [PATCH] fix addrinfo usage
>=20
> Signed-off-by: Peter Wagner <tripolar@gmx.at>
> ---
> support/export/client.c   |  3 ++-
> support/export/hostname.c |  2 +-
> utils/exportfs/exportfs.c | 12 ++++++++----
> utils/mount/stropts.c     |  3 ++-
> utils/mountd/cache.c      |  6 ++++--
> utils/statd/hostname.c    |  6 ++++--
> 6 files changed, 21 insertions(+), 11 deletions(-)
>=20
> diff --git a/support/export/client.c b/support/export/client.c
> index baf59c8..750eb7d 100644
> --- a/support/export/client.c
> +++ b/support/export/client.c
> @@ -309,7 +309,8 @@ client_lookup(char *hname, int canonical)
>       init_addrlist(clp, ai);
>=20
> out:
> -    freeaddrinfo(ai);
> +    if (ai)
> +        freeaddrinfo(ai);
>   return clp;
> }
>=20
> diff --git a/support/export/hostname.c b/support/export/hostname.c
> index 5c4c824..710bf61 100644
> --- a/support/export/hostname.c
> +++ b/support/export/hostname.c
> @@ -354,7 +354,7 @@ host_numeric_addrinfo(const struct sockaddr *sap)
>    * getaddrinfo(AI_NUMERICHOST) never fills in ai_canonname
>    */
>   if (ai !=3D NULL) {
> -        free(ai->ai_canonname);        /* just in case */
> +        //free(ai->ai_canonname);        /* just in case */
>       ai->ai_canonname =3D strdup(buf);
>       if (ai->ai_canonname =3D=3D NULL) {
>           freeaddrinfo(ai);
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index cd3c979..2f8d59a 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -282,7 +282,8 @@ exportfs_parsed(char *hname, char *path, char *options=
, int verbose)
>   validate_export(exp);
>=20
> out:
> -    freeaddrinfo(ai);
> +    if (ai)
> +        freeaddrinfo(ai);
> }
>=20
> static int exportfs_generic(char *arg, char *options, int verbose)
> @@ -395,7 +396,8 @@ unexportfs_parsed(char *hname, char *path, int verbose=
)
>   if (!success)
>       xlog(L_ERROR, "Could not find '%s:%s' to unexport.", hname, path);
>=20
> -    freeaddrinfo(ai);
> +    if (ai)
> +        freeaddrinfo(ai);
> }
>=20
> static int unexportfs_generic(char *arg, int verbose)
> @@ -639,8 +641,10 @@ matchhostname(const char *hostname1, const char *host=
name2)
>           }
>=20
> out:
> -    freeaddrinfo(results1);
> -    freeaddrinfo(results2);
> +    if (results1)
> +        freeaddrinfo(results1);
> +    if (results2)
> +        freeaddrinfo(results2);
>   return result;
> }
>=20
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 0a25b1f..8b7a0a8 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -1268,7 +1268,8 @@ int nfsmount_string(const char *spec, const char *no=
de, char *type,
>   } else
>       nfs_error(_("%s: internal option parsing error"), progname);
>=20
> -    freeaddrinfo(mi.address);
> +    if (mi.address)
> +        freeaddrinfo(mi.address);
>   free(mi.hostname);
>   return retval;
> }
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 7e8d403..8cee1c8 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -834,7 +834,8 @@ static void nfsd_fh(int f)
> out:
>   if (found_path)
>       free(found_path);
> -    freeaddrinfo(ai);
> +    if(ai)
> +        freeaddrinfo(ai);
>   free(dom);
>   xlog(D_CALL, "nfsd_fh: found %p path %s", found, found ? found->e_path :=
 NULL);
> }
> @@ -1355,7 +1356,8 @@ static void nfsd_export(int f)
>   xlog(D_CALL, "nfsd_export: found %p path %s", found, path ? path : NULL)=
;
>   if (dom) free(dom);
>   if (path) free(path);
> -    freeaddrinfo(ai);
> +    if (ai)
> +        freeaddrinfo(ai);
> }
>=20
>=20
> diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
> index 8cccdb8..6556ab1 100644
> --- a/utils/statd/hostname.c
> +++ b/utils/statd/hostname.c
> @@ -308,8 +308,10 @@ statd_matchhostname(const char *hostname1, const char=
 *hostname2)
>           }
>=20
> out:
> -    freeaddrinfo(results2);
> -    freeaddrinfo(results1);
> +    if (results2)
> +        freeaddrinfo(results2);
> +    if (results1)
> +        freeaddrinfo(results1);
>=20
>   xlog(D_CALL, "%s: hostnames %s and %s %s", __func__,
>           hostname1, hostname2,
> --=20
> 2.20.1
>=20

