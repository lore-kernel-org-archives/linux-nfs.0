Return-Path: <SRS0=QdOa=QZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5726FC43381
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 17:00:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1AE4220700
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 17:00:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Z+0cOGrL"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732804AbfBRRAV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Feb 2019 12:00:21 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:58820 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731758AbfBRRAU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2019 12:00:20 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1IGsMsJ180877;
        Mon, 18 Feb 2019 17:00:10 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=jkNkGozWDticrVm7/X6dW1Dtr4V6nn9HMkR9o0ix4RY=;
 b=Z+0cOGrL2U7rmlnDIjtoLCcpdBQ1AH7tCcJEFBbSn7zxpyWfLRQF/FnjlIloXD7dUhhA
 ANwaL2EVDFNotV8CW9MqVfQMTx1UqXB+XCJHxE0gxnImANOy/bvaU6QaVeKKLwiVe3Tx
 3ED9Ber3tptfOn4lPbfY+E2/GnSUfbxYkBQjUihTFd8duuhQ+dwvE41QxlIIWSrjiZ7E
 CdrKHKIL/R2NeI/pTEUJB1pc0QBmX2WG/F74zG7js264L5ZCRuvdQC8FQGcQ0xoKPdc+
 v1Hf7XsX1oYDsSYjvqgNCxKGNdnmS9oOiILF4KWuLyll3mSfOBqnmWSz28boY8ZNNq/F ew== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by aserp2130.oracle.com with ESMTP id 2qp81dycef-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 18 Feb 2019 17:00:10 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1IH09Q5017382
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 18 Feb 2019 17:00:09 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1IH09sL020142;
        Mon, 18 Feb 2019 17:00:09 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 18 Feb 2019 09:00:08 -0800
Content-Type: text/plain;
        charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH] nfs-utils: fix addrinfo usage with musl-1.1.21
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <137b8db8-a6d6-33a6-408b-73f8915eee08@RedHat.com>
Date:   Mon, 18 Feb 2019 12:00:07 -0500
Cc:     Peter Wagner <tripolar@gmx.at>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <EE3790BC-A5B4-4C34-9F21-7009579B3A25@oracle.com>
References: <20190217173901.33296254@onion.lan>
 <1081BBCD-8CA0-49CC-A02C-16F46FF613BF@oracle.com>
 <20190218001153.3d21b28c@onion.lan>
 <34D9E70A-7F29-4C6B-8A10-18F7A7EFFE2E@oracle.com>
 <137b8db8-a6d6-33a6-408b-73f8915eee08@RedHat.com>
To:     Steve Dickson <SteveD@RedHat.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9171 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902180126
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Feb 18, 2019, at 11:34 AM, Steve Dickson <SteveD@RedHat.com> wrote:
>=20
>=20
>=20
> On 2/17/19 9:21 PM, Chuck Lever wrote:
>>=20
>>=20
>>> On Feb 17, 2019, at 6:11 PM, Peter Wagner <tripolar@gmx.at> wrote:
>>>=20
>>> Hi Chuck,
>>>=20
>>>> It might be cleaner to define a local version of freeaddrinfo in
>>>> nfs-utils to reduce duplication of code and provide a place
>>>> in the code itself to document this issue with a comment.
>>>=20
>>> But why use a local freeaddrinfo function? The code is checking at
>>> multiple places if an addrinfo* =3D=3D NULL and if it's NULL it just =
returns
>>> without freeing it and at some other places it just frees it. For=20
>>> censistence reasions i would propose to check if it's !=3D NULL =
before=20
>>> freeing it.
>>=20
>> I didn't think this would be a controversial suggestion.
>> Here is what I meant:
>>=20
>> Find a common location, say support/include/exportfs.h, and
>> add this:
>>=20
>> /*
>> * Some versions of freeaddrinfo(3) do not tolerate being
>> * passed a NULL pointer.
>> */
>> static inline void nfs_freeaddrinfo(struct addrinfo *ai)
>> {
>> 	if (ai)
>> 		freeaddrinfo(ai);
>> }
>>=20
>> Then replace the freeaddrinfo() call sites within nfs-utils
>> with calls to nfs_freeaddrinfo().
> +1
>=20
>>=20
>>=20
>>=20
>> The logic in host_numeric_addrinfo() will need a closer
>> look. If what Rich says is true then both freeing the
>> ai_canonname string _and_ replacing it with strdup(3)
>> will be problematic.
>>=20
>> I see that host_reliable_addrinfo() has the same issue.
> I just ran Rich's program that is suppose to
> crash... It does not crash on Fedora 29.

It probably does crash with musl 1.1.21. :-)


>>> The spec also just defines the !=3D NULL case and we shouldn't =
depend on
>>> undefined behavior imho.
>>=20
>> Some counterpoints:
>>=20
>> - It is good defensive coding that a library function should
>> perform basic sanity checks on its argument(s) to prevent
>> crashes.
>>=20
>> - It's always possible for a spec to be wrong.
>>=20
>> - If a spec says the behavior is "undefined" that generally
>> means the spec writer is giving the implementer permission
>> to choose a convenient and possibly useful behavior. Crashing
>> is not especially useful. A better approach would be to ignore
>> NULL, and add hooks to a tool like valgrind to report this
>> kind of issue.
>>=20
>> - nfs-utils is not careless about this. The design of the code
>> clearly assumes that freeaddrinfo(3) will not crash in this
>> case. It's not an unreasonable assumption. The goal here is
>> to construct simple-to-read code.
>>=20
>> - Strictly speaking, d1395c43 introduced a regression in
>> freeaddrinfo(3) that should be fixed, because existing
>> applications have depended on the old behavior for a long
>> while. IMO a better fix here would be to make musl's
>> freeaddrinfo(3) deal properly with a NULL argument instead
>> of changing all of its callers, but that's not my call.

> I also took a look at how freeaddrinfo(3) in glibc works:
>=20
> void
> freeaddrinfo (struct addrinfo *ai)
> {
>  struct addrinfo *p;
>=20
>  while (ai !=3D NULL)
>    {
>      p =3D ai;
>      ai =3D ai->ai_next;
>      free (p->ai_canonname);
>      free (p);
>    }
> }
> It makes the assumption that ai_canonname is
> free-able memory....

Right, I seem to recall looking at this implementation when
I wrote the IPv6 support for nfs-utils. That seems sensible
to me.

However Peter's point is not all C libraries have to work
that way, and I can see that argument too.

I have no objection to taking his fix as long as the hunk
in host_numeric_addrinfo() is dropped while we figure out
a more complete fix for that issue. I would also like to
see his fix use a helper like nfs_freeaddrinfo(), but that
is only a suggestion.


> steved.
>>=20
>> - The equivalent to free(3) in the Linux kernel, kfree(),
>> explicitly allows callers to pass NULL because that eliminates
>> the need to add "if (arg !=3D NULL)" at every call site.
>>=20
>> I'm not arguing that we should do nothing, but rather that
>> there is a matter of subjectivity and taste here about what
>> is correct behavior. The OG spec is just one opinion.
>>=20
>>=20
>>> Regards,
>>> Peter
>>>=20
>>>=20
>>>=20
>>> On Sun, 17 Feb 2019 12:40:10 -0500
>>> Chuck Lever <chuck.lever@oracle.com> wrote:
>>>=20
>>>> Hi Peter-
>>>>=20
>>>>> On Feb 17, 2019, at 11:39 AM, Peter Wagner <tripolar@gmx.at> =
wrote:
>>>>>=20
>>>>> Afer the update to musl 1.1.21 freeaddrinfo is broken in some
>>>>> places in the nfs-utils code because glibc seems to ignore when
>>>>> freeaddrinfo is called with a NULL pointer which seems to be not
>>>>> defined in the spec.
>>>>>=20
>>>>> See: https://www.openwall.com/lists/musl/2019/02/03/4 =20
>>>>=20
>>>> It might be cleaner to define a local version of freeaddrinfo in
>>>> nfs-utils to reduce duplication of code and provide a place
>>>> in the code itself to document this issue with a comment.
>>>>=20
>>>>=20
>>>>> The free in support/export/hostname.c is removed too
>>>>>=20
>>>>> See: https://www.openwall.com/lists/musl/2019/02/17/2 =20
>>>>=20
>>>> Actually this seems like a separate issue because a distribution
>>>> that uses another C library might decide it is pertinent to apply
>>>> separately from the other changes here.
>>>>=20
>>>> Please create a separate patch. It should remove the free(3)
>>>> call instead of commenting it out, and the patch description
>>>> should have its own copy of Rich=E2=80=99s email comments.
>>>>=20
>>>> Thanks!
>>>>=20
>>>>=20
>>>>> =46rom 43e27735553b4c1e75964f32b2f887e84398055f Mon Sep 17 =
00:00:00
>>>>> 2001 From: Peter Wagner <tripolar@gmx.at>
>>>>> Date: Sun, 17 Feb 2019 17:32:08 +0100
>>>>> Subject: [PATCH] fix addrinfo usage
>>>>>=20
>>>>> Signed-off-by: Peter Wagner <tripolar@gmx.at>
>>>>> ---
>>>>> support/export/client.c   |  3 ++-
>>>>> support/export/hostname.c |  2 +-
>>>>> utils/exportfs/exportfs.c | 12 ++++++++----
>>>>> utils/mount/stropts.c     |  3 ++-
>>>>> utils/mountd/cache.c      |  6 ++++--
>>>>> utils/statd/hostname.c    |  6 ++++--
>>>>> 6 files changed, 21 insertions(+), 11 deletions(-)
>>>>>=20
>>>>> diff --git a/support/export/client.c b/support/export/client.c
>>>>> index baf59c8..750eb7d 100644
>>>>> --- a/support/export/client.c
>>>>> +++ b/support/export/client.c
>>>>> @@ -309,7 +309,8 @@ client_lookup(char *hname, int canonical)
>>>>>     init_addrlist(clp, ai);
>>>>>=20
>>>>> out:
>>>>> -    freeaddrinfo(ai);
>>>>> +    if (ai)
>>>>> +        freeaddrinfo(ai);
>>>>> return clp;
>>>>> }
>>>>>=20
>>>>> diff --git a/support/export/hostname.c b/support/export/hostname.c
>>>>> index 5c4c824..710bf61 100644
>>>>> --- a/support/export/hostname.c
>>>>> +++ b/support/export/hostname.c
>>>>> @@ -354,7 +354,7 @@ host_numeric_addrinfo(const struct sockaddr
>>>>> *sap)
>>>>>  * getaddrinfo(AI_NUMERICHOST) never fills in ai_canonname
>>>>>  */
>>>>> if (ai !=3D NULL) {
>>>>> -        free(ai->ai_canonname);        /* just in case */
>>>>> +        //free(ai->ai_canonname);        /* just in case */
>>>>>     ai->ai_canonname =3D strdup(buf);
>>>>>     if (ai->ai_canonname =3D=3D NULL) {
>>>>>         freeaddrinfo(ai);
>>>>> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
>>>>> index cd3c979..2f8d59a 100644
>>>>> --- a/utils/exportfs/exportfs.c
>>>>> +++ b/utils/exportfs/exportfs.c
>>>>> @@ -282,7 +282,8 @@ exportfs_parsed(char *hname, char *path, char
>>>>> *options, int verbose) validate_export(exp);
>>>>>=20
>>>>> out:
>>>>> -    freeaddrinfo(ai);
>>>>> +    if (ai)
>>>>> +        freeaddrinfo(ai);
>>>>> }
>>>>>=20
>>>>> static int exportfs_generic(char *arg, char *options, int verbose)
>>>>> @@ -395,7 +396,8 @@ unexportfs_parsed(char *hname, char *path, int
>>>>> verbose) if (!success)
>>>>>     xlog(L_ERROR, "Could not find '%s:%s' to unexport.", hname,
>>>>> path);
>>>>>=20
>>>>> -    freeaddrinfo(ai);
>>>>> +    if (ai)
>>>>> +        freeaddrinfo(ai);
>>>>> }
>>>>>=20
>>>>> static int unexportfs_generic(char *arg, int verbose)
>>>>> @@ -639,8 +641,10 @@ matchhostname(const char *hostname1, const
>>>>> char *hostname2) }
>>>>>=20
>>>>> out:
>>>>> -    freeaddrinfo(results1);
>>>>> -    freeaddrinfo(results2);
>>>>> +    if (results1)
>>>>> +        freeaddrinfo(results1);
>>>>> +    if (results2)
>>>>> +        freeaddrinfo(results2);
>>>>> return result;
>>>>> }
>>>>>=20
>>>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>>>> index 0a25b1f..8b7a0a8 100644
>>>>> --- a/utils/mount/stropts.c
>>>>> +++ b/utils/mount/stropts.c
>>>>> @@ -1268,7 +1268,8 @@ int nfsmount_string(const char *spec, const
>>>>> char *node, char *type, } else
>>>>>     nfs_error(_("%s: internal option parsing error"), progname);
>>>>>=20
>>>>> -    freeaddrinfo(mi.address);
>>>>> +    if (mi.address)
>>>>> +        freeaddrinfo(mi.address);
>>>>> free(mi.hostname);
>>>>> return retval;
>>>>> }
>>>>> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
>>>>> index 7e8d403..8cee1c8 100644
>>>>> --- a/utils/mountd/cache.c
>>>>> +++ b/utils/mountd/cache.c
>>>>> @@ -834,7 +834,8 @@ static void nfsd_fh(int f)
>>>>> out:
>>>>> if (found_path)
>>>>>     free(found_path);
>>>>> -    freeaddrinfo(ai);
>>>>> +    if(ai)
>>>>> +        freeaddrinfo(ai);
>>>>> free(dom);
>>>>> xlog(D_CALL, "nfsd_fh: found %p path %s", found, found ?
>>>>> found->e_path : NULL); }
>>>>> @@ -1355,7 +1356,8 @@ static void nfsd_export(int f)
>>>>> xlog(D_CALL, "nfsd_export: found %p path %s", found, path ?
>>>>> path : NULL); if (dom) free(dom);
>>>>> if (path) free(path);
>>>>> -    freeaddrinfo(ai);
>>>>> +    if (ai)
>>>>> +        freeaddrinfo(ai);
>>>>> }
>>>>>=20
>>>>>=20
>>>>> diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
>>>>> index 8cccdb8..6556ab1 100644
>>>>> --- a/utils/statd/hostname.c
>>>>> +++ b/utils/statd/hostname.c
>>>>> @@ -308,8 +308,10 @@ statd_matchhostname(const char *hostname1,
>>>>> const char *hostname2) }
>>>>>=20
>>>>> out:
>>>>> -    freeaddrinfo(results2);
>>>>> -    freeaddrinfo(results1);
>>>>> +    if (results2)
>>>>> +        freeaddrinfo(results2);
>>>>> +    if (results1)
>>>>> +        freeaddrinfo(results1);
>>>>>=20
>>>>> xlog(D_CALL, "%s: hostnames %s and %s %s", __func__,
>>>>>         hostname1, hostname2,
>>>>> --=20
>>>>> 2.20.1
>>>>>=20
>>>>=20
>>>=20
>>=20
>> --
>> Chuck Lever

--
Chuck Lever



