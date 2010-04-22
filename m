From: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Subject: nfsd restart attempt ended in nfsd hang
Date: Thu, 22 Apr 2010 11:06:29 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1004221105060.18536@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:55778 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752602Ab0DVJGa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Apr 2010 05:06:30 -0400
Received: from localhost (localhost [127.0.0.1])
	by borg.medozas.de (Postfix) with ESMTP id 2A9BF64C8
	for <linux-nfs@vger.kernel.org>; Thu, 22 Apr 2010 11:06:29 +0200 (CEST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi,


I am observing this hanging nfsd kernel thread:

Linux 2.6.33.2
0404] nfsd          D ffff88033b29d100     0 26090      2 0x00000000
0410]  ffff880191b45c60 0000000000000046 0000000000000010 ffff880191b45fd8
0415]  ffff880101e943c0 ffff880191b45fd8 0000000000012300 0000000000012300
0420]  0000000000012300 0000000000012300 0000000000012300 ffff880191b45fd8
0426] Call Trace:
0442]  [<ffffffffa04afb42>] rpc_wait_bit_killable+0x30/0x34 [sunrpc]
0459]  [<ffffffff812e2997>] __wait_on_bit+0x3e/0x6f
0465]  [<ffffffff812e2a36>] out_of_line_wait_on_bit+0x6e/0x77
0479]  [<ffffffffa04b02d7>] __rpc_execute+0xf9/0x1b1 [sunrpc]
0501]  [<ffffffffa04aa569>] rpc_run_task+0x4f/0x57 [sunrpc]
0515]  [<ffffffffa04aa654>] rpc_call_sync+0x3d/0x5a [sunrpc]
0535]  [<ffffffffa04b7581>] rpcb_register_call+0x18/0x4b [sunrpc]
0574]  [<ffffffffa04b7770>] rpcb_v4_register+0xb4/0x16c [sunrpc]
0612]  [<ffffffffa04b26c4>] svc_unregister+0x53/0xe1 [sunrpc]
0643]  [<ffffffffa04b285d>] svc_destroy+0x10b/0x123 [sunrpc]
0667]  [<ffffffffa07cb883>] nfsd+0x117/0x131 [nfsd]
0674]  [<ffffffff8104bd7d>] kthread+0x75/0x7d
0680]  [<ffffffff810037a4>] kernel_thread_helper+0x4/0x10

Is it going to timeout, if so when?
