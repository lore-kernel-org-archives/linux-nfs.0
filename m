Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:34745 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842Ab2FKNcl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jun 2012 09:32:41 -0400
Message-ID: <4FD5F35A.3000903@panasas.com>
Date: Mon, 11 Jun 2012 16:32:10 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>, bfields <bfields@fieldses.org>,
        Steve Dickson <steved@redhat.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Joerg Platte <jplatte@naasa.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Hans de Bruin <jmdebruin@xmsnet.nl>
Subject: Re: Kernel 3.4.X NFS server regression
References: <4FD47D4E.9070307@naasa.net> <1339340441.4751.1.camel@lade.trondhjem.org> <20120611121634.GB7654@fieldses.org> <20120611083932.24e27e39@corrin.poochiereds.net>
In-Reply-To: <20120611083932.24e27e39@corrin.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/11/2012 03:39 PM, Jeff Layton wrote:

> On Mon, 11 Jun 2012 08:16:34 -0400
> bfields <bfields@fieldses.org> wrote:
> 
>> On Sun, Jun 10, 2012 at 03:00:42PM +0000, Myklebust, Trond wrote:
>>> Cc: linux-nfs@vger.kernel.org + bfields and changing title to label it
>>> as a server regression since that is what the trace appears to imply.
>>>
>>> On Sun, 2012-06-10 at 12:56 +0200, Joerg Platte wrote:
>>>> All 3.4 kernels I tried so far (3.4, 3.4.1 and 3.4.2) suffer from the 
>>>> same NFS related problem:
>>>>
>>>> Jun 10 09:23:36 coco kernel: INFO: task kworker/u:1:8 blocked for more 
>>>> than 120 seconds.
>>>> Jun 10 09:23:36 coco kernel: "echo 0 > 
>>>> /proc/sys/kernel/hung_task_timeout_secs" disables this message.
>>>> Jun 10 09:23:36 coco kernel: kworker/u:1     D 002ba28c     0     8 
>>>>   2 0x00000000
>>>> Jun 10 09:23:36 coco kernel:  df465ec0 00000046 00000005 002ba28c 
>>>> 00000000 0000000a 00000282 df465e70
>>>> Jun 10 09:23:36 coco kernel:  df465ec0 df44d2b0 ffff6b60 df465e84 
>>>> df44d2b0 e33fa6b3 00000282 de764ae0
>>>> Jun 10 09:23:36 coco kernel:  ffffffff d78bcfb8 df465e8c c012e0f6 
>>>> df465ea4 c013610c 00000000 d78bcf80
>>>> Jun 10 09:23:36 coco kernel: Call Trace:
>>>> Jun 10 09:23:36 coco kernel:  [<c012e0f6>] ? add_timer+0x11/0x17
>>>> Jun 10 09:23:36 coco kernel:  [<c013610c>] ? queue_delayed_work_on+0x74/0xf0
>>>> Jun 10 09:23:36 coco kernel:  [<c0136ba4>] ? queue_delayed_work+0x1b/0x28
>>>> Jun 10 09:23:36 coco kernel:  [<c0350f5b>] schedule+0x1d/0x4c
>>>> Jun 10 09:23:36 coco kernel:  [<e0cda5f1>] cld_pipe_upcall+0x4e/0x75 [nfsd]
>>>> Jun 10 09:23:36 coco kernel:  [<e0cda678>] 
>>>> nfsd4_cld_grace_done+0x60/0x99 [nfsd]
>>>> Jun 10 09:23:36 coco kernel:  [<e0cd9cb5>] 
>>>> nfsd4_record_grace_done+0x10/0x12 [nfsd]
>>>> Jun 10 09:23:36 coco kernel:  [<e0cd6696>] laundromat_main+0x291/0x2d8 
>>>> [nfsd]
>>>> Jun 10 09:23:36 coco kernel:  [<c0136d2f>] process_one_work+0xff/0x325
>>>> Jun 10 09:23:36 coco kernel:  [<c0134bec>] ? start_worker+0x20/0x23
>>>> Jun 10 09:23:36 coco kernel:  [<e0cd6405>] ? 
>>>> nfsd4_process_open1+0x32b/0x32b [nfsd]
>>>> Jun 10 09:23:36 coco kernel:  [<c013727a>] worker_thread+0xf4/0x39a
>>>> Jun 10 09:23:36 coco kernel:  [<c0137186>] ? rescuer_thread+0x231/0x231
>>>> Jun 10 09:23:36 coco kernel:  [<c013a556>] kthread+0x6c/0x6e
>>>> Jun 10 09:23:36 coco kernel:  [<c013a4ea>] ? kthreadd+0xe8/0xe8
>>>> Jun 10 09:23:36 coco kernel:  [<c035263e>] kernel_thread_helper+0x6/0xd
>>>>
>>>> A kworker task is stuck in D state and nfs mounts from other clients do 
>>>> not work at all. This happens only on one machine, another one with the 
>>>> same kernel (same self compiled Debian package) works. All previous 3.3 
>>>> kernels work as well.
>>>>
>>>> Since this machine is remote it is not that easy to bisect to find the 
>>>> bad commit. Are there any other things I can try?
>>
>> If you create a directory named /var/lib/nfs/v4recovery/, does the
>> problem go away?
>>
>> My guess would be that it's trying to upcall to the new reboot-recovery
>> state daemon, and you don't have that running.
>>
>> Before the addition of that upcall state was kept in
>> /var/lib/nfs/v4recovery.  So we decide whether to use the old method or
>> the new one by checking for the existance of that path.
>>
>> But I'm guessing we were wrong to assume that existing setups that
>> people perceived as working would have that path, because the failures
>> in the absence of that path were probably less obvious.
>>
>> --b.
> 
> This sounds like the same problem that Hans reported as well. I've not
> been able to reproduce that so far. Here's what I get when I start nfsd
> with no v4recoverdir and nfsdcld isn't running:
> 
> [  109.715080] NFSD: starting 90-second grace period
> [  229.984220] NFSD: Unable to end grace period: -110
> 
> What I don't quite understand is why the queue_timeout job isn't
> getting run here. What should happen is that 30s after upcall,
> rpc_timeout_upcall_queue should run. The message will be found to be
> still sitting on the , so it should set its status to -ETIMEDOUT
> and wake up the caller.
> 
> I can only assume that the queue_timeout job isn't getting run for some
> reason, but I'm unclear on why that would be.
> 


Regression fixing aside. I would consider changing the all mechanism to
a call_usermodehelper mechanism. Not only it cuts the in-kernel code
to 1/3, it also cuts user-mode code to 1/3. And specially it relives you
of any special daemon setup dependency. All you do is run an app/script
that does what it does when it does it, directly without anyone waiting
and/or any kind of handshake.

It is easy to pass any kind of parameters from Kernel to user-mode. Passing
info from user-mode to Kernel is also easy by setting up a sysfs connection
point.

And most important there are no timeouts in the new-kernel vs old user-mode.
If the script/app does not exists the call_usermodehelper returns immediately
and the old behavior can be used.

And lastly if persistent performance is an issue in the steady state. (since
calling call_usermodehelper in the hot path can be slow at times) Then I
would consider that the init script ran at startup via call_usermodehelper
then sets up a faster communication channel like a udev even and/or some
other event mechanism. In any way the old dual local-RPC channel has proved
to be a pain in the ass.

(BTW: if you attempt it you will see that so many lines of code where eliminated
 you might consider it for a Regression fixing to @stable)

Thank to Steve Dickson who suggested this wonderful idea when I had the same
exact problem. I'm just repeating his suggestion, and in light of the experience
of implementing both methods.

Just my $0.017
Boaz
