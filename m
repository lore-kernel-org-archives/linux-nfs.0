Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:38881 "EHLO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755386Ab0FQV6R convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jun 2010 17:58:17 -0400
Received: from indyvss1.am.thmulti.com (unknown [157.254.92.61])
	by mail2.thomson.net (Postfix) with ESMTP id 4965D23CA9B
	for <linux-nfs@vger.kernel.org>; Thu, 17 Jun 2010 21:58:16 +0000 (GMT)
Received: from INDYSMAILCS04.am.thmulti.com (indysmailcs04.am.thmulti.com [157.254.96.12])
	by indyvss1.am.thmulti.com (Postfix) with ESMTP id 477012018FA
	for <linux-nfs@vger.kernel.org>; Thu, 17 Jun 2010 21:58:16 +0000 (GMT)
Content-Type: text/plain;
	charset="iso-8859-1"
Subject: NFSv4 client deadlock, large rsize/wsize
Date: Thu, 17 Jun 2010 17:58:14 -0400
Message-ID: <68DF70B3485CC648835655773E92314F920C27@prinsmail02.am.thmulti.com>
From: "Kashyap Ashwin" <Ashwin.Kashyap@technicolor.com>
To: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,
I'm experiencing client side deadlocks while using NFSv4, after long periods of use, typically 1-2 months. This happens even when the server is reachable and other clients can access and use the mounts normally. This does not bring down the machine, but the entire mount directory hierarchy becomes unresponsive. It is very difficult to reproduce. 

I have configured an NFSv4 server and 4 clients as follows: 

Server1 (16Gb ram, 64bit Ubuntu Hardy) /etc/exports:
/srv          192.168.1.0/24(fsid=0,crossmnt,insecure,no_all_squash,no_root_squash,no_subtree_check,no_acl,rw,async)

Client (8Gb ram, 64bit, Ubuntu Hardy) /etc/fstab:
Server1:/home /home nfs4    _netdev,proto=tcp,port=2049,auto,nolock,nocto,rsize=1048576,wsize=1048576,intr,relatime    0    0

Client and server have 2 interfaces and NFS uses the private 192.* address.

When the client deadlocks, any access to the /home dir hangs (some succeed since data can be cached). Running the command with strace shows a hang at one of the FS syscalls. A strange thing is that on the server side, tcpdump never receives any requests. I can ping/ssh/etc to the server normally. Also, the other clients continue to work normally.
I hit alt-prinscrn-t to showTask, ls /home/ hangs and has the following call trace:

kernel: [3631914.659232] ls            S 0000000000000000     0 20953      1
kernel: [3631914.659348]  ffff810139869b08 0000000000000086 0000000000000000 00007f44a76fd000
kernel: [3631914.659542]  ffffffff8067f600 ffffffff80682c80 ffffffff80682c80 ffffffff80682c80
kernel: [3631914.659735]  ffffffff8067f0a0 ffffffff80682c80 ffff8100b54e4a20 ffff810139869ad4
kernel: [3631914.659884] Call Trace:
kernel: [3631914.659990]  [sunrpc:rpc_wait_bit_interruptible+0x0/0x30] :sunrpc:rpc_wait_bit_interruptible+0x0/0x30
kernel: [3631914.660070]  [sunrpc:rpc_wait_bit_interruptible+0x22/0x30] :sunrpc:rpc_wait_bit_interruptible+0x22/0x30
kernel: [3631914.660143]  [__wait_on_bit+0x4f/0x80] __wait_on_bit+0x4f/0x80
kernel: [3631914.660207]  [sunrpc:rpc_wait_bit_interruptible+0x0/0x30] :sunrpc:rpc_wait_bit_interruptible+0x0/0x30
kernel: [3631914.660279]  [nfs:out_of_line_wait_on_bit+0x7a/0xa0] out_of_line_wait_on_bit+0x7a/0xa0
kernel: [3631914.660336]  [<ffffffff80254380>] wake_bit_function+0x0/0x30
kernel: [3631914.660400]  [sunrpc:xprt_reserve+0xbd/0x180] :sunrpc:xprt_reserve+0xbd/0x180
kernel: [3631914.660465]  [sunrpc:__rpc_execute+0xd1/0x290] :sunrpc:__rpc_execute+0xd1/0x290
kernel: [3631914.660530]  [sunrpc:rpc_do_run_task+0x76/0xd0] :sunrpc:rpc_do_run_task+0x76/0xd0
kernel: [3631914.660596]  [sunrpc:rpc_call_sync+0x15/0x40] :sunrpc:rpc_call_sync+0x15/0x40
kernel: [3631914.660660]  [nfs:_nfs4_proc_getattr+0x65/0x70] :nfs:_nfs4_proc_getattr+0x65/0x70
kernel: [3631914.660719]  [sunrpc:recalc_sigpending+0xe/0x40] recalc_sigpending+0xe/0x40
kernel: [3631914.660782]  [nfs:nfs4_proc_getattr+0x32/0x60] :nfs:nfs4_proc_getattr+0x32/0x60
kernel: [3631914.660839]  [sunrpc:recalc_sigpending+0xe/0x40] recalc_sigpending+0xe/0x40
kernel: [3631914.660902]  [nfs:__nfs_revalidate_inode+0x1cd/0x300] :nfs:__nfs_revalidate_inode+0x1cd/0x300
kernel: [3631914.660960]  [link_path_walk+0x81/0x100] link_path_walk+0x81/0x100
kernel: [3631914.661018]  [sys_rt_sigreturn+0x35f/0x400] sys_rt_sigreturn+0x35f/0x400
kernel: [3631914.661074]  [dequeue_signal+0x59/0x150] dequeue_signal+0x59/0x150
kernel: [3631914.661130]  [do_path_lookup+0x8a/0x250] do_path_lookup+0x8a/0x250
kernel: [3631914.661193]  [nfs:nfs_getattr+0x76/0x100] :nfs:nfs_getattr+0x76/0x100
kernel: [3631914.661250]  [vfs_stat_fd+0x46/0x80] vfs_stat_fd+0x46/0x80
kernel: [3631914.661307]  [sys_rt_sigreturn+0x35f/0x400] sys_rt_sigreturn+0x35f/0x400
kernel: [3631914.661364]  [sys_newstat+0x27/0x50] sys_newstat+0x27/0x50
kernel: [3631914.661420]  [int_signal+0x12/0x17] int_signal+0x12/0x17
kernel: [3631914.661475]  [system_call+0x7e/0x83] system_call+0x7e/0x83 

Does anyone have any idea what is happening? My hunch was that the large rsize and esize is causing some allocation problems, maybe due to fragmentation. But then I'm no kernel developer... Workarounds greatly appreciated.

Thanks,
Ashwin


