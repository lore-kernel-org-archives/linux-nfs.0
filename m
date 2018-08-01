Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:49896 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2389611AbeHARA2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Aug 2018 13:00:28 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v1 0/4] NFS/RDMA server patches for v4.19
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180801143622.GF16651@fieldses.org>
Date: Wed, 1 Aug 2018 11:14:14 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A73AEC28-2A67-4EFB-8C42-0B0842F4DF4D@oracle.com>
References: <20180727142007.21878.77494.stgit@klimt.1015granger.net>
 <20180801143622.GF16651@fieldses.org>
To: Bruce Fields <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Aug 1, 2018, at 10:36 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Fri, Jul 27, 2018 at 11:18:48AM -0400, Chuck Lever wrote:
>> This short series includes clean-ups related to performance-related
>> work that you and I have discussed in the past.
> 
> Thanks, applying.

Thanks for looking!


>> Let me give an
>> update on the progress of that work as context for these patches.
>> 
>> We had discussed moving the generation of RDMA Read requests from
>> ->recvfrom up into the NFSD proc functions that handle WRITE and
>> SYMLINK operations. There were two reasons for this change:
>> 
>> 1. To enable the upper layer to choose the pages that act as the
>> RDMA Read sink buffer, rather than always using anonymous pages
>> for this purpose
>> 
>> 2. To reduce the average latency of ->recvfrom calls on RPC/RDMA,
>> which are serialized per transport connection
>> 
>> I was able to successfully prototype this change. The scope of this
>> prototype was limited to exploring how to move the RDMA Read code.
>> I have not yet tried to implement a per-FH page selection mechanism.
>> 
>> There was no measurable performance impact of this change. The good
>> news is that this confirms that the RDMA Read code can be moved
>> upstairs without negative performance consequences. The not-so-good
>> news:
>> 
>> - Serialization of ->recvfrom might not be the problem that I
>> predicted.
>> 
>> - I don't have a macro benchmark that mixes small NFS requests with
>> NFS requests with Read chunks in a way that can assess the
>> serialization issue.
>> 
>> - The most significant current bottleneck for NFS WRITE performance
>> is on the Linux client, which obscures performance improvements in
>> the server-side NFS WRITE path. The bottleneck is generic, not
>> related to the use of pNFS or the choice of transport type.
> 
> Would it be practical to test with an artificial workload that takes the
> client out of the test?

For instance, that is what SPEC NFS does: it has a synthetic client.


> But if there are client issues then they need to be fixed anyway, so
> the better use of time may be fixing those first, and then we get to
> test the server with more realistic workloads....

I've been dabbling with the client a little, and have more to
discuss whenever there is a f2f meeting.


>> To complete my prototype, I disabled the server's DRC. Going forward
>> with this work will require some thought about how to deal with non-
>> idempotent requests with Read chunks. Some possibilities:
>> 
>> - For RPC Calls with Read chunks, don't include the payload in the
>> checksum. This could be done by providing a per-transport checksum
>> callout that would manage the details.
> 
> I believe the checksum is there to prevent rpc's being incorrectly
> treated as replays on xid wraparound.  If we're skipping it in the case
> of writes (for example), then we may be slightly increasing the chance
> of data coruption in some cases.  I don't know if it's significant.

One thing Parav has suggested is the use of T10 PI signatures.
We had discussed using it to offload the computation of the
checksum on the inline part (RDMA Send), but that's variable
size, and PI likes multiples of 512 bytes.

Instead, perhaps we could grab a PI signature on the payload
(the Read chunk, whose size will often be a multiple of a page),
and toss that into the checksum computation. Dunno if that would
be practical in general, or for write payloads that are not
appropriately length-aligned.


>> - Support late RDMA Reads for session-based versions of NFS, but not
>> for earlier versions of NFS which utilize the legacy DRC.
> 
> To me that sounds like it might be simplest to start off with?
> 
>> - Adopt an entirely different DRC hashing mechanism.
> 
> I guess we could delay the hashing somehow too.

There is plenty of room for creativity.


> But I'd rather not invest a lot of time trying to make NFSv2/v3 better,
> the priority for older protocols is just to avoid regressions.

Fair 'nuf.

I'm not clear where NFSv4.0 fits here. I realize most of us would
consider NFSv4.0 to be a "legacy protocol". Does the Linux server
utilize the DRC for NFSv4.0 ?


--
Chuck Lever



