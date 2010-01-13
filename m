Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:64299 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755637Ab0AMWOl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jan 2010 17:14:41 -0500
Received: by pzk1 with SMTP id 1so7701813pzk.33
        for <linux-nfs@vger.kernel.org>; Wed, 13 Jan 2010 14:14:40 -0800 (PST)
Date: Wed, 13 Jan 2010 14:08:48 -0800
Message-ID: <294d5daa1001131408o4531e6c8o65d4682d5e5e4c16@mail.gmail.com>
Subject: Is it safe to increase RPC_CREDCACHE_HASHBITS?
From: Mark Moseley <moseleymark@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'm seeing an issue similar to
http://www.spinics.net/lists/linux-nfs/msg09255.html in a heavy NFS
environment. The topology is all Debian Etch servers (8-core Dell
1950s) talking to a variety of Netapp filers. In trying to diagnose
high loads and esp high 'system' CPU usage in vmstat, using the 'perf'
tool from the linux distro, I can see that the
"rpcauth_lookup_credcache" call is far and away the top function in
'perf top'. I see similar results across ~80 servers of the same type
of service. On servers that have been up for a while,
rpcauth_lookup_credcache is usually ~40-50%; looking at a box rebooted
about an hour ago, rpcauth_lookup_credcache is around ~15-25%. Here's
a box that's been up for a while:

------------------------------------------------------------------------------
   PerfTop:  113265 irqs/sec  kernel:42.7% [100000 cycles],  (all, 8 CPUs)
------------------------------------------------------------------------------

             samples    pcnt         RIP          kernel function
  ______     _______   _____   ________________   _______________

           359151.00 - 44.8% - 00000000003d2081 : rpcauth_lookup_credcache
            33414.00 -  4.2% - 000000000001b0ec : native_write_cr0
            27852.00 -  3.5% - 00000000003d252c : generic_match
            19254.00 -  2.4% - 0000000000092565 : sanitize_highpage
            18779.00 -  2.3% - 0000000000004610 : system_call
            12047.00 -  1.5% - 00000000000a137f : copy_user_highpage
            11736.00 -  1.5% - 00000000003f5137 : _spin_lock
            11066.00 -  1.4% - 00000000003f5420 : page_fault
             8981.00 -  1.1% - 000000000001b322 : native_flush_tlb_single
             8490.00 -  1.1% - 000000000006c98f : audit_filter_syscall
             7169.00 -  0.9% - 0000000000208e43 : __copy_to_user_ll
             6000.00 -  0.7% - 00000000000219c1 : kunmap_atomic
             5262.00 -  0.7% - 00000000001fae02 : glob_match
             4687.00 -  0.6% - 0000000000021acc : kmap_atomic_prot
             4404.00 -  0.5% - 0000000000008fb2 : read_tsc


I took the advice in the above thread and adjusted the
RPC_CREDCACHE_HASHBITS #define in include/linux/sunrpc/auth.h to 12 --
but didn't modify anything else. After doing so,
rpcauth_lookup_credcache drops off the list (even when the top list is
widened to 40 lines) and 'system' CPU usage drops by quite a bit,
under the same workload. And even after a day of running, it's still
performing favourably, despite having the same workload and uptime as
RPC_CREDCACHE_HASHBITS=4 boxes that are still struggling. Both patched
and unpatched kernels are 2.6.32.3, both with grsec and ipset. Here's
'perf top' of a patched box:

------------------------------------------------------------------------------
   PerfTop:  116525 irqs/sec  kernel:27.0% [100000 cycles],  (all, 8 CPUs)
------------------------------------------------------------------------------

             samples    pcnt         RIP          kernel function
  ______     _______   _____   ________________   _______________

            15844.00 -  7.0% - 0000000000019eb2 : native_write_cr0
            11479.00 -  5.0% - 00000000000934fd : sanitize_highpage
            11328.00 -  5.0% - 0000000000003d10 : system_call
             6578.00 -  2.9% - 00000000000a26d2 : copy_user_highpage
             6417.00 -  2.8% - 00000000003fdb80 : page_fault
             6237.00 -  2.7% - 00000000003fd897 : _spin_lock
             4732.00 -  2.1% - 000000000006d3b0 : audit_filter_syscall
             4504.00 -  2.0% - 000000000020cf59 : __copy_to_user_ll
             4309.00 -  1.9% - 000000000001a370 : native_flush_tlb_single
             3293.00 -  1.4% - 00000000001fefba : glob_match
             2911.00 -  1.3% - 00000000003fda25 : _spin_lock_irqsave
             2753.00 -  1.2% - 00000000000d30f1 : __d_lookup
             2500.00 -  1.1% - 00000000000200b8 : kunmap_atomic
             2418.00 -  1.1% - 0000000000008483 : read_tsc
             2387.00 -  1.0% - 0000000000089a7b : perf_poll


My question is, is it safe to make that change to
RPC_CREDCACHE_HASHBITS, or will that lead to some overflow somewhere
else in the NFS/RPC stack? Looking over the code in net/sunrpc/auth.c,
I don't see any big red flags, but I don't flatter myself into
thinking I can debug kernel code, so I wanted to pose the question
here. Is it pretty safe to change RPC_CREDCACHE_HASHBITS from 4 to 12?
Or am I setting myself up for instability and/or security issues? I'd
rather be slow than hacked.

Thanks!
