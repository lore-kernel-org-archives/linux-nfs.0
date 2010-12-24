Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12327 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752281Ab0LXPHT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Dec 2010 10:07:19 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id oBOF7J7L009191
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 24 Dec 2010 10:07:19 -0500
Received: from tlielax.poochiereds.net (vpn-8-9.rdu.redhat.com [10.11.8.9])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id oBOF7Iof020028
	for <linux-nfs@vger.kernel.org>; Fri, 24 Dec 2010 10:07:19 -0500
Date: Fri, 24 Dec 2010 10:07:17 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: machine won't suspend with nfs4 mount mounted
Message-ID: <20101224100717.79895965@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I upgraded one of my machines to a very recent fedora rawhide kernel
today (2.6.37-0.rc7.git0.2.fc15.x86_64). When I tried to suspend it, it
failed, and I got this:

[  387.811334] Freezing user space processes ... 
[  407.821049] Freezing of tasks failed after 20.00 seconds (1 tasks refusing to freeze, wq_busy=0):
[  407.821115] umount        D 00000001000150d5     0  8656   8637 0x00800084
[  407.821120]  ffff8801d3657968 0000000000000082 ffff8801d36578d0 ffffffff00000000
[  407.821125]  0000000000013780 0000000000013780 0000000000013780 ffff8801d37bdc80
[  407.821130]  0000000000013780 ffff8801d3657fd8 0000000000013780 0000000000013780
[  407.821134] Call Trace:
[  407.821153]  [<ffffffffa04443db>] ? rpc_wait_bit_killable+0x0/0x38 [sunrpc]
[  407.821163]  [<ffffffffa044440f>] rpc_wait_bit_killable+0x34/0x38 [sunrpc]
[  407.821168]  [<ffffffff8147672a>] __wait_on_bit+0x48/0x7b
[  407.821173]  [<ffffffff810564d4>] ? _local_bh_enable_ip.clone.6+0x25/0x8e
[  407.821177]  [<ffffffff814767cb>] out_of_line_wait_on_bit+0x6e/0x79
[  407.821186]  [<ffffffffa04443db>] ? rpc_wait_bit_killable+0x0/0x38 [sunrpc]
[  407.821191]  [<ffffffff8106ad90>] ? wake_bit_function+0x0/0x31
[  407.821194]  [<ffffffff810564d4>] ? _local_bh_enable_ip.clone.6+0x25/0x8e
[  407.821203]  [<ffffffffa0445017>] __rpc_execute+0xff/0x1e1 [sunrpc]
[  407.821212]  [<ffffffffa0445169>] rpc_execute+0x42/0x46 [sunrpc]
[  407.821219]  [<ffffffffa043efc7>] rpc_run_task+0xed/0xf8 [sunrpc]
[  407.821226]  [<ffffffffa043f0bc>] rpc_call_sync+0x42/0x63 [sunrpc]
[  407.821245]  [<ffffffffa051caab>] _nfs4_call_sync+0x22/0x24 [nfs]
[  407.821258]  [<ffffffffa051c29f>] _nfs4_proc_access+0x104/0x161 [nfs]
[  407.821272]  [<ffffffffa051de6a>] nfs4_proc_access+0x34/0x60 [nfs]
[  407.821280]  [<ffffffffa05049ab>] nfs_do_access+0x15f/0x3a6 [nfs]
[  407.821289]  [<ffffffffa0446961>] ? generic_lookup_cred+0x15/0x17 [sunrpc]
[  407.821299]  [<ffffffffa0445f21>] ? rpcauth_lookupcred+0x93/0xb0 [sunrpc]
[  407.821307]  [<ffffffffa0504cc1>] nfs_permission+0xcf/0x16b [nfs]
[  407.821312]  [<ffffffff81128bd4>] exec_permission+0x26/0x78
[  407.821316]  [<ffffffff81129fc0>] link_path_walk+0x70/0x490
[  407.821319]  [<ffffffff8112a4d1>] path_walk+0x4f/0x9f
[  407.821322]  [<ffffffff81129a66>] ? path_init+0x88/0x14d
[  407.821326]  [<ffffffff8112a5fa>] do_path_lookup+0x2f/0x7b
[  407.821329]  [<ffffffff8112b2be>] user_path_at+0x54/0x91
[  407.821333]  [<ffffffff810fa4b4>] ? do_brk+0x245/0x299
[  407.821336]  [<ffffffff810f8864>] ? remove_vma+0x7f/0x87
[  407.821339]  [<ffffffff81124270>] sys_readlinkat+0x30/0x98
[  407.821342]  [<ffffffff811242f3>] sys_readlink+0x1b/0x1d
[  407.821346]  [<ffffffff8100acc2>] system_call_fastpath+0x16/0x1b
[  407.821350] 
[  407.821351] Restarting tasks ... done.

I had a nfsv4 mount mounted at the time and I seem to be able to
reproduce this at will by making sure a nfs mount is mounted and trying
to suspend the machine.

It seems likely that the network interface had gone offline before the
call could complete. Anyone have  thoughts on ways to deal with this?

-- 
Jeff Layton <jlayton@redhat.com>
