From: Scott Atchley <atchley-vV262kQ/Wyo@public.gmane.org>
Subject: Re: Congestion window or other reason?
Date: Wed, 14 Jan 2009 15:28:53 -0500
Message-ID: <D23ADEBB-6653-4C8B-9725-79243BEB91F5@myri.com>
References: <ADA11BC1-B3F1-49F0-8B6A-5303A034DDE3@myri.com> <RTPCLUEXC2-PRDIuB1z00000045@RTPMVEXC1-PRD.hq.netapp.com> <5E69B347-E76C-473D-ABEB-6D0992D66755@myri.com> <RTPCLUEXC2-PRDPaRTO00000047@RTPMVEXC1-PRD.hq.netapp.com> <01F77AFC-1D5A-459B-A5AC-7F02E598F2E9@myri.com> <RTPCLUEXC2-PRDctLVm00000079@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1915 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752913AbZANU3F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jan 2009 15:29:05 -0500
In-Reply-To: <RTPCLUEXC2-PRDctLVm00000079-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reviving an old thread....

Hi Tom Talpey and Tom Tucker, it was good to meet you at SC08. :-)

On Sep 30, 2008, at 8:34 AM, Talpey, Thomas wrote:

>> I believe that I am duplicating the RPCRDMA usage of credits. I need
>> to check.
>
> If you are passing credits, then be sure you're managing them  
> correctly and
> that you have at least as many client RPC slots configured as the  
> server can
> optimally handle. It's very important to throughput. The NFSv4.1  
> protocol
> will manage these explicitly, btw - the session "slot table" is  
> basically the
> same interaction. The RPC/RDMA credits will basically be managed by  
> them,
> so the whole stack will bebefit.

A quick glance seems to indicate that I am using credits. The client  
never sends more than 32 requests in my tests.

>>> RPCRDMA credits are primarily used for this, it's not so much the
>>> fact that there's a queuepair, it's actually the number of posted  
>>> receives. If the client sends more than the server has available,  
>>> then the connection
>>> will fail. However, the server can implement something called  
>>> "shared   receive queue" which permits a sort of oversubscription.
>>
>> MX's behavior is more like the shared receive queue. Unexpected
>> messages <=32KB are stored in a temp buffer until the matching  
>> receive
>> has been posted. Once it is posted, the data is copied to the receive
>> buffers and the app can complete the request by testing (polling) or
>> waiting (blocking).
>
> Ouch. I guess that's convenient for the upper layer, but it costs  
> quite a
> bit of NIC memory, or if host memory is used, makes latency and bus
> traffic quite indeterminate. I would strongly suggest fully  
> provisioning
> each server endpoint, and using the protocol's credits to manage  
> resources.

Host memory. In the kernel, we limit the unexpected queue to 2 MB in  
the kernel. Ideally, the only unexpected messages are RPC requests,  
and I have already allocated 32 per client.

>> I chose not to pre-post the receives for the client's request  
>> messages
>> since they could overwhelm the MX posted receive list. By using the
>> unexpected handler, only bulk IO are pre-posted (i.e. after the
>> request has come in).
>
> The client never posts more than the max_inline_write size, which is
> fully configurable. By default, it's only 1KB, and there are  
> normally just
> 32 credits. Bulk data is handled by RDMA, which can be scheduled at
> the server's convenience - this is a key design point of the RPC/RDMA
> protocol. Only 32KB per client is "overwhelm" territory?

I upped my inline size to 3072 bytes (each context gets a full page,  
but I can't use all of it since the header needs to go in there).

32 KB is not overwhelm territory. Posting 32 identical, small recvs  
for RPC request messages per client (e.g. 1000 clients) would mean  
that to match a single, large IO, MX would have to walk a linked-list  
with potentially 32,000 small messages before finding the correct  
large message. Using the unexpected handler to manage RPC requests in  
an active message manner keeps the posted recv linked-list populated  
only with large IO messages.

I could instead have RPC requests and IO messages on separate  
completion queues which would do the same thing. I use the former out  
of habit.

>>> Yes, and dedicating that much memory to clients is another. With the
>>> IB and iWARP protocols and the current Linux server, these buffers  
>>> are
>>> not shared. This enhances integrity and protection, but it limits  
>>> the
>>> maximum scaling. I take it this is not a concern for you?
>>
>> I am not sure about what you mean by integrity and protection. A
>> buffer is only used by one request at a time.
>
> Correct - and that's precisely the goal. The issue is whether there  
> are
> data paths which can expose the buffer(s) outside of the scope of a
> single request, for example to allow a buggy server to corrupt  
> messages
> which are being processed at the client, or to allow attacks on  
> clients or
> servers from foreign hosts. Formerly, with IB and iWARP we had to  
> choose
> between performance and protection. With the new iWARP "FRMR"  
> facility,
> we (finally) have a scheme that protects well, without costing a large
> per-io penalty.

Hmmm. When using MX over Myrinet, such an attack is not feasible. When  
using MX over Ethernet, it is still probably not feasible since MX  
traffic is not viewable within the kernel (via wireshark, etc.). Could  
someone use a non-Myricom NIC to craft a bogus Myrinet over Ethernet  
frame, it is theoretically possible.

>>> RPC is purely a request/response mechanism, with rules for  
>>> discovering
>>> endpoints and formatting requests and replies. RPCRDMA adds framing
>>> for RDMA networks, and mechanisms for managing RDMA networks such
>>> as credits and rules on when to use RDMA. Finally, the NFS/RDMA
>>> transport binding makes requirements for sending messages. Since  
>>> there are
>>> several NFS protocol versions, the answer to your question depends  
>>> on that.
>>> There is no congestion control (slow start, message sizes) in the  
>>> RPC
>>> protocol, however there are many implementations of it in RPC.
>>
>> I am trying to duplicate all of the above from RPCRDMA. I am curious
>> why a client read of 256 pages with a rsize of 128 pages arrives in
>> three transfers of 32, 128, and then 96 pages. I assume that the same
>> reason is allowing client writes to succeed only if the max pages  
>> is 32.
>
> Usually, this is because the server's filesystem delivered the  
> results in
> these chunks. For example, yours may have had a 128-page extent size,
> which the client was reading on a 96-page offset. Therefore the  
> first read
> yielded the last 32 pages of the first extent, followed by a full  
> 128 and
> a 96 to finish up. Or perhaps, it was simply convenient for it to  
> return
> them in such a way.
>
> You can maybe recode the server to perform full-sized IO, but I don't
> recommend it. You'll be performing synchronous filesystem ops in order
> to avoid a few network transfers. That is, in all likelihood, a very  
> bad
> trade. But I don't know your server.

I was just curious. Thanks for the clear explanation. We will behave  
like the others and service what NFS hands us.

>>> I'm not certain if your question is purely about TCP, or if it's
>>> about RDMA with TCP as an example. However in both cases the  
>>> answer is the same:
>>> it's not about the size of a message, it's about the message itself.
>>> If the client and server have agreed that a 1MB write is ok, then  
>>> yes the
>>> client may immediately send 1MB.
>>>
>>> Tom.
>>
>> Hmmm, I will try to debug the svc_process code to find the oops.

I found several bugs and I think I have fixed them. I seem to have it  
working correctly with 32 KB messages (reading, writing, [un]mounting,  
etc.). On a few reads or writes out of a 1,000, I will get a NFS stale  
handle error. I need to track this down.

Also, when using more than 8 pages (32 KB), reads and writes complete  
but the data is corrupted. This is clearly a bug in my code and I am  
looking into it.

Scott
