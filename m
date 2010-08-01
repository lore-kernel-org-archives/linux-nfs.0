From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 	0000000000000020
Date: Sun, 01 Aug 2010 21:18:03 +0300
Message-ID: <4C55BA5B.7060305@panasas.com>
References: <AANLkTikYDGpeX8kcK3ygFzjM+bYMFTtqr8Wgx+CygUt8@mail.gmail.com>	<4C5105F8.5050101@cn.fujitsu.com>	<1280514531.12852.23.camel@heimdal.trondhjem.org> <AANLkTi=nA8FCQrOB09uqCfFyduSATgzg-Q2GyZk-D+GP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Bian Naimeng <biannm@cn.fujitsu.com>, linux-nfs@vger.kernel.org
To: yo mama <mamamia69@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43696 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750829Ab0HASSI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Aug 2010 14:18:08 -0400
In-Reply-To: <AANLkTi=nA8FCQrOB09uqCfFyduSATgzg-Q2GyZk-D+GP-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pnfs4_layout_reclaim was removed from pnfs-all-latest.
Can you please sync with the latest tree and retry your test?

Thanks for reporting and helping to resolve this issue!

Benny

On Jul. 31, 2010, 7:56 +0300, yo mama <mamamia69@gmail.com> wrote:
> Just an update, kernel crash occurs even when running iozone in
> automode, please see the updated /var/log/messages
> 
> 
> Jul 30 21:26:21 localhost kernel: FS-Cache: Loaded
> Jul 30 21:26:22 localhost kernel: FS-Cache: Netfs 'nfs' registered for caching
> Jul 30 21:29:22 localhost kernel: nfs: server 192.168.100.12 not responding, ti
> med out
> Jul 30 21:29:22 localhost kernel: Error: state manager failed on NFSv4 server 1
> 92.168.100.12 with error 5
> Jul 30 21:37:38 localhost kernel: nfs4filelayout_init: NFSv4 File Layout Driver
>  Registering...
> Jul 30 21:39:29 localhost kernel: BUG: unable to handle kernel NULL pointer der
> eference at 0000000000000030
> Jul 30 21:39:29 localhost kernel: IP: [<ffffffff814411d4>] _raw_spin_lock+0xe/0
> x25
> Jul 30 21:39:29 localhost kernel: PGD 0
> Jul 30 21:39:29 localhost kernel: Oops: 0002 [#1] SMP
> Jul 30 21:39:29 localhost kernel: last sysfs file: /sys/devices/pci0000:00/0000
> :00:19.0/irq
> Jul 30 21:39:29 localhost kernel: CPU 3
> Jul 30 21:39:29 localhost kernel: Modules linked in: nfslayoutdriver nfs lockd
> fscache nfs_acl auth_rpcgss sunrpc ipv6 p4_clockmod freq_table speedstep_lib dm
> _multipath uinput e1000e iTCO_wdt iTCO_vendor_support i2c_i801 pcspkr serio_raw
>  usb_storage i915 drm_kms_helper drm i2c_algo_bit i2c_core video output [last u
> nloaded: mperf]
> Jul 30 21:39:29 localhost kernel:
> Jul 30 21:39:29 localhost kernel: Pid: 1629, comm: 192.168.100.12- Not tainted
> 2.6.35-rc5-pnfs #1 To be filled by O.E.M./To Be Filled By O.E.M.
> Jul 30 21:39:29 localhost kernel: RIP: 0010:[<ffffffff814411d4>]  [<ffffffff814
> 411d4>] _raw_spin_lock+0xe/0x25
> Jul 30 21:39:29 localhost kernel: RSP: 0018:ffff8800700b5cb0  EFLAGS: 00010282
> Jul 30 21:39:29 localhost kernel: RAX: 0000000000010000 RBX: 0000000000000000 R
> CX: 000000000020001d
> Jul 30 21:39:29 localhost kernel: RDX: ffff88007bfc9900 RSI: ffffffffa0225fe0 R
> DI: 0000000000000030
> Jul 30 21:39:29 localhost kernel: RBP: ffff8800700b5cb0 R08: ffff88007c7c1800 R
> 09: ffff880000000001
> Jul 30 21:39:29 localhost kernel: R10: ffff88007bfc9c00 R11: ffff880070b12a00 R
> 12: ffffffffa0225fe0
> Jul 30 21:39:29 localhost kernel: R13: ffff880070bdaf64 R14: ffff88007979f800 R
> 15: ffff8800700b5d60
> Jul 30 21:39:29 localhost kernel: FS:  0000000000000000(0000) GS:ffff8800021800
> 00(0000) knlGS:0000000000000000
> Jul 30 21:39:29 localhost kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005
> 003b
> Jul 30 21:39:29 localhost kernel: CR2: 0000000000000030 CR3: 0000000001a42000 C
> R4: 00000000000006e0
> Jul 30 21:39:29 localhost kernel: DR0: 0000000000000000 DR1: 0000000000000000 D
> R2: 0000000000000000
> Jul 30 21:39:29 localhost kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 D
> R7: 0000000000000400
> Jul 30 21:39:29 localhost kernel: Process 192.168.100.12- (pid: 1629, threadinf
> o ffff8800700b4000, task ffff8800796e1730)
> Jul 30 21:39:29 localhost kernel: Stack:
> Jul 30 21:39:29 localhost kernel: ffff8800700b5cc0 ffffffffa0212c6e ffff8800700
> b5ce0 ffffffffa0214168
> Jul 30 21:39:29 localhost kernel: <0> ffff880070bdaf00 ffff880070bdaf54 ffff880
> 0700b5d00 ffffffffa0201ab1
> Jul 30 21:39:29 localhost kernel: <0> ffff8800700b5d00 ffff880070bdaf00 ffff880
> 0700b5d40 ffffffffa0201b92
> Jul 30 21:39:29 localhost kernel: Call Trace:
> Jul 30 21:39:29 localhost kernel: [<ffffffffa0212c6e>] spin_lock+0xe/0x10 [nfs]
> Jul 30 21:39:29 localhost kernel: [<ffffffffa0214168>] pnfs_set_layout_stateid+
> 0x1b/0x3b [nfs]
> Jul 30 21:39:29 localhost kernel: [<ffffffffa0201ab1>] pnfs4_layout_reclaim+0x3
> 5/0x39 [nfs]
> Jul 30 21:39:29 localhost kernel: [<ffffffffa0201b92>] nfs4_open_recover+0xdd/0
> xf1 [nfs]
> Jul 30 21:39:29 localhost kernel: [<ffffffffa0201d04>] nfs4_open_delegation_rec
> all+0x80/0x13f [nfs]
> Jul 30 21:39:29 localhost kernel: [<ffffffffa020e7e0>] __nfs_inode_return_deleg
> ation+0xc7/0x1f5 [nfs]
> Jul 30 21:39:29 localhost kernel: [<ffffffff810caf61>] ? do_writepages+0x21/0x2
> a
> Jul 30 21:39:29 localhost kernel: [<ffffffffa020e9ff>] nfs_client_return_marked
> _delegations+0x85/0xc6 [nfs]
> Jul 30 21:39:29 localhost kernel: [<ffffffffa020d7da>] nfs4_run_state_manager+0
> x368/0x494 [nfs]
> Jul 30 21:39:29 localhost kernel: [<ffffffffa020d472>] ? nfs4_run_state_manager
> +0x0/0x494 [nfs]
> Jul 30 21:39:29 localhost kernel: [<ffffffff81064bd9>] kthread+0x7f/0x87
> Jul 30 21:39:29 localhost kernel: [<ffffffff8100aa24>] kernel_thread_helper+0x4
> /0x10
> Jul 30 21:39:29 localhost kernel: [<ffffffff81064b5a>] ? kthread+0x0/0x87
> Jul 30 21:39:29 localhost kernel: [<ffffffff8100aa20>] ? kernel_thread_helper+0
> x0/0x10
> Jul 30 21:39:29 localhost kernel: Code: c2 8d 90 00 00 01 00 75 04 f0 0f b1 17
> 0f 94 c2 0f b6 c2 85 c0 c9 0f 95 c0 0f b6 c0 c3 55 48 89 e5 0f 1f 44 00 00 b8 0
> 0 00 01 00 <f0> 0f c1 07 0f b7 d0 c1 e8 10 39 c2 74 07 f3 90 0f b7 17 eb f5
> Jul 30 21:39:29 localhost kernel: RIP  [<ffffffff814411d4>] _raw_spin_lock+0xe/
> 0x25
> 
> 
> On Fri, Jul 30, 2010 at 11:58 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
>> On Thu, 2010-07-29 at 12:39 +0800, Bian Naimeng wrote:
>>>> Hello,
>>>>
>>>> I am running Kernel version 2.6.35-rc5-pnfs and notice there is kernel
>>>> crash everytime i run iozone on the mounted directory. Is there a
>>>> patch already developed for this bug which i can apply. Please see the
>>>> error message from message log.
>>>>
>>>
>>>  I'm not sure it's ok, please try it.
>>>
>>> ----
>>>
>>>  nfs_writeargs.lock_context always NULL at direct write procedure,
>>> it will cause kernel panic when encode stateid.
>>>
>>> Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
>>>
>>> ---
>>>  fs/nfs/direct.c |    1 +
>>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
>>> index 3ef9b0c..cb2e1fd 100644
>>> --- a/fs/nfs/direct.c
>>> +++ b/fs/nfs/direct.c
>>> @@ -801,6 +801,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
>>>               data->cred = msg.rpc_cred;
>>>               data->args.fh = NFS_FH(inode);
>>>               data->args.context = ctx;
>>> +             data->args.lock_context = nfs_get_lock_context(ctx);
>>>               data->args.offset = pos;
>>>               data->args.pgbase = pgbase;
>>>               data->args.pages = data->pagevec;
>>> --
>>> 1.6.5.2
>>>
>>
>> Well caught. There is a similar issue with NFS reads too. I'll fix up
>> the lock state tracking patch...
>>
>> Thanks
>>  Trond
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
