Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43629 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556AbbJGOsr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 10:48:47 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v2 06/16] xprtrdma: Use workqueue to process RPC/RDMA replies
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <56152E96.9040400@dev.mellanox.co.il>
Date: Wed, 7 Oct 2015 10:48:43 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <4983C0DB-A6E3-4A64-B822-8D45D9847C31@oracle.com>
References: <20151006142430.11788.42604.stgit@manet.1015granger.net> <20151006145924.11788.64757.stgit@manet.1015granger.net> <56152E96.9040400@dev.mellanox.co.il>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 7, 2015, at 10:39 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
> 
> On 10/6/2015 5:59 PM, Chuck Lever wrote:
>> The reply tasklet is fast, but it's single threaded. After reply
>> traffic saturates a single CPU, there's no more reply processing
>> capacity.
>> 
>> Replace the tasklet with a workqueue to spread reply handling across
>> all CPUs.  This also moves RPC/RDMA reply handling out of the soft
>> IRQ context and into a context that allows sleeps.
> 
> Hi Chuck,
> 
> I'm probably missing something here, but do you ever schedule in
> the workqueue context? Don't you need to explicitly schedule after
> a jiffie or so the code works also in a non fully preemptable kernel?

Each RPC reply gets its own work request. This is unlike
the tasklet, which continues to run as long as there are
items on xprtrdma’s global tasklet queue.

I can’t think of anything in the current reply handler
that would take longer than a few microseconds to run,
unless there is lock contention on the transport_lock.

wake_up_bit can also be slow sometimes, but it schedules
internally.

Eventually the reply handler will also synchronously
perform R_key invalidation. In that case, I think there
will be an implicit schedule while waiting for the
invalidation to finish.


-—
Chuck Lever



