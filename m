Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:35331 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754351Ab1B1SYk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Feb 2011 13:24:40 -0500
Message-ID: <4D6BE865.7010307@panasas.com>
Date: Mon, 28 Feb 2011 20:24:37 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH] SQUASHME: pnfs: FIX stupid recall_layout BUG
References: <4D686893.7010106@panasas.com>	<4D6A67F3.3060308@panasas.com> <AANLkTimZS=54ZkwXwK9tMUUBn_JDXD5=+ohBpnKemtbQ@mail.gmail.com>
In-Reply-To: <AANLkTimZS=54ZkwXwK9tMUUBn_JDXD5=+ohBpnKemtbQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 02/28/2011 12:09 AM, Fred Isaman wrote:
> On Sun, Feb 27, 2011 at 7:04 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>
>> OK, who wrote this code? He did not stop to think for even a
>> second. And surely it was never tested, since it is 100%
>> repeatable. Smack yourself on the head!
>>
> 
> I wrote the code.  But note that the tree you are using is taking the
> tested, reasonably mature code that is currently in the downstream
> kernel and reverting it back to ancient buggy prototype code.  My
> understanding was that Benny was rightly ripping out the reversions at
> bakeathon.
> 

OK that figures then. I was using the only tree I could use,
I guess I'll have to wait out until things settle.

> Fred

However with the tree released by benny few hours ago I get
a new crash. The uml backtrace is really bad I'll try to print
out more context to see where was the last put done.
This time it takes a long time to trigger. It feels like
a race.

Call Trace: 
602678a8:  [<6001585b>] panic_exit+0x2f/0x45
602678c8:  [<60049a3e>] notifier_call_chain+0x32/0x5e
60267908:  [<60049a8c>] atomic_notifier_call_chain+0x13/0x15
60267918:  [<601b3b9b>] panic+0x105/0x1dc
602679c8:  [<601b6056>] _raw_spin_unlock_irqrestore+0x18/0x1c
602679e8:  [<60016e5f>] free_irqs+0x74/0xde
60267a18:  [<60015162>] relay_signal+0x38/0x79
60267a28:  [<60012cef>] sigio_handler+0x5a/0x5f
60267a48:  [<600224d0>] sig_handler_common+0x84/0x98
60267a68:  [<6002257d>] real_alarm_handler+0x3c/0x3e
60267af0:  [<60186de1>] tcp_rcv_established+0x107/0x5fa
60267b78:  [<60022616>] sig_handler+0x30/0x3b
60267b98:  [<60022848>] handle_signal+0x6d/0xa3
60267be8:  [<600241c8>] hard_handler+0x10/0x14
60267ca8:  [<7b9cdaa3>] destroy_layout_hdr+0x33/0x52 [nfs]

(gdb) list *(destroy_layout_hdr+0x33)
0x2eac7 is in destroy_layout_hdr (/usr0/export/dev/bharrosh/git/pub/linux-pnfs/fs/nfs/pnfs.c:262).
257
258     static void
259     destroy_layout_hdr(struct pnfs_layout_hdr *lo)
260     {
261             dprintk("%s: freeing layout cache %p\n", __func__, lo);
262             BUG_ON(!list_empty(&lo->plh_layouts));
263             NFS_I(lo->plh_inode)->layout = NULL;
264             pnfs_free_layout_hdr(lo);
265     }
266
