Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f46.google.com ([209.85.210.46]:42476 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755044Ab1LNQfc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Dec 2011 11:35:32 -0500
Received: by dajs34 with SMTP id s34so680889daj.19
        for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 08:35:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EE8B3C9.8070800@netapp.com>
References: <1323812158-5183-1-git-send-email-bjschuma@netapp.com>
	<20111213221209.GA30904@fieldses.org>
	<4EE8A7BA.6050406@netapp.com>
	<20111214140744.GA4322@fieldses.org>
	<4EE8B3C9.8070800@netapp.com>
Date: Wed, 14 Dec 2011 11:35:32 -0500
Message-ID: <CAMeBU_2LCtuzaFtxMZ1VASoU5UcJo805_sJ2ovbtPZTWDUL-Bg@mail.gmail.com>
Subject: Re: [PATCH] NFSD: Only reinitilize the recall_lru list under the
 recall lock
From: Casey Bodley <cbodley@citi.umich.edu>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 14, 2011 at 9:33 AM, Bryan Schumaker <bjschuma@netapp.com> wrote:
> On Wed Dec 14 09:07:44 2011, J. Bruce Fields wrote:
>> On Wed, Dec 14, 2011 at 08:42:18AM -0500, Bryan Schumaker wrote:
>>> On Tue Dec 13 17:12:09 2011, J. Bruce Fields wrote:
>>>> On Tue, Dec 13, 2011 at 04:35:58PM -0500, bjschuma@netapp.com wrote:
>>>>> From: Bryan Schumaker <bjschuma@netapp.com>
>>>>>
>>>>> unhash_delegation() will grab the recall lock before calling
>>>>> list_del_init() in each of these places.  This patch removes the
>>>>> redundant calls.
>>>>
>>>> Looks right, thanks.  (How did you happen across this?)
>>>
>>> I was looking over the fault injection stuff to see if I can figure out
>>> where an occasional oops was coming from.  It seems to happen when I
>>> forget delegations, so I was looking at how other functions release
>>> delegations to see if there was something I missed.  The oops doesn't
>>> happen often enough for me to know if this patch fixes it yet, though.
>>
>> Hm, OK.  Could you post the oops?
>
> I don't see it in the logs on the server, but I'll keep looking.  I'll
> post it the next time I come across it.

I'm not sure if this is the same oops, but I'm able to reproduce it
consistently against Bruce's 3.2.0-rc1 tree with fault injection
enabled.  I use the windows client to read a file, then 'echo 0 >
/sys/kernel/debug/nfsd/forget_delegations'.  I just tested with the
patch above, and was able to reproduce the same oops:

[ 1200.251735] NFSD Fault Injection: forget_delegations (all)
[ 1200.251830] general protection fault: 0000 [#1] SMP
[ 1200.252450] CPU 1
[ 1200.252597] Modules linked in:
[ 1200.253062]
[ 1200.253256] Pid: 2004, comm: bash Not tainted 3.2.0-rc1+ #9 VMware,
Inc. VMware Virtual Platform/440BX Desktop Reference Platform
[ 1200.254102] RIP: 0010:[<ffffffff811ae7f5>]  [<ffffffff811ae7f5>]
nfsd_process_n_delegations+0x3e/0xbe
[ 1200.254746] RSP: 0018:ffff88003b579e08  EFLAGS: 00010287
[ 1200.255067] RAX: dead000000100100 RBX: 0000000000000000 RCX: 00000001802c002b
[ 1200.255458] RDX: ffff88003d2d3328 RSI: ffffffff811aa49e RDI: ffff88003d2d3308
[ 1200.255842] RBP: ffff88003b579e58 R08: ffff88003b558000 R09: ffff88003d2d3480
[ 1200.256226] R10: ffff88003b68b750 R11: 0000000000000040 R12: dead0000001000f8
[ 1200.256610] R13: 0000000000000001 R14: 000000000000002b R15: 00000000000000d5
[ 1200.257029] FS:  00007fbad1d44700(0000) GS:ffff88003fa20000(0000)
knlGS:0000000000000000
[ 1200.257512] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1200.257850] CR2: 00007fbad1d49000 CR3: 000000003b593000 CR4: 00000000000006e0
[ 1200.258272] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1200.258693] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1200.259083] Process bash (pid: 2004, threadinfo ffff88003b578000,
task ffff88003cc3dfe0)
[ 1200.259561] Stack:
[ 1200.259768]  ffffffff811aa49e ffff88003d2d3308 ffffffff81be1560
ffff88003d2d3328
[ 1200.260553]  ffff88003b579e88 ffffffff81a2b6a0 0000000000000000
0000000000000002
[ 1200.261337]  ffff88003d8c1550 ffff88003d8c1528 ffff88003b579e88
ffffffff811ae897
[ 1200.262121] Call Trace:
[ 1200.262346]  [<ffffffff811aa49e>] ? nfs4_put_delegation+0x55/0x55
[ 1200.262701]  [<ffffffff811ae897>] nfsd_forget_delegations+0x22/0x40
[ 1200.263119]  [<ffffffff8119d3e7>] nfsd_inject_set+0x3f/0x46
[ 1200.263470]  [<ffffffff810fb878>] simple_attr_write+0x8a/0xb2
[ 1200.263818]  [<ffffffff810e0949>] vfs_write+0xa7/0xfa
[ 1200.264136]  [<ffffffff810e0b41>] sys_write+0x45/0x69
[ 1200.264483]  [<ffffffff81450f3b>] system_call_fastpath+0x16/0x1b
[ 1200.264832] Code: 45 31 ed 41 54 53 48 89 fb 48 83 ec 28 49 63 c6
48 c1 e0 04 4c 8b a0 b0 12 be 81 48 05 b0 12 be 81 48 89 45 c0 49 83
ec 08 eb 57
[ 1200.270209]  8b 7c 24 28 49 8d 54 24 28 48 89 55 c8 48 83 ef 20 48 8b 47
[ 1200.272534] RIP  [<ffffffff811ae7f5>] nfsd_process_n_delegations+0x3e/0xbe
[ 1200.273007]  RSP <ffff88003b579e08>
[ 1200.273331] ---[ end trace 0071bb3837d120e2 ]---

>
> - Bryan
>>
>> --b.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
