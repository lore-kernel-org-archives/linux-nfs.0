Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:36157 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbbGFJqp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jul 2015 05:46:45 -0400
Received: by wguu7 with SMTP id u7so135276056wgu.3
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jul 2015 02:46:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150702060827.66fc27f1@tlielax.poochiereds.net>
References: <1435687950-22037-1-git-send-email-jeff.layton@primarydata.com>
 <20150701093547.116dd788@tlielax.poochiereds.net> <CAJ75kXYQ1+_1hRun-kUq=VH2Y3wM+2SEH0zd5-j7xsq9x+RSLA@mail.gmail.com>
 <20150702060827.66fc27f1@tlielax.poochiereds.net>
From: William Dauchy <wdauchy@gmail.com>
Date: Mon, 6 Jul 2015 11:46:24 +0200
Message-ID: <CAJ75kXYfpWSYxVw482Y48hf0AMvtRH12ROGTDOd3Tv03nxe0hw@mail.gmail.com>
Subject: Re: [PATCH] nfs: take extra reference to fl->fl_file when running a
 LOCKU operation
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jean Spector <jean@primarydata.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I don't know if it's related but after applying these two patches, I
got a crash; will try to get more info.

BUG: unable to handle kernel NULL pointer dereference at            (nil)
IP: [<ffffffff810ee2b3>] filemap_fault+0x23/0x430
PGD 0
Oops: 0000 [#1] PREEMPT SMP
CPU: 2 PID: 32013 Comm: umount.nfs4 Tainted: G        W    3.14.46 #1
task: ffff880f6044ecc0 ti: ffff880f6044f248 task.ti: ffff880f6044f248
RIP: 0010:[<ffffffff810ee2b3>]  [<ffffffff810ee2b3>] filemap_fault+0x23/0x430
RSP: 0000:ffff880f4e56fcc8  EFLAGS: 00010292
RAX: 0000000000000000 RBX: ffff881ff95d4480 RCX: ffff880f4e5749c8
RDX: ffffffff817b60c0 RSI: ffff880f4e56fd50 RDI: ffff881ff95d4480
RBP: ffff880f4e56fd18 R08: 0000000000000007 R09: 00000000000000a8
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000007
R13: ffff880f5b884700 R14: 000002d4a72be5fc R15: 0000000000000000
FS:  000002d4a80c47e0(0000) GS:ffff88103fc40000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000000 CR3: 000000000160c000 CR4: 00000000001607f0
Stack:
ffff880f6044ecc0 0000000000000009 0000000000000082 0000000000000000
ffff880f6044f448 ffff881ff95d4480 00000000000000a8 0000000000000007
000002d4a72be5fc 0000000000000000 ffff880f4e56fd98 ffffffff81111f88
Call Trace:
[<ffffffff81111f88>] __do_fault+0x78/0x5e0
[<ffffffff81116f0c>] handle_mm_fault+0x39c/0xcb0
[<ffffffff81033e23>] __do_page_fault+0x1b3/0x620
[<ffffffff815fc01e>] ? retint_swapgs_pax+0x10/0x15
[<ffffffff810a889d>] ? trace_hardirqs_on_caller+0x13d/0x1e0
[<ffffffff812c827e>] ? trace_hardirqs_off_thunk+0x41/0x43
[<ffffffff812c8238>] ? trace_hardirqs_on_thunk+0x41/0x46
[<ffffffff81178c8b>] ? SyS_umount+0x8b/0x4a0
[<ffffffff815fca33>] ? system_call_fastpath+0x16/0x1b
[<ffffffff810342cc>] do_page_fault+0xc/0x20
[<ffffffff815fc272>] page_fault+0x22/0x30
Code: fe ff ff 0f 1f 44 00 00 55 48 89 e5 41 57 41 56 41 55 41 54 53
48 83 ec 28 4c 8b af a0 00 00 00 4c 8b 66 08 49 8b 85 b8 01 00 00 <4c>
8b 38 48 89 45 c8 49 8b 47 40 48 8d 90 ff 0f 00 00 b8 02 00
RIP  [<ffffffff810ee2b3>] filemap_fault+0x23/0x430
RSP <ffff880f4e56fcc8>
CR2: 0000000000000000
---[ end trace 59f46e48035e53e4 ]---

-- 
William
