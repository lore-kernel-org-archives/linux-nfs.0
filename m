Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:45465 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556Ab2FJLoJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Jun 2012 07:44:09 -0400
Message-ID: <4FD4887B.1050901@panasas.com>
Date: Sun, 10 Jun 2012 14:43:55 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Joerg Platte <jplatte@naasa.net>
CC: <linux-kernel@vger.kernel.org>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Kernel 3.4.X NFS regression
References: <4FD47D4E.9070307@naasa.net>
In-Reply-To: <4FD47D4E.9070307@naasa.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Forwarding to Linux-NFS ML

On 06/10/2012 01:56 PM, Joerg Platte wrote:

> All 3.4 kernels I tried so far (3.4, 3.4.1 and 3.4.2) suffer from the 
> same NFS related problem:
> 
> Jun 10 09:23:36 coco kernel: INFO: task kworker/u:1:8 blocked for more 
> than 120 seconds.
> Jun 10 09:23:36 coco kernel: "echo 0 > 
> /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> Jun 10 09:23:36 coco kernel: kworker/u:1     D 002ba28c     0     8 
>   2 0x00000000
> Jun 10 09:23:36 coco kernel:  df465ec0 00000046 00000005 002ba28c 
> 00000000 0000000a 00000282 df465e70
> Jun 10 09:23:36 coco kernel:  df465ec0 df44d2b0 ffff6b60 df465e84 
> df44d2b0 e33fa6b3 00000282 de764ae0
> Jun 10 09:23:36 coco kernel:  ffffffff d78bcfb8 df465e8c c012e0f6 
> df465ea4 c013610c 00000000 d78bcf80
> Jun 10 09:23:36 coco kernel: Call Trace:
> Jun 10 09:23:36 coco kernel:  [<c012e0f6>] ? add_timer+0x11/0x17
> Jun 10 09:23:36 coco kernel:  [<c013610c>] ? queue_delayed_work_on+0x74/0xf0
> Jun 10 09:23:36 coco kernel:  [<c0136ba4>] ? queue_delayed_work+0x1b/0x28
> Jun 10 09:23:36 coco kernel:  [<c0350f5b>] schedule+0x1d/0x4c
> Jun 10 09:23:36 coco kernel:  [<e0cda5f1>] cld_pipe_upcall+0x4e/0x75 [nfsd]
> Jun 10 09:23:36 coco kernel:  [<e0cda678>] 
> nfsd4_cld_grace_done+0x60/0x99 [nfsd]
> Jun 10 09:23:36 coco kernel:  [<e0cd9cb5>] 
> nfsd4_record_grace_done+0x10/0x12 [nfsd]
> Jun 10 09:23:36 coco kernel:  [<e0cd6696>] laundromat_main+0x291/0x2d8 
> [nfsd]
> Jun 10 09:23:36 coco kernel:  [<c0136d2f>] process_one_work+0xff/0x325
> Jun 10 09:23:36 coco kernel:  [<c0134bec>] ? start_worker+0x20/0x23
> Jun 10 09:23:36 coco kernel:  [<e0cd6405>] ? 
> nfsd4_process_open1+0x32b/0x32b [nfsd]
> Jun 10 09:23:36 coco kernel:  [<c013727a>] worker_thread+0xf4/0x39a
> Jun 10 09:23:36 coco kernel:  [<c0137186>] ? rescuer_thread+0x231/0x231
> Jun 10 09:23:36 coco kernel:  [<c013a556>] kthread+0x6c/0x6e
> Jun 10 09:23:36 coco kernel:  [<c013a4ea>] ? kthreadd+0xe8/0xe8
> Jun 10 09:23:36 coco kernel:  [<c035263e>] kernel_thread_helper+0x6/0xd
> 
> A kworker task is stuck in D state and nfs mounts from other clients do 
> not work at all. This happens only on one machine, another one with the 
> same kernel (same self compiled Debian package) works. All previous 3.3 
> kernels work as well.
> 
> Since this machine is remote it is not that easy to bisect to find the 
> bad commit. Are there any other things I can try?
> 
> regards,
> Joerg
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 


