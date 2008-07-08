From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.6.26-rc5 call trace
Date: Tue, 8 Jul 2008 10:41:56 -0400
Message-ID: <20080708144156.GC7032@fieldses.org>
References: <18129.195.41.66.226.1215508839.squirrel@mail.jabbernet.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60615 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752968AbYGHOl5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jul 2008 10:41:57 -0400
In-Reply-To: <18129.195.41.66.226.1215508839.squirrel-e3PW5SUo3N5/BLzvFphCflpr/1R2p/CL@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 08, 2008 at 11:20:39AM +0200, Jesper Krogh wrote:
> Hi
> 
> I'm getting this call trace on the server: 2.6.26-rc5
> 
> [4571608.304232] INFO: task nfsd:7747 blocked for more than 120 seconds.
> [4571608.304232] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> disables this message.
> [4571608.304232] nfsd          D ffff810303a20300     0  7747      2
> [4571608.304232]  ffff8102faa49d18 0000000000000046 0000000000004000
> 0000000000000001
> [4571608.304232]  ffffffff8069c300 ffffffff8069c300 ffffffff80698480
> ffffffff8069c300
> [4571608.304232]  ffff8102fb5d4ee0 0000000000000000 ffffffff802b89f0
> fffffffffffffffe
> [4571608.304232] Call Trace:
> [4571608.304232]  [<ffffffff802b89f0>] permission+0xb0/0x160
> [4571608.304232]  [<ffffffffa03d02cf>] :nfsd:nfsd_permission+0x9f/0x130
> [4571608.304232]  [<ffffffffa03cf335>] :nfsd:fh_verify+0x105/0x530
> [4571608.304232]  [<ffffffff80476051>] __mutex_lock_slowpath+0x81/0xd0
> [4571608.304232]  [<ffffffff80475e3a>] mutex_lock+0xa/0x10
> [4571608.304232]  [<ffffffffa03d1f12>] :nfsd:nfsd_lookup_dentry+0x182/0x4b0
> [4571608.304232]  [<ffffffffa03d2270>] :nfsd:nfsd_lookup+0x30/0xd0
> [4571608.304232]  [<ffffffffa03da711>] :nfsd:nfsd3_proc_lookup+0xa1/0x120
> [4571608.304232]  [<ffffffffa03cc271>] :nfsd:nfsd_dispatch+0xb1/0x240
> [4571608.304232]  [<ffffffffa03782ca>] :sunrpc:svc_process+0x48a/0x7f0
> [4571608.304232]  [<ffffffff8022bd90>] default_wake_function+0x0/0x10
> [4571608.304232]  [<ffffffff80476f02>] __down_read+0x12/0xad
> [4571608.304232]  [<ffffffffa03cc810>] :nfsd:nfsd+0x0/0x2e0
> [4571608.304232]  [<ffffffffa03cc99b>] :nfsd:nfsd+0x18b/0x2e0
> [4571608.304232]  [<ffffffffa03cc810>] :nfsd:nfsd+0x0/0x2e0
> [4571608.304232]  [<ffffffff8020d0e8>] child_rip+0xa/0x12
> [4571608.304232]  [<ffffffffa03cc810>] :nfsd:nfsd+0x0/0x2e0
> [4571608.304232]  [<ffffffffa03cc810>] :nfsd:nfsd+0x0/0x2e0
> [4571608.304232]  [<ffffffff8020d0de>] child_rip+0x0/0x12
> 
> $ dmesg | grep -c INFO
> 73

Thanks for the report!

What filesystem are you exporting, with what export options?  And with
which kernel version did you start seeing this?

--b.
