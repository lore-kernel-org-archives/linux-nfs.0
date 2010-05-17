Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43331 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067Ab0EQKil (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 May 2010 06:38:41 -0400
Received: by wyb39 with SMTP id 39so304582wyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 17 May 2010 03:38:40 -0700 (PDT)
Message-ID: <4BF11C37.3020703@panasas.com>
Date: Mon, 17 May 2010 13:36:39 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
CC: linux-nfs@vger.kernel.org, bhalevy@panasas.com
Subject: Re: [PATCH] pnfs: devide put_lseg and return_layout_barrier into
 different workqueue
References: <20100517095941.GA10823@MDS-78.localdomain> <4BF11B7F.2090800@panasas.com>
In-Reply-To: <4BF11B7F.2090800@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/17/2010 01:33 PM, Boaz Harrosh wrote:
> On 05/17/2010 12:59 PM, Zhang Jingwang wrote:
>> These two functions mustn't be called from the same workqueue. Otherwise
>> deadlock may occur. So we schedule the return_layout_barrier to nfsiod.
>> nfsiod may not be a good choice, maybe we should setup a new workqueue
>> to do the job.
> 
> Please give more information. When does it happen that pnfs_XXX_done will
> return -EAGAIN?
> 
> What is the stack trace of the deadlock?
> 
> And please rebase that patch on the latest changes to _pnfs_return_layout().
> but since in the new code _pnfs_return_layout() must be called with NO_WAIT
> if called from the nfsiod then you cannot call pnfs_initiate_write/read() right
> after. For writes you can get by with doing nothing because the write-back
> thread will kick in soon enough. For reads I'm not sure, you'll need to send
> me more information, stack trace.
> 
> Or you can wait for the new state machine.
> 
> Boaz
> 

BTW: I agree that current code is crap. Do to bugs in the osd library
we never return -EAGAIN. so I never tried that code. But it should theoretically
trigger when an OSD reboots or a network connection fails.

>>
>> Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
>> ---

Thanks
Boaz
