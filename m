From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: Congestion window or other reason?
Date: Fri, 26 Sep 2008 17:24:00 -0400
Message-ID: <RTPCLUEXC2-PRDPaRTO00000047@RTPMVEXC1-PRD.hq.netapp.com>
References: <ADA11BC1-B3F1-49F0-8B6A-5303A034DDE3@myri.com>
 <RTPCLUEXC2-PRDIuB1z00000045@RTPMVEXC1-PRD.hq.netapp.com>
 <5E69B347-E76C-473D-ABEB-6D0992D66755@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org
To: Scott Atchley <atchley-vV262kQ/Wyo@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36013 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885AbYIZVZP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 17:25:15 -0400
In-Reply-To: <5E69B347-E76C-473D-ABEB-6D0992D66755-vV262kQ/Wyo@public.gmane.org>
References: <ADA11BC1-B3F1-49F0-8B6A-5303A034DDE3-vV262kQ/Wyo@public.gmane.org>
 <RTPCLUEXC2-PRDIuB1z00000045-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
 <5E69B347-E76C-473D-ABEB-6D0992D66755-vV262kQ/Wyo@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 04:33 PM 9/26/2008, Scott Atchley wrote:
>On Sep 26, 2008, at 4:08 PM, Talpey, Thomas wrote:
>
>> I'd love to hear more about RPCMX! What is it?
>
>It is based on the RPCRDMA code using MX. MX is Myricom's second- 
>generation zero-copy, kernel-bypass API (GM was the first). Unlike IB/ 
>iWarp, MX provides only a two-sided interface (send/recv) and is  
>closely modeled after MPI-1 semantics.

Ok, you've got my attention! Is the code visible somewhere btw?

>
>I wrote the MX ports for Lustre and PVFS2. I am finding this to be  
>more challenging than either of those.
>
>> The congestion window is all about the number of concurrent RPC  
>> requests,
>> and isn't dependent on the number of segments or even size of each  
>> message.
>> Congestion is a client-side thing, the server never delays its  
>> replies.
>
>Interesting. The client does not have a global view, unfortunately,  
>and has no idea how busy the server is (i.e. how many other clients it  
>is servicing).

Correct, because the NFS protocol is not designed this way. However,
the server can manage clients via the RPCRDMA credit mechanism, by
allowing them to send more or less messages in response to its own
load.

>
>> The RPC/RDMA code uses the congestion window to manage its flow  
>> control
>> window with the server. There is a second, somewhat hidden congestion
>> window that the RDMA adapters use between one another for RDMA Read
>> requests, the IRD/ORD. But those aren't visible outside the lowest  
>> layer.
>
>Is this due to the fact that IB uses queue pairs (QP) and one peer  
>cannot send a message to another unless a slot is available in the QP?  
>If so, we do not have this limitation in MX (no QPs).

RPCRDMA credits are primarily used for this, it's not so much the fact that
there's a queuepair, it's actually the number of posted receives. If the
client sends more than the server has available, then the connection will
fail. However, the server can implement something called "shared receive
queue" which permits a sort of oversubscription.


>
>> I would be surprised if you can manage hundreds of pages times dozens
>> of active requests without some significant resource issues at the
>> server. Perhaps your problems are related to those?
>>
>> Tom.
>
>In Lustre and PVFS2, the network MTU is 1 MB (and optionally 4 MB in  
>PVFS2). We do not have issues in MX scaling to hundreds or thousands  
>of peers (again no QPs). As for handling a few hundred MBs from a few  
>hundred clients, it should be no problem. Whether the filesystem back- 
>end can handle it is another question.

Yes, and dedicating that much memory to clients is another. With the
IB and iWARP protocols and the current Linux server, these buffers are
not shared. This enhances integrity and protection, but it limits the
maximum scaling. I take it this is not a concern for you?

>
>When using TCP with rsize=wsize=1MB, is there anything in RPC besides  
>TCP that restricts how much data is sent over (or received at the  
>server) initially? That is, does a client start by sending a smaller  
>amount, then increase up to the 1 MB limit? Or, does it simply try to  
>write() 1 MB? Or does the server read a smaller amount and then  
>subsequently larger amounts?

RPC is purely a request/response mechanism, with rules for discovering
endpoints and formatting requests and replies. RPCRDMA adds framing
for RDMA networks, and mechanisms for managing RDMA networks such
as credits and rules on when to use RDMA. Finally, the NFS/RDMA transport
binding makes requirements for sending messages. Since there are several
NFS protocol versions, the answer to your question depends on that.
There is no congestion control (slow start, message sizes) in the RPC
protocol, however there are many implementations of it in RPC.

I'm not certain if your question is purely about TCP, or if it's about RDMA
with TCP as an example. However in both cases the answer is the same:
it's not about the size of a message, it's about the message itself. If
the client and server have agreed that a 1MB write is ok, then yes the
client may immediately send 1MB.

Tom.

