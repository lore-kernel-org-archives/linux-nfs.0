Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp10.mail.sp.isp-net.nl ([217.149.192.65]:41009 "EHLO
	smtp10.mail.sp.isp-net.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251Ab2E1WaD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 18:30:03 -0400
Received: from [10.10.0.12] by smtp10.mail.sp.isp-net.nl
	via 152-124-254-92.ftth.xms.internl.net [92.254.124.152] with ESMTP for <linux-nfs@vger.kernel.org>
	id q4SMJYG8011176 (8.13.2/2.04); Tue, 29 May 2012 00:19:34 +0200 (MEST)
Message-ID: <4FC3F9F6.7010107@xmsnet.nl>
Date: Tue, 29 May 2012 00:19:34 +0200
From: Hans de Bruin <jmdebruin@xmsnet.nl>
MIME-Version: 1.0
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: nfsroot client will not start firefox or thunderbird from 3.4.0 nfsserver
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I just upgraded my home server from kernel 3.3.5 to 3.4.0 and ran into 
some trouble. My laptop, a nfsroot client, will not run firefox and 
thunderbird anymore. When I start these programs from an xterm, the 
cursor goes to the next line and waits indefinitely.

I do not know if there is any order is lsof's output. A lsof | grep 
firefox or thunderbird shows ......./.parentlock as the last line.

It does not matter whether the client is running a 3.4.0 or a 3.3.0 
kernel, or if the server is running on top of xen or not.

There is some noise in the servers dmesg:

[  241.256684] INFO: task kworker/u:2:801 blocked for more than 120 seconds.
[  241.256691] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[  241.256698] kworker/u:2     D 000000000000000c     0   801      2 
0x00000000
[  241.256710]  ffff8801390e5cf0 0000000000000046 0000000000012d00 
0000000000012d00
[  241.256721]  0000000000012d00 ffff880139f8bd50 0000000000012d00 
ffff8801390e5fd8
[  241.256732]  ffff8801390e5fd8 0000000000012d00 ffff880139ce4420 
ffff880139f8bd50
[  241.256743] Call Trace:
[  241.256759]  [<ffffffff8158733e>] schedule+0x64/0x66
[  241.256769]  [<ffffffff8120184e>] cld_pipe_upcall+0x95/0xd1
[  241.256780]  [<ffffffff811fbd8d>] ? nfsd4_exchange_id+0x23e/0x23e
[  241.256789]  [<ffffffff81201d06>] nfsd4_cld_grace_done+0x50/0x8a
[  241.256798]  [<ffffffff81202233>] nfsd4_record_grace_done+0x18/0x1a
[  241.256807]  [<ffffffff811fbdd7>] laundromat_main+0x4a/0x213
[  241.256818]  [<ffffffff8106a06b>] ? need_resched+0x1e/0x28
[  241.256826]  [<ffffffff8158725d>] ? __schedule+0x49d/0x4b5
[  241.256835]  [<ffffffff811fbd8d>] ? nfsd4_exchange_id+0x23e/0x23e
[  241.256844]  [<ffffffff8105be2d>] process_one_work+0x190/0x28d
[  241.256854]  [<ffffffff8105ca67>] worker_thread+0x105/0x189
[  241.256862]  [<ffffffff81587b8d>] ? _raw_spin_unlock_irqrestore+0x1a/0x1d
[  241.256872]  [<ffffffff8105c962>] ? manage_workers.clone.17+0x173/0x173
[  241.256881]  [<ffffffff810604b0>] kthread+0x8a/0x92
[  241.256891]  [<ffffffff815899a4>] kernel_thread_helper+0x4/0x10
[  241.256900]  [<ffffffff81060426>] ? 
kthread_freezable_should_stop+0x47/0x47
[  241.256909]  [<ffffffff815899a0>] ? gs_change+0x13/0x13

or xenified:


[  240.563448] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[  240.563458] kworker/u:2     D ffff88007fc12d00     0   808      2 
0x00000000
[  240.563479]  ffff88007532fcf0 0000000000000246 0000000000012d00 
0000000000012d00
[  240.563504]  0000000000012d00 ffff880075f7caf0 0000000000012d00 
ffff88007532ffd8
[  240.563530]  ffff88007532ffd8 0000000000012d00 ffffffff81813020 
ffff880075f7caf0
[  240.563555] Call Trace:
[  240.563578]  [<ffffffff8158733e>] schedule+0x64/0x66
[  240.563594]  [<ffffffff8120184e>] cld_pipe_upcall+0x95/0xd1
[  240.563611]  [<ffffffff811fbd8d>] ? nfsd4_exchange_id+0x23e/0x23e
[  240.563625]  [<ffffffff81201d06>] nfsd4_cld_grace_done+0x50/0x8a
[  240.563640]  [<ffffffff81202233>] nfsd4_record_grace_done+0x18/0x1a
[  240.563654]  [<ffffffff811fbdd7>] laundromat_main+0x4a/0x213
[  240.563670]  [<ffffffff8100d085>] ? xen_spin_unlock+0x12/0x30
[  240.563685]  [<ffffffff811fbd8d>] ? nfsd4_exchange_id+0x23e/0x23e
[  240.563700]  [<ffffffff8105be2d>] process_one_work+0x190/0x28d
[  240.563714]  [<ffffffff8100d337>] ? xen_spin_lock+0xb/0xd
[  240.563729]  [<ffffffff8105ca67>] worker_thread+0x105/0x189
[  240.563743]  [<ffffffff81587b8d>] ? _raw_spin_unlock_irqrestore+0x1a/0x1d
[  240.563758]  [<ffffffff8105c962>] ? manage_workers.clone.17+0x173/0x173
[  240.563772]  [<ffffffff810604b0>] kthread+0x8a/0x92
[  240.563787]  [<ffffffff815899a4>] kernel_thread_helper+0x4/0x10
[  240.563802]  [<ffffffff81587f38>] ? retint_restore_args+0x5/0x6
[  240.563816]  [<ffffffff815899a0>] ? gs_change+0x13/0x13


-- 
Hans

