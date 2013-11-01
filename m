Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f179.google.com ([209.85.212.179]:57451 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738Ab3KAEiU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Nov 2013 00:38:20 -0400
Received: by mail-wi0-f179.google.com with SMTP id hm4so607956wib.12
        for <linux-nfs@vger.kernel.org>; Thu, 31 Oct 2013 21:38:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131031141538.GA621@fieldses.org>
References: <CA+uAZNPquD-JA1SDpFHtx9ZawQA5=o+fBigOTy+9NEiDL+hmyw@mail.gmail.com>
	<20131031141538.GA621@fieldses.org>
Date: Fri, 1 Nov 2013 10:08:18 +0530
Message-ID: <CA+uAZNO7VrBA1MLgGoqGpXGPHMMy0VF_3KBr93Y5w1M=ZO7s4w@mail.gmail.com>
Subject: Re: Need help with NFS Server SUNRPC performance issue
From: Shyam Kaushik <shyamnfs1@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

Yes I am using NFSv4. I am willing to test any kernel/patches that you
suggest. Please let me know where we can start. Also I have
sunrpc/nfsd/lockd etc compiled as modules & can readily debug it as
needed.

I digged this a bit further & I think you are on dot that the issue is
with rcp layer + buffer space. From tcpdump I see that the initial
request comes from client to server according to the number of
outstanding IOs that fio initiates, but then there are multiple back &
forth packets (RPC continuation & acks) that is slowing up things. I
thought waking up the NFSD threads that are sleeping within
svc_get_next_xprt() was an issue initially & made the
schedule_timeout() with a smaller timeout, but then all the threads
wakeup & saw there was no work enqueued & went back to sleep again. So
from sunrpc server standpoint enqueue() is not happening as it should
be.

In the meantime from NFS client side I see a single rpc thread thats
working all the time.

Thanks.

--Shyam



On Thu, Oct 31, 2013 at 7:45 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Oct 31, 2013 at 12:19:01PM +0530, Shyam Kaushik wrote:
>> Hi Folks,
>>
>> I am chasing a NFS server performance issue on Ubuntu
>> 3.8.13-030813-generic kernel. We setup 32 NFSD threads on our NFS
>> server.
>>
>> The issue is:
>> # I am using fio to generate 4K random writes (over a sync mounted NFS
>> server filesystem) with 64 outstanding IOs per job for 10 jobs. fio
>> direct flag is set.
>> # When doing fio randwrite 4K IOs, realized that we cannot exceed 2.5K
>> IOPs on the NFS server from a single client.
>> # With multiple clients we can do more IOPs (like 3x more IOPs with 3 clients)
>> # Further chasing the issue, I realized that at any point in time only
>> 8 NFSD threads are active doing vfs_wrte(). Remaining 24 threads are
>> sleeping within svc_recv()/svc_get_next_xprt().
>> # First I thought its TCP socket contention/sleeping at the wrong
>> time. I introduced a one-sec sleep around vfs_write() within NFSD
>> using msleep(). With this I can clearly see that only 8 NFSD threads
>> are active doing the write+sleep loop while all other threads are
>> sleeping.
>> # I enabled rpcdebug/nfs debug on NFS client side + used tcpdump on
>> NFS server side to confirm that client is queuing all the outstanding
>> IOs concurrently & its not a NFS client side problem.
>>
>> Now the question is what is holding up the sunrpc layer to do only 8
>> outstanding IOs? Is there some TCP level buffer size limitation or so
>> that is causing this issue? I also added counters around which all
>> nfsd threads get to process the SVC xport & I see always only the
>> first 10 threads being used up all the time. The rest of the NFSD
>> threads never receive a packet at all to handle.
>>
>> I already setup number of RPC slots tuneable to 128 on both server &
>> client before the mount, so this is not the issue.
>>
>> Are there some other tuneables that control this behaviour? I think if
>> I cross the 8 concurrent IOs per client<>server, I will be able to get
>> >2.5K IOPs.
>>
>> I also confirmed that each NFS multi-step operation that comes from
>> client has an OP_PUTFH/OP_WRITE/OP_GETATTR. I dont see any other
>> unnecessary NFS packets in the flow.
>>
>> Any help/inputs on this topic greatly appreciated.
>
> There's some logic in the rpc layer that tries not to accept requests
> unless there's adequate send buffer space for the worst case reply.  It
> could be that logic interfering.....  I'm not sure how to test that
> quickly.
>
> Would you be willing to test an upstream kernel and/or some patches?
>
> Sounds like you're using only NFSv4?
>
> --b.
