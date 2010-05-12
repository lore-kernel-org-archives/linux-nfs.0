From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: NFS client stall
Date: Wed, 12 May 2010 12:43:15 -0400
Message-ID: <1273682595.2810.86.camel@localhost.localdomain>
References: <DF18387A-0E5C-493B-B4F9-774D2068E4CD@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Andy Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28297 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756528Ab0ELQnc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 May 2010 12:43:32 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4CGhG2U016465
	for <linux-nfs@vger.kernel.org>; Wed, 12 May 2010 09:43:16 -0700 (PDT)
In-Reply-To: <DF18387A-0E5C-493B-B4F9-774D2068E4CD@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-05-12 at 11:17 -0400, Andy Adamson wrote: 
> I've seen the following intermittently while running the Connecatathon  
> special 'write/read 30MB file' test.  It's always been with the pNFS  
> client, either running with the pNFS file module installed, or running  
> without it installed (NFSv4.1 only). But given the intermittent  
> behavior, that could just be because I run a lot more tests on the  
> pNFS kernel.
> 
> I've seen this with 2.6.34-rc3 and up.
> 
> Any ideas?
> 
> -->Andy
> 
> May 11 19:35:41 fedora-64 kernel: INFO: task bigfile:2174 blocked for  
> more than
> 120 seconds.
> May 11 19:35:41 fedora-64 kernel: "echo 0 > /proc/sys/kernel/ 
> hung_task_timeout_s
> ecs" disables this message.
> May 11 19:35:41 fedora-64 kernel: bigfile       D ffff88005b10d380      
> 0  2174
>   2137 0x00000084
> May 11 19:35:41 fedora-64 kernel: ffff88005ac83c28 0000000000000082  
> 000000000000
> 0000 0010000000000000
> May 11 19:35:41 fedora-64 kernel: ffff88005ac83fd8 ffff8800520d0000  
> 000000000001
> 3780 ffff88005ac83fd8
> May 11 19:35:41 fedora-64 kernel: 0000000000013780 0000000000013780  
> 000000000001
> 3780 0000000000013780
> May 11 19:35:41 fedora-64 kernel: Call Trace:
> May 11 19:35:41 fedora-64 kernel: [<ffffffff810aae7a>] ? sync_page 
> +0x0/0x4a
> May 11 19:35:41 fedora-64 kernel: [<ffffffff813b1b26>] io_schedule 
> +0x3d/0x52
> May 11 19:35:41 fedora-64 kernel: [<ffffffff810aaec0>] sync_page 
> +0x46/0x4a
> May 11 19:35:41 fedora-64 kernel: [<ffffffff813b1f61>]  
> __wait_on_bit_lock+0x46/0
> x8f
> May 11 19:35:41 fedora-64 kernel: [<ffffffff8103cee6>] ?  
> release_console_sem+0x1
> bd/0x1ee
> May 11 19:35:41 fedora-64 kernel: [<ffffffff810aae20>] __lock_page 
> +0x66/0x6d
> May 11 19:35:41 fedora-64 kernel: [<ffffffff81055ad5>] ?  
> wake_bit_function+0x0/0
> x33
> May 11 19:35:41 fedora-64 kernel: [<ffffffff810aae63>] lock_page+0x3c/ 
> 0x41
> May 11 19:35:41 fedora-64 kernel: [<ffffffff810ab533>] filemap_fault 
> +0xc3/0x30b
> May 11 19:35:41 fedora-64 kernel: [<ffffffff810c3202>] __do_fault 
> +0x54/0x416
> May 11 19:35:41 fedora-64 kernel: [<ffffffff810c39fa>] handle_mm_fault 
> +0x436/0x82b
> May 11 19:35:41 fedora-64 kernel: [<ffffffff810c7f49>] ? do_mmap_pgoff 
> +0x290/0x2f3
> May 11 19:35:41 fedora-64 kernel: [<ffffffff813b64e8>] do_page_fault 
> +0x25e/0x273
> May 11 19:35:41 fedora-64 kernel: [<ffffffff813b3bb5>] page_fault 
> +0x25/0x30
> 
> 

The above is just an ordinary page fault. Something else is apparently
holding a lock on the page and so you are waiting for it to be released.

Is there a page lock leak somewhere in the pNFS client perhaps?

Cheers
  Trond
