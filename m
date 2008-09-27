From: Scott Atchley <atchley-vV262kQ/Wyo@public.gmane.org>
Subject: Re: Congestion window or other reason?
Date: Fri, 26 Sep 2008 20:35:18 -0400
Message-ID: <01F77AFC-1D5A-459B-A5AC-7F02E598F2E9@myri.com>
References: <ADA11BC1-B3F1-49F0-8B6A-5303A034DDE3@myri.com> <RTPCLUEXC2-PRDIuB1z00000045@RTPMVEXC1-PRD.hq.netapp.com> <5E69B347-E76C-473D-ABEB-6D0992D66755@myri.com> <RTPCLUEXC2-PRDPaRTO00000047@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1914 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751648AbYI0Af2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 20:35:28 -0400
In-Reply-To: <RTPCLUEXC2-PRDPaRTO00000047-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 26, 2008, at 5:24 PM, Talpey, Thomas wrote:

> Ok, you've got my attention! Is the code visible somewhere btw?

No, it is in our internal CVS. I can send you a tarball if you want to  
take a look.

>> Interesting. The client does not have a global view, unfortunately,
>> and has no idea how busy the server is (i.e. how many other clients  
>> it
>> is servicing).
>
> Correct, because the NFS protocol is not designed this way. However,
> the server can manage clients via the RPCRDMA credit mechanism, by
> allowing them to send more or less messages in response to its own
> load.

I believe that I am duplicating the RPCRDMA usage of credits. I need  
to check.

> RPCRDMA credits are primarily used for this, it's not so much the  
> fact that
> there's a queuepair, it's actually the number of posted receives. If  
> the
> client sends more than the server has available, then the connection  
> will
> fail. However, the server can implement something called "shared  
> receive
> queue" which permits a sort of oversubscription.

MX's behavior is more like the shared receive queue. Unexpected  
messages <=32KB are stored in a temp buffer until the matching receive  
has been posted. Once it is posted, the data is copied to the receive  
buffers and the app can complete the request by testing (polling) or  
waiting (blocking).

MX also gives an app the ability to supply a function to handle  
unexpected messages. Instead of per-posting receives like RPCRDMA, I  
allocate the ctxt and hang them on an idle queue (doubly-linked list).  
In the unexpected handler, I dequeue a ctxt and post the matching  
receive. MX then can place the data in the proper buffer without an  
additional copy.

I chose not to pre-post the receives for the client's request messages  
since they could overwhelm the MX posted receive list. By using the  
unexpected handler, only bulk IO are pre-posted (i.e. after the  
request has come in).

> Yes, and dedicating that much memory to clients is another. With the
> IB and iWARP protocols and the current Linux server, these buffers are
> not shared. This enhances integrity and protection, but it limits the
> maximum scaling. I take it this is not a concern for you?

I am not sure about what you mean by integrity and protection. A  
buffer is only used by one request at a time.

> RPC is purely a request/response mechanism, with rules for discovering
> endpoints and formatting requests and replies. RPCRDMA adds framing
> for RDMA networks, and mechanisms for managing RDMA networks such
> as credits and rules on when to use RDMA. Finally, the NFS/RDMA  
> transport
> binding makes requirements for sending messages. Since there are  
> several
> NFS protocol versions, the answer to your question depends on that.
> There is no congestion control (slow start, message sizes) in the RPC
> protocol, however there are many implementations of it in RPC.

I am trying to duplicate all of the above from RPCRDMA. I am curious  
why a client read of 256 pages with a rsize of 128 pages arrives in  
three transfers of 32, 128, and then 96 pages. I assume that the same  
reason is allowing client writes to succeed only if the max pages is 32.

> I'm not certain if your question is purely about TCP, or if it's  
> about RDMA
> with TCP as an example. However in both cases the answer is the same:
> it's not about the size of a message, it's about the message itself.  
> If
> the client and server have agreed that a 1MB write is ok, then yes the
> client may immediately send 1MB.
>
> Tom.

Hmmm, I will try to debug the svc_process code to find the oops.

I am on vacation next week. I will take a look once I get back.

Thanks!

Scott
