Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f177.google.com ([209.85.220.177]:51854 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758048AbaHZM6h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2014 08:58:37 -0400
Received: by mail-vc0-f177.google.com with SMTP id hy4so16348818vcb.8
        for <linux-nfs@vger.kernel.org>; Tue, 26 Aug 2014 05:58:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140826105304.GT17696@novell.com>
References: <53F6F772.6020708@oracle.com>
	<1408747772-37938-1-git-send-email-trond.myklebust@primarydata.com>
	<20140825164852.50723141@notabene.brown>
	<20140826105304.GT17696@novell.com>
Date: Tue, 26 Aug 2014 08:58:36 -0400
Message-ID: <CAHQdGtRMFuH9MsJBj5YsOrJW+qFLFp_-X=b_gZPVmgVQ22swqQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] SUNRPC: Fix memory reclaim deadlocks in rpciod
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Mel Gorman <mgorman@suse.com>
Cc: NeilBrown <neilb@suse.de>, Junxiao Bi <junxiao.bi@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 26, 2014 at 6:53 AM, Mel Gorman <mgorman@suse.com> wrote:
> On Mon, Aug 25, 2014 at 04:48:52PM +1000, NeilBrown wrote:
>> On Fri, 22 Aug 2014 18:49:31 -0400 Trond Myklebust
>> <trond.myklebust@primarydata.com> wrote:
>>
>> > Junxiao Bi reports seeing the following deadlock:
>> >
>> > @ crash> bt 1539
>> > @ PID: 1539   TASK: ffff88178f64a040  CPU: 1   COMMAND: "rpciod/1"
>> > @  #0 [ffff88178f64d2c0] schedule at ffffffff8145833a
>> > @  #1 [ffff88178f64d348] io_schedule at ffffffff8145842c
>> > @  #2 [ffff88178f64d368] sync_page at ffffffff810d8161
>> > @  #3 [ffff88178f64d378] __wait_on_bit at ffffffff8145895b
>> > @  #4 [ffff88178f64d3b8] wait_on_page_bit at ffffffff810d82fe
>> > @  #5 [ffff88178f64d418] wait_on_page_writeback at ffffffff810e2a1a
>> > @  #6 [ffff88178f64d438] shrink_page_list at ffffffff810e34e1
>> > @  #7 [ffff88178f64d588] shrink_list at ffffffff810e3dbe
>> > @  #8 [ffff88178f64d6f8] shrink_zone at ffffffff810e425e
>> > @  #9 [ffff88178f64d7b8] do_try_to_free_pages at ffffffff810e4978
>> > @ #10 [ffff88178f64d828] try_to_free_pages at ffffffff810e4c31
>> > @ #11 [ffff88178f64d8c8] __alloc_pages_nodemask at ffffffff810de370
>>
>> This stack trace (from 2.6.32) cannot happen in mainline, though it took me a
>> while to remember/discover exactly why.
>>
>> try_to_free_pages() creates a 'struct scan_control' with ->target_mem_cgroup
>> set to NULL.
>> shrink_page_list() checks ->target_mem_cgroup using global_reclaim() and if
>> it is NULL, wait_on_page_writeback is *not* called.
>>
>
> wait_on_page_writeback has a host of other damage associated with it which
> is why we don't do it from reclaim any more. If the storage is very slow
> then a process can be stalled by unrelated IO to slow storage.  If the
> storage is broken and the writeback can never complete then it causes other
> issues. That kind of thing.
>
>> So we can only hit this deadlock if mem-cgroup limits are imposed on a
>> process which is using NFS - which is quite possible but probably not common.
>>
>> The fact that a dead-lock can happen only when memcg limits are imposed seems
>> very fragile.  People aren't going to test that case much so there could well
>> be other deadlock possibilities lurking.
>>
>
> memcgs still can call wait_on_page_writeback and this is known to be a
> hand-grenade to the memcg people but I've never heard of them trying to
> tackle the problem.
>
>> Mel: might there be some other way we could get out of this deadlock?
>> Could the wait_on_page_writeback() in shrink_page_list() be made a timed-out
>> wait or something?  Any other wait out of this deadlock other than setting
>> PF_MEMALLOC_NOIO everywhere?
>>
>
> I don't have the full thread as it was not cc'd to lkml so I don't know
> what circumstances reached this deadlock in the first place. If this is
> on 2.6.32 and the deadline cannot happen during reclaim in mainline then
> why is mainline being patched?
>
> Do not alter wait_on_page_writeback() to timeout as it will blow
> up spectacularly -- swap unuse races, data would not longer be synced
> correctly to disk, sync IO would be flaky, stable page writes would be
> fired out the window etc.

Hi Mel,

The above stack trace really is the entire deadlock: the rpciod work
queue, which drives I/O on behalf of NFS, gets caught in a
shrink_page_list() situation where it ends up waiting on page
writeback. Boom....

Even if this can only happen for non-trivial memcg situations, then it
still needs to be addressed: if rpciod blocks, then all NFS I/O will
block and we can no longer write out the dirty pages. This is why we
need a mainline fix.

Cheers
  Trond

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
