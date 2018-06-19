Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52936 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750973AbeFSXKz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Jun 2018 19:10:55 -0400
Subject: Re: warning about locking with nfsroot on 4.17
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>,
        Ingo Molnar <mingo@kernel.org>
References: <20180525102736.xhu7djoo64i7etnj@pengutronix.de>
 <20180619081533.qmivmfgtvrq6bhax@pengutronix.de>
 <87ef229f7f724720e1cf237116bd35a5a91dfe99.camel@eckelmann.de>
 <20180619205505.yz6bhfah3aunchod@pengutronix.de>
From: Waiman Long <longman@redhat.com>
Message-ID: <2d7a12f5-184f-4bdc-c617-cbd1e9bff02c@redhat.com>
Date: Wed, 20 Jun 2018 07:10:51 +0800
MIME-Version: 1.0
In-Reply-To: <20180619205505.yz6bhfah3aunchod@pengutronix.de>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/20/2018 04:55 AM, Uwe Kleine-König wrote:
> Hello,
>
> a customer reports the below reproducible locking splat when booting
> with nfsroot and changing a password:
>
> On Tue, Jun 19, 2018 at 10:30:28AM +0000, said customer wrote:
>> root@hostname:~ uname -a
>> Linux hostame 4.17.0-20180520-1-g248646e6c511 #3 SMP 2018-05-01 armv7l GNU/Linux
>>
>> root@hostname:~ passwd 
>> Changing password for root
>> New password: 
>> Bad password: too short
>> Retype password: 
>> [   31.945836] ------------[ cut here ]------------
>> [   31.950545] WARNING: CPU: 1 PID: 74 at kernel/locking/rwsem.c:217 up_read_non_owner+0xb4/0xb8
>> [   31.959079] DEBUG_LOCKS_WARN_ON(sem->owner != ((struct task_struct *)(1UL << 0)))
>> [   31.959085] Modules linked in:
>> [   31.969836] CPU: 1 PID: 74 Comm: kworker/1:3 Not tainted 4.17.0-20180520-1-g248646e6c511 #3
>> [   31.978201] Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
>> [   31.984776] Workqueue: nfsiod rpc_async_release
>> [   31.989348] Backtrace: 
>> [   31.991851] [<8010f404>] (dump_backtrace) from [<8010f6ac>] (show_stack+0x20/0x24)
>> [   31.999456]  r7:810ae570 r6:00000000 r5:60070013 r4:810ae570
>> [   32.005155] [<8010f68c>] (show_stack) from [<80b78638>] (dump_stack+0xb0/0xdc)
>> [   32.012428] [<80b78588>] (dump_stack) from [<80126240>] (__warn+0x100/0x11c)
>> [   32.019513]  r10:be161ef8 r9:000000d9 r8:8017ede0 r7:00000009 r6:80e014ec r5:00000000
>> [   32.027370]  r4:be161e50 r3:bf7cfa58
>> [   32.038506]  r9:810b64f0 r8:81007528 r7:bf7d8e00 r6:bde27000 r5:bdade600 r4:80dfd978
>> [   32.046295] [<80126260>] (warn_slowpath_fmt) from [<8017ede0>] (up_read_non_owner+0xb4/0xb8)
>> [   32.054761]  r3:80e014b8 r2:80dfd978
>> [   32.058361]  r4:bec40cc8
>> [   32.060945] [<8017ed2c>] (up_read_non_owner) from [<803e8020>] (nfs_async_unlink_release+0x30/0x78)
>> [   32.070018]  r5:bdade600 r4:bd697730
>> [   32.073637] [<803e7ff0>] (nfs_async_unlink_release) from [<80a6d08c>] (rpc_free_task+0x34/0x54)
>> [   32.082368]  r7:bf7d8e00 r6:bf7d2ec0 r5:00000881 r4:bd81dcc0
>> [   32.088067] [<80a6d058>] (rpc_free_task) from [<80a6d0c8>] (rpc_async_release+0x1c/0x20)
>> [   32.096185]  r5:be118d80 r4:bd81dce4
>> [   32.099803] [<80a6d0ac>] (rpc_async_release) from [<80146298>] (process_one_work+0x2b4/0x7d4)
>> [   32.108366] [<80145fe4>] (process_one_work) from [<8014752c>] (worker_thread+0x64/0x5bc)
>> [   32.116490]  r10:81004900 r9:00000008 r8:ffffe000 r7:bf7d2ef4 r6:be118d98 r5:bf7d2ec0
>> [   32.124345]  r4:be118d80
>> [   32.126919] [<801474c8>] (worker_thread) from [<8014df28>] (kthread+0x174/0x178)
>> [   32.134350]  r10:bf15be74 r9:801474c8 r8:be118d80 r7:be160000 r6:00000000 r5:be11ed00
>> [   32.142207]  r4:be0b1e80
>> [   32.144778] [<8014ddb4>] (kthread) from [<801010b4>] (ret_from_fork+0x14/0x20)
>> [   32.152027] Exception stack(0xbe161fb0 to 0xbe161ff8)
>> [   32.157110] 1fa0:                                     00000000 00000000 00000000 00000000
>> [   32.165321] 1fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
>> [   32.173531] 1fe0: 00000000 00000000 00000000 00000000 00000013 00000000
>> [   32.180179]  r10:00000000 r9:00000000 r8:00000000 r7:00000000 r6:00000000 r5:8014ddb4
>> [   32.188033]  r4:be11ed00
>> [   32.190810] irq event stamp: 16391
>> [   32.194282] hardirqs last  enabled at (16391): [<80b965bc>] _raw_spin_unlock_irq+0x34/0x3c
>> [   32.202707] hardirqs last disabled at (16390): [<80b9648c>] _raw_spin_lock_irq+0x28/0x58
>> [   32.210881] softirqs last  enabled at (7494): [<801a1258>] srcu_invoke_callbacks+0xa4/0x150
>> [   32.219279] softirqs last disabled at (7490): [<801a1258>] srcu_invoke_callbacks+0xa4/0x150
>> [   32.227704] ---[ end trace 57db2425555c8696 ]---
>> passwd: password for root changed by root
> this happens since they upgraded to 4.17, it was bisected to
> 5149cbac4235e12a34cf089592a8bd1c9fcfa467, which isn't very helpful
> though.
>
> Before I start investigating this issue, I'd like to know if you are
> maybe already aware of this problem to prevent duplicate work.
>
> Best regards
> Uwe
>
Yes, that is a known issue. The fix is available and hopefully can be
merged soon.

Cheers,
Longman

