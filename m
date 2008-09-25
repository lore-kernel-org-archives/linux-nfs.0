From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: svcrdma/xprtrdma fast memory registration questions
Date: Thu, 25 Sep 2008 15:29:58 -0500
Message-ID: <48DBF4C6.7010008@opengridcomputing.com>
References: <1222357183.32577.34.camel@sale659>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Jim Schutt <jaschut@sandia.gov>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:36161 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753544AbYIYU37 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Sep 2008 16:29:59 -0400
In-Reply-To: <1222357183.32577.34.camel@sale659>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jim Schutt wrote:
> Hi,
> 
> I've been giving the fast memory registration NFS RDMA
> patches a spin, and I've got a couple questions.
> 
> AFAICS the default xprtrdma memory registration model 
> is still RPCRDMA_ALLPHYSICAL; I had to 
>   "echo 6 > /proc/sys/sunrpc/rdma_memreg_strategy"
> prior to a mount to get fast registration.  Given that fast 
> registration has better security properties for iWARP, and 
> the fallback is RPCRDMA_ALLPHYSICAL if fast registration is 
> not supported, is it more appropriate to have RPCRDMA_FASTREG 
   ???
> be the default?

I'm not sure I parsed this right, but I think you're asking if FASTREG 
should be the default if it _is_ supported by the HW. IMO yes.

> 
> Second, it seems that the number of pages in a client fast 
> memory registration is still limited to RPCRDMA_MAX_DATA_SEGS.
> So on a client write, without fast registration I get 
> RPCRDMA_MAX_DATA_SEGS RDMA reads of 1 page each, whereas with 
> fast registration I get 1 RDMA read of RPCRDMA_MAX_DATA_SEGS 
> pages.
> 
> In either case my maximum rsize, wsize for an RDMA mount
> is still 32 KiB.

Sure, Big data was not the purpose of the patch.

> 
> My understanding is that, e.g., a Chelsio T3 with the 
> 2.6.27-rc driver can support 24 pages in a fast registration
> request.  So, what I was hoping to see with a T3 were RPCs with 
> RPCRDMA_MAX_DATA_SEGS  chunks, each for a fast registration of 
> 24 pages each, making possible an RDMA mount with 768 KiB for
> rsize, wsize.
> 
> Is something like that possible?  If so, do you have any
> work in progress along those lines?
> 

I have nothing in the works along those lines -- sorry.

> -- Jim
> 
> 

