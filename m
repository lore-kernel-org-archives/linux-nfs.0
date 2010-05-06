From: Timo Aaltonen <timo.aaltonen-uOixanVlb7U@public.gmane.org>
Subject: Re: session hangs with 2.6.33rc7 & nfs-utils 1.2.2rc9
Date: Thu, 6 May 2010 18:40:33 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1005061730460.3282@deckard.hut.fi>
References: <alpine.DEB.2.00.1002111604420.18032@kosh.hut.fi> <1265897747.478.1.camel@localhost> <alpine.DEB.2.00.1002111616470.18032@kosh.hut.fi> <1265898673.478.3.camel@localhost> <20100211102322.1581a385@barsoom.rdu.redhat.com> <alpine.DEB.2.00.1002112017550.18032@kosh.hut.fi>
 <alpine.DEB.2.00.1002112114190.18032@kosh.hut.fi> <20100211152822.622dcc70@barsoom.rdu.redhat.com> <alpine.DEB.2.00.1002121410090.18032@kosh.hut.fi> <alpine.DEB.2.00.1002121615290.18032@kosh.hut.fi> <20100212143249.GA17928@fieldses.org>
 <alpine.DEB.2.00.1002121705390.18032@kosh.hut.fi> <20100212111343.101fd0ce@tlielax.poochiereds.net> <1265998794.2832.23.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: Jeff Layton <jlayton@redhat.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-3.hut.fi ([130.233.228.93]:38417 "EHLO smtp-3.hut.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758977Ab0EFPlI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 May 2010 11:41:08 -0400
In-Reply-To: <1265998794.2832.23.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Reviving the old thread, since it's still happening. Maybe I should file a 
proper bug about this?

On Fri, 12 Feb 2010, Trond Myklebust wrote:

> On Fri, 2010-02-12 at 11:13 -0500, Jeff Layton wrote:
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513] 130.233.227.1 D 00000000ffffffff     0 29902      2 0x00000080
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  ffff8800c158dc50 0000000000000046 0000000000015ac0 0000000000015ac0
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  ffff880116251ab0 ffff8800c158dfd8 0000000000015ac0 ffff8801162516f0
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  0000000000015ac0 ffff8800c158dfd8 0000000000015ac0 ffff880116251ab0
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513] Call Trace:
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffffa09fec20>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffffa09fec44>] rpc_wait_bit_killable+0x24/0x40 [sunrpc]
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffff8155f05f>] __wait_on_bit+0x5f/0x90
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffffa09fec20>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffff8155f108>] out_of_line_wait_on_bit+0x78/0x90
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffff81083640>] ? wake_bit_function+0x0/0x40
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffffa09ff555>] __rpc_execute+0x105/0x220 [sunrpc]
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffffa09ff696>] rpc_execute+0x26/0x30 [sunrpc]
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffffa09f7b8a>] rpc_run_task+0x3a/0x90 [sunrpc]
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffffa09f7ce2>] rpc_call_sync+0x42/0x70 [sunrpc]
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffff81055080>] ? finish_task_switch+0x50/0xd0
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffffa0baa0ed>] nfs4_proc_renew+0x4d/0xa0 [nfs]
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffffa0bb61fc>] nfs4_check_lease+0x8c/0xc0 [nfs]
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffffa0bb6fa0>] ? nfs4_run_state_manager+0x0/0x40 [nfs]
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffffa0bb6e98>] nfs4_state_manager+0xf8/0x200 [nfs]
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffff810672ed>] ? allow_signal+0x9d/0xb0
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffffa0bb6fc3>] nfs4_run_state_manager+0x23/0x40 [nfs]
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffff81083286>] kthread+0x96/0xa0
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffff8101422a>] child_rip+0xa/0x20
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffff810831f0>] ? kthread+0x0/0xa0
>> Feb 12 16:11:38 nexus6 kernel: [10629.733513]  [<ffffffff81014220>] ? child_rip+0x0/0x20
>>
>> Here, the mount appears to be attempting to renew the state.
>>
>> <wild ass speculation>
>> Another thread (not shown in the sysrq-t) is attempting to do writeback
>> (maybe the bdev flush thread?) and that's in turn blocked by the state
>> recovery code?
>> </wild ass speculation>
>>
>> Looking back over the capture that you sent originally, I see that the
>> client is attempting a WRITE, getting a NFS4ERR_BAD_STATEID back from
>> the server, issuing a RENEW which succeeds and then reattempting the
>> WRITE.
>>
>> Trond, shouldn't it be trying to recover the state before reissuing the
>> write?
>>
>
> Yes. Both nfs4_read_done() and nfs4_write_done() will call
> nfs4_async_handle_error(), which again should call
> nfs4_state_mark_reclaim_nograce() on the stateid. The state manager
> should then end up recovering that stateid before the write is
> reattempted.
>
> We did previously have an issue if the server were to return
> NFS4ERR_STALE_STATEID, followed by NFS4ERR_OK to our RENEW probe
> (==seriously buggy server), but 2.6.33-rc7 has a fix for that.

The offending app seems to be the new "indicator-applet" on the Ubuntu 
GNOME desktop, so maybe that's why others haven't seen this bug yet? 
Here's the trace from dmesg:

[482400.730245] INFO: task indicator-apple:28782 blocked for more than 120 seconds.
[482400.730247] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[482400.730249] indicator-app D 0000000000000000     0 28782      1 0x00000080
[482400.730253]  ffff880010579ac8 0000000000000082 0000000000015bc0 0000000000015bc0
[482400.730257]  ffff880109bb1ab0 ffff880010579fd8 0000000000015bc0 ffff880109bb16f0
[482400.730261]  0000000000015bc0 ffff880010579fd8 0000000000015bc0 ffff880109bb1ab0
[482400.730265] Call Trace:
[482400.730275]  [<ffffffffa0b6b2b0>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
[482400.730279]  [<ffffffff8153eb57>] io_schedule+0x47/0x70
[482400.730288]  [<ffffffffa0b6b2be>] nfs_wait_bit_uninterruptible+0xe/0x20 [nfs]
[482400.730292]  [<ffffffff8153f3af>] __wait_on_bit+0x5f/0x90
[482400.730302]  [<ffffffffa0b6b2b0>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
[482400.730305]  [<ffffffff8153f458>] out_of_line_wait_on_bit+0x78/0x90
[482400.730309]  [<ffffffff81085360>] ? wake_bit_function+0x0/0x40
[482400.730318]  [<ffffffffa0b6b29f>] nfs_wait_on_request+0x2f/0x40 [nfs]
[482400.730329]  [<ffffffffa0b6f6af>] nfs_wait_on_requests_locked+0x7f/0xd0 [nfs]
[482400.730340]  [<ffffffffa0b70aee>] nfs_sync_mapping_wait+0x9e/0x1a0 [nfs]
[482400.730350]  [<ffffffffa0b70ed9>] nfs_write_mapping+0x79/0xb0 [nfs]
[482400.730361]  [<ffffffffa0b70f47>] nfs_wb_all+0x17/0x20 [nfs]
[482400.730369]  [<ffffffffa0b5feba>] nfs_do_fsync+0x2a/0x60 [nfs]
[482400.730378]  [<ffffffffa0b608b6>] nfs_file_write+0x106/0x1e0 [nfs]
[482400.730381]  [<ffffffff8114270a>] do_sync_write+0xfa/0x140
[482400.730385]  [<ffffffff81085320>] ? autoremove_wake_function+0x0/0x40
[482400.730389]  [<ffffffff81250b96>] ? security_file_permission+0x16/0x20
[482400.730392]  [<ffffffff81142a08>] vfs_write+0xb8/0x1a0
[482400.730396]  [<ffffffff810c03e2>] ? audit_syscall_entry+0x242/0x270
[482400.730399]  [<ffffffff811432a1>] sys_write+0x51/0x80
[482400.730403]  [<ffffffff810131b2>] system_call_fastpath+0x16/0x1b

I haven't tried the 2.6.34-series yet..

-- 
Timo Aaltonen
Systems Specialist
IT Services, Aalto University
