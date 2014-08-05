Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga11.intel.com ([192.55.52.93]:18522 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751329AbaHEODN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Aug 2014 10:03:13 -0400
Date: Tue, 5 Aug 2014 22:03:07 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Peter Zijlstra <peterz@infradead.org>, linux-nfs@vger.kernel.org
Cc: Jet Chen <jet.chen@intel.com>, Su Tao <tao.su@intel.com>,
        Yuanhan Liu <yuanhan.liu@intel.com>, LKP <lkp@01.org>,
        linux-kernel@vger.kernel.org
Subject: [nfs] BUG: sleeping function called from invalid context at
 include/linux/wait.h:976
Message-ID: <20140805140307.GB5593@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="H+4ONPRPur6+Ovig"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--H+4ONPRPur6+Ovig
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

Here is an NFS error triggered by this debug check.

git://git.kernel.org/pub/scm/linux/kernel/git/peterz/queue.git sched/wait
commit b87699e5fa31f451987a992b9cbda22d29ebcb46
Author:     Peter Zijlstra <peterz@infradead.org>
AuthorDate: Mon Aug 4 11:12:21 2014 +0200
Commit:     Peter Zijlstra <a.p.zijlstra@chello.nl>
CommitDate: Mon Aug 4 13:29:57 2014 +0200

    wait: Add might_sleep()
    
    Add more might_sleep() checks, suppose someone put a wait_event() like
    thing in a wait loop..
    
    Can't put might_sleep() in ___wait_event() because there's the locked
    primitives which call ___wait_event() with locks held.
    
    Signed-off-by: Peter Zijlstra <peterz@infradead.org>
    Link: http://lkml.kernel.org/n/tip-amr894sd1j012khd3fgyh9m8@git.kernel.org


[   13.363454] BUG: sleeping function called from invalid context at include/linux/wait.h:976
[   13.365679] in_atomic(): 1, irqs_disabled(): 0, pid: 2715, name: dmesg
[   13.367109] CPU: 1 PID: 2715 Comm: dmesg Not tainted 3.16.0-00048-gb87699e #1
[   13.368385] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   13.369544]  0000000000000000 ffff88003e3efad0 ffffffff819c6bad ffff880035e9e480
[   13.371838]  ffff88003e3efae0 ffffffff81106e96 ffff88003e3efb00 ffffffff81306a2e
[   13.373822]  ffff880035e9e480 ffff88001b8a1a40 ffff88003e3efb48 ffffffff8130975a
[   13.376165] Call Trace:
[   13.376890]  [<ffffffff819c6bad>] dump_stack+0x4d/0x66
[   13.377903]  [<ffffffff81106e96>] __might_sleep+0x10a/0x10c
[   13.379247]  [<ffffffff81306a2e>] nfs_page_group_lock+0x4e/0x7b
[   13.380739]  [<ffffffff8130975a>] nfs_lock_and_join_requests+0x83/0x334
[   13.381884]  [<ffffffff81309a9f>] nfs_do_writepage+0x94/0x191
[   13.383078]  [<ffffffff81309baf>] nfs_writepages_callback+0x13/0x25
[   13.384592]  [<ffffffff81309b9c>] ? nfs_do_writepage+0x191/0x191
[   13.385745]  [<ffffffff811963d0>] write_cache_pages+0x281/0x3a9
[   13.386829]  [<ffffffff81309b9c>] ? nfs_do_writepage+0x191/0x191
[   13.388524]  [<ffffffff8130a1fd>] nfs_writepages+0xa9/0x10f
[   13.389903]  [<ffffffff811994e1>] ? release_pages+0x1a2/0x20b
[   13.391087]  [<ffffffff81194835>] ? free_pcppages_bulk+0x298/0x33c
[   13.392198]  [<ffffffff81197c8b>] do_writepages+0x1e/0x2c
[   13.393202]  [<ffffffff8118e3f4>] __filemap_fdatawrite_range+0x55/0x57
[   13.394313]  [<ffffffff8118e4b4>] filemap_write_and_wait_range+0x2a/0x58
[   13.395448]  [<ffffffff812ff101>] nfs_file_fsync+0x4e/0x10c
[   13.396546]  [<ffffffff81211395>] vfs_fsync_range+0x1b/0x23
[   13.397567]  [<ffffffff812113b9>] vfs_fsync+0x1c/0x1e
[   13.398517]  [<ffffffff812ff679>] nfs_file_flush+0x6c/0x6f
[   13.399513]  [<ffffffff811e918b>] filp_close+0x3c/0x72
[   13.400646]  [<ffffffff8120295a>] put_files_struct+0x67/0xb3
[   13.401759]  [<ffffffff81202a43>] exit_files+0x4a/0x4f
[   13.402756]  [<ffffffff810e4073>] do_exit+0x3c9/0x985
[   13.403740]  [<ffffffff8106e605>] ? trace_do_page_fault+0x52/0xb7
[   13.404875]  [<ffffffff810e46a9>] do_group_exit+0x44/0xac
[   13.405878]  [<ffffffff810e4725>] SyS_exit_group+0x14/0x14
[   13.406892]  [<ffffffff819ce6a9>] system_call_fastpath+0x16/0x1b
[   15.733276] BUG: sleeping function called from invalid context at include/linux/wait.h:976
[   15.735154] in_atomic(): 1, irqs_disabled(): 0, pid: 2716, name: cat
[   15.736263] CPU: 1 PID: 2716 Comm: cat Not tainted 3.16.0-00048-gb87699e #1
[   15.737414] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   15.738754]  0000000000000000 ffff88000068b910 ffffffff819c6bad ffff880035e9e080
[   15.746872]  ffff88000068b920 ffffffff81106e96 ffff88000068b940 ffffffff81306a2e
[   15.748694]  ffff880035e9e080 ffff88001b8a1a40 ffff88000068b988 ffffffff8130975a
[   15.750479] Call Trace:
[   15.751164]  [<ffffffff819c6bad>] dump_stack+0x4d/0x66
[   15.752141]  [<ffffffff81106e96>] __might_sleep+0x10a/0x10c
[   15.753148]  [<ffffffff81306a2e>] nfs_page_group_lock+0x4e/0x7b
[   15.754183]  [<ffffffff8130975a>] nfs_lock_and_join_requests+0x83/0x334
[   15.755294]  [<ffffffff81309a9f>] nfs_do_writepage+0x94/0x191
[   15.756335]  [<ffffffff81309baf>] nfs_writepages_callback+0x13/0x25
[   15.757405]  [<ffffffff81309b9c>] ? nfs_do_writepage+0x191/0x191
[   15.758452]  [<ffffffff811963d0>] write_cache_pages+0x281/0x3a9
[   15.759483]  [<ffffffff81309b9c>] ? nfs_do_writepage+0x191/0x191
[   15.760547]  [<ffffffff8130a1fd>] nfs_writepages+0xa9/0x10f
[   15.761541]  [<ffffffff81197c8b>] do_writepages+0x1e/0x2c
[   15.762514]  [<ffffffff8118e3f4>] __filemap_fdatawrite_range+0x55/0x57
[   15.763612]  [<ffffffff8118e4b4>] filemap_write_and_wait_range+0x2a/0x58
[   15.764746]  [<ffffffff812ff101>] nfs_file_fsync+0x4e/0x10c
[   15.765748]  [<ffffffff81211395>] vfs_fsync_range+0x1b/0x23
[   15.766745]  [<ffffffff812113b9>] vfs_fsync+0x1c/0x1e
[   15.767681]  [<ffffffff812ff679>] nfs_file_flush+0x6c/0x6f
[   15.768690]  [<ffffffff811e918b>] filp_close+0x3c/0x72
[   15.769638]  [<ffffffff8120295a>] put_files_struct+0x67/0xb3
[   15.770635]  [<ffffffff81202a43>] exit_files+0x4a/0x4f
[   15.771581]  [<ffffffff810e4073>] do_exit+0x3c9/0x985
[   15.772537]  [<ffffffff819caf04>] ? __schedule+0x4cb/0x734
[   15.773522]  [<ffffffff810e46a9>] do_group_exit+0x44/0xac
[   15.774493]  [<ffffffff810f0c03>] get_signal_to_deliver+0x53b/0x5cb
[   15.775575]  [<ffffffff810392b9>] do_signal+0x49/0x511
[   15.776561]  [<ffffffff81127334>] ? do_syslog+0x141/0x4a8
[   15.777564]  [<ffffffff8124915d>] ? kmsg_read+0x2d/0x54
[   15.778513]  [<ffffffff8123d924>] ? proc_reg_read+0x56/0x69
[   15.779504]  [<ffffffff810397b6>] do_notify_resume+0x35/0x72
[   15.780521]  [<ffffffff819ce908>] int_signal+0x12/0x17

This script may reproduce the error.

----------------------------------------------------------------------------
#!/bin/bash

kernel=$1
initrd=debian-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/initrd/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu Nehalem
	-kernel $kernel
	-initrd $initrd
	-m 1024
	-smp 2
	-net nic,vlan=1,model=e1000
	-net user,vlan=1
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null 
)

append=(
	root=/dev/ram0
	ip=::::vm-vp-1G-5::dhcp
	oops=panic
	earlyprintk=ttyS0,115200
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	panic=10
	softlockup_panic=1
	nmi_watchdog=panic
	load_ramdisk=2
	prompt_ramdisk=0
	console=ttyS0,115200
	console=tty0
	vga=normal
)

"${kvm[@]}" --append "${append[*]}"
----------------------------------------------------------------------------

Thanks,
Fengguang

--H+4ONPRPur6+Ovig
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

_______________________________________________
LKP mailing list
LKP@linux.intel.com

--H+4ONPRPur6+Ovig--
