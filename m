From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [NFS] [PATCH] xprtrdma: fix XDR tail buf marshalling for
  all ops
Date: Mon, 10 Dec 2007 11:27:48 -0500
Message-ID: <EXNANE01yeKzGZuNY1S00000afe@exnane01.hq.netapp.com>
References: <Pine.LNX.4.64.0711291521010.7142@jlentini-linux.nane.netapp.com>
 <1196902607.17724.2.camel@heimdal.trondhjem.org>
 <Pine.LNX.4.64.0712061255200.12638@jlentini-linux.nane.netapp.com>
 <1196969392.7990.9.camel@localhost.localdomain>
 <Pine.LNX.4.64.0712061803240.12638@jlentini-linux.nane.netapp.com>
 <EXNANE01G5aYY61LEdy00000ae1@exnane01.hq.netapp.com>
 <1197300897.21931.9.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24091 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751860AbXLJQ1q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2007 11:27:46 -0500
In-Reply-To: <1197300897.21931.9.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
References: <Pine.LNX.4.64.0711291521010.7142-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
 <1196902607.17724.2.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
 <Pine.LNX.4.64.0712061255200.12638-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
 <1196969392.7990.9.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
 <Pine.LNX.4.64.0712061803240.12638-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
 <EXNANE01G5aYY61LEdy00000ae1-kboziUmgGqYSZCGxjG3uujkOHZLvdrmu@public.gmane.org>
 <1197300897.21931.9.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 10:34 AM 12/10/2007, Tom Tucker wrote:
>
>On Fri, 2007-12-07 at 12:02 -0500, Talpey, Thomas wrote:
>> At 06:11 PM 12/6/2007, James Lentini wrote:
>> >On Thu, 6 Dec 2007, Trond Myklebust wrote:
>> >> Eeewwww.... What an unholy mess!
>> >> 
>> >> Why are you trying to shoehorn reading and writing into 
>> >> rpcrdma_create_chunks()? The way every action is split into 'if 
>> >> (read) {} else {}' should be an obvious hint that none of this 
>> >> belongs together. Please split this up for 2.6.25.
>> >
>> >ok.
>> 
>> Agreed - well except for the "unholy mess" part. This code has been
>> in the nfs/rdma client basically since it was written (for 2.4.18). The
>> split version introduces quite a bit of redundancy, but clarity is good
>> too. I'll split it willingly.
>> 
>
>Hmm. I guess I disagree. I don't see how consolidating similar logic is
>an unholy mess. The purpose of the function is singular, i.e. preparing
>the chunk list contained in the request sent to the server. Although it

I think you and I (the two Tom's) are in agreement. I'll still commit to
splitting the routine, as an exercise for comparison. When it was first
written, the code would be largely duplicated, therefore harder to maintain
in the long run. But it might be different today.

Another thing to think about is the possibility that in the future, multiple
chunk lists might need to be marshaled, for instance an NFSv4 COMPOUND
that needed both a chunked argument and chunked result. The code today
doesn't need to support that, but someday it might. That was deferred
intentionally, of course (there's a comment to that effect).

Tom.

>is true that the chunklist encodes memory in the response (for read
>requests), the chunk list itself is a single entity. Splitting it up may
>be more confusing than combining and will certainly introduce copied
>logic.
>
>
>> >> So yes, for read buffers, you should be looking at the storage 
>> >> buffer length (xdr_buf->buflen) since the message length is 
>> >> obviously going to be zero.
>> >
>> >Agreed. This is why we removed the incorrect references to len in the 
>> >patch.
>> >
>> >What is your opinion on including the fix in 2.6.24? It addresses an 
>> >observed problem for certain I/Os over NFS/RDMA. Would you like me to 
>> >resend the patch with a revised description?
>> 
>> The patch basically removes a debug-only assertion (the "failed to marshal"
>> message), but the single line that tested for buflen > pos has the side
>> effect of failing to marshal the tail buffer. So that one line is 
>the key which
>> introduces the issue, and it should be removed for 2.6.24.
>> 
>> The other stuff is harmless, if wrong, and can be removed later.
>> 
>> Tom.
>> 
>> -------------------------------------------------------------------------
>> SF.Net email is sponsored by:
>> Check out the new SourceForge.net Marketplace.
>> It's the best place to buy or sell services for
>> just about anything Open Source.
>> http://sourceforge.net/services/buy/index.php
>> _______________________________________________
>> NFS maillist  -  NFS@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/nfs
>> _______________________________________________
>> Please note that nfs@lists.sourceforge.net is being discontinued.
>> Please subscribe to linux-nfs@vger.kernel.org instead.
>>     http://vger.kernel.org/vger-lists.html#linux-nfs
