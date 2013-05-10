Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f51.google.com ([209.85.160.51]:48485 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab3EJHvj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 03:51:39 -0400
Received: by mail-pb0-f51.google.com with SMTP id wy7so2581598pbc.10
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 00:51:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <61eb00$3kapi3@dgate20u.abg.fsc.net>
References: <61eb00$3kapi3@dgate20u.abg.fsc.net>
Date: Fri, 10 May 2013 16:51:39 +0900
Message-ID: <CAKYAXd9dWGA1Eaq5mi-eRbY0RRhkmWDR7CeDoeW18dBcKcGv+Q@mail.gmail.com>
Subject: Re: sunrpc/cache.c: races while updating cache entries
From: Namjae Jeon <linkinjeon@gmail.com>
To: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Cc: bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org,
        Amit Sahrawat <a.sahrawat@samsung.com>,
        Nam-Jae Jeon <namjae.jeon@samsung.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi. Bodo.

We are facing issues with respect to the SUNRPC cache.
In our case we have two targets connected back-to-back
NFS Server: Kernel version, 2.6.35

At times, when Client tries to connect to the Server it stucks for
very long duration and keeps on trying to mount.

When we try to figure out using logs, we checked that client was not
getting response of FSINFO request.

Further, by debugging we found that the request was getting dropped at
the SERVER, so this request was not being served.

In the code we reached this point:
svcauth_unix_set_client()->
  gi = unix_gid_find(cred->cr_uid, rqstp);
        switch (PTR_ERR(gi)) {
        case -EAGAIN:
                return SVC_DROP;

This path is related with the SUNRPC cache management.

When we remove this UNIX_GID_FIND path from our code, there is no problem.

When we try to figure the possible related problems as per our
scneario, We found that you have faced similar issue for RACE in the
cache.
Can you please suggest what could be the problem  so that we can check further ?

Or from the solution if you encounter the similar situation.
can you please suggest on the possible patches for 2.6.35 - which we
can try in our environment ?

We will be highly grateful.

Thanks


2013/4/20, Bodo Stroesser <bstroesser@ts.fujitsu.com>:
> On 05 Apr 2013 23:09:00 +0100 J. Bruce Fields <bfields@fieldses.org> wrote:
>> On Fri, Apr 05, 2013 at 05:33:49PM +0200, Bodo Stroesser wrote:
>> > On 05 Apr 2013 14:40:00 +0100 J. Bruce Fields <bfields@fieldses.org>
>> > wrote:
>> > > On Thu, Apr 04, 2013 at 07:59:35PM +0200, Bodo Stroesser wrote:
>> > > > There is no reason for apologies. The thread meanwhile seems to be a
>> > > > bit
>> > > > confusing :-)
>> > > >
>> > > > Current state is:
>> > > >
>> > > > - Neil Brown has created two series of patches. One for SLES11-SP1
>> > > > and a
>> > > >   second one for -SP2
>> > > >
>> > > > - AFAICS, the series for -SP2 will match with mainline also.
>> > > >
>> > > > - Today I found and fixed the (hopefully) last problem in the -SP1
>> > > > series.
>> > > >   My test using this patchset will run until Monday.
>> > > >
>> > > > - Provided the test on SP1 succeeds, probably on Tuesday I'll start
>> > > > to test
>> > > >   the patches for SP2 (and mainline). If it runs fine, we'll have a
>> > > > tested
>> > > >   patchset not later than Mon 15th.
>> > >
>> > > OK, great, as long as it hasn't just been forgotten!
>> > >
>> > > I'd also be curious to understand why we aren't getting a lot of
>> > > complaints about this from elsewhere....  Is there something unique
>> > > about your setup?  Do the bugs that remain upstream take a long time
>> > > to
>> > > reproduce?
>> > >
>> > > --b.
>> > >
>> >
>> > It's no secret, what we are doing. So let me try to explain:
>>
>> Thanks for the detailed explanation!  I'll look forward to the patches.
>>
>> --b.
>>
>
> Let me give an intermediate result:
>
> The test of the -SP1 patch series succeeded.
>
> We started the test of the -SP2 (and mainline) series on Tue, 9th, but had
> no
> success.
> We did _not_ find a problem with the patches, but under -SP2 our test
> scenario
> has less than 40% of the throughput we saw under -SP1. With that low
> performance, we had a 4 day run without any dropped RPC request. But we
> don't
> know the error rate without the patches under these conditions. So we can't
> give an o.k. for the patches yet.
>
> Currently we try to find the reason for the different behavior of SP1 and
> SP2
>
> Bodo
>
