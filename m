From: Scott Atchley <atchley-vV262kQ/Wyo@public.gmane.org>
Subject: Re: Congestion window or other reason?
Date: Fri, 26 Sep 2008 16:33:23 -0400
Message-ID: <5E69B347-E76C-473D-ABEB-6D0992D66755@myri.com>
References: <ADA11BC1-B3F1-49F0-8B6A-5303A034DDE3@myri.com> <RTPCLUEXC2-PRDIuB1z00000045@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:2007 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751461AbYIZUdZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 16:33:25 -0400
In-Reply-To: <RTPCLUEXC2-PRDIuB1z00000045-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 26, 2008, at 4:08 PM, Talpey, Thomas wrote:

> I'd love to hear more about RPCMX! What is it?

It is based on the RPCRDMA code using MX. MX is Myricom's second- 
generation zero-copy, kernel-bypass API (GM was the first). Unlike IB/ 
iWarp, MX provides only a two-sided interface (send/recv) and is  
closely modeled after MPI-1 semantics.

I wrote the MX ports for Lustre and PVFS2. I am finding this to be  
more challenging than either of those.

> The congestion window is all about the number of concurrent RPC  
> requests,
> and isn't dependent on the number of segments or even size of each  
> message.
> Congestion is a client-side thing, the server never delays its  
> replies.

Interesting. The client does not have a global view, unfortunately,  
and has no idea how busy the server is (i.e. how many other clients it  
is servicing).

> The RPC/RDMA code uses the congestion window to manage its flow  
> control
> window with the server. There is a second, somewhat hidden congestion
> window that the RDMA adapters use between one another for RDMA Read
> requests, the IRD/ORD. But those aren't visible outside the lowest  
> layer.

Is this due to the fact that IB uses queue pairs (QP) and one peer  
cannot send a message to another unless a slot is available in the QP?  
If so, we do not have this limitation in MX (no QPs).

> I would be surprised if you can manage hundreds of pages times dozens
> of active requests without some significant resource issues at the
> server. Perhaps your problems are related to those?
>
> Tom.

In Lustre and PVFS2, the network MTU is 1 MB (and optionally 4 MB in  
PVFS2). We do not have issues in MX scaling to hundreds or thousands  
of peers (again no QPs). As for handling a few hundred MBs from a few  
hundred clients, it should be no problem. Whether the filesystem back- 
end can handle it is another question.

When using TCP with rsize=wsize=1MB, is there anything in RPC besides  
TCP that restricts how much data is sent over (or received at the  
server) initially? That is, does a client start by sending a smaller  
amount, then increase up to the 1 MB limit? Or, does it simply try to  
write() 1 MB? Or does the server read a smaller amount and then  
subsequently larger amounts?

Thanks,

Scott
