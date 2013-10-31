Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f193.google.com ([209.85.212.193]:53905 "EHLO
	mail-wi0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358Ab3JaGtD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Oct 2013 02:49:03 -0400
Received: by mail-wi0-f193.google.com with SMTP id cb5so568907wib.0
        for <linux-nfs@vger.kernel.org>; Wed, 30 Oct 2013 23:49:01 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 31 Oct 2013 12:19:01 +0530
Message-ID: <CA+uAZNPquD-JA1SDpFHtx9ZawQA5=o+fBigOTy+9NEiDL+hmyw@mail.gmail.com>
Subject: Need help with NFS Server SUNRPC performance issue
From: Shyam Kaushik <shyamnfs1@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Folks,

I am chasing a NFS server performance issue on Ubuntu
3.8.13-030813-generic kernel. We setup 32 NFSD threads on our NFS
server.

The issue is:
# I am using fio to generate 4K random writes (over a sync mounted NFS
server filesystem) with 64 outstanding IOs per job for 10 jobs. fio
direct flag is set.
# When doing fio randwrite 4K IOs, realized that we cannot exceed 2.5K
IOPs on the NFS server from a single client.
# With multiple clients we can do more IOPs (like 3x more IOPs with 3 clients)
# Further chasing the issue, I realized that at any point in time only
8 NFSD threads are active doing vfs_wrte(). Remaining 24 threads are
sleeping within svc_recv()/svc_get_next_xprt().
# First I thought its TCP socket contention/sleeping at the wrong
time. I introduced a one-sec sleep around vfs_write() within NFSD
using msleep(). With this I can clearly see that only 8 NFSD threads
are active doing the write+sleep loop while all other threads are
sleeping.
# I enabled rpcdebug/nfs debug on NFS client side + used tcpdump on
NFS server side to confirm that client is queuing all the outstanding
IOs concurrently & its not a NFS client side problem.

Now the question is what is holding up the sunrpc layer to do only 8
outstanding IOs? Is there some TCP level buffer size limitation or so
that is causing this issue? I also added counters around which all
nfsd threads get to process the SVC xport & I see always only the
first 10 threads being used up all the time. The rest of the NFSD
threads never receive a packet at all to handle.

I already setup number of RPC slots tuneable to 128 on both server &
client before the mount, so this is not the issue.

Are there some other tuneables that control this behaviour? I think if
I cross the 8 concurrent IOs per client<>server, I will be able to get
>2.5K IOPs.

I also confirmed that each NFS multi-step operation that comes from
client has an OP_PUTFH/OP_WRITE/OP_GETATTR. I dont see any other
unnecessary NFS packets in the flow.

Any help/inputs on this topic greatly appreciated.

Thanks.

--Shyam
