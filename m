Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lucidpixels.com ([72.73.18.11]:36085 "EHLO lucidpixels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757663Ab1I3SEY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Sep 2011 14:04:24 -0400
Date: Fri, 30 Sep 2011 14:04:24 -0400 (EDT)
From: Justin Piszcz <jpiszcz@lucidpixels.com>
To: linux-kernel@vger.kernel.org
cc: linux-nfs@vger.kernel.org, Alan Piszcz <ap@solarrain.com>
Subject: 3.1-rc8 kernel bug when mounting nfs server that runs on cygwin
Message-ID: <alpine.DEB.2.02.1109301402260.8036@p34.internal.lan>
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

When I run mount (on my Linux/3.1-rc8 host) against a cygwin server, I get 
the following when copying / or removing files: (note cygwin only supports 
nfsvers=1, or nfsvers=2) I used nfsvers=2.

[30436.475161] Call Trace:
[30436.475170]  [<ffffffff810ce253>] ? iput+0x43/0x220
[30436.475174]  [<ffffffff810ccaa0>] ? find_inode_number+0x30/0x30
[30436.475178]  [<ffffffff810ccaa9>] ? inode_wait+0x9/0x10
[30436.475183]  [<ffffffff8168939f>] ? __wait_on_bit+0x4f/0x80
[30436.475189]  [<ffffffff810d7d96>] ? inode_wait_for_writeback+0xa6/0xd0
[30436.475194]  [<ffffffff8104f650>] ? autoremove_wake_function+0x30/0x30
[30436.475198]  [<ffffffff810d8824>] ? wb_writeback+0xf4/0x1e0
[30436.475202]  [<ffffffff810cce12>] ? get_nr_dirty_inodes+0x52/0x80
[30436.475206]  [<ffffffff810d89ac>] ? wb_check_old_data_flush+0x9c/0xb0
[30436.475210]  [<ffffffff810d8cc0>] ? wb_do_writeback+0xc0/0x160
[30436.475214]  [<ffffffff8168921e>] ? schedule_timeout+0x15e/0x230
[30436.475220]  [<ffffffff81040420>] ? internal_add_timer+0x110/0x110
[30436.475224]  [<ffffffff810d8dca>] ? bdi_writeback_thread+0x6a/0x140
[30436.475228]  [<ffffffff810d8d60>] ? wb_do_writeback+0x160/0x160
[30436.475232]  [<ffffffff8104ec0e>] ? kthread+0x7e/0x90
[30436.475237]  [<ffffffff8168cbb4>] ? kernel_thread_helper+0x4/0x10
[30436.475241]  [<ffffffff8104eb90>] ? kthread_flush_work_fn+0x10/0x10
[30436.475245]  [<ffffffff8168cbb0>] ? gs_change+0xb/0xb
[30606.849865] ------------[ cut here ]------------
[30606.849875] WARNING: at fs/dcache.c:2460 prepend_path+0x149/0x160()
[30606.849877] Hardware name: X8DTH-i/6/iF/6F
[30606.849879] Root dentry has weird name <>
[30606.849883] Pid: 24800, comm: lsof Not tainted 3.1.0-rc8 #1
[30606.849885] Call Trace:
[30606.849890]  [<ffffffff810c9859>] ? prepend_path+0x149/0x160
[30606.849898]  [<ffffffff81034be6>] ? warn_slowpath_common+0x76/0xc0
[30606.849902]  [<ffffffff81034ca5>] ? warn_slowpath_fmt+0x45/0x50
[30606.849906]  [<ffffffff810c9859>] ? prepend_path+0x149/0x160
[30606.849909]  [<ffffffff810c9500>] ? __d_shrink+0x60/0xa0
[30606.849914]  [<ffffffff810cc2e6>] ? d_path+0xb6/0xf0
[30606.849920]  [<ffffffff81104eea>] ? proc_pid_readlink+0x8a/0xe0
[30606.849925]  [<ffffffff810bab47>] ? sys_readlinkat+0x67/0xa0
[30606.849932]  [<ffffffff8168b13b>] ? system_call_fastpath+0x16/0x1b
[30606.849934] ---[ end trace e75d6b5b89c1aa53 ]---
[30606.851245] ------------[ cut here ]------------
[30606.851253] WARNING: at fs/dcache.c:2460 prepend_path+0x149/0x160()
[30606.851259] Hardware name: X8DTH-i/6/iF/6F
[30606.851263] Root dentry has weird name <>
[30606.851269] Pid: 24800, comm: lsof Tainted: G        W   3.1.0-rc8 #1
[30606.851275] Call Trace:
[30606.851281]  [<ffffffff810c9859>] ? prepend_path+0x149/0x160
[30606.851289]  [<ffffffff81034be6>] ? warn_slowpath_common+0x76/0xc0
[30606.851296]  [<ffffffff81034ca5>] ? warn_slowpath_fmt+0x45/0x50
[30606.851303]  [<ffffffff810c9859>] ? prepend_path+0x149/0x160
[30606.851310]  [<ffffffff810c9500>] ? __d_shrink+0x60/0xa0
[30606.851316]  [<ffffffff810cc2e6>] ? d_path+0xb6/0xf0
[30606.851324]  [<ffffffff81104eea>] ? proc_pid_readlink+0x8a/0xe0
[30606.851330]  [<ffffffff810bab47>] ? sys_readlinkat+0x67/0xa0
[30606.851337]  [<ffffffff8168b13b>] ? system_call_fastpath+0x16/0x1b
[30606.851342] ---[ end trace e75d6b5b89c1aa54 ]---
[30606.863948] ------------[ cut here ]------------
[30606.863953] WARNING: at fs/dcache.c:2460 prepend_path+0x149/0x160()
[30606.863955] Hardware name: X8DTH-i/6/iF/6F
[30606.863957] Root dentry has weird name <>
[30606.863960] Pid: 24800, comm: lsof Tainted: G        W   3.1.0-rc8 #1
[30606.863962] Call Trace:
[30606.863966]  [<ffffffff810c9859>] ? prepend_path+0x149/0x160
[30606.863971]  [<ffffffff81034be6>] ? warn_slowpath_common+0x76/0xc0
[30606.863975]  [<ffffffff81034ca5>] ? warn_slowpath_fmt+0x45/0x50
[30606.863979]  [<ffffffff810c9859>] ? prepend_path+0x149/0x160
[30606.863982]  [<ffffffff810c9500>] ? __d_shrink+0x60/0xa0
[30606.863986]  [<ffffffff810cc2e6>] ? d_path+0xb6/0xf0
[30606.863990]  [<ffffffff81104eea>] ? proc_pid_readlink+0x8a/0xe0
[30606.863994]  [<ffffffff810bab47>] ? sys_readlinkat+0x67/0xa0
[30606.863998]  [<ffffffff8168b13b>] ? system_call_fastpath+0x16/0x1b
[30606.864001] ---[ end trace e75d6b5b89c1aa55 ]---
[30606.865326] ------------[ cut here ]------------
[30606.865334] WARNING: at fs/dcache.c:2460 prepend_path+0x149/0x160()
[30606.865339] Hardware name: X8DTH-i/6/iF/6F
[30606.865343] Root dentry has weird name <>
[30606.865348] Pid: 24800, comm: lsof Tainted: G        W   3.1.0-rc8 #1
[30606.865353] Call Trace:
[30606.865360]  [<ffffffff810c9859>] ? prepend_path+0x149/0x160
[30606.865369]  [<ffffffff81034be6>] ? warn_slowpath_common+0x76/0xc0
[30606.865376]  [<ffffffff81034ca5>] ? warn_slowpath_fmt+0x45/0x50
[30606.865382]  [<ffffffff810c9859>] ? prepend_path+0x149/0x160
[30606.865388]  [<ffffffff810c9500>] ? __d_shrink+0x60/0xa0

Justin.

