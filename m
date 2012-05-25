Return-Path: linux-nfs-owner@vger.kernel.org
Received: from isrv.corpit.ru ([86.62.121.231]:58948 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751506Ab2EYGxO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 May 2012 02:53:14 -0400
Message-ID: <4FBF2C57.3070203@msgid.tls.msk.ru>
Date: Fri, 25 May 2012 10:53:11 +0400
From: Michael Tokarev <mjt@tls.msk.ru>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org, Linux-kernel <linux-kernel@vger.kernel.org>
Subject: 3.0+ NFS issues
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello.

I updated my nfs server machine to kernel 3.0, and
noticed that its main usage become, well, problematic.

While trying to dig deeper, I also found a few other
interesting issues, which are mentioned below.

But first thing first: nfs.

i686pae kernel, lots of RAM, Atom-based (cedar trail)
machine with usual rtl8169 NIC.  3.0 or 3.2 kernel
(I will try current 3.4 but I don't have much hopes
there).  NFSv4.

When a client machine (also 3.0 kernel) does some reading,
the process often stalls somewhere in the read syscall,
or, rarer, during close, for up to two MINUTES.  During
this time, the client (kernel) reports "NFS server <foo>
does not respond" several times, and finally "NFS server
<foo> ok", client process "unstucks" from the read(2),
and is able to perform a few more reads till the whole
thing repeats.

While this happens, ie, while the client process is stuck,
any access to the mounted filesystem results in an
uninterruptible sleep - all processes including the
initial client are unkillable.  This is very annoying,
but I was never able to fix this, including the real
case when the server becomes unreachable - "intr" mount
option which is supposed to help here makes no difference.
This is first and longstanding issue, but it is not really
related to the issue at hand.

On the server side things are more interesting.  During
the client stall, all NFSD threads are busy running,
using all available CPU.  The machine has 2 cores, and
if I reduce number of NFSD threads to 1, one core will
be used by the single NFSD to 100%.  With default 8
NFSDs, both cores are used, by 4 NFSD threads each.
This is according to top(1), which show proportional
and equal CPU activity for each of NFSD thread.

But.  And this is where things becomes more interesting.
perf top shows almost no activity with any number of NFSD
threads but one.  For example, this is a typical perf top
display with 2 NFSD threads:

     samples  pcnt function                  DSO
     1558.00  6.4% svc_recv                  [sunrpc]
     1084.00  5.2% __schedule                [kernel]
     1065.00  5.1% select_task_rq_fair       [kernel]
      692.00  3.3% try_to_wake_up            [kernel]


Yes, there's some 6.4% time spent in svc_recv, but it is
FAR from the 200% CPU usage reported by top(1).  Now, when
I reduce number of NFSD threds to 1, perf top output becomes
dramatically different:

     samples  pcnt function                    DSO
     5996.00 59.2% svc_recv                    [sunrpc]
      750.00  7.4% cache_check                 [sunrpc]
      519.00  5.1% svc_tcp_has_wspace          [sunrpc]
      465.00  4.6% local_bh_enable_ip          [kernel.kallsyms]
      301.00  3.0% svc_defer                   [sunrpc]
      294.00  2.9% page_address                [kernel.kallsyms]

Ie, scv_recv time usage jumps from 6 to 60%, ie, 10 times
the difference.

So, apparently, `perf top' tool does not show the truth.

Trying to catch this high CPU usage with Sysrq+T does not
show anything interesting, the NFSD thread is running (and
is the only thread(s) shown in the "Runnable tasks" output):


May 25 10:48:37 gnome vmunix: [ 1709.483771] nfsd            R running      0  5853      2 0x00000000
May 25 10:48:37 gnome vmunix: [ 1709.483796]  f4477030 00000046 00000000 5c8e8929 0000018e f4c700f0 f4043a70 f545b140
May 25 10:48:37 gnome vmunix: [ 1709.483841]  050a8544 0000018e c1469140 c1469140 f4043a70 00000086 00000000 c1048575
May 25 10:48:37 gnome vmunix: [ 1709.483887]  c101ba11 c12fac18 f31bf800 f8f7bd30 0000003a c12fb156 0000003a 00000000
May 25 10:48:37 gnome vmunix: [ 1709.483931] Call Trace:
May 25 10:48:37 gnome vmunix: [ 1709.483950]  [<c1048575>] ? irq_exit+0x35/0x90
May 25 10:48:37 gnome vmunix: [ 1709.483973]  [<c101ba11>] ? smp_apic_timer_interrupt+0x51/0x90
May 25 10:48:37 gnome vmunix: [ 1709.483997]  [<c12fac18>] ? _raw_spin_lock_bh+0x8/0x30
May 25 10:48:37 gnome vmunix: [ 1709.484029]  [<f8f7bd30>] ? svc_xprt_enqueue+0x40/0x1e0 [sunrpc]
May 25 10:48:37 gnome vmunix: [ 1709.484053]  [<c12fb156>] ? apic_timer_interrupt+0x2a/0x30
May 25 10:48:37 gnome vmunix: [ 1709.484084]  [<f8f7007b>] ? svc_destroy+0xdb/0x110 [sunrpc]
May 25 10:48:37 gnome vmunix: [ 1709.484107]  [<c103d3e3>] ? __cond_resched+0x13/0x30
May 25 10:48:37 gnome vmunix: [ 1709.484129]  [<c12f92b5>] ? _cond_resched+0x25/0x30
May 25 10:48:37 gnome vmunix: [ 1709.484159]  [<f8f7cb5d>] ? svc_recv+0x1cd/0x7e0 [sunrpc]
May 25 10:48:37 gnome vmunix: [ 1709.484182]  [<c101ba11>] ? smp_apic_timer_interrupt+0x51/0x90
May 25 10:48:37 gnome vmunix: [ 1709.484206]  [<c103a3d0>] ? try_to_wake_up+0x200/0x200
May 25 10:48:37 gnome vmunix: [ 1709.484233]  [<f90ea08c>] ? nfsd+0x8c/0x120 [nfsd]
May 25 10:48:37 gnome vmunix: [ 1709.484255]  [<c102d240>] ? complete+0x40/0x60
May 25 10:48:37 gnome vmunix: [ 1709.484279]  [<f90ea000>] ? 0xf90e9fff
May 25 10:48:37 gnome vmunix: [ 1709.484299]  [<c105ea99>] ? kthread+0x69/0x70
May 25 10:48:37 gnome vmunix: [ 1709.484321]  [<c105ea30>] ? kthread_worker_fn+0x150/0x150
May 25 10:48:37 gnome vmunix: [ 1709.484345]  [<c1301876>] ? kernel_thread_helper+0x6/0xd

May 25 10:49:37 gnome vmunix: [ 1769.982791] nfsd            R running      0  5853      2 0x00000000
May 25 10:49:37 gnome vmunix: [ 1769.982816]  f5449f80 00000000 00000000 7636b581 0000019c 00000003 7603dcb8 0000019c
May 25 10:49:37 gnome vmunix: [ 1769.982859]  7603dcb8 0000019c 00000046 00000000 f4043a70 00000086 00000000 c1048575
May 25 10:49:37 gnome vmunix: [ 1769.982903]  f31bf800 c12fac18 f31bf800 f8f7bd30 00000047 f31bf800 f418c2c0 f8f7c03c
May 25 10:49:37 gnome vmunix: [ 1769.982948] Call Trace:
May 25 10:49:37 gnome vmunix: [ 1769.982966]  [<c1048575>] ? irq_exit+0x35/0x90
May 25 10:49:37 gnome vmunix: [ 1769.982987]  [<c12fac18>] ? _raw_spin_lock_bh+0x8/0x30
May 25 10:49:37 gnome vmunix: [ 1769.983019]  [<f8f7bd30>] ? svc_xprt_enqueue+0x40/0x1e0 [sunrpc]
May 25 10:49:37 gnome vmunix: [ 1769.983050]  [<f8f7c03c>] ? svc_xprt_release+0x1c/0xd0 [sunrpc]
May 25 10:49:37 gnome vmunix: [ 1769.983081]  [<f8f7c0ad>] ? svc_xprt_release+0x8d/0xd0 [sunrpc]
May 25 10:49:37 gnome vmunix: [ 1769.983112]  [<f8f7cc03>] ? svc_recv+0x273/0x7e0 [sunrpc]
May 25 10:49:37 gnome vmunix: [ 1769.983143]  [<f8f7c300>] ? svc_age_temp_xprts+0x110/0x190 [sunrpc]
May 25 10:49:37 gnome vmunix: [ 1769.983166]  [<c103a3d0>] ? try_to_wake_up+0x200/0x200
May 25 10:49:37 gnome vmunix: [ 1769.983193]  [<f90ea08c>] ? nfsd+0x8c/0x120 [nfsd]
May 25 10:49:37 gnome vmunix: [ 1769.983215]  [<c102d240>] ? complete+0x40/0x60
May 25 10:49:37 gnome vmunix: [ 1769.983238]  [<f90ea000>] ? 0xf90e9fff
May 25 10:49:37 gnome vmunix: [ 1769.983258]  [<c105ea99>] ? kthread+0x69/0x70
May 25 10:49:37 gnome vmunix: [ 1769.983278]  [<c105ea30>] ? kthread_worker_fn+0x150/0x150
May 25 10:49:37 gnome vmunix: [ 1769.983301]  [<c1301876>] ? kernel_thread_helper+0x6/0xd

This is 3.2, on 3.0 it was in different place.

This problem is persistent, always reproducible, happens
on reads from the server (I haven't seen it with writes),
and completely goes away when reverting to the kernel I
previously used on this machine - 2.6.32.  But unfortunately
2.6.32 does not quite work on the new hardware (I replaced
the motherboard), due to lack of drivers for several pieces.
(This is a different story, I think NFSD should work in 3.0
regardless of 2.6.32 issues :)

Anything I can do to make NFS work again?

Thanks,

/mjt
