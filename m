Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:22349 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755319AbbBFVNU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Feb 2015 16:13:20 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150206202800.GH29783@fieldses.org>
Date: Fri, 6 Feb 2015 16:12:51 -0500
Cc: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B1A0C74D-725B-43B6-8325-7A70E189CF2A@oracle.com>
References: <20150205162326.GA18977@infradead.org> <54D39DC2.9060808@Netapp.com> <20150206115456.GA28915@infradead.org> <20150206160848.GA29783@fieldses.org> <067E5610-290A-4AA7-9A19-F2EF9AB4163E@oracle.com> <8B871365-A241-4BA8-BD95-0946AEA55E38@oracle.com> <20150206175915.GE29783@fieldses.org> <B89860CD-5445-45DF-BEEF-35F450D84BF3@oracle.com> <20150206193529.GF29783@fieldses.org> <265D0458-ED72-4154-B0E3-F828E3D36E5A@oracle.com> <20150206202800.GH29783@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 6, 2015, at 3:28 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Fri, Feb 06, 2015 at 03:07:08PM -0500, Chuck Lever wrote:
>> 
>> On Feb 6, 2015, at 2:35 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>>> 
>>>> Small replies are sent inline. There is a size maximum for inline
>>>> messages, however. I guess 5667 section 5 assumes this context, which
>>>> appears throughout RFC 5666.
>>>> 
>>>> If an expected reply exceeds the inline size, then a client will
>>>> set up a reply list for the server. A memory region on the client is
>>>> registered as a target for RDMA WRITE operations, and the co-ordinates
>>>> of that region are sent to the server in the RPC call.
>>>> 
>>>> If the server finds the reply will indeed be larger than the inline
>>>> maximum, it plants the reply in the client memory region described by
>>>> the request’s reply list, and repeats the co-ordinates of that region
>>>> back to the client in the RPC reply.
>>>> 
>>>> A server may also choose to send a small reply inline, even if the
>>>> client provided a reply list. In that case, the server does not
>>>> repeat the reply list in the reply, and the full reply appears
>>>> inline.
>>>> 
>>>> Linux registers part of the RPC reply buffer for the reply list. After
>>>> it is received on the client, the reply payload is copied by the client
>>>> CPU to its final destination.
>>>> 
>>>> Inline and reply list are the mechanisms used when the upper layer
>>>> has some processing to do to the incoming data (eg READDIR). When
>>>> a request just needs raw data to be simply dropped off in the client’s
>>>> memory, then the write list is preferred. A write list is basically a
>>>> zero-copy I/O.
>>> 
>>> The term "reply list" doesn't appear in either RFC.  I believe you mean
>>> "client-posted write list" in most of the above, except this last
>>> paragraph, which should have started with "Inline and server-posted read list...”  ?
>> 
>> No, I meant “reply list.” Definitely not read list.
>> 
>> The terms used in the RFCs and the implementations vary,
> 
> OK.  Would you mind defining the term "reply list" for me?  Google's not helping.

Let’s look at section 4.3 of RFC 5666. Each RPC/RDMA header begins
with this:
 
      struct rdma_msg {
         uint32    rdma_xid;     /* Mirrors the RPC header xid */
         uint32    rdma_vers;    /* Version of this protocol */
         uint32    rdma_credit;  /* Buffers requested/granted */
         rdma_body rdma_body;
      };

rdma_body starts with a uint32 which discriminates a union:

      union rdma_body switch (rdma_proc proc) {
. . .
         case RDMA_NOMSG:
           rpc_rdma_header_nomsg rdma_nomsg;
. . .
      };

When “proc” == RDMA_NOMSG, rdma_body is made up of three lists:

      struct rpc_rdma_header_nomsg {
         struct xdr_read_list   *rdma_reads;
         struct xdr_write_list  *rdma_writes;
         struct xdr_write_chunk *rdma_reply;
      };

The “reply list” is that last part: rdma_reply, which is a counted
array of xdr_rdma_segment’s.

Large replies for non-NFS READ operations are sent using RDMA_NOMSG.
The RPC/RDMA header is sent as the inline portion of the message.
The RPC reply message (the part we are all familiar with) is planted
in the memory region described by rdma_reply, it’s not inline.

rdma_reply is a write chunk. The server WRITEs its RPC reply into the
memory region described by rdma_reply. That description was provided
by the client in the matching RPC call message.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



