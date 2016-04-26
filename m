Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39033 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528AbcDZU4s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2016 16:56:48 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 04/18] xprtrdma: Prevent inline overflow
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <571FD2B3.1010505@grimberg.me>
Date: Tue, 26 Apr 2016 16:56:38 -0400
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <928930E0-0767-4BF4-A704-B4E46788820F@oracle.com>
References: <20160425185956.3566.64142.stgit@manet.1015granger.net> <20160425192120.3566.99978.stgit@manet.1015granger.net> <571FC7A3.2010407@grimberg.me> <B6501EE8-870B-40C6-8F44-FA74308EC6E5@oracle.com> <571FD2B3.1010505@grimberg.me>
To: Sagi Grimberg <sagi@grimberg.me>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 26, 2016, at 4:42 PM, Sagi Grimberg <sagi@grimberg.me> wrote:
> 
> 
>>>> When deciding whether to send a Call inline, rpcrdma_marshal_req
>>>> doesn't take into account header bytes consumed by chunk lists.
>>>> This results in Call messages on the wire that are sometimes larger
>>>> than the inline threshold.
>>> 
>>> I'm not sure I understand why you need to account the chunk list size
>>> when deciding on the inline data size., aren't chunk lists for remote
>>> access only?
>> 
>> The chunk lists and RPC message payload effectively
>> share the same 1024-byte buffer (it's two buffers
>> gathered, but the sum of the two buffer sizes has to
>> be less than 1025).
>> 
>> If the chunk lists are large, the RPC message size is
>> reduced.
>> 
> 
> I'm effectively asking when will a chunk list and inline data
> would appear in the same message?
> 
> Is it when we want to send the first X bytes inline and have the
> remote read the rest Y-X bytes?
> 
> Sorry if this is completely basic, just trying to understand if you
> really need that upper limit...

It's kind of subtle, actually.

Consider the case when the ULP operation expects a
large reply.

When there is a Reply chunk or Write list, the client
provides those via chunk lists in the header of the
Call message. Thus those chunk lists share the 1024
bytes with the RPC Call message.

If the chunk lists plus the Call message don't fit
inline, then the client will have to send the Call
message in a Read chunk (RDMA_NOMSG).


--
Chuck Lever



