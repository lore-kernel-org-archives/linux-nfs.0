Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:50882 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532Ab3ANGIi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jan 2013 01:08:38 -0500
Message-ID: <50F3A0D9.5080103@parallels.com>
Date: Mon, 14 Jan 2013 10:08:25 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <devel@openvz.org>
Subject: Re: [Devel] [PATCH 2/6] nfsd: swap fs root in NFSd kthreads
References: <20121206153204.30693.11408.stgit@localhost.localdomain> <20121206153447.30693.54128.stgit@localhost.localdomain> <20121210202842.GB17350@fieldses.org> <50C73C60.8060405@parallels.com> <50C73F58.1080005@parallels.com> <20121211145621.GA3336@fieldses.org> <50C74C14.8030807@parallels.com> <20121211152036.GB3336@fieldses.org> <20121211153527.GC3336@fieldses.org> <50F0283A.6040509@parallels.com> <20130111170312.GF17909@fieldses.org>
In-Reply-To: <20130111170312.GF17909@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

11.01.2013 21:03, J. Bruce Fields пишет:
> On Fri, Jan 11, 2013 at 06:56:58PM +0400, Stanislav Kinsbursky wrote:
>> 11.12.2012 19:35, J. Bruce Fields пишет:
>>> On Tue, Dec 11, 2012 at 10:20:36AM -0500, J. Bruce Fields wrote:
>>>> On Tue, Dec 11, 2012 at 07:07:00PM +0400, Stanislav Kinsbursky wrote:
>>>>> I don't really understand, how  mountd's root can be wrong. I.e.
>>>>> its' always right as I see it. NFSd kthreads have to swap/use
>>>>> relative path/whatever to communicate with proper mountd.
>>>>> Or I'm missing something?
>>>>
>>>> Ugh, I see the problem: I thought svc_export_request was called at the
>>>> time mountd does the read, but instead its done at the time nfsd does
>>>> the upcall.
>>>>
>>>> I suspect that's wrong, and we really want this done in the context of
>>>> the mountd process when it does the read call.  If d_path is called
>>>> there then we have no problem.
>>>
>>> Right, so I'd be happier if we could modify sunrpc_cache_pipe_upcall to
>>> skip calling cache_request and instead delay that until cache_read().  I
>>> think that should be possible.
>>>
>>
>> So, Bruce, what we going to do (or what you want me to do) with the rest of NFSd changes?
>> I.e. how I should solve this d_path() problem?
>> I.e. I don't understand what did you mean by "I'd be happier if we could modify sunrpc_cache_pipe_upcall to
>> skip calling cache_request and instead delay that until cache_read()".
>> Could you give me a hint?
>
> Definitely.  So normally the way these upcalls happen are:
>
> 	1. the kernel does a cache lookup, finds no matching item, and
> 	   calls sunrpc_cache_pipe_upcall().
> 	2. sunrpc_cache_pipe_upcall() formats the upcall: it allocates a
> 	   struct cache_request crq and fills crq->buf with the upcall
> 	   data by calling the cache's ->cache_request() method.
> 	3. Then rpc.mountd realizes there's data available in
> 	   /proc/net/rpc/nfsd.fh/content, so it does a read on that file.
> 	4. cache_read copies the formatted upcall from crq->buf to
> 	   to userspace.
>
> So all I'm suggesting is that instead of calling ->cache_request() at
> step 2, we do it at step 4.
>
> Then cache_request will be called from rpc.mountd's read.  So we'll know
> which container rpc.mountd is in.
>
> Does that make sense?
>

Ok, now I understand.
If the upcall is just the way to inform rpc.mound, that there are some data to read and process, then it your proposing changes should work.
I'll prepare initial patch set.
Thanks!

> --b.
>


-- 
Best regards,
Stanislav Kinsbursky
