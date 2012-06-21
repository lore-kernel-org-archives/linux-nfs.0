Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:21657 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754460Ab2FUTkO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jun 2012 15:40:14 -0400
Message-ID: <4FE3789A.4090305@oracle.com>
Date: Thu, 21 Jun 2012 13:40:10 -0600
From: Jeff Wright <jeff.wright@oracle.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org, Jeff Wright <jeff.wright@oracle.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Craig Flaskerud <Craig.flaskerud@oracle.com>,
        Andy Adamson <androsadamson@gmail.com>
Subject: Diagnosing and resolving bottleneck with NFS I/O
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Team,

Earlier this month I posted a note about diagnosing RPC bottlenecks on 
Linux when sorting out throughput problems with NFS.  I took advantage 
of the mountstats and nfsiostat commands to watch the RPC backlog and 
server response time (RTT) in a sequence of write tests.  We also used 
netstat to watch the TCP send/receive queues on the client and server, 
netstat to watch the TCP send/receive queues on the server, DTrace to 
watch NFS read/write response time on the server, and iostat to watch 
the physical media response time on the server.

To simplify analysis we ran an application that would time the execution 
of stable pwrite64() (O_DIRECT) for a single I/O.  We observed a large 
increase in response time at the application (time to run pwrite64()) 
compared to the reported response time from nfsiostat.  We also measured 
that the response time measured by nfsiostat on the client closely 
matched the back-end media response time in the server, and that the RPC 
backlog was 0.  netstat showed that we had some data in the TCP send 
queue on the client, but not overloaded, and that we had very little 
data in the TCP receive queue on the server.  The values of the I/O rate 
and response time in this test were as follows:
* Application I/O rate: 102 IOPS
* Application I/O response time: 9.9 ms
* nfsstat I/O rate: 102 IOPS
* nfsstat I/O response time (RTT): 3.8 ms
* NFS server I/O rate: 104
* NFS server I/O response time: 1.5 ms
* Media I/O rate: 105 IOPS
* Media I/O response  time: 3.2 ms

In this use case I think we have unstable writes from the NFS client 
followed by commits, and this would lead to the short NFS server write 
response time because the commit is not included.  The nfsstat response 
time matching the media response time would be correct if the nfsstat 
response time included the commit time for the I/O.  Could anyone verify 
if the RTT reported includes the the total time to commit the writes, or 
if it only includes the write and not the subsequent commit?

If the nfsstat RTT includes the commit, then the bottleneck for this 
test appears to be between the NFS client and the pwrite64() call 
because of the large difference in response time for these 2 
operations.  I don't know this part of the stack well, so I'd like to 
ask the list if anyone has seen behavior like this before, and if there 
is a way to instrument the code path between pwrite64() and the nfs write?

Next, we doubled the amount of pending I/O (2 separate pwrite64() 
commands).  System throughput doubled in this case, and all of the 
response times remained the about the same:
* Application I/O rate: 200 IOPS
* Application I/O response time: 10 ms
* nfsstat I/O rate: 200 IOPS
* nfsstat I/O response time (RTT): 3.7 ms
* NFS server I/O rate: 190 IOPS
* NFS server I/O response time: 1.5 ms
* Media I/O rate: 200 IOPS
* Media I/O response  time: 3.5 ms

I think this shows that the bottleneck affecting the application 
response time is per-process, and that the underlying NFS subsystem is 
still not the bottleneck in the system.  Does this sound reasonable, or 
is there more interaction between the client application and the NFS 
subsystem?

We continued to scale the number of concurrent pwrite64() processes.  A 
possibly important detail is that the separate pwrite64() processes 
could update the same file.  We started to see another bottleneck with 4 
concurrent pwrite64() processes, and the bottleneck was in full-force 
with 8 processes.  In both cases, the response time reported by 
nfsiostat was constant at about 3.7 ms, and this nearly matched the 
media I/O response time in the server, about 4.0 ms.  The application 
response time measured 12.6 ms with 4 pending requests, and 18.6 ms with 
8 pending requests.  I think this suggests that the NFS client-server 
interaction is clean, and that something is amiss between the pwrite64() 
call and the NFS client - does this sound right, or is there something 
else we should be looking at to sort out the bottleneck?

Thanks for letting us know where you think we should check next to sort 
out the bottleneck.

Thanks,

Jeff



