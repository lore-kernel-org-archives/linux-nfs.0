Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33171 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336AbbGZJBR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jul 2015 05:01:17 -0400
Date: Sun, 26 Jul 2015 11:01:01 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: kernel test robot <ying.huang@intel.com>,
        Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, LKP <lkp@01.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [lkp] [sched/preempt] 103637a5b94: 12.4% fsmark.app_overhead,
 -1.4% fsmark.files_per_sec
Message-ID: <20150726090101.GN19282@twins.programming.kicks-ass.net>
References: <87si8cahvi.fsf@yhuang-dev.intel.com>
 <CALYGNiNtLYwts6mu5-yTZTJ_7-FDym=bbtzUv-pmX5yhHWfRuA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CALYGNiNtLYwts6mu5-yTZTJ_7-FDym=bbtzUv-pmX5yhHWfRuA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jul 25, 2015 at 07:32:03PM +0300, Konstantin Khlebnikov wrote:
> I guess that's because of cond_resched_lock() usage in nfs_scan_commit_list().
> My patch fixes cond_resched_lock() which never worked since v3.13.

Yeah, I wasn't surprised to see preemptions go up with this patch, not
total throughput suffer a bit due to that.
