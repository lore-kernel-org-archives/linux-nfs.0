From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: Congestion window or other reason?
Date: Tue, 30 Sep 2008 08:34:41 -0400
Message-ID: <RTPCLUEXC2-PRDctLVm00000079@RTPMVEXC1-PRD.hq.netapp.com>
References: <ADA11BC1-B3F1-49F0-8B6A-5303A034DDE3@myri.com>
 <RTPCLUEXC2-PRDIuB1z00000045@RTPMVEXC1-PRD.hq.netapp.com>
 <5E69B347-E76C-473D-ABEB-6D0992D66755@myri.com>
 <RTPCLUEXC2-PRDPaRTO00000047@RTPMVEXC1-PRD.hq.netapp.com>
 <01F77AFC-1D5A-459B-A5AC-7F02E598F2E9@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org
To: Scott Atchley <atchley-vV262kQ/Wyo@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30709 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751642AbYI3Mej (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Sep 2008 08:34:39 -0400
In-Reply-To: <01F77AFC-1D5A-459B-A5AC-7F02E598F2E9-vV262kQ/Wyo@public.gmane.org>
References: <ADA11BC1-B3F1-49F0-8B6A-5303A034DDE3-vV262kQ/Wyo@public.gmane.org>
 <RTPCLUEXC2-PRDIuB1z00000045-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
 <5E69B347-E76C-473D-ABEB-6D0992D66755-vV262kQ/Wyo@public.gmane.org>
 <RTPCLUEXC2-PRDPaRTO00000047-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
 <01F77AFC-1D5A-459B-A5AC-7F02E598F2E9-vV262kQ/Wyo@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 08:35 PM 9/26/2008, Scott Atchley wrote:
>On Sep 26, 2008, at 5:24 PM, Talpey, Thomas wrote:
>
>> Ok, you've got my attention! Is the code visible somewhere btw?
>
>No, it is in our internal CVS. I can send you a tarball if you want to  
>take a look.
>
>>> Interesting. The client does not have a global view, unfortunately,
>>> and has no idea how busy the server is (i.e. how many other clients  
>>> it
>>> is servicing).
>>
>> Correct, because the NFS protocol is not designed this way. However,
>> the server can manage clients via the RPCRDMA credit mechanism, by
>> allowing them to send more or less messages in response to its own
>> load.
>
>I believe that I am duplicating the RPCRDMA usage of credits. I need  
>to check.

If you are passing credits, then be sure you're managing them correctly and
that you have at least as many client RPC slots configured as the server can
optimally handle. It's very important to throughput. The NFSv4.1 protocol
will manage these explicitly, btw - the session "slot table" is basically the
same interaction. The RPC/RDMA credits will basically be managed by them,
so the whole stack will bebefit.

>
>> RPCRDMA credits are primarily used for this, it's not so much the  
>> fact that
>> there's a queuepair, it's actually the number of posted receives. If  
>> the
>> client sends more than the server has available, then the connection  
>> will
>> fail. However, the server can implement something called "shared  
>> receive
>> queue" which permits a sort of oversubscription.
>
>MX's behavior is more like the shared receive queue. Unexpected  
>messages <=32KB are stored in a temp buffer until the matching receive  
>has been posted. Once it is posted, the data is copied to the receive  
>buffers and the app can complete the request by testing (polling) or  
>waiting (blocking).

Ouch. I guess that's convenient for the upper layer, but it costs quite a
bit of NIC memory, or if host memory is used, makes latency and bus
traffic quite indeterminate. I would strongly suggest fully provisioning
each server endpoint, and using the protocol's credits to manage resources.

>MX also gives an app the ability to supply a function to handle  
>unexpected messages. Instead of per-posting receives like RPCRDMA, I  
>allocate the ctxt and hang them on an idle queue (doubly-linked list).  
>In the unexpected handler, I dequeue a ctxt and post the matching  
>receive. MX then can place the data in the proper buffer without an  
>additional copy.

I guess that will help you implement the server. I still think it's best
to start simple.

>I chose not to pre-post the receives for the client's request messages  
>since they could overwhelm the MX posted receive list. By using the  
>unexpected handler, only bulk IO are pre-posted (i.e. after the  
>request has come in).

The client never posts more than the max_inline_write size, which is
fully configurable. By default, it's only 1KB, and there are normally just
32 credits. Bulk data is handled by RDMA, which can be scheduled at
the server's convenience - this is a key design point of the RPC/RDMA
protocol. Only 32KB per client is "overwhelm" territory?

>> Yes, and dedicating that much memory to clients is another. With the
>> IB and iWARP protocols and the current Linux server, these buffers are
>> not shared. This enhances integrity and protection, but it limits the
>> maximum scaling. I take it this is not a concern for you?
>
>I am not sure about what you mean by integrity and protection. A  
>buffer is only used by one request at a time.

Correct - and that's precisely the goal. The issue is whether there are
data paths which can expose the buffer(s) outside of the scope of a
single request, for example to allow a buggy server to corrupt messages
which are being processed at the client, or to allow attacks on clients or
servers from foreign hosts. Formerly, with IB and iWARP we had to choose
between performance and protection. With the new iWARP "FRMR" facility,
we (finally) have a scheme that protects well, without costing a large
per-io penalty.

>> RPC is purely a request/response mechanism, with rules for discovering
>> endpoints and formatting requests and replies. RPCRDMA adds framing
>> for RDMA networks, and mechanisms for managing RDMA networks such
>> as credits and rules on when to use RDMA. Finally, the NFS/RDMA  
>> transport
>> binding makes requirements for sending messages. Since there are  
>> several
>> NFS protocol versions, the answer to your question depends on that.
>> There is no congestion control (slow start, message sizes) in the RPC
>> protocol, however there are many implementations of it in RPC.
>
>I am trying to duplicate all of the above from RPCRDMA. I am curious  
>why a client read of 256 pages with a rsize of 128 pages arrives in  
>three transfers of 32, 128, and then 96 pages. I assume that the same  
>reason is allowing client writes to succeed only if the max pages is 32.

Usually, this is because the server's filesystem delivered the results in
these chunks. For example, yours may have had a 128-page extent size,
which the client was reading on a 96-page offset. Therefore the first read
yielded the last 32 pages of the first extent, followed by a full 128 and
a 96 to finish up. Or perhaps, it was simply convenient for it to return
them in such a way.

You can maybe recode the server to perform full-sized IO, but I don't
recommend it. You'll be performing synchronous filesystem ops in order
to avoid a few network transfers. That is, in all likelihood, a very bad
trade. But I don't know your server.

>> I'm not certain if your question is purely about TCP, or if it's  
>> about RDMA
>> with TCP as an example. However in both cases the answer is the same:
>> it's not about the size of a message, it's about the message itself.  
>> If
>> the client and server have agreed that a 1MB write is ok, then yes the
>> client may immediately send 1MB.
>>
>> Tom.
>
>Hmmm, I will try to debug the svc_process code to find the oops.
>
>I am on vacation next week. I will take a look once I get back.

Ok!

Tom.

>
>Thanks!
>
>Scott
>

