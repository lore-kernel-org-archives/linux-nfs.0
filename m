Return-Path: <SRS0=zHXY=OH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B4D4C43441
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 21:00:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 247182081C
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 21:00:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 247182081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=RedHat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726413AbeK2IDK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 29 Nov 2018 03:03:10 -0500
Received: from mx1.redhat.com ([209.132.183.28]:33880 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725996AbeK2IDK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Nov 2018 03:03:10 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 33070308FC5A;
        Wed, 28 Nov 2018 21:00:14 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-162.phx2.redhat.com [10.3.116.162])
        by smtp.corp.redhat.com (Postfix) with ESMTP id BA9AD19754;
        Wed, 28 Nov 2018 21:00:13 +0000 (UTC)
Subject: Re: [PATCH v1 3/3] Finish port of junction support to nfs-utils
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20181031200218.7507.15214.stgit@klimt.1015granger.net>
 <20181031200229.7507.26189.stgit@klimt.1015granger.net>
 <EA0135DC-ADCF-49C1-A5C3-03499F62C37E@oracle.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <6443fe07-373c-2ef2-c491-20bdd083e620@RedHat.com>
Date:   Wed, 28 Nov 2018 16:00:13 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <EA0135DC-ADCF-49C1-A5C3-03499F62C37E@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 28 Nov 2018 21:00:14 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 11/27/18 11:45 AM, Chuck Lever wrote:
> Ping!
My apologies for taking so long to get to this... 
I took an extended Thanksgiving then completely 
for got about it... Thanks for the ping... but :-) 

When I enable junctions via  --enable-junction I get the
following compile error with or w/out these patches

gcc -DHAVE_CONFIG_H -I. -I../../support/include  -I. -I../../support/include -D_GNU_SOURCE -pipe  -Wall  -Wextra  -Werror=strict-prototypes  -Werror=missing-prototypes  -Werror=missing-declarations  -Werror=format=2  -Werror=undef  -Werror=missing-include-dirs  -Werror=strict-aliasing=2  -Werror=init-self  -Werror=implicit-function-declaration  -Werror=return-type  -Werror=switch  -Werror=overflow  -Werror=parentheses  -Werror=aggregate-return  -Werror=unused-result  -fno-strict-aliasing  -Werror=format-overflow=2 -Werror=int-conversion -Werror=incompatible-pointer-types -Werror=misleading-indentation -g -O2 -MT remove.o -MD -MP -MF .deps/remove.Tpo -c -o remove.o remove.c
In file included from lookup.c:31:
../../support/include/rpcsvc/nfs_prot.h:9:10: fatal error: rpc/rpc.h: No such file or directory
 #include <rpc/rpc.h>
          ^~~~~~~~~~~
I know how to fix it... Add the following to CFLAGS and LDFLAGS
`pkg-config --cflags libtirpc`
`pkg-config --libs libtirpc`

First I'm wonder how you got things to compile w/out making these changes
and secondly I'm wondering where we should make these changes... 

Maybe we should hardcode the -I/usr/include/tirpc and -ltirpc
flags in aclocal/libtirpc.m4? 

steved.

> 
> 
>> On Oct 31, 2018, at 4:02 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>
>> CONFIG_JUNCTION was defined for use in Makefiles, but that does not
>> provide a -DCONFIG_JUNCTION on the compiler command line. Add logic
>> to configure.ac to get the compiler flags right.
>>
>> Now that mountd junction support is getting built, a few last minute
>> porting bugs popped out. Fix those up.
>>
>> Reported-by: Yongcheng Yang <yoyang@redhat.com>
>> BugLink: https://bugzilla.redhat.com/show_bug.cgi?id=1543126
>> Fixes: 79978ed34973 ("mountd: Solder in support for NFS basic ... ")
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> configure.ac         |    8 +++++++-
>> utils/mountd/cache.c |   18 +++++++++---------
>> 2 files changed, 16 insertions(+), 10 deletions(-)
>>
>> diff --git a/configure.ac b/configure.ac
>> index 16eae06..b458891 100644
>> --- a/configure.ac
>> +++ b/configure.ac
>> @@ -185,7 +185,13 @@ AC_ARG_ENABLE(junction,
>> 			[enable support for NFS junctions @<:@default=no@:>@])],
>> 	enable_junction=$enableval,
>> 	enable_junction=no)
>> -AM_CONDITIONAL(CONFIG_JUNCTION, [test "$enable_junction" = "yes" ])
>> +	if test "$enable_junction" = yes; then
>> +		AC_DEFINE(HAVE_JUNCTION_SUPPORT, 1,
>> +                          [Define this if you want junction support compiled in])
>> +	else
>> +		enable_junction=
>> +	fi
>> +	AM_CONDITIONAL(CONFIG_JUNCTION, [test "$enable_junction" = "yes" ])
>>
>> AC_ARG_ENABLE(tirpc,
>> 	[AC_HELP_STRING([--disable-tirpc],
>> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
>> index 6f42512..7e8d403 100644
>> --- a/utils/mountd/cache.c
>> +++ b/utils/mountd/cache.c
>> @@ -976,8 +976,9 @@ lookup_export(char *dom, char *path, struct addrinfo *ai)
>> 	return found;
>> }
>>
>> -#ifdef CONFIG_JUNCTION
>> +#ifdef HAVE_JUNCTION_SUPPORT
>>
>> +#include <libxml/parser.h>
>> #include "junction.h"
>>
>> struct nfs_fsloc_set {
>> @@ -1084,8 +1085,7 @@ static bool locations_to_fslocdata(struct nfs_fsloc_set *locations,
>> 	*ttl = 0;
>>
>> 	for (;;) {
>> -		enum jp_status status;
>> -		int len;
>> +		int len, status;
>>
>> 		status = get_next_location(locations, &server,
>> 							&rootpath, ttl);
>> @@ -1219,7 +1219,7 @@ nfs_get_basic_junction(const char *junct_path, struct nfs_fsloc_set **locset)
>> 		return EINVAL;
>> 	}
>>
>> -	locset->ns_current = locset->ns_list;
>> +	new->ns_current = new->ns_list;
>> 	new->ns_ttl = 300;
>> 	*locset = new;
>> 	return 0;
>> @@ -1242,7 +1242,7 @@ static struct exportent *lookup_junction(char *dom, const char *pathname,
>> 	status = nfs_get_basic_junction(pathname, &locations);
>> 	switch (status) {
>> 		xlog(L_WARNING, "Dangling junction %s: %s",
>> -			pathname, strerro(status));
>> +			pathname, strerror(status));
>> 		goto out;
>> 	}
>>
>> @@ -1252,8 +1252,8 @@ static struct exportent *lookup_junction(char *dom, const char *pathname,
>>
>> 	exp = locations_to_export(locations, pathname, parent);
>>
>> -	nfs_free_locations(locset->ns_list);
>> -	free(locset);
>> +	nfs_free_locations(locations->ns_list);
>> +	free(locations);
>>
>> out:
>> 	xmlCleanupParser();
>> @@ -1273,7 +1273,7 @@ static void lookup_nonexport(int f, char *buf, int buflen, char *dom, char *path
>> 	free(eep);
>> }
>>
>> -#else	/* !CONFIG_JUNCTION */
>> +#else	/* !HAVE_JUNCTION_SUPPORT */
>>
>> static void lookup_nonexport(int f, char *buf, int buflen, char *dom, char *path,
>> 		struct addrinfo *UNUSED(ai))
>> @@ -1281,7 +1281,7 @@ static void lookup_nonexport(int f, char *buf, int buflen, char *dom, char *path
>> 	dump_to_cache(f, buf, buflen, dom, path, NULL, 0);
>> }
>>
>> -#endif	/* !CONFIG_JUNCTION */
>> +#endif	/* !HAVE_JUNCTION_SUPPORT */
>>
>> static void nfsd_export(int f)
>> {
>>
> 
> --
> Chuck Lever
> 
> 
> 
