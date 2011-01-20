Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:52996 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755760Ab1ATPTz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Jan 2011 10:19:55 -0500
Subject: Re: [PATCH] nfs: don't drop kiocb->ki_users in error case
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110120004650.GA2790@laptop.jp.oracle.com>
Date: Thu, 20 Jan 2011 10:19:15 -0500
Cc: Nick Piggin <npiggin@gmail.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>, joe.jin@oracle.com,
        greg.marsden@oracle.com
Message-Id: <2C2F5A73-95ED-4691-AFD7-D56EA9204666@oracle.com>
References: <D9095AA4-D555-4961-8344-8FBBCE0C670F@oracle.com> <20110120004650.GA2790@laptop.jp.oracle.com>
To: Wengang Wang <wen.gang.wang@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jan 19, 2011, at 7:46 PM, Wengang Wang wrote:

> On 11-01-19 11:09, Chuck Lever wrote:
>> 
>> On Jan 19, 2011, at 7:53 AM, Wengang Wang wrote:
>> 
>>> I got the crash when test with fio + (ctrl-C). The panic info is like this:
>>> 
>>> ------------[ cut here ]------------
>>> kernel BUG at fs/aio.c:558!
>>> invalid opcode: 0000 [#1] SMP
>>> last sysfs file: /sys/devices/system/cpu/cpu0/cache/index0/coherency_line_size
>>> CPU 0
>>> Modules linked in: netconsole(U) configfs(U) hidp(U) l2cap(U) bluetooth(U) rfkill(U) ipv6(U) nfs(U) lockd(U) fscache(U) nfs_acl(U) auth_rpcgss(U) sunrpc(U) cpufreq_ondemand(U) acpi_cpufreq(U) freq_table(U) dm_multipath(U) sbs(U) sbshc(U) lp(U) snd_hda_codec_analog(U) snd_hda_intel(U) snd_hda_codec(U) snd_hwdep(U) snd_seq_dummy(U) snd_seq_oss(U) i915(U) snd_seq_midi_event(U) snd_seq(U) snd_seq_device(U) snd_pcm_oss(U) drm_kms_helper(U) snd_mixer_oss(U) drm(U) tg3(U) snd_pcm(U) snd_timer(U) snd(U) parport_pc(U) i2c_algo_bit(U) i2c_i801(U) serio_raw(U) parport(U) iTCO_wdt(U) shpchp(U) soundcore(U) video(U) i2c_core(U) dcdbas(U) iTCO_vendor_support(U) snd_page_alloc(U) pcspkr(U) output(U) pata_acpi(U) ata_piix(U) ata_generic(U) uhci_hcd(U) ohci_hcd(U) ehci_hcd(U) [last unloaded: netconsole]
>>> Pid: 3112, comm: fio Tainted: G        W  2.6.32.21 #3 OptiPlex 745
>>> RIP: 0010:[<ffffffff8114eb30>]  [<ffffffff8114eb30>] __aio_put_req+0x6e/0x150
>>> RSP: 0018:ffff88006cd7be38  EFLAGS: 00010092
>>> RAX: 0000000000000038 RBX: ffff880078f2b9c0 RCX: 0000000000007da3
>>> RDX: 0000000000000000 RSI: 0000000000000082 RDI: 0000000000000046
>>> RBP: ffff88006cd7be58 R08: 0000000000000001 R09: 0000000000000020
>>> R10: ffff88006cd7bdb8 R11: 0000000000000001 R12: ffff880078f2b9c0
>>> R13: ffff880037ef3e40 R14: ffff880037ef3e40 R15: 0000000000000000
>>> FS:  0000000042eb4940(0063) GS:ffff880001c00000(0000) knlGS:0000000000000000
>>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>> CR2: 00007fa172484000 CR3: 000000006ce48000 CR4: 00000000000006f0
>>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>>> Process fio (pid: 3112, threadinfo ffff88006cd7a000, task ffff88007a7de040)
>>> Stack:
>>> ffff880037ef3e40 ffff880037ef3e40 ffff880078f2b9c0 ffff88006cd7bf40
>>> <0> ffff88006cd7be88 ffffffff8114ec3d ffff88006bc11ed0 ffff880078f2b9c0
>>> <0> ffff88006bc11ed0 ffff880078f2b9c0 ffff88006cd7bf78 ffffffff81150a15
>>> Call Trace:
>>> [<ffffffff8114ec3d>] aio_put_req+0x2b/0x43
>>> [<ffffffff81150a15>] sys_io_submit+0x56a/0x6f1
>>> [<ffffffff81011db2>] system_call_fastpath+0x16/0x1b
>>> Code: 7f 45 81 e8 a9 8d f0 ff e8 32 6d ec ff 83 7b 18 00 7d 1c 48 89 da 48 c7 c6 58 7f 45 81 48 c7 c7 d4 b1 5d 81 31 c0 e8 86 8d f0 ff <0f> 0b eb fe 74 07 31 c0 e9 cd 00 00 00 4c 8d a3 d8 00 00 00 48
>>> RIP  [<ffffffff8114eb30>] __aio_put_req+0x6e/0x150
>>> RSP <ffff88006cd7be38>
>>> ---[ end trace 52431c8b3d9e71ba ]---
>>> Kernel panic - not syncing: Fatal exception
>>> 
>>> The number 558 should be 552 in original codes. It is the
>>> 	BUG_ON(req->ki_users < 0);
>>> in __aio_put_req().
>>> 
>>> My analysis is(correct me):
>>> In the sys_io_submit path, the vfs doesn't hope the FS under ground drop the
>>> ki_users in "error" case. The error is -ERESTARTSYS, in my test, instead of
>>> -EIOCBQUEUED. But seems the nfs drops ki_users in error case as well as
>>> in successful cases too.
>>> 
>>> So my first attempt is coming for discussion.
>>> Basically, it makes nfs don't drop(actually it gets then puts) ki_users in error
>>> cases.
>>> Let the nfs_direct_req.error records the error from get_user_pages() and
>>> rpc_run_task() in nfs_direct_read/write path, assuming both the two function
>>> returns all error they hit.
>> 
>> Yes, get_user_pages() is invoked in both the read and write path, and returns -ERESTARTSYS when a signal is pending.  It can return other errors as well, but -ERESTARTSYS seems to be by far the common case.
>> 
>>> And in nfs_direct_complete(), if error occured(per
>>> nfs_direct_req.error), take another ref on kiocb->ki_users. (and then drop it in
>>> aio_complete in existing codes).
>> 
>> Reporting error codes via dreq.error is probably a good change for async I/O.
>> 
>> The open-coded equivalent of "aio get iocb" is probably not what we want, however.  By my reading of this logic, nfs_direct_write_schedule_iovec() returns a non-zero value in this case, so nfs_direct_complete() is skipped altogether.  I think your new code would never be executed.
> 
> Yes, it's the tricky place. :)
> Actually the nfs_direct_complete() is alled in
> nfs_direct_read/write_schedule_iovec() like:
> 
>        if (put_dreq(dreq))
>                nfs_direct_complete(dreq);
> 
> It does not depend on any return value. And yes, it's here, in error case, it's
> last ref on ki_users.
> 
> I have tested the fix with a dump_stack() showing that it really take place. The
> stack is like:
> 
> Call Trace:
> [<c0505dff>] ? __aio_put_req+0x47/0x12a
> [<c0506c1d>] ? aio_complete+0x148/0x181
> [<f93efb25>] ? nfs_direct_complete+0x23/0x3a [nfs]
> [<f93efe81>] ? nfs_direct_write_complete+0x345/0x34d [nfs]
> [<c04a986f>] ? mempool_free_slab+0x13/0x15
> [<c04a986f>] ? mempool_free_slab+0x13/0x15
> [<c04a98ed>] ? mempool_free+0x67/0x6e
> [<f93f0530>] ? nfs_file_direct_write+0x529/0x58d [nfs]
> [<f93e907d>] ? nfs_file_write+0x4d/0x145 [nfs]
> [<c0505bf1>] ? aio_rw_vect_retry+0x72/0x127
> [<f93e9030>] ? nfs_file_write+0x0/0x145 [nfs]
> [<c0506cd0>] ? aio_run_iocb+0x7a/0x15c
> [<c04400b0>] ? try_acquire_console_sem+0x12/0x4b
> [<c0505b7f>] ? aio_rw_vect_retry+0x0/0x127
> [<c042d55d>] ? kmap_atomic_prot+0x132/0x152
> [<c042d3d7>] ? __kunmap_atomic+0x8e/0xc7
> [<c042d55d>] ? kmap_atomic_prot+0x132/0x152
> [<c077a1d5>] ? printk+0x14/0x17
> [<c050768f>] ? do_io_submit+0x44c/0x5e1
> [<c050783c>] ? sys_io_submit+0x18/0x1a
> [<c077c335>] ? syscall_call+0x7/0xb
> 
> And also I have a printk just before increasing the ki_users by 1, and
> that shows.

My mistake, I conflated nfs_direct_wait() and nfs_direct_complete().  ENOCOFFEE

>> 
>> Currently I agree with Nick: nfs_file_direct_{read,write}() are returning the wrong error codes for asynchronous I/O.  Thus the generic aio logic will try to complete a second time NFS I/O that has already failed.
> 
> -ERESTARTSYS could be a wrong error codes? For my test case, I kicked
> ctrl+c, I think -ERESTARTSYS is the correct error number. correct me?

Yes, get_user_pages() returns -ERESTARTSYS after a ^C, when it detects a pending signal.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




