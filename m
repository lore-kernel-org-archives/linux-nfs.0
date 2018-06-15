Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:43266 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755925AbeFOMx4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jun 2018 08:53:56 -0400
MIME-Version: 1.0
In-Reply-To: <CAJKOXPd2rntNOpU1quR9Zm_J22+=pEaj4ZTC_tdZ0zcRYUciFg@mail.gmail.com>
References: <CAJKOXPd2rntNOpU1quR9Zm_J22+=pEaj4ZTC_tdZ0zcRYUciFg@mail.gmail.com>
From: Sudeep Holla <sudeep.holla@arm.com>
Date: Fri, 15 Jun 2018 13:53:54 +0100
Message-ID: <CAPKp9uZ79ybkv7dMpcy2GQ9L+rWk+vdExQ48diWWQPOUdDQtSQ@mail.gmail.com>
Subject: Re: [BUG BISECT] NFSv4 client fails on Flush Journal to Persistent Storage
To: Krzysztof Kozlowski <krzk@kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>,
        "linux-samsung-soc@vger.kernel.org"
        <linux-samsung-soc@vger.kernel.org>,
        Sudeep Holla <sudeep.holla@arm.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On Thu, Jun 7, 2018 at 12:19 PM, Krzysztof Kozlowski <krzk@kernel.org> wrot=
e:
> Hi,
>
> When booting my boards under recent linux-next, I see failures of systemd=
:
>
> [FAILED] Failed to start Flush Journal to Persistent Storage.
> See 'systemctl status systemd-journal-flush.service' for details.
>          Starting Create Volatile Files and Directories...
> [**    ] A start job is running for Create V=E2=80=A6 [  223.209289] nfs:
> server 192.168.1.10 not responding, still trying
> [  223.209377] nfs: server 192.168.1.10 not responding, still trying
>
> Effectively the boards fails to boot. Example is here:
> https://krzk.eu/#/builders/1/builds/2157
>

I too encountered the same issue.

> This was bisected to:
> commit 37ac86c3a76c113619b7d9afe0251bbfc04cb80a
> Author: Chuck Lever <chuck.lever@oracle.com>
> Date:   Fri May 4 15:34:53 2018 -0400
>
>     SUNRPC: Initialize rpc_rqst outside of xprt->reserve_lock
>
>     alloc_slot is a transport-specific op, but initializing an rpc_rqst
>     is common to all transports. In addition, the only part of initial-
>     izing an rpc_rqst that needs serialization is getting a fresh XID.
>
>     Move rpc_rqst initialization to common code in preparation for
>     adding a transport-specific alloc_slot to xprtrdma.
>
>     Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>     Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
>

Unfortunately, spent time to bisect independently without seeing this
report and got the same culprit.

>
> Bisect log attached. Full configuration:
> 1. exynos_defconfig
> 2. ARMv7, octa-core, Exynos5422 and Exynos4412 (Odroid XU3, U3 and others=
)
> 3. NFSv4 client (from Raspberry Pi)
>

Yes the issue is seen only with NFSv4 client and with latest systemd I thin=
k.
My Ubuntu 16.04(32bit FS) is  boots fine while 18.04 has the above issue.
Passing nfsv3 in kernel command line makes it work again.

> Let me know if you need any more information.
>

Also I was observing this issue with Linus master branch from
the time the above patch was merged until today. The issue
is no longer seen since this morning however I just enabled lockdep
and got these messages.

---->8

DEBUG_LOCKS_WARN_ON(sem->owner !=3D ((struct task_struct *)(1UL << 0)))
WARNING: CPU: 2 PID: 74 at kernel/locking/rwsem.c:217
up_read_non_owner+0x78/0x90
Modules linked in:
CPU: 2 PID: 74 Comm: kworker/2:1 Not tainted 4.17.0-10597-g4c5e8fc62d6a #40
Hardware name: ARM LTD ARM Juno Development Platform/ARM Juno
Development Platform, BIOS EDK II Jun 14 2018
Workqueue: nfsiod rpc_async_release
pstate: 40000005 (nZcv daif -PAN -UAO)
pc : up_read_non_owner+0x78/0x90
lr : up_read_non_owner+0x78/0x90
Call trace:
 up_read_non_owner+0x78/0x90
 nfs_async_unlink_release+0x2c/0x88
 rpc_free_task+0x28/0x48
 rpc_async_release+0x10/0x18
 process_one_work+0x29c/0x7a0
 worker_thread+0x40/0x458
 kthread+0x12c/0x130
 ret_from_fork+0x10/0x18
irq event stamp: 64737
hardirqs last  enabled at (64737): _raw_spin_unlock_irq+0x2c/0x60
hardirqs last disabled at (64736): _raw_spin_lock_irq+0x1c/0x60
softirqs last  enabled at (64728): srcu_invoke_callbacks+0xec/0x1a8
softirqs last disabled at (64724): srcu_invoke_callbacks+0xec/0x1a8


DEBUG_LOCKS_WARN_ON(sem->owner !=3D ((struct task_struct *)(1UL << 0)))
WARNING: CPU: 2 PID: 1517 at kernel/locking/rwsem.c:217
up_read_non_owner+0x78/0x90
Modules linked in:
CPU: 2 PID: 1517 Comm: kworker/2:2 Not tainted
4.17.0-10597-g4c5e8fc62d6a-dirty #42
Hardware name: ARM LTD ARM Juno Development Platform/ARM Juno
Development Platform, BIOS EDK II Jun 14 2018
Workqueue: nfsiod rpc_async_release
pstate: 40000005 (nZcv daif -PAN -UAO)
pc : up_read_non_owner+0x78/0x90
lr : up_read_non_owner+0x78/0x90
Call trace:
 up_read_non_owner+0x78/0x90
 nfs_async_unlink_release+0x2c/0x88
 rpc_free_task+0x28/0x48
 rpc_async_release+0x10/0x18
 process_one_work+0x258/0x400
 worker_thread+0x40/0x448
 kthread+0x11c/0x120
 ret_from_fork+0x10/0x18
irq event stamp: 69059
hardirqs last  enabled at (69059): _raw_spin_unlock_irq+0x2c/0x60
hardirqs last disabled at (69058): _raw_spin_lock_irq+0x1c/0x60
softirqs last  enabled at (68194): css_release_work_fn+0x188/0x1c0
softirqs last disabled at (68192): css_release_work_fn+0x170/0x1c0

Regards,
Sudeep
