Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64738 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751766Ab1HDPj3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Aug 2011 11:39:29 -0400
Subject: Re: 2.6.39.3: rpcb_getport_done() BUG trying to deref 0x6b6b6b6f
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Frank van Maarseveen <frankvm@frankvm.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Date: Thu, 04 Aug 2011 11:38:01 -0400
In-Reply-To: <20110804121444.GA14024@janus>
References: <20110804121444.GA14024@janus>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1312472281.3769.3.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-08-04 at 14:14 +0200, Frank van Maarseveen wrote: 
> While testing NLM I saw this once (reformatted a bit because logged
> over netconsole):
> 
>  BUG: unable to handle kernel paging request at 6b6b6b6f
>  IP: [<c174ffa2>] rpcb_getport_done+0x32/0xc0
>  *pdpt = 000000003547c001
>  *pde = 0000000000000000
>  Oops: 0000 [#1]
>  PREEMPT SMP 
>  Pid: 1512, comm: kworker/0:2 Not tainted 2.6.39.3-x260 #1
>  EIP: 0060:[<c174ffa2>] EFLAGS: 00010286 CPU: 0
>  EIP is at rpcb_getport_done+0x32/0xc0
>  EAX: 00009712 EBX: 00000000 ECX: c174ff70 EDX: f5434c40
>  ESI: 6b6b6b6b EDI: f5434c40 EBP: f5fa9ef8 ESP: f5fa9ed8
>   DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
>  Process kworker/0:2 (pid: 1512, ti=f5fa8000 task=f65008a0 task.ti=f5fa8000)
>  Call Trace:
>   [<c1741ded>] ? call_decode+0x13d/0x200
>   [<c174835e>] rpc_exit_task+0x1e/0x50
>   [<c17488f8>] __rpc_execute+0x68/0x1b0
>   [<c1746694>] ? xs_udp_setup_socket+0x34/0x180
>   [<c1748a8b>] rpc_async_schedule+0xb/0x10
>   [<c1084400>] process_one_work+0x110/0x360
>   [<c1748a80>] ? rpc_execute+0x40/0x40
>   [<c1084977>] worker_thread+0x137/0x370
>   [<c1084840>] ? manage_workers+0x110/0x110
>   [<c1089d84>] kthread+0x74/0x80
>   [<c1089d10>] ? __init_kthread_worker+0x30/0x30
>   [<c17871b6>] kernel_thread_helper+0x6/0xd

Probably another instance of the bug that was fixed by commit
ec0dd267bf7d08cb30e321e45a75fd40edd7e528 (SUNRPC: Fix use of static
variable in rpcb_getport_async).

2.6.39.4 contains a backport of the above fix. Can you try it out?

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

