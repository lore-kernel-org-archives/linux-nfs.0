Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:36489 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750952AbdFALl1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jun 2017 07:41:27 -0400
Received: by mail-qt0-f171.google.com with SMTP id f55so33600662qta.3
        for <linux-nfs@vger.kernel.org>; Thu, 01 Jun 2017 04:41:26 -0700 (PDT)
Message-ID: <1496317284.2845.4.camel@redhat.com>
Subject: Re: [lkp-robot] [fs/locks]  9d21d181d0:
 will-it-scale.per_process_ops -14.1% regression
From: Jeff Layton <jlayton@redhat.com>
To: kernel test robot <xiaolong.ye@intel.com>,
        Benjamin Coddington <bcodding@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, bfields@fieldses.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        lkp@01.org, Christoph Hellwig <hch@infradead.org>
Date: Thu, 01 Jun 2017 07:41:24 -0400
In-Reply-To: <20170601020556.GE16905@yexl-desktop>
References: <20170601020556.GE16905@yexl-desktop>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-06-01 at 10:05 +0800, kernel test robot wrote:
> Greeting,
> 
> FYI, we noticed a -14.1% regression of will-it-scale.per_process_ops due to commit:
> 
> 
> commit: 9d21d181d06acab9a8e80eac2ec4eed77b656793 ("fs/locks: Set fl_nspid at file_lock allocation")
> url: https://github.com/0day-ci/linux/commits/Benjamin-Coddington/fs-locks-Alloc-file_lock-where-practical/20170527-050700
> 
> 

Ouch, that's a rather nasty performance hit. In hindsight, maybe we
shouldn't move those off the stack after all? Heck, if it's that
significant, maybe we should move the F_SETLK callers to allocate these
on the stack as well?

> in testcase: will-it-scale
> on test machine: 4 threads Intel(R) Core(TM) i3-3220 CPU @ 3.30GHz with 4G memory
> with following parameters:
> 
> 	test: lock1
> 	cpufreq_governor: performance
> 
> test-description: Will It Scale takes a testcase and runs it from 1 through to n parallel copies to see if the testcase will scale. It builds both a process and threads based test in order to see any differences between the two.
> test-url: https://github.com/antonblanchard/will-it-scale
> 
> In addition to that, the commit also has significant impact on the following tests:
> 
> +------------------+----------------------------------------------------------------+
> > testcase: change | will-it-scale: will-it-scale.per_process_ops -4.9% regression  |
> > test machine     | 16 threads Intel(R) Atom(R) CPU 3958 @ 2.00GHz with 64G memory |
> > test parameters  | cpufreq_governor=performance                                   |
> >                  | mode=process                                                   |
> >                  | nr_task=100%                                                   |
> >                  | test=lock1                                                     |
> 
> +------------------+----------------------------------------------------------------+
> 
> 
> Details are as below:
> -------------------------------------------------------------------------------------------------->
> 
> 
> To reproduce:
> 
>         git clone https://github.com/01org/lkp-tests.git
>         cd lkp-tests
>         bin/lkp install job.yaml  # job file is attached in this email
>         bin/lkp run     job.yaml
> 
> testcase/path_params/tbox_group/run: will-it-scale/lock1-performance/lkp-ivb-d04
> 
> 09790e423b32fba4  9d21d181d06acab9a8e80eac2e  
> ----------------  --------------------------  
>       0.51              19%       0.60 ±  7%  will-it-scale.scalability
>    2462089             -14%    2114597        will-it-scale.per_process_ops
>    2195246             -26%    1631578        will-it-scale.per_thread_ops
>        350                         356        will-it-scale.time.system_time
>      28.89             -24%      22.06        will-it-scale.time.user_time
>      32.78                       31.97        turbostat.PkgWatt
>      15.58              -5%      14.80        turbostat.CorWatt
>      19284                       18803        vmstat.system.in
>      32208              -4%      31052        vmstat.system.cs
>       1630 ±173%      2e+04      18278 ± 27%  latency_stats.avg.perf_event_alloc.SYSC_perf_event_open.SyS_perf_event_open.entry_SYSCALL_64_fastpath
>       1630 ±173%      2e+04      18278 ± 27%  latency_stats.max.perf_event_alloc.SYSC_perf_event_open.SyS_perf_event_open.entry_SYSCALL_64_fastpath
>       1630 ±173%      2e+04      18278 ± 27%  latency_stats.sum.perf_event_alloc.SYSC_perf_event_open.SyS_perf_event_open.entry_SYSCALL_64_fastpath
>  1.911e+09 ±  6%       163%  5.022e+09 ±  5%  perf-stat.cache-references
>      27.58 ± 12%        17%      32.14 ±  7%  perf-stat.iTLB-load-miss-rate%
>    9881103              -4%    9527607        perf-stat.context-switches
>  9.567e+11 ±  9%       -14%  8.181e+11 ±  9%  perf-stat.dTLB-loads
>   6.85e+11 ±  4%       -16%  5.761e+11 ±  6%  perf-stat.branch-instructions
>  3.469e+12 ±  4%       -17%  2.893e+12 ±  6%  perf-stat.instructions
>       1.24 ±  4%       -19%       1.00        perf-stat.ipc
>       3.18 ±  8%       -62%       1.19 ± 19%  perf-stat.cache-miss-rate%
> 
> 
> 
>                              perf-stat.cache-references
> 
>   8e+09 ++------------------------------------------------------------------+
>         |                                                                   |
>   7e+09 ++                                             O       O            |
>         |                  O                                                |
>   6e+09 ++                                  O                               |
>         |                                                             O     |
>   5e+09 ++O                       O             O    O       O          O   O
>         O   O O  O O O O O   O O    O O   O   O    O       O        O     O |
>   4e+09 ++                              O                O       O          |
>         |                                                                   |
>   3e+09 ++                                                                  |
>         |   *.                 *..        *.                                |
>   2e+09 *+ +  *..         .*. +   *. .*. +  *.    .*.*.   .*.*. .*..*       |
>         | *      *.*.*.*.*   *      *   *     *.*.     *.*     *            |
>   1e+09 ++------------------------------------------------------------------+
> 
> 
>                           will-it-scale.time.user_time
> 
>   30 ++--*-------------------*-----------*----------------------------------+
>   29 *+*    *.*.*.*..*.*.*.*    *.*.*.*.   *.*.     *. .*.    .*.*.*        |
>      |                                         *. ..  *   *.*.              |
>   28 ++                                          *                          |
>   27 ++                                                                     |
>      |                                                                      |
>   26 ++                                                                     |
>   25 ++                                                                     |
>   24 ++                                                                     |
>      |                                                                      |
>   23 ++  O    O                   O O O  O O O O    O   O   O    O          |
>   22 O+O    O   O O      O O O  O                O    O        O     O  O O |
>      |               O                                    O        O        O
>   21 ++                O                                                    |
>   20 ++---------------------------------------------------------------------+
> 
> 
>                           will-it-scale.time.system_time
> 
>   358 ++--------------------------------------------------------------------+
>   357 O+O    O   O      O       O                 O                     O   O
>       |   O    O   O O    O O     O  O O O          O O    O O O   O O    O |
>   356 ++                      O            O O  O       O        O          |
>   355 ++                                                                    |
>       |                                                                     |
>   354 ++                                                                    |
>   353 ++                                                                    |
>   352 ++                                                                    |
>       |                                                                     |
>   351 ++                                          *. .*.    .*.             |
>   350 *+*.  .*   *     .*.*.*. .*    *.*. .*     +  *   *..*   *.*.*        |
>       |   *.  + + + .*.       *  + ..    *  +  .*                           |
>   349 ++       *   *              *          *.                             |
>   348 ++--------------------------------------------------------------------+
> 
> 
>                              will-it-scale.per_thread_ops
> 
>   2.3e+06 ++----------------------------------------------------------------+
>           |                                                                 |
>   2.2e+06 ++*.*.   .*. .*..*. .*.*.     .*.*.         .*.*..*.*.*.*.*       |
>           *     *.*   *      *     *.*.*     *.*. .*.*                      |
>   2.1e+06 ++                                     *                          |
>     2e+06 ++                                                                |
>           |                                                                 |
>   1.9e+06 ++                                                                |
>           |                                                                 |
>   1.8e+06 ++                                                                |
>   1.7e+06 ++      O                    O O   O       O        O             |
>           O O O     O              O       O       O     O        O     O   |
>   1.6e+06 ++    O     O      O O O   O         O O     O    O   O   O O   O O
>           |             O  O                                                |
>   1.5e+06 ++----------------------------------------------------------------+
> 
>   [*] bisect-good sample
>   [O] bisect-bad  sample
> 
> 
> Disclaimer:
> Results have been estimated based on internal Intel analysis and are provided
> for informational purposes only. Any difference in system hardware or software
> design or configuration may affect actual performance.
> 
> 
> Thanks,
> Xiaolong

-- 
Jeff Layton <jlayton@redhat.com>
