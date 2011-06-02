Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59834 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752577Ab1FBQ6c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jun 2011 12:58:32 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p52GwWF3014104
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 2 Jun 2011 09:58:32 -0700
Message-ID: <4DE7C137.5060906@candelatech.com>
Date: Thu, 02 Jun 2011 09:58:31 -0700
From: Ben Greear <greearb@candelatech.com>
To: linux-nfs@vger.kernel.org
Subject: possible NFS related deadlock in hacked 2.6.38.7
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This kernel is running some patches to make NFS support multiple
mounts bound to a local IP, though only a single mount
(and 20 readers, 20 writer threads) was used for this test case.

We are doing failover testing with an OpenFiler HA cluster.

We were also doing CIFS and iSCSI traffic concurrently with
the NFS, so it's possible those protocols are the root cause
instead...

We're trying to reproduce this with a kernel supporting lockdep
and other debugging logic, but I'm curious if anyone else
has seen a problem like this.  I believe we saw a similar
lockup on a 2.6.34 (or maybe .36 kernel), but it was several
weeks ago...this doesn't seem to be an easy problem to hit.




nfs: server 192.168.100.19 not responding, still trying
nfs: server 192.168.100.19 not responding, still trying
nfs: server 192.168.100.19 not responding, still trying
INFO: task btserver:20572 blocked for more than 180 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
btserver        D 0000000000000000     0 20572   2020 0x00000000
  ffff8802e5365ca8 0000000000000086 0000000000000001 0000000000000000
  ffff8802e573ac40 ffff8802e5365fd8 ffff8802e573af00 ffff8802e573aef8
  0000000000013280 ffff8802e5365fd8 0000000000013280 0000000000013280
Call Trace:
  [<ffffffff814122b0>] __mutex_lock_common+0x212/0x3bc
  [<ffffffff8141246e>] __mutex_lock_slowpath+0x14/0x16
  [<ffffffff81412549>] mutex_lock+0x27/0x3e
  [<ffffffff810f4f43>] do_last+0xb1/0x2bf
  [<ffffffff810f6d47>] do_filp_open+0x2c1/0x655
  [<ffffffff810da8a9>] ? __bit_spin_unlock.clone.1+0x1d/0x38
  [<ffffffff8103fde4>] ? get_parent_ip+0x11/0x42
  [<ffffffff814163ac>] ? sub_preempt_count+0x92/0xa5
  [<ffffffff81100a10>] ? alloc_fd+0x111/0x123
  [<ffffffff810e91c3>] do_sys_open+0x5b/0xed
  [<ffffffff8100bcaf>] ? math_state_restore+0x49/0x4b
  [<ffffffff810e927e>] sys_open+0x1b/0x1d
  [<ffffffff8100aad2>] system_call_fastpath+0x16/0x1b
INFO: task btserver:20583 blocked for more than 180 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
btserver        D 0000000000000002     0 20583   2020 0x00000000
  ffff8802e50dbca8 0000000000000082 0000000000000001 00000000ffffffff
  ffff880305bfb3a0 ffff8802e50dbfd8 ffff880305bfb660 ffff880305bfb658
  0000000000013280 ffff8802e50dbfd8 0000000000013280 0000000000013280
Call Trace:
  [<ffffffff814122b0>] __mutex_lock_common+0x212/0x3bc
  [<ffffffff8141246e>] __mutex_lock_slowpath+0x14/0x16
  [<ffffffff81412549>] mutex_lock+0x27/0x3e
  [<ffffffff810f4f43>] do_last+0xb1/0x2bf
  [<ffffffff810f6d47>] do_filp_open+0x2c1/0x655
  [<ffffffff8103fde4>] ? get_parent_ip+0x11/0x42
  [<ffffffff814163ac>] ? sub_preempt_count+0x92/0xa5
  [<ffffffff81100a10>] ? alloc_fd+0x111/0x123
  [<ffffffff810e91c3>] do_sys_open+0x5b/0xed
  [<ffffffff8100bcaf>] ? math_state_restore+0x49/0x4b
  [<ffffffff810e927e>] sys_open+0x1b/0x1d
  [<ffffffff8100aad2>] system_call_fastpath+0x16/0x1b
INFO: task btserver:20584 blocked for more than 180 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
btserver        D ffff8802e53ac740     0 20584   2020 0x00000000
  ffff8802e5407ca8 0000000000000086 0000000000000001 0000000000000001
  ffff880305bf8760 ffff8802e5407fd8 ffff880305bf8a20 ffff880305bf8a18
  0000000000013280 ffff8802e5407fd8 0000000000013280 0000000000013280
Call Trace:
  [<ffffffff8103fde4>] ? get_parent_ip+0x11/0x42
  [<ffffffff814122b0>] __mutex_lock_common+0x212/0x3bc
  [<ffffffff8141246e>] __mutex_lock_slowpath+0x14/0x16
  [<ffffffff81412549>] mutex_lock+0x27/0x3e
  [<ffffffff810f4f43>] do_last+0xb1/0x2bf
  [<ffffffff810f6d47>] do_filp_open+0x2c1/0x655
  [<ffffffff810da8a9>] ? __bit_spin_unlock.clone.1+0x1d/0x38
  [<ffffffff8103fde4>] ? get_parent_ip+0x11/0x42
  [<ffffffff814163ac>] ? sub_preempt_count+0x92/0xa5
  [<ffffffff81100a10>] ? alloc_fd+0x111/0x123
  [<ffffffff810e91c3>] do_sys_open+0x5b/0xed
  [<ffffffff8100bcaf>] ? math_state_restore+0x49/0x4b
  [<ffffffff810e927e>] sys_open+0x1b/0x1d
  [<ffffffff8100aad2>] system_call_fastpath+0x16/0x1b
INFO: task btserver:20587 blocked for more than 180 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
btserver        D 0000000000000004     0 20587   2020 0x00000000
  ffff8802e5373ca8 0000000000000086 0000000000000001 0000000000000000
  ffff88030474f600 ffff8802e5373fd8 ffff88030474f8c0 ffff88030474f8b8
  0000000000013280 ffff8802e5373fd8 0000000000013280 0000000000013280
Call Trace:
  [<ffffffff814122b0>] __mutex_lock_common+0x212/0x3bc
  [<ffffffff8141246e>] __mutex_lock_slowpath+0x14/0x16
  [<ffffffff81412549>] mutex_lock+0x27/0x3e
  [<ffffffff810f4f43>] do_last+0xb1/0x2bf
  [<ffffffff810f6d47>] do_filp_open+0x2c1/0x655
  [<ffffffff810da8a9>] ? __bit_spin_unlock.clone.1+0x1d/0x38
  [<ffffffff8103fde4>] ? get_parent_ip+0x11/0x42
  [<ffffffff814163ac>] ? sub_preempt_count+0x92/0xa5
  [<ffffffff81100a10>] ? alloc_fd+0x111/0x123
  [<ffffffff810e91c3>] do_sys_open+0x5b/0xed
  [<ffffffff8100bcaf>] ? math_state_restore+0x49/0x4b
  [<ffffffff810e927e>] sys_open+0x1b/0x1d
  [<ffffffff8100aad2>] system_call_fastpath+0x16/0x1b
INFO: task btserver:23670 blocked for more than 180 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
btserver        D 0000000000000007     0 23670   2020 0x00000000
  ffff8802e2351e38 0000000000000082 ffff8803046bd580 ffff880000000000
  ffff8802e211dfe0 ffff8802e2351fd8 ffff8802e211e2a0 ffff8802e211e298
  0000000000013280 ffff8802e2351fd8 0000000000013280 0000000000013280
Call Trace:
  [<ffffffff814122b0>] __mutex_lock_common+0x212/0x3bc
  [<ffffffff8141246e>] __mutex_lock_slowpath+0x14/0x16
  [<ffffffff81412549>] mutex_lock+0x27/0x3e
  [<ffffffffa01b3311>] nfs_llseek_dir+0x51/0x9e [nfs]
  [<ffffffff810ea249>] vfs_llseek+0x2e/0x30
  [<ffffffff810ea36c>] sys_lseek+0x3e/0x5d
  [<ffffffff8100aad2>] system_call_fastpath+0x16/0x1b
INFO: task btserver:20572 blocked for more than 180 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
btserver        D 0000000000000000     0 20572   2020 0x00000000
  ffff8802e5365ca8 0000000000000086 0000000000000001 0000000000000000
  ffff8802e573ac40 ffff8802e5365fd8 ffff8802e573af00 ffff8802e573aef8
  0000000000013280 ffff8802e5365fd8 0000000000013280 0000000000013280
Call Trace:
  [<ffffffff814122b0>] __mutex_lock_common+0x212/0x3bc
  [<ffffffff8141246e>] __mutex_lock_slowpath+0x14/0x16
  [<ffffffff81412549>] mutex_lock+0x27/0x3e
  [<ffffffff810f4f43>] do_last+0xb1/0x2bf
  [<ffffffff810f6d47>] do_filp_open+0x2c1/0x655
  [<ffffffff810da8a9>] ? __bit_spin_unlock.clone.1+0x1d/0x38
  [<ffffffff8103fde4>] ? get_parent_ip+0x11/0x42
  [<ffffffff814163ac>] ? sub_preempt_count+0x92/0xa5
  [<ffffffff81100a10>] ? alloc_fd+0x111/0x123
  [<ffffffff810e91c3>] do_sys_open+0x5b/0xed
  [<ffffffff8100bcaf>] ? math_state_restore+0x49/0x4b
  [<ffffffff810e927e>] sys_open+0x1b/0x1d
  [<ffffffff8100aad2>] system_call_fastpath+0x16/0x1b
INFO: task btserver:20583 blocked for more than 180 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
btserver        D 0000000000000002     0 20583   2020 0x00000000
  ffff8802e50dbca8 0000000000000082 0000000000000001 00000000ffffffff
  ffff880305bfb3a0 ffff8802e50dbfd8 ffff880305bfb660 ffff880305bfb658
  0000000000013280 ffff8802e50dbfd8 0000000000013280 0000000000013280
Call Trace:
  [<ffffffff814122b0>] __mutex_lock_common+0x212/0x3bc
  [<ffffffff8141246e>] __mutex_lock_slowpath+0x14/0x16
  [<ffffffff81412549>] mutex_lock+0x27/0x3e
  [<ffffffff810f4f43>] do_last+0xb1/0x2bf
  [<ffffffff810f6d47>] do_filp_open+0x2c1/0x655
  [<ffffffff8103fde4>] ? get_parent_ip+0x11/0x42
  [<ffffffff814163ac>] ? sub_preempt_count+0x92/0xa5
  [<ffffffff81100a10>] ? alloc_fd+0x111/0x123
  [<ffffffff810e91c3>] do_sys_open+0x5b/0xed
  [<ffffffff8100bcaf>] ? math_state_restore+0x49/0x4b
  [<ffffffff810e927e>] sys_open+0x1b/0x1d
  [<ffffffff8100aad2>] system_call_fastpath+0x16/0x1b
INFO: task btserver:20584 blocked for more than 180 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
btserver        D ffff8802e53ac740     0 20584   2020 0x00000000
  ffff8802e5407ca8 0000000000000086 0000000000000001 0000000000000001
  ffff880305bf8760 ffff8802e5407fd8 ffff880305bf8a20 ffff880305bf8a18
  0000000000013280 ffff8802e5407fd8 0000000000013280 0000000000013280
Call Trace:
  [<ffffffff8103fde4>] ? get_parent_ip+0x11/0x42
  [<ffffffff814122b0>] __mutex_lock_common+0x212/0x3bc
  [<ffffffff8141246e>] __mutex_lock_slowpath+0x14/0x16
  [<ffffffff81412549>] mutex_lock+0x27/0x3e
  [<ffffffff810f4f43>] do_last+0xb1/0x2bf
  [<ffffffff810f6d47>] do_filp_open+0x2c1/0x655
  [<ffffffff810da8a9>] ? __bit_spin_unlock.clone.1+0x1d/0x38
  [<ffffffff8103fde4>] ? get_parent_ip+0x11/0x42
  [<ffffffff814163ac>] ? sub_preempt_count+0x92/0xa5
  [<ffffffff81100a10>] ? alloc_fd+0x111/0x123
  [<ffffffff810e91c3>] do_sys_open+0x5b/0xed
  [<ffffffff8100bcaf>] ? math_state_restore+0x49/0x4b
  [<ffffffff810e927e>] sys_open+0x1b/0x1d
  [<ffffffff8100aad2>] system_call_fastpath+0x16/0x1b
INFO: task btserver:20587 blocked for more than 180 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
btserver        D 0000000000000004     0 20587   2020 0x00000000
  ffff8802e5373ca8 0000000000000086 0000000000000001 0000000000000000
  ffff88030474f600 ffff8802e5373fd8 ffff88030474f8c0 ffff88030474f8b8
  0000000000013280 ffff8802e5373fd8 0000000000013280 0000000000013280
Call Trace:
  [<ffffffff814122b0>] __mutex_lock_common+0x212/0x3bc
  [<ffffffff8141246e>] __mutex_lock_slowpath+0x14/0x16
  [<ffffffff81412549>] mutex_lock+0x27/0x3e
  [<ffffffff810f4f43>] do_last+0xb1/0x2bf
  [<ffffffff810f6d47>] do_filp_open+0x2c1/0x655
  [<ffffffff810da8a9>] ? __bit_spin_unlock.clone.1+0x1d/0x38
  [<ffffffff8103fde4>] ? get_parent_ip+0x11/0x42
  [<ffffffff814163ac>] ? sub_preempt_count+0x92/0xa5
  [<ffffffff81100a10>] ? alloc_fd+0x111/0x123
  [<ffffffff810e91c3>] do_sys_open+0x5b/0xed
  [<ffffffff8100bcaf>] ? math_state_restore+0x49/0x4b
  [<ffffffff810e927e>] sys_open+0x1b/0x1d
  [<ffffffff8100aad2>] system_call_fastpath+0x16/0x1b
INFO: task btserver:23670 blocked for more than 180 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
btserver        D 0000000000000007     0 23670   2020 0x00000000
  ffff8802e2351e38 0000000000000082 ffff8803046bd580 ffff880000000000
  ffff8802e211dfe0 ffff8802e2351fd8 ffff8802e211e2a0 ffff8802e211e298
  0000000000013280 ffff8802e2351fd8 0000000000013280 0000000000013280
Call Trace:
  [<ffffffff814122b0>] __mutex_lock_common+0x212/0x3bc
  [<ffffffff8141246e>] __mutex_lock_slowpath+0x14/0x16
  [<ffffffff81412549>] mutex_lock+0x27/0x3e
  [<ffffffffa01b3311>] nfs_llseek_dir+0x51/0x9e [nfs]
  [<ffffffff810ea249>] vfs_llseek+0x2e/0x30
  [<ffffffff810ea36c>] sys_lseek+0x3e/0x5d
  [<ffffffff8100aad2>] system_call_fastpath+0x16/0x1b
  connection5:0: detected conn error (1020)
  connection3:0: detected conn error (1020)


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

