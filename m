Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:48407 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752865AbcJ1VIZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Oct 2016 17:08:25 -0400
Date: Fri, 28 Oct 2016 23:08:14 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: kernel test robot <xiaolong.ye@intel.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, tglx@linutronix.de, lkp@01.org
Subject: Re: [lkp] [NFSv4]  931437ee2c: BUG: sleeping function called from
 invalid context at mm/slab.h:393
Message-ID: <20161028210813.6uqeblto2lymdf3b@linutronix.de>
References: <20161021164727.24485-1-bigeasy@linutronix.de>
 <20161025065239.GC3341@yexl-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20161025065239.GC3341@yexl-desktop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2016-10-25 14:52:39 [+0800], kernel test robot wrote:
> 
> FYI, we noticed the following commit:
> 
> https://github.com/0day-ci/linux Sebastian-Andrzej-Siewior/NFSv4-replace-seqcount_t-with-a-seqlock_t/20161022-013104
> commit 931437ee2c100a50c36771c947ce3674f8160592 ("NFSv4: replace seqcount_t with a seqlock_t")
> 
> in testcase: ebizzy
> with following parameters:
> 
> 	nr_threads: 200%
> 	iterations: 100x
> 	duration: 10s
> 
> 
> ebizzy is designed to generate a workload resembling common web application server workloads.
> 
> 
> on test machine: qemu-system-x86_64 -enable-kvm -cpu kvm64,+ssse3 -m 1G

It can't get it triggered. In fact I never get even close to the code
path. I tried NFS as rootfs and this test of yours. And I tried
"xfstests-dev -nfs" with no luck.
So you have NFS as your rootfs. Anything special on the server side? It
seems to be a basic NFSv4 export.

Sebastian
