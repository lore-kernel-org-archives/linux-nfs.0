From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: 2.6.24.3 kernel BUG at fs/nfs/pagelist.c:82
Date: Wed, 19 Mar 2008 10:49:42 +0100
Message-ID: <20080319094942.GA7627@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:52079 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752897AbYCTDJE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Mar 2008 23:09:04 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FYI,

2.6.24.3 wrote:
> kernel BUG at fs/nfs/pagelist.c:82!

BUG_ON(PagePrivate(page));

> invalid opcode: 0000 [#1] SMP 
> Modules linked in: vmnetfilter vmnet(P) vmmon(P) vmthrottle

In addition, there are some NFS patches for handling >16 groups and
selectively disabling attribute caching so its not a clean kernel.

> 
> Pid: 4575, comm: tail Tainted: P        (2.6.24.3-x177 #1)
> EIP: 0060:[<c01fc084>] EFLAGS: 00010202 CPU: 1
> EIP is at nfs_create_request+0xf4/0x100
> EAX: 80000821 EBX: e31a5300 ECX: 00000000 EDX: c1f0712c
> ESI: c1f0712c EDI: e31a5338 EBP: e56dfd90 ESP: e56dfd74
>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068 
> Process tail (pid: 4575, ti=e56de000 task=d4b65500 task.ti=e56de000) 
> Stack: 00000000 f669ad20 cac3c168 e7330cb0 00000000 00000000 cac3c168 e56dfdc8 
>        c01fded5 00000000 000000a4 039cffff 000000a4 c1f0712c cac3c168 e7330cb0 
>        e56dfdb4 e56dfdb4 ffffff8c c1f0712c e7330cb0 e56dfdf0 c01fe8ce e56dfddc 
> Call Trace:
>  [<c010562a>] show_trace_log_lvl+0x1a/0x30
>  [<c01056fa>] show_stack_log_lvl+0x9a/0xc0
>  [<c01058a8>] show_registers+0xc8/0x1d0
>  [<c0105b1c>] die+0x10c/0x230
>  [<c0105cd1>] do_trap+0x91/0xd0  
>  [<c0105f79>] do_invalid_op+0x89/0xa0
>  [<c05bba02>] error_code+0x72/0x80
>  [<c01fded5>] nfs_readpage_async+0xb5/0x1b0
>  [<c01fe8ce>] nfs_readpage+0xae/0x120
>  [<c0155268>] do_generic_mapping_read+0xe8/0x440
>  [<c01558b0>] generic_file_aio_read+0x160/0x190
>  [<c01f4fb7>] nfs_file_read+0x97/0xe0
>  [<c01795e7>] do_sync_read+0xc7/0x120
>  [<c01796c4>] vfs_read+0x84/0x130
>  [<c01799fd>] sys_read+0x3d/0x70 
>  [<c0104292>] syscall_call+0x7/0xb
>  =======================
> Code: 02 75 0a e8 4f dc 3b 00 e9 4a ff ff ff 83 c4 10 b8 00 fe ff ff 5b 5e 5f 5d c3 8b 56 0c e9 7a ff ff ff 0f 0b eb fe 90 0f 0b eb fe <0f> 0b eb fe 90 8d b4 26 00 00 00 00 55 89 e5 53 83 ec 04 89 c3 
> EIP: [<c01fc084>] nfs_create_request+0xf4/0x100 SS:ESP 0068:e56dfd74
> ---[ end trace 0ef921372ea6410b ]--- 

The machine is a quad Xeon with 4GB ram with CONFIG_HIGHMEM64G=y

-- 
Frank
