Return-Path: <SRS0=zHXY=OH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B845C43441
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 21:05:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 08DA02081C
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 21:05:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="lNFMPZPy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08DA02081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726369AbeK2IID (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 29 Nov 2018 03:08:03 -0500
Received: from aserp2120.oracle.com ([141.146.126.78]:57336 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725996AbeK2IID (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2018 03:08:03 -0500
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wASL4PFf053376;
        Wed, 28 Nov 2018 21:05:03 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=mgYy0UsyO6GHP1eepXEiXExA1kvMQgyRnr9TNTcN/1g=;
 b=lNFMPZPy+eExJ8yqpTuxSDiq9qbheUcWZxFQEPCi5ceUqHKCKEelns+veixRAavbSgYn
 riplmWLNIG0ZBFt3K3xxWhCF/ks9/d7WSSU2PaoLTwMtnFNcjDVmY0PnJfmdb1vlVCoS
 Bk06EIquF5xgMD73ocmY2kdYr/bgXhxJVH6knBmug+7gOt/u+mqGoOARWDfcOlEIDxM3
 6zEuYqZR2EGGyt8RUlTmnvLbBWj6BcVOu056YJK0FrH7E690bfxs2s6ao9rrezNtJAjX
 Uy8vqvJJv8WDPAfm5axtU7HmLI2wKlgmBBSfEjBOzVRPhumquH/IdTawboDfDNWbCtRf 6w== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by aserp2120.oracle.com with ESMTP id 2nxxkqmnf7-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 28 Nov 2018 21:05:03 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wASL52Hq009283
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 28 Nov 2018 21:05:02 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wASL52IO012965;
        Wed, 28 Nov 2018 21:05:02 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Wed, 28 Nov 2018 13:05:01 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v1 3/3] Finish port of junction support to nfs-utils
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <6443fe07-373c-2ef2-c491-20bdd083e620@RedHat.com>
Date:   Wed, 28 Nov 2018 16:05:00 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <D30C0131-84B2-4A95-ADEC-E688FFF2FE64@oracle.com>
References: <20181031200218.7507.15214.stgit@klimt.1015granger.net>
 <20181031200229.7507.26189.stgit@klimt.1015granger.net>
 <EA0135DC-ADCF-49C1-A5C3-03499F62C37E@oracle.com>
 <6443fe07-373c-2ef2-c491-20bdd083e620@RedHat.com>
To:     Steve Dickson <SteveD@RedHat.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9091 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1811280183
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Nov 28, 2018, at 4:00 PM, Steve Dickson <SteveD@RedHat.com> wrote:
>=20
>=20
>=20
> On 11/27/18 11:45 AM, Chuck Lever wrote:
>> Ping!
> My apologies for taking so long to get to this...=20
> I took an extended Thanksgiving then completely=20
> for got about it... Thanks for the ping... but :-)=20
>=20
> When I enable junctions via  --enable-junction I get the
> following compile error with or w/out these patches
>=20
> gcc -DHAVE_CONFIG_H -I. -I../../support/include  -I. =
-I../../support/include -D_GNU_SOURCE -pipe  -Wall  -Wextra  =
-Werror=3Dstrict-prototypes  -Werror=3Dmissing-prototypes  =
-Werror=3Dmissing-declarations  -Werror=3Dformat=3D2  -Werror=3Dundef  =
-Werror=3Dmissing-include-dirs  -Werror=3Dstrict-aliasing=3D2  =
-Werror=3Dinit-self  -Werror=3Dimplicit-function-declaration  =
-Werror=3Dreturn-type  -Werror=3Dswitch  -Werror=3Doverflow  =
-Werror=3Dparentheses  -Werror=3Daggregate-return  -Werror=3Dunused-result=
  -fno-strict-aliasing  -Werror=3Dformat-overflow=3D2 =
-Werror=3Dint-conversion -Werror=3Dincompatible-pointer-types =
-Werror=3Dmisleading-indentation -g -O2 -MT remove.o -MD -MP -MF =
.deps/remove.Tpo -c -o remove.o remove.c
> In file included from lookup.c:31:
> ../../support/include/rpcsvc/nfs_prot.h:9:10: fatal error: rpc/rpc.h: =
No such file or directory
> #include <rpc/rpc.h>
>          ^~~~~~~~~~~
> I know how to fix it... Add the following to CFLAGS and LDFLAGS
> `pkg-config --cflags libtirpc`
> `pkg-config --libs libtirpc`
>=20
> First I'm wonder how you got things to compile w/out making these =
changes

Well I built and tested this on RHEL 7. If you're testing on
late-model Fedora, you're probably getting a slightly different
build configuration. Just a guess.


> and secondly I'm wondering where we should make these changes...=20
>=20
> Maybe we should hardcode the -I/usr/include/tirpc and -ltirpc
> flags in aclocal/libtirpc.m4?

libtirpc.m4 seems like the right place, but hard-coding seems
like a sledgehammer. Maybe have a look at the changes I made
to libxml2.m4 and do something similar?


> steved.
>=20
>>=20
>>=20
>>> On Oct 31, 2018, at 4:02 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>>=20
>>> CONFIG_JUNCTION was defined for use in Makefiles, but that does not
>>> provide a -DCONFIG_JUNCTION on the compiler command line. Add logic
>>> to configure.ac to get the compiler flags right.
>>>=20
>>> Now that mountd junction support is getting built, a few last minute
>>> porting bugs popped out. Fix those up.
>>>=20
>>> Reported-by: Yongcheng Yang <yoyang@redhat.com>
>>> BugLink: https://bugzilla.redhat.com/show_bug.cgi?id=3D1543126
>>> Fixes: 79978ed34973 ("mountd: Solder in support for NFS basic ... ")
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> configure.ac         |    8 +++++++-
>>> utils/mountd/cache.c |   18 +++++++++---------
>>> 2 files changed, 16 insertions(+), 10 deletions(-)
>>>=20
>>> diff --git a/configure.ac b/configure.ac
>>> index 16eae06..b458891 100644
>>> --- a/configure.ac
>>> +++ b/configure.ac
>>> @@ -185,7 +185,13 @@ AC_ARG_ENABLE(junction,
>>> 			[enable support for NFS junctions =
@<:@default=3Dno@:>@])],
>>> 	enable_junction=3D$enableval,
>>> 	enable_junction=3Dno)
>>> -AM_CONDITIONAL(CONFIG_JUNCTION, [test "$enable_junction" =3D "yes" =
])
>>> +	if test "$enable_junction" =3D yes; then
>>> +		AC_DEFINE(HAVE_JUNCTION_SUPPORT, 1,
>>> +                          [Define this if you want junction support =
compiled in])
>>> +	else
>>> +		enable_junction=3D
>>> +	fi
>>> +	AM_CONDITIONAL(CONFIG_JUNCTION, [test "$enable_junction" =3D =
"yes" ])
>>>=20
>>> AC_ARG_ENABLE(tirpc,
>>> 	[AC_HELP_STRING([--disable-tirpc],
>>> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
>>> index 6f42512..7e8d403 100644
>>> --- a/utils/mountd/cache.c
>>> +++ b/utils/mountd/cache.c
>>> @@ -976,8 +976,9 @@ lookup_export(char *dom, char *path, struct =
addrinfo *ai)
>>> 	return found;
>>> }
>>>=20
>>> -#ifdef CONFIG_JUNCTION
>>> +#ifdef HAVE_JUNCTION_SUPPORT
>>>=20
>>> +#include <libxml/parser.h>
>>> #include "junction.h"
>>>=20
>>> struct nfs_fsloc_set {
>>> @@ -1084,8 +1085,7 @@ static bool locations_to_fslocdata(struct =
nfs_fsloc_set *locations,
>>> 	*ttl =3D 0;
>>>=20
>>> 	for (;;) {
>>> -		enum jp_status status;
>>> -		int len;
>>> +		int len, status;
>>>=20
>>> 		status =3D get_next_location(locations, &server,
>>> 							&rootpath, ttl);
>>> @@ -1219,7 +1219,7 @@ nfs_get_basic_junction(const char *junct_path, =
struct nfs_fsloc_set **locset)
>>> 		return EINVAL;
>>> 	}
>>>=20
>>> -	locset->ns_current =3D locset->ns_list;
>>> +	new->ns_current =3D new->ns_list;
>>> 	new->ns_ttl =3D 300;
>>> 	*locset =3D new;
>>> 	return 0;
>>> @@ -1242,7 +1242,7 @@ static struct exportent *lookup_junction(char =
*dom, const char *pathname,
>>> 	status =3D nfs_get_basic_junction(pathname, &locations);
>>> 	switch (status) {
>>> 		xlog(L_WARNING, "Dangling junction %s: %s",
>>> -			pathname, strerro(status));
>>> +			pathname, strerror(status));
>>> 		goto out;
>>> 	}
>>>=20
>>> @@ -1252,8 +1252,8 @@ static struct exportent *lookup_junction(char =
*dom, const char *pathname,
>>>=20
>>> 	exp =3D locations_to_export(locations, pathname, parent);
>>>=20
>>> -	nfs_free_locations(locset->ns_list);
>>> -	free(locset);
>>> +	nfs_free_locations(locations->ns_list);
>>> +	free(locations);
>>>=20
>>> out:
>>> 	xmlCleanupParser();
>>> @@ -1273,7 +1273,7 @@ static void lookup_nonexport(int f, char *buf, =
int buflen, char *dom, char *path
>>> 	free(eep);
>>> }
>>>=20
>>> -#else	/* !CONFIG_JUNCTION */
>>> +#else	/* !HAVE_JUNCTION_SUPPORT */
>>>=20
>>> static void lookup_nonexport(int f, char *buf, int buflen, char =
*dom, char *path,
>>> 		struct addrinfo *UNUSED(ai))
>>> @@ -1281,7 +1281,7 @@ static void lookup_nonexport(int f, char *buf, =
int buflen, char *dom, char *path
>>> 	dump_to_cache(f, buf, buflen, dom, path, NULL, 0);
>>> }
>>>=20
>>> -#endif	/* !CONFIG_JUNCTION */
>>> +#endif	/* !HAVE_JUNCTION_SUPPORT */
>>>=20
>>> static void nfsd_export(int f)
>>> {
>>>=20
>>=20
>> --
>> Chuck Lever
>>=20
>>=20
>>=20

--
Chuck Lever



