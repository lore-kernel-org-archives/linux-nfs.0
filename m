Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:64824 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757961Ab2HQM2J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Aug 2012 08:28:09 -0400
Received: by lagy9 with SMTP id y9so2062388lag.19
        for <linux-nfs@vger.kernel.org>; Fri, 17 Aug 2012 05:28:07 -0700 (PDT)
Message-ID: <502E3905.2070709@compcenter.org>
Date: Fri, 17 Aug 2012 16:28:53 +0400
From: "Denis V. Nagorny" <dvnagorny@compcenter.org>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: Randomly inaccessible files through NFS
References: <502B55A3.3030007@compcenter.org> <502E1C38.2060104@compcenter.org> <CAA4Z2ZQR4RVCEzct2AH4yBy=oGkw78M=Gc8pOWC5C0vGbSy-Xg@mail.gmail.com>
In-Reply-To: <CAA4Z2ZQR4RVCEzct2AH4yBy=oGkw78M=Gc8pOWC5C0vGbSy-Xg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

One more observation,
It looks like NFS4ERR_EXPIRED messages are delivered for the process 
blocked in the kernel:

Aug 17 13:18:41 srvmpidev03 kernel: INFO: task bcast2:6338 blocked for 
more than 120 seconds.
Aug 17 13:18:41 srvmpidev03 kernel: "echo 0 > 
/proc/sys/kernel/hung_task_timeout_secs" disables this message.
Aug 17 13:18:41 srvmpidev03 kernel: bcast2        D 000000000000000e     
0  6338      1 0x00000084
Aug 17 13:18:41 srvmpidev03 kernel: ffff880c238b76e8 0000000000000082 
0000000000000000 ffffffffa03a9eed
Aug 17 13:18:41 srvmpidev03 kernel: ffff880621561080 ffff880603c79aa0 
ffff880603c79bc0 00000001004eaf4f
Aug 17 13:18:41 srvmpidev03 kernel: ffff880c23f325f8 ffff880c238b7fd8 
000000000000f598 ffff880c23f325f8
Aug 17 13:18:41 srvmpidev03 kernel: Call Trace:
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffffa03a9eed>] ? 
__put_nfs_open_context+0x4d/0xf0 [nfs]
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff8110d310>] ? 
sync_page+0x0/0x50
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff814daf13>] 
io_schedule+0x73/0xc0
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff8110d34d>] sync_page+0x3d/0x50
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff814db77f>] 
__wait_on_bit+0x5f/0x90
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff8110d503>] 
wait_on_page_bit+0x73/0x80
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff8108e140>] ? 
wake_bit_function+0x0/0x50
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff8110d5aa>] 
__lock_page_or_retry+0x3a/0x60
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff8110e73f>] 
filemap_fault+0x2df/0x500
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff81136fe4>] 
__do_fault+0x54/0x510
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff81137597>] 
handle_pte_fault+0xf7/0xb50
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff811544ca>] ? 
alloc_pages_current+0xaa/0x110
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff81045b77>] ? 
pte_alloc_one+0x37/0x50
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff811381c8>] 
handle_mm_fault+0x1d8/0x2a0
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff810414e9>] 
__do_page_fault+0x139/0x480
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff8112dbc0>] ? 
vma_prio_tree_insert+0x30/0x50
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff8113ac8c>] ? 
__vma_link_file+0x4c/0x80
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff8113b45b>] ? 
vma_link+0x9b/0xf0
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff8113d9e9>] ? 
mmap_region+0x269/0x590
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff814e007e>] 
do_page_fault+0x3e/0xa0
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff814dd425>] 
page_fault+0x25/0x30
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff8126e3af>] ? 
__clear_user+0x3f/0x70
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff8126e391>] ? 
__clear_user+0x21/0x70
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff8126e418>] 
clear_user+0x38/0x40
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff811c4e1d>] padzero+0x2d/0x40
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff811c6e3e>] 
load_elf_binary+0x88e/0x1b10
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff811330f1>] ? 
follow_page+0x321/0x460
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff8113839f>] ? 
__get_user_pages+0x10f/0x420
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff811c38dc>] ? 
load_misc_binary+0xac/0x3e0
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff81179f2b>] 
search_binary_handler+0x10b/0x350
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff8117b0b9>] 
do_execve+0x239/0x310
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff8126e4ca>] ? 
strncpy_from_user+0x4a/0x90
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff810095ca>] 
sys_execve+0x4a/0x80
Aug 17 13:18:41 srvmpidev03 kernel: [<ffffffff8100b5ca>] 
stub_execve+0x6a/0xc0


17.08.2012 14:50, Adrien Kunysz пишет:
> I would try to tcpdump all NFS traffic starting when the client is in
> the "stable" state (including the MOUNT call). Once it's in the
> "unstable" state, I would stop the capture then try to figure out
> exactly at what point it switched from "stable" to "unstable" (maybe
> figure out when exactly the NFS4ERR_EXPIRED start to happen) and track
> it down to a specific NFS pattern.
>
> I don't know much about NFS really so I cannot be more specific. Yes,
> this probably requires lot of storage to capture all the traffic and
> lot of time to analyse the captured data.
>
> On Fri, Aug 17, 2012 at 11:26 AM, Denis V. Nagorny
> <dvnagorny@compcenter.org> wrote:
>> 15.08.2012 11:54, Denis V. Nagorny пишет:
>>
>>> Hello,
>>>
>>> Using Scientific Linux 6.1 (I think it's equal to RH EL 6.1) we met the
>>> strange issue.  Several last months we have problem. After one or two days
>>> of successful work, files on nfs server begins to be randomly unacessible.
>>> I doesn't mean that files becames hidden or something like this. It means
>>> that attempts to open some random files may be unsuccessful. Usually restart
>>> of nfs server makes situation better but for several days only. There are no
>>> any messages about errors in logs on server and clients machines. Can
>>> anybody point me how can I try to understand what happens at least. Sorry
>>> for my english.
>>>
>>> Denis.
>>
>> Hello again,
>>
>> I've made some additional experiments. It looks like nfs clients can be in
>> one of two states: "quite stable" and "quite unstable". Clients are usually
>> stable but after some heavy job with a lot of I/O with NFS server clients
>> become "quite unstable" and fails even with single file operations with NFS
>> server. In this state I can't unmount NFS shares and so on.  I've tried to
>> analyse with wireshark and found that in unstable state there are a lot of
>> NFS4ERR_EXPIRED answers from NFS server.  In one of experiments I've changed
>> NICs in both machines involved - result the same. So I'm still looking for
>> the ways to understand the problem.
>> Can anybody give me any advices?
>>
>> Denis
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

