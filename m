From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: Congestion window or other reason?
Date: Fri, 26 Sep 2008 16:08:13 -0400
Message-ID: <RTPCLUEXC2-PRDIuB1z00000045@RTPMVEXC1-PRD.hq.netapp.com>
References: <ADA11BC1-B3F1-49F0-8B6A-5303A034DDE3@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org
To: Scott Atchley <atchley-vV262kQ/Wyo@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27945 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912AbYIZUIx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 16:08:53 -0400
In-Reply-To: <ADA11BC1-B3F1-49F0-8B6A-5303A034DDE3-vV262kQ/Wyo@public.gmane.org>
References: <ADA11BC1-B3F1-49F0-8B6A-5303A034DDE3-vV262kQ/Wyo@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 03:16 PM 9/26/2008, Scott Atchley wrote:
>Hi all,
>
>I have bulk writing and reading working on RPCMX, sort of.

I'd love to hear more about RPCMX! What is it?

>
>Reading seems to work fine. Writing seems to work fine if  
>RPCMX_MAX_DATA_SEGS is set to <=32 (versus the default of 8 in  
>RPCRDMA). Above that value, I get an oops on the server.
>
>Reading seems to work fine with values up to 128. I have not tried  
>256, because the code then adds 2 to create RPCMX_MAX_SEGS and MX is  
>limited to 256 total segments. I tried 254, but the client seems to  
>prefer power of 2 values, so it uses 128 pages (512 KB).
>
>As best I can tell when reading a 1 MB file, the first transfer is 32  
>pages, the second transfer is 128 pages, and the final transfer is the  
>remaining 96 pages.
>
>When writing, the client tries to send 128 pages twice. The SVC MX  
>layer receives them correctly (it parses the request correctly and  
>posts 128 pages), but I get an oops in svc_process().
>
>Is this related to the congestion window or something else? It doesn't  
>come up in RPCRDMA since it is limited to 8 pages.

The congestion window is all about the number of concurrent RPC requests,
and isn't dependent on the number of segments or even size of each message.
Congestion is a client-side thing, the server never delays its replies.

The RPC/RDMA code uses the congestion window to manage its flow control
window with the server. There is a second, somewhat hidden congestion
window that the RDMA adapters use between one another for RDMA Read
requests, the IRD/ORD. But those aren't visible outside the lowest layer.

I would be surprised if you can manage hundreds of pages times dozens
of active requests without some significant resource issues at the
server. Perhaps your problems are related to those?

Tom.

