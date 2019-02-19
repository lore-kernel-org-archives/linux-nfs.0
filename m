Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9775C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 15:41:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6F58721738
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 15:41:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="OSL64Upn"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725885AbfBSPlQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 10:41:16 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:56228 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726110AbfBSPlQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 10:41:16 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1JFdDGq040200;
        Tue, 19 Feb 2019 15:41:01 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=BfclNLPBkf4+4h/mytdGTKOYXaePFfIEtoa9LYG2Usc=;
 b=OSL64Upnq0q1rmRsItOQsmvIm5PTIdgCo4flY0NDEqb2jZXbXOFRr7x5jqto9qOnZwBu
 tdv4I99iWq5eR+vLWJi9d7ib7zeZzjhlXRiX46QulthkUghdJDW4dbx3FPomAJiWAzmc
 CmcEM0ouHkXbW/oN2fRpdHoN/Vso5paCtGBe/9g5N8mgiFV/vNgcsMaeLPO+TVfD7Dgw
 N7Cag3a/21MG2cJXXy/M69aNF/LWF9ybnqgtRO+RAJbY5rJQL7MHSNN7HIba2Eg0Xwp4
 eJpPmZnX/wG4ZILWslML6FbTDVwttoMlkv+H5vdfXTD+Mvz2ukk0q84TmhiywITW/fsw Dg== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2130.oracle.com with ESMTP id 2qp9xtv0d4-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 19 Feb 2019 15:41:01 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1JFf1e3002588
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 19 Feb 2019 15:41:01 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1JFf0mR012219;
        Tue, 19 Feb 2019 15:41:00 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 19 Feb 2019 07:41:00 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH RFC] Remove one usage of ai_canonname
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190219153100.16674.71283.stgit@manet.1015granger.net>
Date:   Tue, 19 Feb 2019 10:40:59 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <6F18BB24-1D6A-47F0-B545-6528B1E7F61C@oracle.com>
References: <20190219153100.16674.71283.stgit@manet.1015granger.net>
To:     Steve Dickson <SteveD@redhat.com>, Peter Wagner <tripolar@gmx.at>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9172 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902190116
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Feb 19, 2019, at 10:31 AM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>=20
> Peter Wagner <tripolar@gmx.at> reports a portability issue with
> freeing ai_canonname (and subsequently replacing that pointer via
> strdup(3)). The relevant standards text is:
>=20
>> If nodename is not null, and if requested by the AI_CANONNAME
>> flag, the ai_canonname field of the first returned addrinfo
>> structure shall point to a null-terminated string containing the
>> canonical name corresponding to the input nodename; if the
>> canonical name is not available, then ai_canonname shall refer to
>> the nodename argument or a string with the same contents.
>=20
> There is no indication that this string may be freed using free(3).
> Eg, the library could have allocated it as part of the addrinfo
> struct itself, or it could point to static memory. The Linux man
> page is equally silent on this issue.
>=20
> There is only one caller to host_reliable_addrinfo() that actually
> uses the string in ai->ai_canonname, and then only for debugging
> messages. Change those to display the IP address instead.

Actually, now that I look at callers to host_numeric_addrinfo,
it appears that client_resolve is the only one. So this might fix
the entire issue (with the addition of hunks to remove the faulty
free/strdup logic from host_numeric_addrinfo).

Steve, Peter, is that your reading as well?


> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> support/export/hostname.c |   25 ++++++++++---------------
> utils/mountd/auth.c       |   16 ++++++++--------
> 2 files changed, 18 insertions(+), 23 deletions(-)
>=20
> This patch is compile-tested only. Steve, does this patch pass your
> internal tests? Are the new debugging messages sufficient IYO ?
>=20
> diff --git a/support/export/hostname.c b/support/export/hostname.c
> index 5c4c824..9914e0d 100644
> --- a/support/export/hostname.c
> +++ b/support/export/hostname.c
> @@ -264,9 +264,9 @@ host_canonname(const struct sockaddr *sap)
>  * Reverse and forward lookups are performed to ensure the address has
>  * matching forward and reverse mappings.
>  *
> - * Returns addrinfo structure with just the provided address with
> - * ai_canonname filled in. If there is a problem with resolution or
> - * the resolved records don't match up properly then it returns NULL
> + * Returns addrinfo structure with just the provided address. If =
there
> + * is a problem with resolution or the resolved records don't match =
up
> + * properly then returns NULL.
>  *
>  * Caller must free the returned structure with freeaddrinfo(3).
>  */
> @@ -277,13 +277,15 @@ host_reliable_addrinfo(const struct sockaddr =
*sap)
> 	struct addrinfo *ai, *a;
> 	char *hostname;
>=20
> +	ai =3D NULL;
> 	hostname =3D host_canonname(sap);
> 	if (hostname =3D=3D NULL)
> -		return NULL;
> +		goto out;
>=20
> 	ai =3D host_addrinfo(hostname);
> +	free(hostname);
> 	if (!ai)
> -		goto out_free_hostname;
> +		goto out;
>=20
> 	/* make sure there's a matching address in the list */
> 	for (a =3D ai; a; a =3D a->ai_next)
> @@ -291,22 +293,15 @@ host_reliable_addrinfo(const struct sockaddr =
*sap)
> 			break;
>=20
> 	freeaddrinfo(ai);
> +	ai =3D NULL;
> 	if (!a)
> -		goto out_free_hostname;
> +		goto out;
>=20
> 	/* get addrinfo with just the original address */
> 	ai =3D host_numeric_addrinfo(sap);
> -	if (!ai)
> -		goto out_free_hostname;
>=20
> -	/* and populate its ai_canonname field */
> -	free(ai->ai_canonname);
> -	ai->ai_canonname =3D hostname;
> +out:
> 	return ai;
> -
> -out_free_hostname:
> -	free(hostname);
> -	return NULL;
> }
>=20
> /**
> diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
> index 8299256..cb4848c 100644
> --- a/utils/mountd/auth.c
> +++ b/utils/mountd/auth.c
> @@ -261,40 +261,40 @@ auth_authenticate(const char *what, const struct =
sockaddr *caller,
> 		*p =3D '\0';
> 	}
>=20
> +	host_ntop(caller, buf, sizeof(buf));
> 	switch (error) {
> 	case bad_path:
> 		xlog(L_WARNING, "bad path in %s request from %s: =
\"%s\"",
> -		     what, host_ntop(caller, buf, sizeof(buf)), path);
> +		     what, buf, path);
> 		break;
>=20
> 	case unknown_host:
> 		xlog(L_WARNING, "refused %s request from %s for %s (%s): =
unmatched host",
> -		     what, host_ntop(caller, buf, sizeof(buf)), path, =
epath);
> +		     what, buf, path, epath);
> 		break;
>=20
> 	case no_entry:
> 		xlog(L_WARNING, "refused %s request from %s for %s (%s): =
no export entry",
> -		     what, ai->ai_canonname, path, epath);
> +		     what, buf, path, epath);
> 		break;
>=20
> 	case not_exported:
> 		xlog(L_WARNING, "refused %s request from %s for %s (%s): =
not exported",
> -		     what, ai->ai_canonname, path, epath);
> +		     what, buf, path, epath);
> 		break;
>=20
> 	case illegal_port:
> 		xlog(L_WARNING, "refused %s request from %s for %s (%s): =
illegal port %u",
> -		     what, ai->ai_canonname, path, epath, =
nfs_get_port(caller));
> +		     what, buf, path, epath, nfs_get_port(caller));
> 		break;
>=20
> 	case success:
> 		xlog(L_NOTICE, "authenticated %s request from %s:%u for =
%s (%s)",
> -		     what, ai->ai_canonname, nfs_get_port(caller), path, =
epath);
> +		     what, buf, nfs_get_port(caller), path, epath);
> 		break;
> 	default:
> 		xlog(L_NOTICE, "%s request from %s:%u for %s (%s) gave =
%d",
> -		     what, ai->ai_canonname, nfs_get_port(caller),
> -			path, epath, error);
> +		     what, buf, nfs_get_port(caller), path, epath, =
error);
> 	}
>=20
> 	freeaddrinfo(ai);
>=20

--
Chuck Lever



