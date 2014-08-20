Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:58661 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753229AbaHTWdH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2014 18:33:07 -0400
Received: by mail-vc0-f174.google.com with SMTP id la4so9899274vcb.19
        for <linux-nfs@vger.kernel.org>; Wed, 20 Aug 2014 15:33:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140818161836.GA32603@fieldses.org>
References: <53f0db34.mtq2J6NaXWKpR15G%fengguang.wu@intel.com>
	<20140818161836.GA32603@fieldses.org>
Date: Wed, 20 Aug 2014 18:33:06 -0400
Message-ID: <CAHQdGtQB2cYeMDaVrPF+dcM3Bf2PS=UzrNhJ2-zifTiDj=8ucQ@mail.gmail.com>
Subject: Re: [nfsd:nfsd-next 5/23] net/sunrpc/svc_xprt.c:794:20: error:
 'current_task' undeclared
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: kbuild test robot <fengguang.wu@intel.com>,
        "J. Bruce Fields" <bfields@redhat.com>, kbuild-all@01.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 18, 2014 at 12:18 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Mon, Aug 18, 2014 at 12:41:24AM +0800, kbuild test robot wrote:
>> tree:   git://linux-nfs.org/~bfields/linux.git nfsd-next
>> head:   da8b8f7602ed3b8105c6247a2844455fec72caaa
>> commit: 983c684466e02b21f83c025ea539deee6c0aeac0 [5/23] SUNRPC: get rid of the request wait queue
>> config: make ARCH=xtensa allyesconfig
>>
>> All error/warnings:
>>
>>    net/sunrpc/svc_xprt.c: In function 'svc_recv':
>> >> net/sunrpc/svc_xprt.c:794:20: error: 'current_task' undeclared (first use in this function)
>>       rqstp->rq_task = current_task;
>>                        ^
>>    net/sunrpc/svc_xprt.c:794:20: note: each undeclared identifier is reported only once for each function it appears in
>>
>> vim +/current_task +794 net/sunrpc/svc_xprt.c
>>
>>    788                        printk(KERN_ERR
>>    789                                "svc_recv: service %p, transport not NULL!\n",
>>    790                                 rqstp);
>>    791
>>    792                /* Make sure the task pointer is set! */
>>    793                if (WARN_ON_ONCE(!rqstp->rq_task))
>>  > 794                        rqstp->rq_task = current_task;
>
> I appreciate the effort to fail gracefully here, but maybe this would be
> a case for simple BUG_ON()?
>
> I don't think there are normally any important locks held here, and I
> can't see any other reason why killing a server thread would bring a box
> down.
>
> And the first developer to forget to set rq_task on a newly created
> server will get an immediate bug, so this should be obvious enough.
> Unless there's fear of a race between starting the thread and setting
> rq_task?
>

No, there is no fear of a race. I'm fine with removing the above check
altogether and just letting code Oops if it turns out that we add new
cases that don't set rq_task.

Ultimately, though, I think we need a better interface for starting
RPC server threads; something that combines svc_prepare_thread() and
kthread_run() into a single function call and that can thus set
rqstp->rq_task correctly.


-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
