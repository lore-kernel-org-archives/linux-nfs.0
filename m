From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH] xprtrdma: fix XDR tail buf marshalling for all ops
Date: Fri, 07 Dec 2007 12:02:20 -0500
Message-ID: <EXNANE01G5aYY61LEdy00000ae1@exnane01.hq.netapp.com>
References: <Pine.LNX.4.64.0711291521010.7142@jlentini-linux.nane.netapp.com>
 <1196902607.17724.2.camel@heimdal.trondhjem.org>
 <Pine.LNX.4.64.0712061255200.12638@jlentini-linux.nane.netapp.com>
 <1196969392.7990.9.camel@localhost.localdomain>
 <Pine.LNX.4.64.0712061803240.12638@jlentini-linux.nane.netapp.com> <Pine.LNX.4.64.0712061803240.12638@jlentini-linux.nane.neta
 pp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63602 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753409AbXLGRCj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Dec 2007 12:02:39 -0500
In-Reply-To: <Pine.LNX.4.64.0712061803240.12638-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0Z@public.gmane.org
 pp.com>
References: <Pine.LNX.4.64.0711291521010.7142-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
 <1196902607.17724.2.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
 <Pine.LNX.4.64.0712061255200.12638-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
 <1196969392.7990.9.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
 <Pine.LNX.4.64.0712061803240.12638-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 06:11 PM 12/6/2007, James Lentini wrote:
>On Thu, 6 Dec 2007, Trond Myklebust wrote:
>> Eeewwww.... What an unholy mess!
>> 
>> Why are you trying to shoehorn reading and writing into 
>> rpcrdma_create_chunks()? The way every action is split into 'if 
>> (read) {} else {}' should be an obvious hint that none of this 
>> belongs together. Please split this up for 2.6.25.
>
>ok.

Agreed - well except for the "unholy mess" part. This code has been
in the nfs/rdma client basically since it was written (for 2.4.18). The
split version introduces quite a bit of redundancy, but clarity is good
too. I'll split it willingly.

>> So yes, for read buffers, you should be looking at the storage 
>> buffer length (xdr_buf->buflen) since the message length is 
>> obviously going to be zero.
>
>Agreed. This is why we removed the incorrect references to len in the 
>patch.
>
>What is your opinion on including the fix in 2.6.24? It addresses an 
>observed problem for certain I/Os over NFS/RDMA. Would you like me to 
>resend the patch with a revised description?

The patch basically removes a debug-only assertion (the "failed to marshal"
message), but the single line that tested for buflen > pos has the side
effect of failing to marshal the tail buffer. So that one line is the key which
introduces the issue, and it should be removed for 2.6.24.

The other stuff is harmless, if wrong, and can be removed later.

Tom.
