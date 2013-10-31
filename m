Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34147 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754302Ab3JaOPj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Oct 2013 10:15:39 -0400
Date: Thu, 31 Oct 2013 10:15:38 -0400
To: Shyam Kaushik <shyamnfs1@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Need help with NFS Server SUNRPC performance issue
Message-ID: <20131031141538.GA621@fieldses.org>
References: <CA+uAZNPquD-JA1SDpFHtx9ZawQA5=o+fBigOTy+9NEiDL+hmyw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+uAZNPquD-JA1SDpFHtx9ZawQA5=o+fBigOTy+9NEiDL+hmyw@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 31, 2013 at 12:19:01PM +0530, Shyam Kaushik wrote:
> Hi Folks,
> 
> I am chasing a NFS server performance issue on Ubuntu
> 3.8.13-030813-generic kernel. We setup 32 NFSD threads on our NFS
> server.
> 
> The issue is:
> # I am using fio to generate 4K random writes (over a sync mounted NFS
> server filesystem) with 64 outstanding IOs per job for 10 jobs. fio
> direct flag is set.
> # When doing fio randwrite 4K IOs, realized that we cannot exceed 2.5K
> IOPs on the NFS server from a single client.
> # With multiple clients we can do more IOPs (like 3x more IOPs with 3 clients)
> # Further chasing the issue, I realized that at any point in time only
> 8 NFSD threads are active doing vfs_wrte(). Remaining 24 threads are
> sleeping within svc_recv()/svc_get_next_xprt().
> # First I thought its TCP socket contention/sleeping at the wrong
> time. I introduced a one-sec sleep around vfs_write() within NFSD
> using msleep(). With this I can clearly see that only 8 NFSD threads
> are active doing the write+sleep loop while all other threads are
> sleeping.
> # I enabled rpcdebug/nfs debug on NFS client side + used tcpdump on
> NFS server side to confirm that client is queuing all the outstanding
> IOs concurrently & its not a NFS client side problem.
> 
> Now the question is what is holding up the sunrpc layer to do only 8
> outstanding IOs? Is there some TCP level buffer size limitation or so
> that is causing this issue? I also added counters around which all
> nfsd threads get to process the SVC xport & I see always only the
> first 10 threads being used up all the time. The rest of the NFSD
> threads never receive a packet at all to handle.
> 
> I already setup number of RPC slots tuneable to 128 on both server &
> client before the mount, so this is not the issue.
> 
> Are there some other tuneables that control this behaviour? I think if
> I cross the 8 concurrent IOs per client<>server, I will be able to get
> >2.5K IOPs.
> 
> I also confirmed that each NFS multi-step operation that comes from
> client has an OP_PUTFH/OP_WRITE/OP_GETATTR. I dont see any other
> unnecessary NFS packets in the flow.
> 
> Any help/inputs on this topic greatly appreciated.

There's some logic in the rpc layer that tries not to accept requests
unless there's adequate send buffer space for the worst case reply.  It
could be that logic interfering.....  I'm not sure how to test that
quickly.

Would you be willing to test an upstream kernel and/or some patches?

Sounds like you're using only NFSv4?

--b.
