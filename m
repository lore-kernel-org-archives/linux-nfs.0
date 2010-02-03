Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:61393 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932329Ab0BCXxg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Feb 2010 18:53:36 -0500
Received: by bwz19 with SMTP id 19so692645bwz.28
        for <linux-nfs@vger.kernel.org>; Wed, 03 Feb 2010 15:53:34 -0800 (PST)
In-Reply-To: <465D8B6E-B503-4225-9B3E-37A894D66298@oracle.com>
References: <294d5daa1001131408o4531e6c8o65d4682d5e5e4c16@mail.gmail.com>
	 <294d5daa1001271948h3d14e544i5a42e6d55cda67ed@mail.gmail.com>
	 <4C5D0433-0BAC-4452-A3CB-20E4B72F25E3@oracle.com>
	 <294d5daa1002011625m707af9ffo665988e6da486121@mail.gmail.com>
	 <465D8B6E-B503-4225-9B3E-37A894D66298@oracle.com>
Date: Wed, 3 Feb 2010 15:53:28 -0800
Message-ID: <294d5daa1002031553l1fd33926rd6559aea922ce8ea@mail.gmail.com>
Subject: Re: Is it safe to increase RPC_CREDCACHE_HASHBITS?
From: Mark Moseley <moseleymark@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Feb 2, 2010 at 9:10 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> On Feb 1, 2010, at 7:25 PM, Mark Moseley wrote:
>>
>> On Mon, Feb 1, 2010 at 12:54 PM, Chuck Lever <chuck.lever@oracle.com>
>> wrote:
>>>
>>> On Jan 27, 2010, at 10:48 PM, Mark Moseley wrote:
>>>>
>>>> On Wed, Jan 13, 2010 at 2:08 PM, Mark Moseley <moseleymark@gmail.com>
>>>> wrote:
>>>>>
>>>>> I'm seeing an issue similar to
>>>>> http://www.spinics.net/lists/linux-nfs/msg09255.html in a heavy NFS
>>>>> environment. The topology is all Debian Etch servers (8-core Dell
>>>>> 1950s) talking to a variety of Netapp filers. In trying to diagnose
>>>>> high loads and esp high 'system' CPU usage in vmstat, using the 'perf'
>>>>> tool from the linux distro, I can see that the
>>>>> "rpcauth_lookup_credcache" call is far and away the top function in
>>>>> 'perf top'. I see similar results across ~80 servers of the same type
>>>>> of service. On servers that have been up for a while,
>>>>> rpcauth_lookup_credcache is usually ~40-50%; looking at a box rebooted
>>>>> about an hour ago, rpcauth_lookup_credcache is around ~15-25%. Here's
>>>>> a box that's been up for a while:
>>>>>
>>>>>
>>>>>
>>>>> ------------------------------------------------------------------------------
>>>>>  PerfTop:  113265 irqs/sec  kernel:42.7% [100000 cycles],  (all, 8
>>>>> CPUs)
>>>>>
>>>>>
>>>>> ------------------------------------------------------------------------------
>>>>>
>>>>>           samples    pcnt         RIP          kernel function
>>>>>  ______     _______   _____   ________________   _______________
>>>>>
>>>>>         359151.00 - 44.8% - 00000000003d2081 : rpcauth_lookup_credcache
>>>>>          33414.00 -  4.2% - 000000000001b0ec : native_write_cr0
>>>>>          27852.00 -  3.5% - 00000000003d252c : generic_match
>>>>>          19254.00 -  2.4% - 0000000000092565 : sanitize_highpage
>>>>>          18779.00 -  2.3% - 0000000000004610 : system_call
>>>>>          12047.00 -  1.5% - 00000000000a137f : copy_user_highpage
>>>>>          11736.00 -  1.5% - 00000000003f5137 : _spin_lock
>>>>>          11066.00 -  1.4% - 00000000003f5420 : page_fault
>>>>>           8981.00 -  1.1% - 000000000001b322 : native_flush_tlb_single
>>>>>           8490.00 -  1.1% - 000000000006c98f : audit_filter_syscall
>>>>>           7169.00 -  0.9% - 0000000000208e43 : __copy_to_user_ll
>>>>>           6000.00 -  0.7% - 00000000000219c1 : kunmap_atomic
>>>>>           5262.00 -  0.7% - 00000000001fae02 : glob_match
>>>>>           4687.00 -  0.6% - 0000000000021acc : kmap_atomic_prot
>>>>>           4404.00 -  0.5% - 0000000000008fb2 : read_tsc
>>>>>
>>>>>
>>>>> I took the advice in the above thread and adjusted the
>>>>> RPC_CREDCACHE_HASHBITS #define in include/linux/sunrpc/auth.h to 12 --
>>>>> but didn't modify anything else. After doing so,
>>>>> rpcauth_lookup_credcache drops off the list (even when the top list is
>>>>> widened to 40 lines) and 'system' CPU usage drops by quite a bit,
>>>>> under the same workload. And even after a day of running, it's still
>>>>> performing favourably, despite having the same workload and uptime as
>>>>> RPC_CREDCACHE_HASHBITS=4 boxes that are still struggling. Both patched
>>>>> and unpatched kernels are 2.6.32.3, both with grsec and ipset. Here's
>>>>> 'perf top' of a patched box:
>>>>>
>>>>>
>>>>>
>>>>> ------------------------------------------------------------------------------
>>>>>  PerfTop:  116525 irqs/sec  kernel:27.0% [100000 cycles],  (all, 8
>>>>> CPUs)
>>>>>
>>>>>
>>>>> ------------------------------------------------------------------------------
>>>>>
>>>>>           samples    pcnt         RIP          kernel function
>>>>>  ______     _______   _____   ________________   _______________
>>>>>
>>>>>          15844.00 -  7.0% - 0000000000019eb2 : native_write_cr0
>>>>>          11479.00 -  5.0% - 00000000000934fd : sanitize_highpage
>>>>>          11328.00 -  5.0% - 0000000000003d10 : system_call
>>>>>           6578.00 -  2.9% - 00000000000a26d2 : copy_user_highpage
>>>>>           6417.00 -  2.8% - 00000000003fdb80 : page_fault
>>>>>           6237.00 -  2.7% - 00000000003fd897 : _spin_lock
>>>>>           4732.00 -  2.1% - 000000000006d3b0 : audit_filter_syscall
>>>>>           4504.00 -  2.0% - 000000000020cf59 : __copy_to_user_ll
>>>>>           4309.00 -  1.9% - 000000000001a370 : native_flush_tlb_single
>>>>>           3293.00 -  1.4% - 00000000001fefba : glob_match
>>>>>           2911.00 -  1.3% - 00000000003fda25 : _spin_lock_irqsave
>>>>>           2753.00 -  1.2% - 00000000000d30f1 : __d_lookup
>>>>>           2500.00 -  1.1% - 00000000000200b8 : kunmap_atomic
>>>>>           2418.00 -  1.1% - 0000000000008483 : read_tsc
>>>>>           2387.00 -  1.0% - 0000000000089a7b : perf_poll
>>>>>
>>>>>
>>>>> My question is, is it safe to make that change to
>>>>> RPC_CREDCACHE_HASHBITS, or will that lead to some overflow somewhere
>>>>> else in the NFS/RPC stack? Looking over the code in net/sunrpc/auth.c,
>>>>> I don't see any big red flags, but I don't flatter myself into
>>>>> thinking I can debug kernel code, so I wanted to pose the question
>>>>> here. Is it pretty safe to change RPC_CREDCACHE_HASHBITS from 4 to 12?
>>>>> Or am I setting myself up for instability and/or security issues? I'd
>>>>> rather be slow than hacked.
>>>>>
>>>>> Thanks!
>>>>>
>>>>
>>>> I've read and reread the pertinent sections of code where
>>>> RPC_CREDCACHE_HASHBITS and RPC_CREDCACHE_NR (derived from
>>>> RPC_CREDCACHE_HASHBITS) and it looks pretty safe.
>>>>
>>>> In lieu of a full sysctl-controlled setting to change
>>>> RPC_CREDCACHE_HASHBITS, would it make sense to set
>>>> RPC_CREDCACHE_HASHBITS to something bigger than 4 by default? I'd bet
>>>> a lot of other people in high-traffic environments with a large number
>>>> of active unix accounts are likely unknowingly affected by this. I
>>>> only happened to notice by playing with the kernel's perf tool.
>>>>
>>>> I could be wrong but it doesn't look like it'd tie up an excessive
>>>> amount of memory to have, say, 256 or 1024 or 4096 hash buckets in
>>>> au_credcache (though it wouldn't surprise me if I was way, way off
>>>> about that). It seems (to a non-kernel guy) that the only obvious
>>>> operation that would suffer due to more buckets would be
>>>> rpcauth_prune_expired() in net/sunrpc/auth.c. I haven't tested this
>>>> out with pre-2.6.32.x kernels, but since the default is either 16
>>>> buckets or even 8 way back in 2.6.24.x, I'm guessing that this
>>>> pertains to all recent kernels.
>>>
>>> I haven't looked at the RPC cred cache in specific, but the usual Linux
>>> kernel practice is to size hash tables based on the size of the machine's
>>> physical RAM.  Smaller machines are likely to need fewer entries in the
>>> cred
>>> cache, and will probably not want to take up the fixed address space for
>>> 4096 buckets.
>>
>> 4096 might be a bit much. Though since there doesn't seem to be a
>> ceiling on the number of entries, so at least memory-wise, the only
>> difference in overhead would just be the rest of the size of struct
>> "hlist_head" (at least from a non-kernel-guy perspective), since it'd
>> still have the same sum total of entries across the buckets with 16 or
>> 256 or 4096.
>>
>>> The real test of your hash table size is whether the hash function
>>> adequately spreads entries across the hash buckets, for most workloads.
>>>  Helpful hint: you should test using real workloads (eg. a snapshot of
>>> credentials from a real client or server), not, for instance, synthetic
>>> workloads you made up.
>>
>> In production, it works pretty nicely. Since it looked pretty safe,
>> I've been running on 1 box in a pool of 9, all with identical
>> load-balanced workloads. The RPC_BITS-hacked box consistently spends
>> less time in 'system' time than the other 8. The other boxes in that
>> pool have 'perf top' stats with rpcauth_lookup_credcache in the area
>> of 30-50% (except for right after booting up; takes a couple of hours
>> before rpcauth_lookup_credcache starts monopolizing the output. On the
>> RPC_Bits-hacked box, rpcauth_lookup_credcache never even shows up in
>> the perf top 10 or 20. I could also be abusing/misinterpreting 'perf
>> top' output :)
>
> That's evidence that it's working better, but you need to know if there are
> still any buckets that contain a large number of entries, while the others
> contain only a few.  I don't recall a mention of how many entries your
> systems are caching, but even with a large hash table, if most of them end
> up in just a few buckets, it still isn't working efficiently, even though it
> might be faster.

I had actually meant (and forgotten) to ask in this thread if there
was a way to determine the bucket membership counts. I haven't been
able to find anything in /proc that looks promising, nor does it looks
like it's updating any sort of counters. As far as numbers in buckets,
without a counter it's hard to tell, but at least in the hundreds,
probably into the thousands. Given enough egregious directory walks by
end-users' scripts could push it even higher.


> Another way to look at it is that shows we could get away with a small hash
> table if the hash function can be improved.  It would help us to know what
> the specific problem is.
>
> You could hook up a simple printk that shows how many entries are in the
> fullest and the emptiest bucket (for example, when doing an "echo m >
> /proc/sysrq-trigger", or you could have the entry counts displayed in a
> /proc file).  If the ratio of those numbers approaches 1 when there's a
> large number of entries in the cache, then you know for sure the hash
> function is working properly for your workload.

I don't rate my C remotely good enough to competently modify any
kernel code (beyond changing a constant) :)  Do you know of any
examples that I could rip out and plug in here?
