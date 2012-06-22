Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:20603 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933147Ab2FVOms (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jun 2012 10:42:48 -0400
Message-ID: <4FE48464.5020706@oracle.com>
Date: Fri, 22 Jun 2012 08:42:44 -0600
From: Jeff Wright <jeff.wright@oracle.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org, Craig Flaskerud <Craig.flaskerud@oracle.com>,
        Andy Adamson <androsadamson@gmail.com>
Subject: Re: Diagnosing and resolving bottleneck with NFS I/O
References: <4FE3789A.4090305@oracle.com> <AF35F0DD-427A-4CC5-8E96-DEE760757762@oracle.com>
In-Reply-To: <AF35F0DD-427A-4CC5-8E96-DEE760757762@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/21/12 15:17, Chuck Lever wrote:
> Hi-
>
> On Jun 21, 2012, at 3:40 PM, Jeff Wright wrote:
>
>> To simplify analysis we ran an application that would time the execution of stable pwrite64() (O_DIRECT) for a single I/O.  We observed a large increase in response time at the application (time to run pwrite64()) compared to the reported response time from nfsiostat.  We also measured that the response time measured by nfsiostat on the client closely matched the back-end media response time in the server, and that the RPC backlog was 0.  netstat showed that we had some data in the TCP send queue on the client, but not overloaded, and that we had very little data in the TCP receive queue on the server.  The values of the I/O rate and response time in this test were as follows:
>> * Application I/O rate: 102 IOPS
>> * Application I/O response time: 9.9 ms
>> * nfsstat I/O rate: 102 IOPS
>> * nfsstat I/O response time (RTT): 3.8 ms
>> * NFS server I/O rate: 104
>> * NFS server I/O response time: 1.5 ms
>> * Media I/O rate: 105 IOPS
>> * Media I/O response  time: 3.2 ms
>>
>> In this use case I think we have unstable writes from the NFS client followed by commits, and this would lead to the short NFS server write response time because the commit is not included.  The nfsstat response time matching the media response time would be correct if the nfsstat response time included the commit time for the I/O.  Could anyone verify if the RTT reported includes the the total time to commit the writes, or if it only includes the write and not the subsequent commit?
> It depends on whether the server performs a FILE_SYNC or UNSTABLE write.  nfsiostat doesn't distinguish between them, and the server is free to promote an UNSTABLE write request to a FILE_SYNC write.
>
> If a write is UNSTABLE, then no, the "commit" time is not included in the WRITE RTT statistic.  If a write is FILE_SYNC, then the "commit" time is built into the WRITE request, and the WRITE RTT statistic includes it.
>
> Servers generally don't promote UNSTABLE writes, but NetApp always does.  Clients seldom request FILE_SYNC writes, though they will in some circumstances.
We will check what the S11 nfsd implementation is doing - thanks for the 
clarification.
>

