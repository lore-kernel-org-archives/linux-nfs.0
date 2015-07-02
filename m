Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout4.w1.samsung.com ([210.118.77.14]:25563 "EHLO
	mailout4.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753164AbbGBMUC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jul 2015 08:20:02 -0400
Message-id: <55952C6D.50805@samsung.com>
Date: Thu, 02 Jul 2015 15:19:57 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        Eric Van Hensbergen <ericvh@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: running out of tags in 9P (was Re: [git pull] vfs part 2)
References: <5593A7A0.6050400@samsung.com>
 <20150701085507.GE17109@ZenIV.linux.org.uk> <5593CE37.4070307@samsung.com>
 <20150701184408.GF17109@ZenIV.linux.org.uk>
 <20150702032042.GA32613@ZenIV.linux.org.uk>
 <20150702041046.GG17109@ZenIV.linux.org.uk>
 <CAPAsAGzZVy3-D4J1ZGsUZU4RRQ36NtprZg_Uvfi5=46=1_rpWA@mail.gmail.com>
 <20150702075932.GI17109@ZenIV.linux.org.uk>
 <CAPAsAGzJW1C-4rd9myZOsiA9dLp2d420PTePaguK=y2RWjrz2A@mail.gmail.com>
 <20150702082529.GJ17109@ZenIV.linux.org.uk>
 <20150702084208.GK17109@ZenIV.linux.org.uk>
In-reply-to: <20150702084208.GK17109@ZenIV.linux.org.uk>
Content-type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/02/2015 11:42 AM, Al Viro wrote:
> On Thu, Jul 02, 2015 at 09:25:30AM +0100, Al Viro wrote:
>> On Thu, Jul 02, 2015 at 11:19:03AM +0300, Andrey Ryabinin wrote:
>>> Besides qemu, I've also tried kvmtool with the same result. IOW I'm seeing
>>> this under kvmtool as well. It just takes a bit longer to reproduce
>>> this in kvmtool.
>>>
>>>> The bug I suspected to be the cause of that is in tag allocation in
>>>> net/9p/client.c - we could end up wrapping around 2^16 with enough pending
>>>> requests and that would have triggered that kind of mess.  However, Andrey
>>>> doesn't see that test (tag wraparound in p9_client_prepare_req()) trigger.
>>>> BTW, was that on the run where debugging printk in p9_client_write() *did*
>>>> trigger?
>>>
>>> Yes, WARN_ON_ONCE() in p9_client_prepare_req() didn't trigger,
>>> but debug printk in p9_client_write() *did* trigger.
>>
>> Bloody wonderful...  Could you check if v9fs_write() in qemu
>> hw/9pfs/virtio-9p.c ever gets to
>>     offset = 7;
>>     err = pdu_marshal(pdu, offset, "d", total);
>> with total > count on your testcase?

Added:
+    if (total > count)
+           *(char *)0 = 0

and never hit this condition.

> 
> Another thing that might be worth checking: in p9_tag_alloc() (net/9p/client.c)
> before
>         req->status = REQ_STATUS_ALLOC;
> check that req->status == REQ_STATUS_IDLE and yell if it isn't.
> 

diff --git a/net/9p/client.c b/net/9p/client.c
index 6f4c4c8..16a17a0 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -286,6 +286,8 @@ p9_tag_alloc(struct p9_client *c, u16 tag, unsigned int max_size)
        p9pdu_reset(req->rc);

        req->tc->tag = tag-1;
+       if (WARN_ON(req->status != REQ_STATUS_IDLE))
+               pr_err("req->status: %d\n", req->status);
        req->status = REQ_STATUS_ALLOC;

        return req;

[  150.155020] ------------[ cut here ]------------
[  150.156700] WARNING: CPU: 2 PID: 2304 at ../net/9p/client.c:289 p9_client_prepare_req+0x3b0/0x550()
[  150.158404] Modules linked in:
[  150.160177] CPU: 2 PID: 2304 Comm: trinity-c84 Not tainted 4.1.0-rc8+ #409
[  150.161794] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.7.5.1-0-g8936dbb-20141113_115728-nilsson.home.kraxel.org 04/01/2014
[  150.165540]  0000000000000009 ffff8801ed13f7a8 ffffffff8161434b 0000000000000000
[  150.170939]  0000000000000000 ffff8801ed13f7f8 ffffffff8107cf99 ffff8801f451d5f0
[  150.175942]  ffffffff815f6760 0000000000000003 ffff8800bbac00e0 ffff8800bbac00f0
[  150.178393] Call Trace:
[  150.178883]  [<ffffffff8161434b>] dump_stack+0x45/0x57
[  150.179914]  [<ffffffff8107cf99>] warn_slowpath_common+0x99/0xe0
[  150.181375]  [<ffffffff815f6760>] ? p9_client_prepare_req+0x3b0/0x550
[  150.182597]  [<ffffffff8107d145>] warn_slowpath_null+0x15/0x20
[  150.184067]  [<ffffffff815f6760>] p9_client_prepare_req+0x3b0/0x550
[  150.185043]  [<ffffffff815fb1e2>] p9_client_zc_rpc.constprop.5+0xe2/0x730
[  150.186229]  [<ffffffff8161ba46>] ? _raw_spin_unlock+0x16/0x70
[  150.187049]  [<ffffffff815fb100>] ? p9_client_xattrwalk+0x1b0/0x1b0
[  150.188477]  [<ffffffff812b1b5e>] ? idr_remove+0x2ce/0x420
[  150.189443]  [<ffffffff815f5af0>] ? v9fs_unregister_trans+0x70/0x70
[  150.190456]  [<ffffffff812b1890>] ? idr_mark_full+0x80/0x80
[  150.191489]  [<ffffffff815f5af0>] ? v9fs_unregister_trans+0x70/0x70
[  150.193911]  [<ffffffff8161bae7>] ? _raw_spin_unlock_irqrestore+0x47/0xb0
[  150.195462]  [<ffffffff815fcae4>] ? p9_idpool_put+0x54/0x60
[  150.196729]  [<ffffffff812c9906>] ? iov_iter_advance+0xb6/0x240
[  150.199766]  [<ffffffff815fbea3>] p9_client_write+0x333/0x3d0
[  150.201073]  [<ffffffff811a882e>] ? kasan_kmalloc+0x5e/0x70
[  150.202512]  [<ffffffff815fbb70>] ? p9_client_readdir+0x340/0x340
[  150.204115]  [<ffffffff811c80dd>] ? rw_copy_check_uvector+0xed/0x170
[  150.204960]  [<ffffffff812d82d6>] ? __percpu_counter_add+0x26/0xb0
[  150.206517]  [<ffffffff8113574a>] ? generic_write_checks+0xfa/0x1e0
[  150.208092]  [<ffffffff8125c054>] v9fs_file_write_iter+0xc4/0x200
[  150.209642]  [<ffffffff811c9840>] ? __sb_end_write+0x80/0x80
[  150.211305]  [<ffffffff8125bf90>] ? v9fs_file_lock_dotl+0x3d0/0x3d0
[  150.216908]  [<ffffffff81128d14>] ? ctx_sched_in.isra.57+0xe4/0x2f0
[  150.221069]  [<ffffffff811c6d84>] ? rw_verify_area+0x54/0x150
[  150.222570]  [<ffffffff811c7363>] do_readv_writev+0x223/0x450
[  150.229044]  [<ffffffff811290b7>] ? perf_event_context_sched_in.isra.61+0x127/0x180
[  150.231020]  [<ffffffff8125bf90>] ? v9fs_file_lock_dotl+0x3d0/0x3d0
[  150.231862]  [<ffffffff811c7140>] ? vfs_write+0x1e0/0x1e0
[  150.232583]  [<ffffffff81129b7a>] ? __perf_event_task_sched_in+0x5a/0xa0
[  150.233471]  [<ffffffff810aee08>] ? finish_task_switch+0xa8/0x1b0
[  150.234282]  [<ffffffff8161588b>] ? __schedule+0x3db/0xc90
[  150.235020]  [<ffffffff81616197>] ? schedule+0x57/0xd0
[  150.235709]  [<ffffffff8161ba46>] ? _raw_spin_unlock+0x16/0x70
[  150.236493]  [<ffffffff81618a0f>] ? __mutex_lock_slowpath+0x1df/0x200
[  150.239059]  [<ffffffff811c9840>] ? __sb_end_write+0x80/0x80
[  150.242120]  [<ffffffff81618830>] ? __ww_mutex_lock_interruptible+0xe0/0xe0
[  150.245274]  [<ffffffff810ecfd3>] ? hrtimer_start+0x13/0x20
[  150.247527]  [<ffffffff810ee54d>] ? do_setitimer+0x30d/0x400
[  150.249351]  [<ffffffff811c764e>] vfs_writev+0x4e/0x70
[  150.250378]  [<ffffffff811c8348>] SyS_writev+0xa8/0x140
[  150.251545]  [<ffffffff811c82a0>] ? SyS_readv+0x140/0x140
[  150.253208]  [<ffffffff8161c2ae>] system_call_fastpath+0x12/0x71
[  150.256990] ---[ end trace 4f640ea141ed3d61 ]---
[  150.259076] 9pnet: req->status: 4

> BTW, the loop in there (
>                 /* check again since original check was outside of lock */
>                 while (tag >= c->max_tag) {
> ) looks fishy.  If we get more than P9_ROW_MAXTAG allocations at once,
> we'll have trouble, but I doubt that this is what we are hitting.  In any
> case, adding WARN_ON(c->req[row]); right after

I didn't get this. c->reqs[row] is always non-NULL as it should be, so this warning
will trigger all the time.



>                         row = (tag / P9_ROW_MAXTAG);
> wouldn't hurt.  I would be very surprised if that one triggered, though.
> 

