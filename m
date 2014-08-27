Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f46.google.com ([209.85.213.46]:39661 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbaH0QPe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Aug 2014 12:15:34 -0400
Received: by mail-yh0-f46.google.com with SMTP id a41so444815yho.33
        for <linux-nfs@vger.kernel.org>; Wed, 27 Aug 2014 09:15:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140827153644.GF12374@novell.com>
References: <53F6F772.6020708@oracle.com>
	<1408747772-37938-1-git-send-email-trond.myklebust@primarydata.com>
	<20140825164852.50723141@notabene.brown>
	<20140826105304.GT17696@novell.com>
	<CAHQdGtRMFuH9MsJBj5YsOrJW+qFLFp_-X=b_gZPVmgVQ22swqQ@mail.gmail.com>
	<20140826132624.GU17696@novell.com>
	<20140826231938.GA13889@cmpxchg.org>
	<CAHQdGtRPsVFVfph5OcsZk_+WYPPJ-MpE2myZfXAb3jq6fuM4zw@mail.gmail.com>
	<CAHQdGtQPMJNzSM5Wt4RnNqEawBLqmYHycXTmBHhmAt26dz5wCw@mail.gmail.com>
	<20140827153644.GF12374@novell.com>
Date: Wed, 27 Aug 2014 12:15:33 -0400
Message-ID: <CAHQdGtQGqw9H=io0bYGKCCS1DxHZZymGjTCoiRymKnX2i88w_w@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] SUNRPC: Fix memory reclaim deadlocks in rpciod
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Mel Gorman <mgorman@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, NeilBrown <neilb@suse.de>,
        Junxiao Bi <junxiao.bi@oracle.com>, Michal Hocko <mhocko@suse.cz>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 27, 2014 at 11:36 AM, Mel Gorman <mgorman@suse.com> wrote:
> On Tue, Aug 26, 2014 at 08:00:20PM -0400, Trond Myklebust wrote:
>> On Tue, Aug 26, 2014 at 7:51 PM, Trond Myklebust
>> <trond.myklebust@primarydata.com> wrote:
>> > On Tue, Aug 26, 2014 at 7:19 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>> >> On Tue, Aug 26, 2014 at 02:26:24PM +0100, Mel Gorman wrote:
>> >>> On Tue, Aug 26, 2014 at 08:58:36AM -0400, Trond Myklebust wrote:
>> >>> > On Tue, Aug 26, 2014 at 6:53 AM, Mel Gorman <mgorman@suse.com> wrote:
>> >>> > > On Mon, Aug 25, 2014 at 04:48:52PM +1000, NeilBrown wrote:
>> >>> > >> On Fri, 22 Aug 2014 18:49:31 -0400 Trond Myklebust
>> >>> > >> <trond.myklebust@primarydata.com> wrote:
>> >>> > >>
>> >>> > >> > Junxiao Bi reports seeing the following deadlock:
>> >>> > >> >
>> >>> > >> > @ crash> bt 1539
>> >>> > >> > @ PID: 1539   TASK: ffff88178f64a040  CPU: 1   COMMAND: "rpciod/1"
>> >>> > >> > @  #0 [ffff88178f64d2c0] schedule at ffffffff8145833a
>> >>> > >> > @  #1 [ffff88178f64d348] io_schedule at ffffffff8145842c
>> >>> > >> > @  #2 [ffff88178f64d368] sync_page at ffffffff810d8161
>> >>> > >> > @  #3 [ffff88178f64d378] __wait_on_bit at ffffffff8145895b
>> >>> > >> > @  #4 [ffff88178f64d3b8] wait_on_page_bit at ffffffff810d82fe
>> >>> > >> > @  #5 [ffff88178f64d418] wait_on_page_writeback at ffffffff810e2a1a
>> >>> > >> > @  #6 [ffff88178f64d438] shrink_page_list at ffffffff810e34e1
>> >>> > >> > @  #7 [ffff88178f64d588] shrink_list at ffffffff810e3dbe
>> >>> > >> > @  #8 [ffff88178f64d6f8] shrink_zone at ffffffff810e425e
>> >>> > >> > @  #9 [ffff88178f64d7b8] do_try_to_free_pages at ffffffff810e4978
>> >>> > >> > @ #10 [ffff88178f64d828] try_to_free_pages at ffffffff810e4c31
>> >>> > >> > @ #11 [ffff88178f64d8c8] __alloc_pages_nodemask at ffffffff810de370
>> >>> > >>
>> >>> > >> This stack trace (from 2.6.32) cannot happen in mainline, though it took me a
>> >>> > >> while to remember/discover exactly why.
>> >>> > >>
>> >>> > >> try_to_free_pages() creates a 'struct scan_control' with ->target_mem_cgroup
>> >>> > >> set to NULL.
>> >>> > >> shrink_page_list() checks ->target_mem_cgroup using global_reclaim() and if
>> >>> > >> it is NULL, wait_on_page_writeback is *not* called.
>> >>> > >>
>> >>> > >
>> >>> > > wait_on_page_writeback has a host of other damage associated with it which
>> >>> > > is why we don't do it from reclaim any more. If the storage is very slow
>> >>> > > then a process can be stalled by unrelated IO to slow storage.  If the
>> >>> > > storage is broken and the writeback can never complete then it causes other
>> >>> > > issues. That kind of thing.
>> >>> > >
>> >>> > >> So we can only hit this deadlock if mem-cgroup limits are imposed on a
>> >>> > >> process which is using NFS - which is quite possible but probably not common.
>> >>> > >>
>> >>> > >> The fact that a dead-lock can happen only when memcg limits are imposed seems
>> >>> > >> very fragile.  People aren't going to test that case much so there could well
>> >>> > >> be other deadlock possibilities lurking.
>> >>> > >>
>> >>> > >
>> >>> > > memcgs still can call wait_on_page_writeback and this is known to be a
>> >>> > > hand-grenade to the memcg people but I've never heard of them trying to
>> >>> > > tackle the problem.
>> >>> > >
>> >>> > >> Mel: might there be some other way we could get out of this deadlock?
>> >>> > >> Could the wait_on_page_writeback() in shrink_page_list() be made a timed-out
>> >>> > >> wait or something?  Any other wait out of this deadlock other than setting
>> >>> > >> PF_MEMALLOC_NOIO everywhere?
>> >>> > >>
>> >>> > >
>> >>> > > I don't have the full thread as it was not cc'd to lkml so I don't know
>> >>> > > what circumstances reached this deadlock in the first place. If this is
>> >>> > > on 2.6.32 and the deadline cannot happen during reclaim in mainline then
>> >>> > > why is mainline being patched?
>> >>> > >
>> >>> > > Do not alter wait_on_page_writeback() to timeout as it will blow
>> >>> > > up spectacularly -- swap unuse races, data would not longer be synced
>> >>> > > correctly to disk, sync IO would be flaky, stable page writes would be
>> >>> > > fired out the window etc.
>> >>> >
>> >>> > Hi Mel,
>> >>> >
>> >>> > The above stack trace really is the entire deadlock: the rpciod work
>> >>> > queue, which drives I/O on behalf of NFS, gets caught in a
>> >>> > shrink_page_list() situation where it ends up waiting on page
>> >>> > writeback. Boom....
>> >>> >
>> >>> > Even if this can only happen for non-trivial memcg situations, then it
>> >>> > still needs to be addressed: if rpciod blocks, then all NFS I/O will
>> >>> > block and we can no longer write out the dirty pages. This is why we
>> >>> > need a mainline fix.
>> >>> >
>> >>>
>> >>> In that case I'm adding the memcg people. I recognise that rpciod should
>> >>> never block on writeback for similar reasons why flushers should never block.
>> >>> memcg blocking on writeback is dangerous for reasons other than NFS but
>> >>> adding a variant that times out just means that on occasion processes get
>> >>> stalled for long periods of time timing out on these writeback pages. In
>> >>> that case, forward progress of rpciod would be painfully slow.
>> >>>
>> >>> On the other hand, forcing PF_MEMALLOC_NOIO for all rpciod allocations in
>> >>> an ideal world is massive overkill and while it will work, there will be
>> >>> other consequences -- unable to swap pages for example, unable to release
>> >>> buffers to free clean pages etc.
>> >>>
>> >>> It'd be nice of the memcg people could comment on whether they plan to
>> >>> handle the fact that memcg is the only called of wait_on_page_writeback
>> >>> in direct reclaim paths.
>> >>
>> >> wait_on_page_writeback() is a hammer, and we need to be better about
>> >> this once we have per-memcg dirty writeback and throttling, but I
>> >> think that really misses the point.  Even if memcg writeback waiting
>> >> were smarter, any length of time spent waiting for yourself to make
>> >> progress is absurd.  We just shouldn't be solving deadlock scenarios
>> >> through arbitrary timeouts on one side.  If you can't wait for IO to
>> >> finish, you shouldn't be passing __GFP_IO.
>> >>
>> >> Can't you use mempools like the other IO paths?
>> >
>> > There is no way to pass any allocation flags at all to an operation
>> > such as __sock_create() (which may be needed if the server
>> > disconnects). So in general, the answer is no.
>> >
>>
>> Actually, one question that should probably be raised before anything
>> else: is it at all possible for a workqueue like rpciod to have a
>> non-trivial setting for ->target_mem_cgroup? If not, then the whole
>> question is moot.
>>
>
> AFAIK, today it's not possible to add kernel threads (which rpciod is one)
> to a memcg so the issue is entirely theoritical at the moment.  Even if
> this was to change, it's not clear to me what adding kernel threads to a
> memcg would mean as kernel threads have no RSS. Even if kernel resources
> were accounted for, I cannot see why a kernel thread would join a memcg.
>
> I expec that it's currently impossible for rpciod to have a non-trivial
> target_mem_cgroup. The memcg folk will correct me if I'm wrong or if there
> are plans to change that for some reason.
>

Thanks! Then I'll assume that the problem is nonexistent in upstream
for now, and drop the idea of using PF_MEMALLOC_NOIO. Perhaps we can
then encourage Junxiao to look into backporting some of the VM changes
in order to fix his Oracle legacy kernel issues?

Cheers
  Trond
-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
