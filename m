Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:34272 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753348Ab0BAUzp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2010 15:55:45 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <4C5D0433-0BAC-4452-A3CB-20E4B72F25E3@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Mark Moseley <moseleymark@gmail.com>
In-Reply-To: <294d5daa1001271948h3d14e544i5a42e6d55cda67ed@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: Is it safe to increase RPC_CREDCACHE_HASHBITS?
Date: Mon, 1 Feb 2010 15:54:30 -0500
References: <294d5daa1001131408o4531e6c8o65d4682d5e5e4c16@mail.gmail.com> <294d5daa1001271948h3d14e544i5a42e6d55cda67ed@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Jan 27, 2010, at 10:48 PM, Mark Moseley wrote:
> On Wed, Jan 13, 2010 at 2:08 PM, Mark Moseley  
> <moseleymark@gmail.com> wrote:
>> I'm seeing an issue similar to
>> http://www.spinics.net/lists/linux-nfs/msg09255.html in a heavy NFS
>> environment. The topology is all Debian Etch servers (8-core Dell
>> 1950s) talking to a variety of Netapp filers. In trying to diagnose
>> high loads and esp high 'system' CPU usage in vmstat, using the  
>> 'perf'
>> tool from the linux distro, I can see that the
>> "rpcauth_lookup_credcache" call is far and away the top function in
>> 'perf top'. I see similar results across ~80 servers of the same type
>> of service. On servers that have been up for a while,
>> rpcauth_lookup_credcache is usually ~40-50%; looking at a box  
>> rebooted
>> about an hour ago, rpcauth_lookup_credcache is around ~15-25%. Here's
>> a box that's been up for a while:
>>
>> ------------------------------------------------------------------------------
>>   PerfTop:  113265 irqs/sec  kernel:42.7% [100000 cycles],  (all, 8  
>> CPUs)
>> ------------------------------------------------------------------------------
>>
>>             samples    pcnt         RIP          kernel function
>>  ______     _______   _____   ________________   _______________
>>
>>           359151.00 - 44.8% - 00000000003d2081 :  
>> rpcauth_lookup_credcache
>>            33414.00 -  4.2% - 000000000001b0ec : native_write_cr0
>>            27852.00 -  3.5% - 00000000003d252c : generic_match
>>            19254.00 -  2.4% - 0000000000092565 : sanitize_highpage
>>            18779.00 -  2.3% - 0000000000004610 : system_call
>>            12047.00 -  1.5% - 00000000000a137f : copy_user_highpage
>>            11736.00 -  1.5% - 00000000003f5137 : _spin_lock
>>            11066.00 -  1.4% - 00000000003f5420 : page_fault
>>             8981.00 -  1.1% - 000000000001b322 :  
>> native_flush_tlb_single
>>             8490.00 -  1.1% - 000000000006c98f : audit_filter_syscall
>>             7169.00 -  0.9% - 0000000000208e43 : __copy_to_user_ll
>>             6000.00 -  0.7% - 00000000000219c1 : kunmap_atomic
>>             5262.00 -  0.7% - 00000000001fae02 : glob_match
>>             4687.00 -  0.6% - 0000000000021acc : kmap_atomic_prot
>>             4404.00 -  0.5% - 0000000000008fb2 : read_tsc
>>
>>
>> I took the advice in the above thread and adjusted the
>> RPC_CREDCACHE_HASHBITS #define in include/linux/sunrpc/auth.h to 12  
>> --
>> but didn't modify anything else. After doing so,
>> rpcauth_lookup_credcache drops off the list (even when the top list  
>> is
>> widened to 40 lines) and 'system' CPU usage drops by quite a bit,
>> under the same workload. And even after a day of running, it's still
>> performing favourably, despite having the same workload and uptime as
>> RPC_CREDCACHE_HASHBITS=4 boxes that are still struggling. Both  
>> patched
>> and unpatched kernels are 2.6.32.3, both with grsec and ipset. Here's
>> 'perf top' of a patched box:
>>
>> ------------------------------------------------------------------------------
>>   PerfTop:  116525 irqs/sec  kernel:27.0% [100000 cycles],  (all, 8  
>> CPUs)
>> ------------------------------------------------------------------------------
>>
>>             samples    pcnt         RIP          kernel function
>>  ______     _______   _____   ________________   _______________
>>
>>            15844.00 -  7.0% - 0000000000019eb2 : native_write_cr0
>>            11479.00 -  5.0% - 00000000000934fd : sanitize_highpage
>>            11328.00 -  5.0% - 0000000000003d10 : system_call
>>             6578.00 -  2.9% - 00000000000a26d2 : copy_user_highpage
>>             6417.00 -  2.8% - 00000000003fdb80 : page_fault
>>             6237.00 -  2.7% - 00000000003fd897 : _spin_lock
>>             4732.00 -  2.1% - 000000000006d3b0 : audit_filter_syscall
>>             4504.00 -  2.0% - 000000000020cf59 : __copy_to_user_ll
>>             4309.00 -  1.9% - 000000000001a370 :  
>> native_flush_tlb_single
>>             3293.00 -  1.4% - 00000000001fefba : glob_match
>>             2911.00 -  1.3% - 00000000003fda25 : _spin_lock_irqsave
>>             2753.00 -  1.2% - 00000000000d30f1 : __d_lookup
>>             2500.00 -  1.1% - 00000000000200b8 : kunmap_atomic
>>             2418.00 -  1.1% - 0000000000008483 : read_tsc
>>             2387.00 -  1.0% - 0000000000089a7b : perf_poll
>>
>>
>> My question is, is it safe to make that change to
>> RPC_CREDCACHE_HASHBITS, or will that lead to some overflow somewhere
>> else in the NFS/RPC stack? Looking over the code in net/sunrpc/ 
>> auth.c,
>> I don't see any big red flags, but I don't flatter myself into
>> thinking I can debug kernel code, so I wanted to pose the question
>> here. Is it pretty safe to change RPC_CREDCACHE_HASHBITS from 4 to  
>> 12?
>> Or am I setting myself up for instability and/or security issues? I'd
>> rather be slow than hacked.
>>
>> Thanks!
>>
>
> I've read and reread the pertinent sections of code where
> RPC_CREDCACHE_HASHBITS and RPC_CREDCACHE_NR (derived from
> RPC_CREDCACHE_HASHBITS) and it looks pretty safe.
>
> In lieu of a full sysctl-controlled setting to change
> RPC_CREDCACHE_HASHBITS, would it make sense to set
> RPC_CREDCACHE_HASHBITS to something bigger than 4 by default? I'd bet
> a lot of other people in high-traffic environments with a large number
> of active unix accounts are likely unknowingly affected by this. I
> only happened to notice by playing with the kernel's perf tool.
>
> I could be wrong but it doesn't look like it'd tie up an excessive
> amount of memory to have, say, 256 or 1024 or 4096 hash buckets in
> au_credcache (though it wouldn't surprise me if I was way, way off
> about that). It seems (to a non-kernel guy) that the only obvious
> operation that would suffer due to more buckets would be
> rpcauth_prune_expired() in net/sunrpc/auth.c. I haven't tested this
> out with pre-2.6.32.x kernels, but since the default is either 16
> buckets or even 8 way back in 2.6.24.x, I'm guessing that this
> pertains to all recent kernels.

I haven't looked at the RPC cred cache in specific, but the usual  
Linux kernel practice is to size hash tables based on the size of the  
machine's physical RAM.  Smaller machines are likely to need fewer  
entries in the cred cache, and will probably not want to take up the  
fixed address space for 4096 buckets.

The real test of your hash table size is whether the hash function  
adequately spreads entries across the hash buckets, for most  
workloads.  Helpful hint: you should test using real workloads (eg. a  
snapshot of credentials from a real client or server), not, for  
instance, synthetic workloads you made up.

If the current hash table is small (did you say it was only four  
buckets?) then the existing hash function probably hasn't been really  
exercised appropriately to see if it actually works well on a large  
hash table.

If the hash function is working adequately, a 256 bucket hash table  
(or even smaller) is probably adequate even for a few thousand entries.

> Let me know too if this would be better addressed on the kernel list.
> I'm just assuming since it's nfs-related that this would be the spot
> for it, but I don't know if purely RPC-related things would end up
> here too. Thanks!

I think this is the correct mailing list for this topic.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




