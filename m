Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33709 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753872AbbJGPRx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 11:17:53 -0400
Received: by wiclk2 with SMTP id lk2so218695219wic.0
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2015 08:17:32 -0700 (PDT)
Subject: Re: [PATCH v2 06/16] xprtrdma: Use workqueue to process RPC/RDMA
 replies
To: Chuck Lever <chuck.lever@oracle.com>
References: <20151006142430.11788.42604.stgit@manet.1015granger.net>
 <20151006145924.11788.64757.stgit@manet.1015granger.net>
 <56152E96.9040400@dev.mellanox.co.il>
 <4983C0DB-A6E3-4A64-B822-8D45D9847C31@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <56153786.2000801@dev.mellanox.co.il>
Date: Wed, 7 Oct 2015 18:17:26 +0300
MIME-Version: 1.0
In-Reply-To: <4983C0DB-A6E3-4A64-B822-8D45D9847C31@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/7/2015 5:48 PM, Chuck Lever wrote:
>
>> On Oct 7, 2015, at 10:39 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
>>
>> On 10/6/2015 5:59 PM, Chuck Lever wrote:
>>> The reply tasklet is fast, but it's single threaded. After reply
>>> traffic saturates a single CPU, there's no more reply processing
>>> capacity.
>>>
>>> Replace the tasklet with a workqueue to spread reply handling across
>>> all CPUs.  This also moves RPC/RDMA reply handling out of the soft
>>> IRQ context and into a context that allows sleeps.
>>
>> Hi Chuck,
>>
>> I'm probably missing something here, but do you ever schedule in
>> the workqueue context? Don't you need to explicitly schedule after
>> a jiffie or so the code works also in a non fully preemptable kernel?
>
> Each RPC reply gets its own work request. This is unlike
> the tasklet, which continues to run as long as there are
> items on xprtrdma’s global tasklet queue.

OK I understand now.

So this and the rest of the series looks good to me.

Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
