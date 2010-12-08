Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:41136 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756091Ab0LHVZH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Dec 2010 16:25:07 -0500
Received: from sim by peace.netnation.com with local (Exim 4.69)
	(envelope-from <sim@netnation.com>)
	id 1PQRVa-0007nV-0D
	for linux-nfs@vger.kernel.org; Wed, 08 Dec 2010 13:25:06 -0800
Date: Wed, 8 Dec 2010 13:25:05 -0800
From: Simon Kirby <sim@hostway.ca>
To: linux-nfs@vger.kernel.org
Subject: System CPU increasing on idle 2.6.36
Message-ID: <20101208212505.GA18192@hostway.ca>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Possibly related to the flush-processes-taking-CPU issues I saw
previously, I thought this was interesting.  I found a log-crunching box
that does all of its work via NFS and spends most of the day sleeping. 
It has been using a linearly-increasing amount of system time during the
time where is sleeping.  munin graph:

http://0x.ca/sim/ref/2.6.36/cpu_logcrunch_nfs.png

top shows:

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
 4767 root      20   0     0    0    0 S   16  0.0   2413:29 flush-0:69
22385 root      20   0     0    0    0 S   10  0.0   1320:23 flush-0:70
(rest idle)

perf top shows:

-------------------------------------------------------------------------------------------
   PerfTop:     252 irqs/sec  kernel:97.2%  exact:  0.0% [1000Hz cycles],  (all, 2 CPUs)
-------------------------------------------------------------------------------------------

     samples  pcnt function                        DSO
     _______ _____ _______________________________ ___________

      912.00 21.2% _raw_spin_lock                  [kernel]
      592.00 13.8% nfs_writepages                  [kernel]
      474.00 11.0% queue_io                        [kernel]
      428.00 10.0% writeback_single_inode          [kernel]
      379.00  8.8% writeback_sb_inodes             [kernel]
      237.00  5.5% bit_waitqueue                   [kernel]
      184.00  4.3% do_writepages                   [kernel]
      169.00  3.9% __iget                          [kernel]
      132.00  3.1% redirty_tail                    [kernel]
       85.00  2.0% iput                            [kernel]
       72.00  1.7% _atomic_dec_and_lock            [kernel]
       67.00  1.6% write_cache_pages               [kernel]
       63.00  1.5% port_inb                        [ipmi_si]
       62.00  1.4% __mark_inode_dirty              [kernel]
       48.00  1.1% __wake_up_bit                   [kernel]
       32.00  0.7% nfs_write_inode                 [kernel]
       26.00  0.6% native_read_tsc                 [kernel]
       25.00  0.6% radix_tree_gang_lookup_tag_slot [kernel]
       25.00  0.6% schedule                        [kernel]
       24.00  0.6% wake_up_bit                     [kernel]
       20.00  0.5% apic_timer_interrupt            [kernel]
       19.00  0.4% ia32_syscall                    [kernel]
       16.00  0.4% find_get_pages_tag              [kernel]
       15.00  0.3% _raw_spin_lock_irqsave          [kernel]
       15.00  0.3% load_balance                    [kernel]
       13.00  0.3% ktime_get                       [kernel]
       12.00  0.3% shrink_icache_memory            [kernel]
       11.00  0.3% semop                           libc-2.7.so
	9.00  0.2% nfs_pageio_doio                 [kernel]
	8.00  0.2% dso__find_symbol                perf
	8.00  0.2% down_read                       [kernel]
	7.00  0.2% __switch_to                     [kernel]
	7.00  0.2% __phys_addr                     [kernel]
	7.00  0.2% nfs_pageio_init                 [kernel]
	7.00  0.2% pagevec_lookup_tag              [kernel]
	7.00  0.2% _cond_resched                   [kernel]
	7.00  0.2% up_read                         [kernel]
	6.00  0.1% sched_clock_local               [kernel]
	5.00  0.1% rb_erase                        [kernel]
	5.00  0.1% page_fault                      [kernel]

"tcpdump -i any -n port 2049" and "nfsstat" shows this work does not actually result
in any NFS packets.

Known 2.6.36 issue?  This did not occur on 2.6.35.4, according to the
munin graphs.  I'll try 2.6.37-rc an see if it changes.

Simon-
