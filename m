Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([198.47.19.12]:42610 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932301AbcHKQ0m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Aug 2016 12:26:42 -0400
Subject: Re: Kernel NFS boot failure
To: netdev <netdev@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
References: <674e6841-d2c5-ccae-6633-a699e848e6d2@ti.com>
 <57A1DE28.7020604@arm.com> <c234fc25-ef5b-eecc-450f-34d01410f9de@ti.com>
CC: Vladimir Murzin <vladimir.murzin@arm.com>,
        "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
        Sekhar Nori <nsekhar@ti.com>, open list <linux-kernel@vger.kernel.org>,
        linux-arm <linux-arm-kernel@lists.infradead.org>,
        Neil Brown <neilb@suse.de>
From: Grygorii Strashko <grygorii.strashko@ti.com>
Message-ID: <a094b3c3-0441-4e7f-7e51-f6ee5d6bb2f1@ti.com>
Date: Thu, 11 Aug 2016 19:25:44 +0300
MIME-Version: 1.0
In-Reply-To: <c234fc25-ef5b-eecc-450f-34d01410f9de@ti.com>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/03/2016 06:04 PM, Grygorii Strashko wrote:
> Hi Vladimir,
> 
> On 08/03/2016 03:06 PM, Vladimir Murzin wrote:
>> On 03/08/16 12:41, Grygorii Strashko wrote:
>>> We observe Kernel boot failure while running NFS boot stress test (1000 iterations):
>>> - Linux version 4.7.0 
> 
> I'd like to pay your attention that this issue also reproducible with
> Kernel 4.7.0!
> The same can be seen from the log I've provided in first e-mail:
> [    0.000000] Linux version 4.7.0 (lcpdbld@dflsdit-build06.dal.design.ti.com) (gcc version 4.9.3 20150413 (prerelease) (Linaro GCC 4.9-2015.05) ) #1 SMP Fri Jul 29 17:41:27 CDT 2016
> 
> 
> I've not run the test with current master at it's not been tagged yet.

Still in progress. rc1 unstable on my platforms due to other issues :(

> 
>>> - am335x-evm (TI AM335x EVM)
>>> - failure rate 10-20 times per test.
>>> Originally this issue was reproduced using TI Kernel 4.4
>>> ( git://git.ti.com/ti-linux-kernel/ti-linux-kernel.git, branch: ti-linux-4.4.y)
>>> on both am335x-evm and am57xx-beagle-x15(am57xx-evm) platforms.
>>> This issues has not been reproduced with TI Kernel 4.1 before.
>>>
>>> The SysRq shows that system stuck in nfs_fs_mount()
>>>
>>> [  207.904632] [<c07ab34c>] (schedule) from [<c0783554>] (rpc_wait_bit_killable+0x2c/0xd8)
>>> [  207.912996] [<c0783554>] (rpc_wait_bit_killable) from [<c07ab7f0>] (__wait_on_bit+0x84/0xc0)
>>> [  207.921812] [<c07ab7f0>] (__wait_on_bit) from [<c07ab890>] (out_of_line_wait_on_bit+0x64/0x70)
>>> [  207.930810] [<c07ab890>] (out_of_line_wait_on_bit) from [<c07843f4>] (__rpc_execute+0x18c/0x544)
>>> [  207.939988] [<c07843f4>] (__rpc_execute) from [<c0779f24>] (rpc_run_task+0x13c/0x158)
>>> [  207.948166] [<c0779f24>] (rpc_run_task) from [<c0779f84>] (rpc_call_sync+0x44/0xc4)
>>> [  207.956163] [<c0779f84>] (rpc_call_sync) from [<c077a04c>] (rpc_ping+0x48/0x68)
>>> [  207.963796] [<c077a04c>] (rpc_ping) from [<c077a158>] (rpc_create_xprt+0xec/0x164)
>>> [  207.971702] [<c077a158>] (rpc_create_xprt) from [<c077a2c0>] (rpc_create+0xf0/0x1a0)
>>> [  207.979794] [<c077a2c0>] (rpc_create) from [<c0393088>] (nfs_create_rpc_client+0xd4/0xec)
>>> [  207.988338] [<c0393088>] (nfs_create_rpc_client) from [<c0394d10>] (nfs_init_client+0x20/0x78)
>>> [  207.997332] [<c0394d10>] (nfs_init_client) from [<c03949d4>] (nfs_create_server+0xa0/0x3bc)
>>> [  208.006057] [<c03949d4>] (nfs_create_server) from [<c03b197c>] (nfs3_create_server+0x8/0x20)
>>> [  208.014879] [<c03b197c>] (nfs3_create_server) from [<c03a34c4>] (nfs_try_mount+0xc4/0x1f0)
>>> [  208.023513] [<c03a34c4>] (nfs_try_mount) from [<c03a2c48>] (nfs_fs_mount+0x290/0x910)
>>> [  208.031702] [<c03a2c48>] (nfs_fs_mount) from [<c0294d24>] (mount_fs+0x44/0x168)
>>>
>>> Has anyone else seen this issue?
>>>
>>> I'd be appreciated for any help or advice related to this issue?
>>
>> I did not look at details, but because it is 4.4 and __wait_on_bit
>> showed up you might want to look at [1]
>>
>> [1] https://lkml.org/lkml/2015/11/20/472
> 
> Thanks. I'll take a look.
> 

I've checked this thread and all three commits mentioned there are present in K4.4
>=3.17
commit 743162013d40  sched: Remove proliferation of wait_on_bit() action functions
>=4.4
commit 68985633bccb  sched/wait: Fix signal handling in bit wait helpers
>=4.4
commit dfd01f026058  sched/wait: Fix the signal handling fix


Also, It seems first patch, probably, has copy-past error.
I'm not sure and it may be that patch is correct :)
Any way, It doesn't help with this issue if I use wait_on_bit_lock_io in nfs_page_group_lock().

743162013d40 ("sched: Remove proliferation of wait_on_bit() action functions")
-- does:

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index b6ee3a6..6104d35 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -138,12 +138,6 @@ nfs_iocounter_wait(struct nfs_io_counter *c)
        return __nfs_iocounter_wait(c);
 }
 
-static int nfs_wait_bit_uninterruptible(void *word)
-{
-       io_schedule();
-       return 0;
-}
-
 /*
  * nfs_page_group_lock - lock the head of the page group
  * @req - request in group that is to be locked
@@ -158,7 +152,6 @@ nfs_page_group_lock(struct nfs_page *req)
        WARN_ON_ONCE(head != head->wb_head);
 
        wait_on_bit_lock(&head->wb_flags, PG_HEADLOCK,
-                       nfs_wait_bit_uninterruptible,

[GS] But it seems should be wait_on_bit_lock_io() <----

                        TASK_UNINTERRUPTIBLE);
 }
 
@@ -425,9 +418,8 @@ void nfs_release_request(struct nfs_page *req)
 int
 nfs_wait_on_request(struct nfs_page *req)
 {
-       return wait_on_bit(&req->wb_flags, PG_BUSY,
-                       nfs_wait_bit_uninterruptible,
-                       TASK_UNINTERRUPTIBLE);
+       return wait_on_bit_io(&req->wb_flags, PG_BUSY,
+                             TASK_UNINTERRUPTIBLE);
 }




-- 
regards,
-grygorii
