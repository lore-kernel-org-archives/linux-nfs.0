From: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Subject: stuck/hung nfsv4 mounts
Date: Mon, 03 Nov 2008 10:05:21 -0500
Message-ID: <1225724721.2247.29.camel@brian-laptop>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server.klug.on.ca ([205.189.48.131]:1595 "EHLO
	server.klug.on.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753786AbYKCP0e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Nov 2008 10:26:34 -0500
Received: from linux.interlinx.bc.ca (d193-213-184.home3.cgocable.net [67.193.213.184])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id E513F2805
	for <linux-nfs@vger.kernel.org>; Mon,  3 Nov 2008 10:05:22 -0500 (EST)
Received: from [10.75.22.172] (brian-laptop.ilinx [10.75.22.172])
	by linux.interlinx.bc.ca (Postfix) with ESMTP id CE6AF800A
	for <linux-nfs@vger.kernel.org>; Mon,  3 Nov 2008 10:05:21 -0500 (EST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a system which I migrated a couple of mounts from sys
authentication on nfs3 to gssapi on nfsv4 to overcome the 16
supplementary groups limitation inherent in the "sys" security model.

It was working for a while but now I have "stuck" (i.e. hung) NFS
mounts.  It seems that a mount issued from the automounter kicked all of
this off but I cannot be sure of that.

In my process table I have a number of processes blocked in the NFSv4
path including a mount command:

/bin/mount -t nfs4 -s -o sec=krb5i,rw,soft,intr,rsize=8192,wsize=8192 linux:/home/share /autohome/share

It's stack trace is:

Nov  3 09:54:14 pc kernel: [474304.152005] mount.nfs4    D c012ad55     0 25903  25902
Nov  3 09:54:14 pc kernel: [474304.152005]        dcf1bb34 00000086 dcf1badc c012ad55 00001eff 026b0b7a 00000000 dcf1badc 
Nov  3 09:54:14 pc kernel: [474304.152005]        00000086 f670d7f0 ec213ed0 003649ad 00000000 c012b4ee 00000000 ec2b5340 
Nov  3 09:54:14 pc kernel: [474304.152005]        c050f080 f3740000 dcf1a000 ec214148 c28d1d00 00000000 dcf1bb0c c28d1d00 
Nov  3 09:54:14 pc kernel: [474304.152005] Call Trace:
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c012ad55>] ? check_preempt_wakeup+0x175/0x1b0
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c012b4ee>] ? try_to_wake_up+0xde/0x290
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9574c5d>] rpc_wait_bit_killable+0x1d/0x50 [sunrpc]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c037d2df>] __wait_on_bit+0x4f/0x70
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9574c40>] ? rpc_wait_bit_killable+0x0/0x50 [sunrpc]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c037d3ad>] out_of_line_wait_on_bit+0xad/0xc0
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9574c40>] ? rpc_wait_bit_killable+0x0/0x50 [sunrpc]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c0147500>] ? wake_bit_function+0x0/0x60
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f95756ae>] __rpc_execute+0xae/0x250 [sunrpc]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f95758c9>] rpc_execute+0x79/0x90 [sunrpc]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f956e743>] rpc_run_task+0x33/0x70 [sunrpc]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f956e8a0>] rpc_call_sync+0x40/0x70 [sunrpc]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9cd0401>] nfs4_proc_get_root+0x71/0xc0 [nfs]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9cba216>] nfs4_path_walk+0x86/0x340 [nfs]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01cb0d2>] ? mntput_no_expire+0x22/0x120
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01d1ab4>] ? simple_release_fs+0x54/0x70
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f95818bb>] ? rpc_mkdir+0x9b/0x110 [sunrpc]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c037e61d>] ? _spin_lock+0xd/0x10
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01d1b14>] ? simple_pin_fs+0x44/0xb0
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f956ec30>] ? rpc_setup_pipedir+0x90/0xd0 [sunrpc]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9574528>] ? rpciod_up+0x8/0x30 [sunrpc]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f956ed46>] ? rpc_clone_client+0xd6/0x130 [sunrpc]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9cb373b>] ? nfs_init_server_rpcclient+0x2b/0xf0 [nfs]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9cb4c0a>] ? nfs4_init_server+0xea/0x220 [nfs]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9cb4dbc>] nfs4_create_server+0x7c/0x240 [nfs]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01acc24>] ? kfree+0x14/0xd0
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01ad388>] ? get_slab+0x8/0x60
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9cbdcb3>] ? nfs_parse_simple_hostname+0x83/0x160 [nfs]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c0191496>] ? kstrndup+0x36/0x60
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9cbdcb3>] ? nfs_parse_simple_hostname+0x83/0x160 [nfs]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9cbddb3>] ? nfs_parse_devname+0x23/0x50 [nfs]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9cbfe7e>] ? nfs4_validate_mount_data+0x31e/0x370 [nfs]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9cbff65>] nfs4_get_sb+0x95/0x280 [nfs]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01b43ee>] vfs_kern_mount+0x5e/0x130
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01b451e>] do_kern_mount+0x3e/0xe0
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01cc9ef>] do_new_mount+0x6f/0x90
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01ccf32>] do_mount+0x1d2/0x1f0
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01ca67d>] ? exact_copy_from_user+0x4d/0xa0
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01cac8e>] ? copy_mount_options+0x6e/0xd0
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01ccfe1>] sys_mount+0x91/0xc0
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c0103f7b>] sysenter_do_call+0x12/0x2f

There are a number of other processes stuck in the nfs4 paths as well:

Nov  3 09:54:13 pc kernel: [474304.152005] gnome-panel   D cafc1ca4     0  7266  16025
Nov  3 09:54:13 pc kernel: [474304.152005]        cafc1d08 00000086 f7070000 cafc1ca4 cafc1ca4 00000246 c2e6a204 f7070000 
Nov  3 09:54:13 pc kernel: [474304.152005]        f7070000 cafc1cc4 ec216480 000025ad 00000000 00000246 00000001 f63ec380 
Nov  3 09:54:13 pc kernel: [474304.152005]        c050f080 f0d30000 cafc0000 ec2166f8 c28dcd00 00000001 f9574ec0 c28dcd00 
Nov  3 09:54:13 pc kernel: [474304.152005] Call Trace:
Nov  3 09:54:13 pc kernel: [474304.152005]  [<f9574ec0>] ? __rpc_sleep_on+0x230/0x270 [sunrpc]
Nov  3 09:54:13 pc kernel: [474304.152005]  [<f9574c5d>] rpc_wait_bit_killable+0x1d/0x50 [sunrpc]
Nov  3 09:54:13 pc kernel: [474304.152005]  [<c037d2df>] __wait_on_bit+0x4f/0x70
Nov  3 09:54:13 pc kernel: [474304.152005]  [<f9574c40>] ? rpc_wait_bit_killable+0x0/0x50 [sunrpc]
Nov  3 09:54:13 pc kernel: [474304.152005]  [<c037d3ad>] out_of_line_wait_on_bit+0xad/0xc0
Nov  3 09:54:13 pc kernel: [474304.152005]  [<f9574c40>] ? rpc_wait_bit_killable+0x0/0x50 [sunrpc]
Nov  3 09:54:13 pc kernel: [474304.152005]  [<c0147500>] ? wake_bit_function+0x0/0x60
Nov  3 09:54:13 pc kernel: [474304.152005]  [<f95756ae>] __rpc_execute+0xae/0x250 [sunrpc]
Nov  3 09:54:13 pc kernel: [474304.152005]  [<f95758c9>] rpc_execute+0x79/0x90 [sunrpc]
Nov  3 09:54:13 pc kernel: [474304.152005]  [<f956e743>] rpc_run_task+0x33/0x70 [sunrpc]
Nov  3 09:54:13 pc kernel: [474304.152005]  [<f956e8a0>] rpc_call_sync+0x40/0x70 [sunrpc]
Nov  3 09:54:13 pc kernel: [474304.152005]  [<f9cd0206>] nfs4_proc_getattr+0x76/0xa0 [nfs]
Nov  3 09:54:13 pc kernel: [474304.152005]  [<f9cbbc86>] __nfs_revalidate_inode+0x156/0x2b0 [nfs]
Nov  3 09:54:13 pc kernel: [474304.152005]  [<c014b474>] ? hrtimer_start+0xc4/0x1c0
Nov  3 09:54:13 pc kernel: [474304.152005]  [<c01cb0d2>] ? mntput_no_expire+0x22/0x120
Nov  3 09:54:13 pc kernel: [474304.152005]  [<c01babc5>] ? path_put+0x25/0x30
Nov  3 09:54:13 pc kernel: [474304.152005]  [<c01bca62>] ? path_walk+0xa2/0xb0
Nov  3 09:54:13 pc kernel: [474304.152005]  [<c01ba9fa>] ? putname+0x2a/0x40
Nov  3 09:54:13 pc kernel: [474304.152005]  [<c01ba9fa>] ? putname+0x2a/0x40
Nov  3 09:54:13 pc kernel: [474304.152005]  [<c01bd7e3>] ? user_path_at+0x53/0x80
Nov  3 09:54:13 pc kernel: [474304.152005]  [<f9cbcb2d>] nfs_revalidate_inode+0x3d/0x70 [nfs]
Nov  3 09:54:13 pc kernel: [474304.152005]  [<f9cbcc13>] nfs_getattr+0xb3/0x100 [nfs]
Nov  3 09:54:13 pc kernel: [474304.152005]  [<f9cbcb60>] ? nfs_getattr+0x0/0x100 [nfs]
Nov  3 09:54:13 pc kernel: [474304.152005]  [<c01b5bda>] vfs_getattr+0x4a/0x70
Nov  3 09:54:13 pc kernel: [474304.152005]  [<c01b5e39>] vfs_stat_fd+0x39/0x60
Nov  3 09:54:13 pc kernel: [474304.152005]  [<c01b5f66>] vfs_stat+0x16/0x20
Nov  3 09:54:13 pc kernel: [474304.152005]  [<c01b5f89>] sys_stat64+0x19/0x30
Nov  3 09:54:13 pc kernel: [474304.152005]  [<c0103f7b>] sysenter_do_call+0x12/0x2f

Nov  3 09:54:14 pc kernel: [474304.152005] lsof          D ece08000     0 18247  18245
Nov  3 09:54:14 pc kernel: [474304.152005]        c0e0dd08 00200086 f0953a74 ece08000 c0e0dca0 f95c629b f0953a74 00000000 
Nov  3 09:54:14 pc kernel: [474304.152005]        c0e0dce0 f95c6a10 c2e657f0 00007541 00000000 e5f76cc0 00000000 ee177c00 
Nov  3 09:54:14 pc kernel: [474304.152005]        c050f080 ee066000 c0e0c000 c2e65a68 c28d1d00 00000000 c0e0dce0 c28d1d00 
Nov  3 09:54:14 pc kernel: [474304.152005] Call Trace:
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f95c629b>] ? gss_release_msg+0x4b/0x90 [auth_rpcgss]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f95c6a10>] ? gss_cred_init+0xe0/0x140 [auth_rpcgss]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9574c5d>] rpc_wait_bit_killable+0x1d/0x50 [sunrpc]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c037d2df>] __wait_on_bit+0x4f/0x70
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9574c40>] ? rpc_wait_bit_killable+0x0/0x50 [sunrpc]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c037d3ad>] out_of_line_wait_on_bit+0xad/0xc0
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9574c40>] ? rpc_wait_bit_killable+0x0/0x50 [sunrpc]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c0147500>] ? wake_bit_function+0x0/0x60
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f95756ae>] __rpc_execute+0xae/0x250 [sunrpc]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f95758c9>] rpc_execute+0x79/0x90 [sunrpc]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f956e743>] rpc_run_task+0x33/0x70 [sunrpc]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f956e8a0>] rpc_call_sync+0x40/0x70 [sunrpc]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9cd0206>] nfs4_proc_getattr+0x76/0xa0 [nfs]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9cbbc86>] __nfs_revalidate_inode+0x156/0x2b0 [nfs]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01bac46>] ? path_to_nameidata+0x36/0x50
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01cb0d2>] ? mntput_no_expire+0x22/0x120
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01babc5>] ? path_put+0x25/0x30
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01bca62>] ? path_walk+0xa2/0xb0
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01ba9fa>] ? putname+0x2a/0x40
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01ba9fa>] ? putname+0x2a/0x40
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01bd7e3>] ? user_path_at+0x53/0x80
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9cbcb2d>] nfs_revalidate_inode+0x3d/0x70 [nfs]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9cbcc13>] nfs_getattr+0xb3/0x100 [nfs]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<f9cbcb60>] ? nfs_getattr+0x0/0x100 [nfs]
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01b5bda>] vfs_getattr+0x4a/0x70
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01b5e39>] vfs_stat_fd+0x39/0x60
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01b5f66>] vfs_stat+0x16/0x20
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01b5f89>] sys_stat64+0x19/0x30
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01b26db>] ? vfs_read+0xab/0x110
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01b1e40>] ? do_sync_read+0x0/0x120
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c01b2812>] ? sys_read+0x42/0x70
Nov  3 09:54:14 pc kernel: [474304.152005]  [<c0103f7b>] sysenter_do_call+0x12/0x2f

I have used wireshark and filtered for NFS4 (given that I have lots of
NFV3 still) with "rpc.programversion == 4" on the wire and noticed that
only a couple of packets (1 each after the TCP setup and teardown) are
sent between the client and server.  It was many tens of minutes between
these last night when I was debugging.  For as long as I have been
looking this morning there has not been a single NFS4 packet.

Client machine is the Ubuntu 2.6.27-7-generic kernel and the server is
the Ubuntu 2.6.24-16-generic kernel.

I've tried restarting NFS on the server a number of times and that has
not helped.

Any ideas?

b.


