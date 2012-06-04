Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp10.mail.sp.isp-net.nl ([217.149.192.65]:47469 "EHLO
	smtp10.mail.sp.isp-net.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172Ab2FDUNs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2012 16:13:48 -0400
Message-ID: <4FCD16F5.20407@xmsnet.nl>
Date: Mon, 04 Jun 2012 22:13:41 +0200
From: Hans de Bruin <jmdebruin@xmsnet.nl>
MIME-Version: 1.0
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: nfsroot client will not start firefox or thunderbird from 3.4.0
 nfsserver
References: <4FC3F9F6.7010107@xmsnet.nl> <4FC913FC.2020401@xmsnet.nl> <4FCB7C11.7070300@xmsnet.nl> <4FCC8E6D.9020106@openvz.org>
In-Reply-To: <4FCC8E6D.9020106@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/04/2012 12:31 PM, Konstantin Khlebnikov wrote:
> Hans de Bruin wrote:
>> On 06/01/2012 09:11 PM, Hans de Bruin wrote:
>>> On 05/29/2012 12:19 AM, Hans de Bruin wrote:
>>>> I just upgraded my home server from kernel 3.3.5 to 3.4.0 and ran into
>>>> some trouble. My laptop, a nfsroot client, will not run firefox and
>>>> thunderbird anymore. When I start these programs from an xterm, the
>>>> cursor goes to the next line and waits indefinitely.
>>>>
>>>> I do not know if there is any order is lsof's output. A lsof | grep
>>>> firefox or thunderbird shows ......./.parentlock as the last line.
>>>>
>>>> It does not matter whether the client is running a 3.4.0 or a 3.3.0
>>>> kernel, or if the server is running on top of xen or not.
>>>>
>>>> There is some noise in the servers dmesg:
>>>>
>>>> [ 241.256684] INFO: task kworker/u:2:801 blocked for more than 120
>>>> seconds.
>>>> [ 241.256691] "echo 0> /proc/sys/kernel/hung_task_timeout_secs"
>>>
>>> ...
>>>
>>> On a almost identical testsystem firefox en thunderbird segfault after
>>> upgrading to 3.4.0. I would have been nice if it would behave exaclty
>>> like my home server. I bisected the segfault to:
>>>
>>> commit 0fc9d1040313047edf6a39fd4d7c7defdca97c62
>>> Author: Konstantin Khlebnikov<khlebnikov@openvz.org>
>>> Date: Wed Mar 28 14:42:54 2012 -0700
>>>
>>> radix-tree: use iterators in find_get_pages* functions
>>>
>>>
>>> When I revert that on top of 3.4.0 the segfaults are gone but both
>>> firefox en thunderbird go in the lets wait indefinitely mode like the
>>> homeserver.
>>>
>>> I am going to make a bit-wise copy from from my homeserver to my
>>> testserver and try again.
>>>
>>
>> The bit-wise copy also segfaults firefox and thunderbird at the same
>> commit.
>>
>
> I think bug somewhere in NFS, that patch only highlighted it.
> Please, try to run it with debug patch from attachment.

Before I can start firefox from an xterm the lines below are shown on 
the server:

[  241.260076] INFO: task kworker/u:2:791 blocked for more than 120 seconds.
[  241.260084] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[  241.260090] kworker/u:2     D 000000000000000c     0   791      2 
0x00000000
[  241.260102]  ffff8801390b1cf0 0000000000000046 0000000000012d00 
0000000000012d00
[  241.260113]  0000000000012d00 ffff880139141470 0000000000012d00 
ffff8801390b1fd8
[  241.260124]  ffff8801390b1fd8 0000000000012d00 ffff880139cdc420 
ffff880139141470
[  241.260135] Call Trace:
[  241.260152]  [<ffffffff81513116>] schedule+0x64/0x66
[  241.260162]  [<ffffffff812005a6>] cld_pipe_upcall+0x95/0xd1
[  241.260173]  [<ffffffff811faae5>] ? nfsd4_exchange_id+0x23e/0x23e
[  241.260182]  [<ffffffff81200a5e>] nfsd4_cld_grace_done+0x50/0x8a
[  241.260191]  [<ffffffff81200f8b>] nfsd4_record_grace_done+0x18/0x1a
[  241.260200]  [<ffffffff811fab2f>] laundromat_main+0x4a/0x213
[  241.260210]  [<ffffffff81069aeb>] ? need_resched+0x1e/0x28
[  241.260218]  [<ffffffff81513035>] ? __schedule+0x49d/0x4b5
[  241.260227]  [<ffffffff811faae5>] ? nfsd4_exchange_id+0x23e/0x23e
[  241.260237]  [<ffffffff8105b8ad>] process_one_work+0x190/0x28d
[  241.260248]  [<ffffffff8105c4e7>] worker_thread+0x105/0x189
[  241.260260]  [<ffffffff81513a75>] ? _raw_spin_unlock_irqrestore+0x1a/0x1d
[  241.260274]  [<ffffffff8105c3e2>] ? manage_workers.clone.17+0x173/0x173
[  241.260287]  [<ffffffff8105ff30>] kthread+0x8a/0x92
[  241.260325]  [<ffffffff815158a4>] kernel_thread_helper+0x4/0x10
[  241.260335]  [<ffffffff8105fea6>] ? 
kthread_freezable_should_stop+0x47/0x47
[  241.260343]  [<ffffffff815158a0>] ? gs_change+0x13/0x13
[  361.260025] INFO: task kworker/u:2:791 blocked for more than 120 seconds.
[  361.260032] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[  361.260039] kworker/u:2     D 000000000000000c     0   791      2 
0x00000000
[  361.260051]  ffff8801390b1cf0 0000000000000046 0000000000012d00 
0000000000012d00
[  361.260062]  0000000000012d00 ffff880139141470 0000000000012d00 
ffff8801390b1fd8
[  361.260072]  ffff8801390b1fd8 0000000000012d00 ffff880139cdc420 
ffff880139141470
[  361.260084] Call Trace:
[  361.260099]  [<ffffffff81513116>] schedule+0x64/0x66
[  361.260110]  [<ffffffff812005a6>] cld_pipe_upcall+0x95/0xd1
[  361.260121]  [<ffffffff811faae5>] ? nfsd4_exchange_id+0x23e/0x23e
[  361.260130]  [<ffffffff81200a5e>] nfsd4_cld_grace_done+0x50/0x8a
[  361.260139]  [<ffffffff81200f8b>] nfsd4_record_grace_done+0x18/0x1a
[  361.260148]  [<ffffffff811fab2f>] laundromat_main+0x4a/0x213
[  361.260158]  [<ffffffff81069aeb>] ? need_resched+0x1e/0x28
[  361.260166]  [<ffffffff81513035>] ? __schedule+0x49d/0x4b5
[  361.260175]  [<ffffffff811faae5>] ? nfsd4_exchange_id+0x23e/0x23e
[  361.260185]  [<ffffffff8105b8ad>] process_one_work+0x190/0x28d
[  361.260194]  [<ffffffff8105c4e7>] worker_thread+0x105/0x189
[  361.260203]  [<ffffffff81513a75>] ? _raw_spin_unlock_irqrestore+0x1a/0x1d
[  361.260213]  [<ffffffff8105c3e2>] ? manage_workers.clone.17+0x173/0x173
[  361.260222]  [<ffffffff8105ff30>] kthread+0x8a/0x92
[  361.260231]  [<ffffffff815158a4>] kernel_thread_helper+0x4/0x10
[  361.260241]  [<ffffffff8105fea6>] ? 
kthread_freezable_should_stop+0x47/0x47
[  361.260249]  [<ffffffff815158a0>] ? gs_change+0x13/0x13
[  481.260010] INFO: task kworker/u:2:791 blocked for more than 120 seconds.
[  481.260019] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" 
disables this message.
[  481.260028] kworker/u:2     D 000000000000000c     0   791      2 
0x00000000
[  481.260043]  ffff8801390b1cf0 0000000000000046 0000000000012d00 
0000000000012d00
[  481.260058]  0000000000012d00 ffff880139141470 0000000000012d00 
ffff8801390b1fd8
[  481.260073]  ffff8801390b1fd8 0000000000012d00 ffff880139cdc420 
ffff880139141470
[  481.260088] Call Trace:
[  481.260107]  [<ffffffff81513116>] schedule+0x64/0x66
[  481.260120]  [<ffffffff812005a6>] cld_pipe_upcall+0x95/0xd1
[  481.260135]  [<ffffffff811faae5>] ? nfsd4_exchange_id+0x23e/0x23e
[  481.260147]  [<ffffffff81200a5e>] nfsd4_cld_grace_done+0x50/0x8a
[  481.260159]  [<ffffffff81200f8b>] nfsd4_record_grace_done+0x18/0x1a
[  481.260172]  [<ffffffff811fab2f>] laundromat_main+0x4a/0x213
[  481.260185]  [<ffffffff81069aeb>] ? need_resched+0x1e/0x28
[  481.260196]  [<ffffffff81513035>] ? __schedule+0x49d/0x4b5
[  481.260206]  [<ffffffff811faae5>] ? nfsd4_exchange_id+0x23e/0x23e
[  481.260215]  [<ffffffff8105b8ad>] process_one_work+0x190/0x28d
[  481.260225]  [<ffffffff8105c4e7>] worker_thread+0x105/0x189
[  481.260234]  [<ffffffff81513a75>] ? _raw_spin_unlock_irqrestore+0x1a/0x1d
[  481.260243]  [<ffffffff8105c3e2>] ? manage_workers.clone.17+0x173/0x173
[  481.260252]  [<ffffffff8105ff30>] kthread+0x8a/0x92
[  481.260262]  [<ffffffff815158a4>] kernel_thread_helper+0x4/0x10
[  481.260271]  [<ffffffff8105fea6>] ? 
kthread_freezable_should_stop+0x47/0x47
[  481.260279]  [<ffffffff815158a0>] ? gs_change+0x13/0x13


dmesg on the client side:

[   27.607606] gtk-query-immod[1976]: segfault at 1d2d1f30 ip b7734391 
sp bfe3e984 error 4 in ld-2.13.so[b772b000+1d000]
[   48.136763] start_kdeinit (2086): /proc/2086/oom_adj is deprecated, 
please use /proc/2086/oom_score_adj instead.
[   75.801804] blueman-applet[2150]: segfault at 1cf2cf30 ip b7741391 sp 
bfb456b8 error 4 in ld-2.13.so[b7738000+1d000]
[  140.226371] firefox[2175]: segfault at 1b065f30 ip b76f6391 sp 
bfb15db8 error 4 in ld-2.13.so[b76ed000+1d000]


The firefox dump on client side produces no messages on server side.

md5sum's of ld-2.13.so are equal on server and client and across 
kernlversions.



Did I miss the output off the debug patch?


-- 
Hans




