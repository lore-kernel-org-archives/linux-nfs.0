Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:62070 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006Ab0LUUbY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Dec 2010 15:31:24 -0500
Received: by qwa26 with SMTP id 26so4397605qwa.19
        for <linux-nfs@vger.kernel.org>; Tue, 21 Dec 2010 12:31:23 -0800 (PST)
In-Reply-To: <20101218010801.GE28367@hostway.ca>
References: <20101208212505.GA18192@hostway.ca>
	<20101218010801.GE28367@hostway.ca>
Date: Tue, 21 Dec 2010 12:31:21 -0800
Message-ID: <AANLkTikSBAjk7EDPQ7isC1GDXiBqO4Rq33H3S58Q82i_@mail.gmail.com>
Subject: Re: System CPU increasing on idle 2.6.36
From: Mark Moseley <moseleymark@gmail.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
To: unlisted-recipients:; (no To-header on input)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Dec 17, 2010 at 5:08 PM, Simon Kirby <sim@hostway.ca> wrote:
> On Wed, Dec 08, 2010 at 01:25:05PM -0800, Simon Kirby wrote:
>
>> Possibly related to the flush-processes-taking-CPU issues I saw
>> previously, I thought this was interesting.  I found a log-crunching box
>> that does all of its work via NFS and spends most of the day sleeping.
>> It has been using a linearly-increasing amount of system time during the
>> time where is sleeping.  munin graph:
>>
>> http://0x.ca/sim/ref/2.6.36/cpu_logcrunch_nfs.png
>>...
>> Known 2.6.36 issue?  This did not occur on 2.6.35.4, according to the
>> munin graphs.  I'll try 2.6.37-rc an see if it changes.
>
> So, back on this topic,
>
> It seems that system CPU from "flush" processes is still increasing
> during and after periods of NFS activity, even with 2.6.37-rc5-git4:
>
>        http://0x.ca/sim/ref/2.6.37/cpu_nfs.png
>
> Something is definitely going on while NFS is active, and then keeps
> happening in the idle periods.  top and perf top look the same as in
> 2.6.36.  No userland activity at all, but the kernel keeps doing stuff.
>
> I could bisect this, but I have to wait a day for each build, unless I
> can come up with a way to reproduce it more quickly.  The mount points
> for which the flush processes are active are the two mount points where
> the logs are read from, rotated, compressed, and unlinked, and where the
> reports are written, running in parallel under an xargs -P 15.
>
> I'm pretty sure the only syscalls that are reproducing this are read(),
> readdir(), lstat(), write(), rename(), unlink(), and close().  There's
> nothing special happening here...

I'm running 2.6.36 on a number of mail servers that do a great deal of
write I/O to NFS (all Netapps, NFSv3, UDP). I've seen this exact same
behaviour a number of times since moving to 2.6.36. I just had to
powercycle a box a minute ago doing the same thing. Any time I've seen
this, the only remedy is reboot. These boxes were last running a
2.6.32.x kernel and had no such behaviour. I didn't think to check
nfsstat before rebooting but I can next time if it'd be useful.

'top' consistently showed 6 flush threads tying up 100% total of the CPU:

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
 4853 root      20   0     0    0    0 R   33  0.0  36:47.13
flush-0:26
 4854 root      20   0     0    0    0 R   33  0.0  38:56.89
flush-0:27
 4855 root      20   0     0    0    0 R   33  0.0  38:35.01
flush-0:28
 4856 root      20   0     0    0    0 R   33  0.0  39:00.11
flush-0:29
 4857 root      20   0     0    0    0 R   33  0.0  37:39.08
flush-0:30
 4858 root      20   0     0    0    0 R   31  0.0  37:04.30 flush-0:31


perf top consistently showed _raw_spin_lock at over 50% (these boxes
are only 2 cores though). shrink_icache_memory was usually near the
top and nfs_writepages hung around the top 5 or 6. Looking at tcpdump,
there was no actual packets getting sent to those Netapps (I was
looking at all ports too, not just 2049). This 'perf top' is fairly
representative of what I was seeing:

------------------------------------------------------------------------------
   PerfTop:   23638 irqs/sec  kernel:97.3% [100000 cycles],  (all, 2 CPUs)
------------------------------------------------------------------------------

             samples    pcnt         RIP          kernel function
  ______     _______   _____   ________________   _______________

           330867.00 - 62.5% - 00000000003cc97a : _raw_spin_lock
            19496.00 -  3.7% - 00000000000c83e8 : shrink_icache_memory
            13634.00 -  2.6% - 00000000003cc12c : down_read
            12064.00 -  2.3% - 000000000004d817 : up_read
             7807.00 -  1.5% - 0000000000022c38 : kunmap_atomic_notypecheck
             7496.00 -  1.4% - 0000000000168258 : nfs_writepages
             7343.00 -  1.4% - 00000000000d0244 : writeback_single_inode
             5528.00 -  1.0% - 0000000000022d36 : kmap_atomic_prot
             4915.00 -  0.9% - 00000000000c75c4 : __iget
             3933.00 -  0.7% - 00000000000d0708 : writeback_sb_inodes
             3793.00 -  0.7% - 0000000000049d27 : wake_up_bit
             3579.00 -  0.7% - 00000000000c805c : dispose_list
             3487.00 -  0.7% - 00000000000d08cf : __mark_inode_dirty
             3144.00 -  0.6% - 00000000003cd890 : page_fault
             2539.00 -  0.5% - 00000000001d6afc : _atomic_dec_and_lock
