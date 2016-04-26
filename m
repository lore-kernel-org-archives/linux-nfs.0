Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48277 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074AbcDZUFI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2016 16:05:08 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 04/18] xprtrdma: Prevent inline overflow
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <571FC7A3.2010407@grimberg.me>
Date: Tue, 26 Apr 2016 16:04:59 -0400
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B6501EE8-870B-40C6-8F44-FA74308EC6E5@oracle.com>
References: <20160425185956.3566.64142.stgit@manet.1015granger.net> <20160425192120.3566.99978.stgit@manet.1015granger.net> <571FC7A3.2010407@grimberg.me>
To: Sagi Grimberg <sagi@grimberg.me>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 26, 2016, at 3:55 PM, Sagi Grimberg <sagi@grimberg.me> wrote:
> 
> 
>> When deciding whether to send a Call inline, rpcrdma_marshal_req
>> doesn't take into account header bytes consumed by chunk lists.
>> This results in Call messages on the wire that are sometimes larger
>> than the inline threshold.
> 
> I'm not sure I understand why you need to account the chunk list size
> when deciding on the inline data size., aren't chunk lists for remote
> access only?

The chunk lists and RPC message payload effectively
share the same 1024-byte buffer (it's two buffers
gathered, but the sum of the two buffer sizes has to
be less than 1025).

If the chunk lists are large, the RPC message size is
reduced.


> Is this a first-burst kind of functionality?
> 
>> Likewise, when a Write list or Reply chunk is in play, the server's
>> reply has to emit an RDMA Send that includes a larger-than-minimal
>> RPC-over-RDMA header.
>> 
>> The actual size of a Call message cannot be estimated until after
>> the chunk lists have been registered. Thus the size of each
>> RPC-over-RDMA header can be estimated only after chunks are
>> registered; but the decision to register chunks is based on the size
>> of that header. Chicken, meet egg.
> 
> :)
> 
>> The best a client can do is estimate header size based on the
>> largest header that might occur, and then ensure that inline content
>> is always smaller than that.
> 
> Isn't that a big loss?

For FRWR, the maximum header size is adjusted based on
the HCA's capabilities. If the HCA can send the whole
payload in one chunk, then the maximum header size is
about 64 bytes.


--
Chuck Lever



