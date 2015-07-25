Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:33797 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754991AbbGYQcG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 25 Jul 2015 12:32:06 -0400
MIME-Version: 1.0
In-Reply-To: <87si8cahvi.fsf@yhuang-dev.intel.com>
References: <87si8cahvi.fsf@yhuang-dev.intel.com>
Date: Sat, 25 Jul 2015 19:32:03 +0300
Message-ID: <CALYGNiNtLYwts6mu5-yTZTJ_7-FDym=bbtzUv-pmX5yhHWfRuA@mail.gmail.com>
Subject: Re: [lkp] [sched/preempt] 103637a5b94: 12.4% fsmark.app_overhead,
 -1.4% fsmark.files_per_sec
From: Konstantin Khlebnikov <koct9i@gmail.com>
To: kernel test robot <ying.huang@intel.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, LKP <lkp@01.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I guess that's because of cond_resched_lock() usage in nfs_scan_commit_list().
My patch fixes cond_resched_lock() which never worked since v3.13.

On Sat, Jul 25, 2015 at 9:09 AM, kernel test robot <ying.huang@intel.com> wrote:
> FYI, we noticed the below changes on
>
> git://internal_merge_and_test_tree revert-103637a5b947af7e6abb8d19b341acff6fbf1ec3-103637a5b947af7e6abb8d19b341acff6fbf1ec3
> commit 103637a5b947af7e6abb8d19b341acff6fbf1ec3 ("sched/preempt: Fix cond_resched_lock() and cond_resched_softirq()")
>
>
> =========================================================================================
> tbox_group/testcase/rootfs/kconfig/compiler/cpufreq_governor/iterations/nr_threads/disk/fs/fs2/filesize/test_size/sync_method/nr_directories/nr_files_per_directory:
>   nhm4/fsmark/debian-x86_64-2015-02-07.cgz/x86_64-rhel/gcc-4.9/performance/1x/32t/1HDD/f2fs/nfsv4/9B/400M/fsyncBeforeClose/16d/256fpd
>
> commit:
>   834b9279b37ad019272ff140497b1e07ab52d124
>   103637a5b947af7e6abb8d19b341acff6fbf1ec3
>
> 834b9279b37ad019 103637a5b947af7e6abb8d19b3
> ---------------- --------------------------
>          %stddev     %change         %stddev
>              \          |                \
>   10808007 ±  2%     +12.4%   12147111 ±  3%  fsmark.app_overhead
>     348.95 ±  0%      -1.4%     343.95 ±  0%  fsmark.files_per_sec
>     292.92 ±  0%      +1.8%     298.06 ±  0%  fsmark.time.elapsed_time
>     292.92 ±  0%      +1.8%     298.06 ±  0%  fsmark.time.elapsed_time.max
>     103928 ±  0%     +13.9%     118415 ±  0%  fsmark.time.involuntary_context_switches
>     468477 ±  0%      -2.2%     458135 ±  0%  fsmark.time.voluntary_context_switches
>     103928 ±  0%     +13.9%     118415 ±  0%  time.involuntary_context_switches
>      16609 ±  0%      -2.1%      16267 ±  0%  vmstat.system.in
>    4527868 ±  2%     +25.9%    5698416 ±  2%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_execute.rpc_run_task.nfs4_call_sync_sequence.[nfsv4]._nfs4_proc_lookup.[nfsv4].nfs4_proc_lookup_common.[nfsv4].nfs4_proc_lookup.[nfsv4].nfs_lookup_revalidate.nfs4_lookup_revalidate.lookup_dcache.__lookup_hash
>  2.317e+09 ±  0%      +5.5%  2.444e+09 ±  0%  latency_stats.sum.rpc_wait_bit_killable.__rpc_wait_for_completion_task.nfs4_run_open_task.[nfsv4]._nfs4_open_and_get_state.[nfsv4].nfs4_do_open.[nfsv4].nfs4_atomic_open.[nfsv4].nfs_atomic_open.path_openat.do_filp_open.do_sys_open.SyS_open.entry_SYSCALL_64_fastpath
>  1.548e+09 ±  0%      +2.9%  1.593e+09 ±  0%  latency_stats.sum.wait_on_page_bit.filemap_fdatawait_range.filemap_write_and_wait_range.nfs4_file_fsync.[nfsv4].vfs_fsync_range.do_fsync.SyS_fsync.entry_SYSCALL_64_fastpath
>  3.399e+08 ±  1%     +19.0%  4.043e+08 ±  2%  cpuidle.C1-NHM.time
>   82737781 ±  0%     +24.8%  1.032e+08 ±  0%  cpuidle.C1E-NHM.time
>     141228 ±  0%     +23.4%     174263 ±  0%  cpuidle.C1E-NHM.usage
>     128964 ±154%    +209.1%     398639 ± 26%  cpuidle.POLL.time
>       3.47 ±  0%      -2.5%       3.38 ±  0%  turbostat.%Busy
>     110.25 ±  0%      -2.0%     108.00 ±  0%  turbostat.Avg_MHz
>      32.94 ±  0%     +14.4%      37.69 ±  1%  turbostat.CPU%c1
>      32.26 ±  1%     -11.3%      28.62 ±  1%  turbostat.CPU%c3
>      -2795 ± -9%     -19.2%      -2258 ± -4%  sched_debug.cfs_rq[1]:/.spread0
>       3273 ±  4%     +29.9%       4250 ± 10%  sched_debug.cfs_rq[5]:/.avg->runnable_avg_sum
>      70.25 ±  4%     +29.5%      91.00 ± 10%  sched_debug.cfs_rq[5]:/.tg_runnable_contrib
>      -2687 ±  0%     -14.1%      -2308 ± -2%  sched_debug.cpu#0.nr_uninterruptible
>     333314 ± 74%     -46.7%     177695 ±  3%  sched_debug.cpu#0.ttwu_count
>     318.25 ± 11%     -41.3%     186.75 ±  6%  sched_debug.cpu#1.nr_uninterruptible
>     331.50 ±  9%     -16.0%     278.50 ± 11%  sched_debug.cpu#2.nr_uninterruptible
>     172.25 ± 21%     +63.6%     281.75 ± 14%  sched_debug.cpu#3.nr_uninterruptible
>     753.75 ±  2%     +38.7%       1045 ±  4%  sched_debug.cpu#4.nr_uninterruptible
>     839497 ±169%     -98.0%      16681 ±  1%  sched_debug.cpu#4.ttwu_local
>     392.00 ±  3%     -50.6%     193.50 ± 12%  sched_debug.cpu#5.nr_uninterruptible
>      12.50 ± 35%    +272.0%      46.50 ± 73%  sched_debug.cpu#6.cpu_load[0]
>     385.00 ±  7%     -53.0%     181.00 ±  8%  sched_debug.cpu#6.nr_uninterruptible
>     362.00 ±  2%     -53.8%     167.25 ± 15%  sched_debug.cpu#7.nr_uninterruptible
>
>
> nhm4: Nehalem
> Memory: 4G
>
>
>                                fsmark.files_per_sec
>
>   352 *+-*-------------------------*-----*--*-------------------------------+
>   351 ++    *..                  .. :   :    :                              |
>       |        .                .    :  :     :                             |
>   350 ++        *..           .*     : :      :                             |
>   349 ++           *..*..*..*.        *        *...*..*..*                  |
>       |                                                                     |
>   348 ++                                                                    |
>   347 ++                                                                    |
>   346 ++                                                                    |
>       O     O               O  O      O     O         O           O         |
>   345 ++ O                                                     O            O
>   344 ++              O  O         O                                        |
>       |                                                                     |
>   343 ++        O  O                     O     O   O     O  O         O  O  |
>   342 ++--------------------------------------------------------------------+
>
>
>                              fsmark.time.elapsed_time
>
>   299 ++--------------------------------------------------------------------+
>       |         O  O                     O     O   O     O  O         O  O  |
>   298 ++ O            O  O         O        O         O        O  O         O
>   297 O+                    O  O      O                                     |
>       |     O                                                               |
>   296 ++                                                                    |
>   295 ++                                                                    |
>       |                                                                     |
>   294 ++           *..*..                                                   |
>   293 ++         ..      *..                   *...*..*..                   |
>       *..   *...*           *..*...  .*..     +          *                  |
>   292 ++  ..                       *.    *.. +                              |
>   291 ++ *                                  *                               |
>       |                                                                     |
>   290 ++--------------------------------------------------------------------+
>
>
>                            fsmark.time.elapsed_time.max
>
>   299 ++--------------------------------------------------------------------+
>       |         O  O                     O     O   O     O  O         O  O  |
>   298 ++ O            O  O         O        O         O        O  O         O
>   297 O+                    O  O      O                                     |
>       |     O                                                               |
>   296 ++                                                                    |
>   295 ++                                                                    |
>       |                                                                     |
>   294 ++           *..*..                                                   |
>   293 ++         ..      *..                   *...*..*..                   |
>       *..   *...*           *..*...  .*..     +          *                  |
>   292 ++  ..                       *.    *.. +                              |
>   291 ++ *                                  *                               |
>       |                                                                     |
>   290 ++--------------------------------------------------------------------+
>
>
>                        fsmark.time.voluntary_context_switches
>
>   470000 ++--------------------------------*--------------------------------+
>          |                          *..*.     *..  .*..*..*                 |
>   468000 *+.*..*..  .*..*..*..    ..             *.                         |
>   466000 ++       *.            .*                                          |
>          |                    *.                                            |
>   464000 ++                                                                 |
>          |                                                                  |
>   462000 ++                                                                 |
>          |                                                                  |
>   460000 ++                                                                 |
>   458000 ++                                            O  O  O  O  O  O  O  O
>          |        O  O     O  O  O  O  O            O                       |
>   456000 O+ O  O        O                  O  O  O                          |
>          |                                                                  |
>   454000 ++-----------------------------------------------------------------+
>
>
>                       fsmark.time.involuntary_context_switches
>
>   120000 ++-----------------------------------------------------------------+
>          |                                             O  O     O  O  O     O
>   118000 O+ O        O           O               O  O        O           O  |
>   116000 ++    O  O     O  O  O     O  O   O  O                             |
>          |                                                                  |
>   114000 ++                                                                 |
>   112000 ++                                                                 |
>          |                                                                  |
>   110000 ++                                                                 |
>   108000 ++                                                                 |
>          |                                                                  |
>   106000 ++                                                                 |
>   104000 *+.*..*..*..*..           .*..*...*..*..     .*..*                 |
>          |              *..*..*..*.              *..*.                      |
>   102000 ++-----------------------------------------------------------------+
>
>
>                           time.involuntary_context_switches
>
>   120000 ++-----------------------------------------------------------------+
>          |                                             O  O     O  O  O     O
>   118000 O+ O        O           O               O  O        O           O  |
>   116000 ++    O  O     O  O  O     O  O   O  O                             |
>          |                                                                  |
>   114000 ++                                                                 |
>   112000 ++                                                                 |
>          |                                                                  |
>   110000 ++                                                                 |
>   108000 ++                                                                 |
>          |                                                                  |
>   106000 ++                                                                 |
>   104000 *+.*..*..*..*..           .*..*...*..*..     .*..*                 |
>          |              *..*..*..*.              *..*.                      |
>   102000 ++-----------------------------------------------------------------+
>
>
>         [*] bisect-good sample
>         [O] bisect-bad  sample
>
> To reproduce:
>
>         git clone git://git.kernel.org/pub/scm/linux/kernel/git/wfg/lkp-tests.git
>         cd lkp-tests
>         bin/lkp install job.yaml  # job file is attached in this email
>         bin/lkp run     job.yaml
>
>
> Disclaimer:
> Results have been estimated based on internal Intel analysis and are provided
> for informational purposes only. Any difference in system hardware or software
> design or configuration may affect actual performance.
>
>
> Thanks,
> Ying Huang
