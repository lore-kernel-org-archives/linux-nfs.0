Return-Path: <SRS0=QdOa=QZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BAA1C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 16:34:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 500392173C
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 16:34:46 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732667AbfBRQep (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Feb 2019 11:34:45 -0500
Received: from mx1.redhat.com ([209.132.183.28]:47392 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732534AbfBRQep (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Feb 2019 11:34:45 -0500
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 81D3A80467;
        Mon, 18 Feb 2019 16:34:44 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-107.phx2.redhat.com [10.3.116.107])
        by smtp.corp.redhat.com (Postfix) with ESMTP id E3C1A60139;
        Mon, 18 Feb 2019 16:34:43 +0000 (UTC)
Subject: Re: [PATCH] nfs-utils: fix addrinfo usage with musl-1.1.21
To:     Chuck Lever <chuck.lever@oracle.com>,
        Peter Wagner <tripolar@gmx.at>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20190217173901.33296254@onion.lan>
 <1081BBCD-8CA0-49CC-A02C-16F46FF613BF@oracle.com>
 <20190218001153.3d21b28c@onion.lan>
 <34D9E70A-7F29-4C6B-8A10-18F7A7EFFE2E@oracle.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <137b8db8-a6d6-33a6-408b-73f8915eee08@RedHat.com>
Date:   Mon, 18 Feb 2019 11:34:34 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <34D9E70A-7F29-4C6B-8A10-18F7A7EFFE2E@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Mon, 18 Feb 2019 16:34:44 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 2/17/19 9:21 PM, Chuck Lever wrote:
> 
> 
>> On Feb 17, 2019, at 6:11 PM, Peter Wagner <tripolar@gmx.at> wrote:
>>
>> Hi Chuck,
>>
>>> It might be cleaner to define a local version of freeaddrinfo in
>>> nfs-utils to reduce duplication of code and provide a place
>>> in the code itself to document this issue with a comment.
>>
>> But why use a local freeaddrinfo function? The code is checking at
>> multiple places if an addrinfo* == NULL and if it's NULL it just returns
>> without freeing it and at some other places it just frees it. For 
>> censistence reasions i would propose to check if it's != NULL before 
>> freeing it.
> 
> I didn't think this would be a controversial suggestion.
> Here is what I meant:
> 
> Find a common location, say support/include/exportfs.h, and
> add this:
> 
> /*
>  * Some versions of freeaddrinfo(3) do not tolerate being
>  * passed a NULL pointer.
>  */
> static inline void nfs_freeaddrinfo(struct addrinfo *ai)
> {
> 	if (ai)
> 		freeaddrinfo(ai);
> }
> 
> Then replace the freeaddrinfo() call sites within nfs-utils
> with calls to nfs_freeaddrinfo().
+1

> 
> 
> 
> The logic in host_numeric_addrinfo() will need a closer
> look. If what Rich says is true then both freeing the
> ai_canonname string _and_ replacing it with strdup(3)
> will be problematic.
> 
> I see that host_reliable_addrinfo() has the same issue.
I just ran Rich's program that is suppose to
crash... It does not crash on Fedora 29.

> 
> 
>> The spec also just defines the != NULL case and we shouldn't depend on
>> undefined behavior imho.
> 
> Some counterpoints:
> 
> - It is good defensive coding that a library function should
> perform basic sanity checks on its argument(s) to prevent
> crashes.
> 
> - It's always possible for a spec to be wrong.
> 
> - If a spec says the behavior is "undefined" that generally
> means the spec writer is giving the implementer permission
> to choose a convenient and possibly useful behavior. Crashing
> is not especially useful. A better approach would be to ignore
> NULL, and add hooks to a tool like valgrind to report this
> kind of issue.
> 
> - nfs-utils is not careless about this. The design of the code
> clearly assumes that freeaddrinfo(3) will not crash in this
> case. It's not an unreasonable assumption. The goal here is
> to construct simple-to-read code.
> 
> - Strictly speaking, d1395c43 introduced a regression in
> freeaddrinfo(3) that should be fixed, because existing
> applications have depended on the old behavior for a long
> while. IMO a better fix here would be to make musl's
> freeaddrinfo(3) deal properly with a NULL argument instead
> of changing all of its callers, but that's not my call.I also took a look at how freeaddrinfo(3) in glibc works:

void
freeaddrinfo (struct addrinfo *ai)
{
  struct addrinfo *p;

  while (ai != NULL)
    {
      p = ai;
      ai = ai->ai_next;
      free (p->ai_canonname);
      free (p);
    }
}
It makes the assumption that ai_canonname is
free-able memory.... 

steved.
> 
> - The equivalent to free(3) in the Linux kernel, kfree(),
> explicitly allows callers to pass NULL because that eliminates
> the need to add "if (arg != NULL)" at every call site.
> 
> I'm not arguing that we should do nothing, but rather that
> there is a matter of subjectivity and taste here about what
> is correct behavior. The OG spec is just one opinion.
> 
> 
>> Regards,
>> Peter
>>
>>
>>
>> On Sun, 17 Feb 2019 12:40:10 -0500
>> Chuck Lever <chuck.lever@oracle.com> wrote:
>>
>>> Hi Peter-
>>>
>>>> On Feb 17, 2019, at 11:39 AM, Peter Wagner <tripolar@gmx.at> wrote:
>>>>
>>>> Afer the update to musl 1.1.21 freeaddrinfo is broken in some
>>>> places in the nfs-utils code because glibc seems to ignore when
>>>> freeaddrinfo is called with a NULL pointer which seems to be not
>>>> defined in the spec.
>>>>
>>>> See: https://www.openwall.com/lists/musl/2019/02/03/4  
>>>
>>> It might be cleaner to define a local version of freeaddrinfo in
>>> nfs-utils to reduce duplication of code and provide a place
>>> in the code itself to document this issue with a comment.
>>>
>>>
>>>> The free in support/export/hostname.c is removed too
>>>>
>>>> See: https://www.openwall.com/lists/musl/2019/02/17/2  
>>>
>>> Actually this seems like a separate issue because a distribution
>>> that uses another C library might decide it is pertinent to apply
>>> separately from the other changes here.
>>>
>>> Please create a separate patch. It should remove the free(3)
>>> call instead of commenting it out, and the patch description
>>> should have its own copy of Rich’s email comments.
>>>
>>> Thanks!
>>>
>>>
>>>> From 43e27735553b4c1e75964f32b2f887e84398055f Mon Sep 17 00:00:00
>>>> 2001 From: Peter Wagner <tripolar@gmx.at>
>>>> Date: Sun, 17 Feb 2019 17:32:08 +0100
>>>> Subject: [PATCH] fix addrinfo usage
>>>>
>>>> Signed-off-by: Peter Wagner <tripolar@gmx.at>
>>>> ---
>>>> support/export/client.c   |  3 ++-
>>>> support/export/hostname.c |  2 +-
>>>> utils/exportfs/exportfs.c | 12 ++++++++----
>>>> utils/mount/stropts.c     |  3 ++-
>>>> utils/mountd/cache.c      |  6 ++++--
>>>> utils/statd/hostname.c    |  6 ++++--
>>>> 6 files changed, 21 insertions(+), 11 deletions(-)
>>>>
>>>> diff --git a/support/export/client.c b/support/export/client.c
>>>> index baf59c8..750eb7d 100644
>>>> --- a/support/export/client.c
>>>> +++ b/support/export/client.c
>>>> @@ -309,7 +309,8 @@ client_lookup(char *hname, int canonical)
>>>>      init_addrlist(clp, ai);
>>>>
>>>> out:
>>>> -    freeaddrinfo(ai);
>>>> +    if (ai)
>>>> +        freeaddrinfo(ai);
>>>>  return clp;
>>>> }
>>>>
>>>> diff --git a/support/export/hostname.c b/support/export/hostname.c
>>>> index 5c4c824..710bf61 100644
>>>> --- a/support/export/hostname.c
>>>> +++ b/support/export/hostname.c
>>>> @@ -354,7 +354,7 @@ host_numeric_addrinfo(const struct sockaddr
>>>> *sap)
>>>>   * getaddrinfo(AI_NUMERICHOST) never fills in ai_canonname
>>>>   */
>>>>  if (ai != NULL) {
>>>> -        free(ai->ai_canonname);        /* just in case */
>>>> +        //free(ai->ai_canonname);        /* just in case */
>>>>      ai->ai_canonname = strdup(buf);
>>>>      if (ai->ai_canonname == NULL) {
>>>>          freeaddrinfo(ai);
>>>> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
>>>> index cd3c979..2f8d59a 100644
>>>> --- a/utils/exportfs/exportfs.c
>>>> +++ b/utils/exportfs/exportfs.c
>>>> @@ -282,7 +282,8 @@ exportfs_parsed(char *hname, char *path, char
>>>> *options, int verbose) validate_export(exp);
>>>>
>>>> out:
>>>> -    freeaddrinfo(ai);
>>>> +    if (ai)
>>>> +        freeaddrinfo(ai);
>>>> }
>>>>
>>>> static int exportfs_generic(char *arg, char *options, int verbose)
>>>> @@ -395,7 +396,8 @@ unexportfs_parsed(char *hname, char *path, int
>>>> verbose) if (!success)
>>>>      xlog(L_ERROR, "Could not find '%s:%s' to unexport.", hname,
>>>> path);
>>>>
>>>> -    freeaddrinfo(ai);
>>>> +    if (ai)
>>>> +        freeaddrinfo(ai);
>>>> }
>>>>
>>>> static int unexportfs_generic(char *arg, int verbose)
>>>> @@ -639,8 +641,10 @@ matchhostname(const char *hostname1, const
>>>> char *hostname2) }
>>>>
>>>> out:
>>>> -    freeaddrinfo(results1);
>>>> -    freeaddrinfo(results2);
>>>> +    if (results1)
>>>> +        freeaddrinfo(results1);
>>>> +    if (results2)
>>>> +        freeaddrinfo(results2);
>>>>  return result;
>>>> }
>>>>
>>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>>> index 0a25b1f..8b7a0a8 100644
>>>> --- a/utils/mount/stropts.c
>>>> +++ b/utils/mount/stropts.c
>>>> @@ -1268,7 +1268,8 @@ int nfsmount_string(const char *spec, const
>>>> char *node, char *type, } else
>>>>      nfs_error(_("%s: internal option parsing error"), progname);
>>>>
>>>> -    freeaddrinfo(mi.address);
>>>> +    if (mi.address)
>>>> +        freeaddrinfo(mi.address);
>>>>  free(mi.hostname);
>>>>  return retval;
>>>> }
>>>> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
>>>> index 7e8d403..8cee1c8 100644
>>>> --- a/utils/mountd/cache.c
>>>> +++ b/utils/mountd/cache.c
>>>> @@ -834,7 +834,8 @@ static void nfsd_fh(int f)
>>>> out:
>>>>  if (found_path)
>>>>      free(found_path);
>>>> -    freeaddrinfo(ai);
>>>> +    if(ai)
>>>> +        freeaddrinfo(ai);
>>>>  free(dom);
>>>>  xlog(D_CALL, "nfsd_fh: found %p path %s", found, found ?
>>>> found->e_path : NULL); }
>>>> @@ -1355,7 +1356,8 @@ static void nfsd_export(int f)
>>>>  xlog(D_CALL, "nfsd_export: found %p path %s", found, path ?
>>>> path : NULL); if (dom) free(dom);
>>>>  if (path) free(path);
>>>> -    freeaddrinfo(ai);
>>>> +    if (ai)
>>>> +        freeaddrinfo(ai);
>>>> }
>>>>
>>>>
>>>> diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
>>>> index 8cccdb8..6556ab1 100644
>>>> --- a/utils/statd/hostname.c
>>>> +++ b/utils/statd/hostname.c
>>>> @@ -308,8 +308,10 @@ statd_matchhostname(const char *hostname1,
>>>> const char *hostname2) }
>>>>
>>>> out:
>>>> -    freeaddrinfo(results2);
>>>> -    freeaddrinfo(results1);
>>>> +    if (results2)
>>>> +        freeaddrinfo(results2);
>>>> +    if (results1)
>>>> +        freeaddrinfo(results1);
>>>>
>>>>  xlog(D_CALL, "%s: hostnames %s and %s %s", __func__,
>>>>          hostname1, hostname2,
>>>> -- 
>>>> 2.20.1
>>>>
>>>
>>
> 
> --
> Chuck Lever
> 
> 
> 
