Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:24931 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbbALBOI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Jan 2015 20:14:08 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v1 10/10] svcrdma: Handle additional inline content
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <54B2BA77.20101@dev.mellanox.co.il>
Date: Sun, 11 Jan 2015 20:13:58 -0500
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <46D2849E-39D7-4290-91CE-FD66E3F96B21@oracle.com>
References: <20150109191910.4901.29548.stgit@klimt.1015granger.net> <20150109192319.4901.89444.stgit@klimt.1015granger.net> <54B2BA77.20101@dev.mellanox.co.il>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 11, 2015, at 1:01 PM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:

> On 1/9/2015 9:23 PM, Chuck Lever wrote:
>> Most NFS RPCs place large payload arguments at the end of the RPC
>> header (eg, NFSv3 WRITE). For NFSv3 WRITE and SYMLINK, RPC/RDMA
>> sends the complete RPC header inline, and the payload argument in a
>> read list.
>> 
>> One important case is not like this, however. NFSv4 WRITE compounds
>> can have an operation after the WRITE operation. The proper way to
>> convey an NFSv4 WRITE is to place the GETATTR inline, but _after_
>> the read list position. (Note Linux clients currently do not do
>> this, but they will be changed to do it in the future).
>> 
>> The receiver could put trailing inline content in the XDR tail
>> buffer. But the Linux server's NFSv4 compound processing does not
>> consider the XDR tail buffer.
>> 
>> So, move trailing inline content to the end of the page list. This
>> presents the incoming compound to upper layers the same way the
>> socket code does.
>> 
> 
> Would this memcpy be saved if you just posted a larger receive buffer
> and the client would used it "really inline" as part of it's post_send?

The receive buffer doesn’t need to be larger. Clients already should
construct this trailing inline content in their SEND buffers.

Not that the  Linux client doesn’t yet send the extra inline via RDMA
SEND, it uses a separate RDMA READ to move the extra bytes, and that’s
a bug.

If the client does send this inline as it’s supposed to, the server
would receive it in its pre-posted RECV buffer. This patch simply
moves that content into the XDR buffer page list, where the server’s
XDR decoder can find it.

The TCP transport already places this content at the end of the XDR
buffer’s page list, and svcrdma puts this content in the same spot
if the client sends it via RDMA READ. So now, if the client sends the
extra bytes via SEND, svcrdma will put the bytes in the same spot as
the other cases.

The goal is to provide support for trailing inline content without
altering the upper layers of the NFS server.

> I'm just trying to understand if this complicated logic is worth the
> extra bytes of a larger recv buffer you are saving...

The complexity here arises only because we have to deal with the
possibility that copying the inline content may cross into a new page.
If we could guarantee that will never happen, then half of
rdma_copy_tail() can be removed.

> Will this code path happen a lot? If so you might get some overhead
> you may want to avoid.

It happens for every NFSv4 WRITE compound sent by a Linux NFS client,
and amounts to 16 bytes. (Yes, we’re now doing a 16-byte RDMA READ to
bring that data over. As I said, that’s a bug).

The overhead on the server for moving the extra 16 bytes is tiny, and
we get to re-use the current server’s NFSv4 compound decoder instead
of creating upper layer code just for svcrdma.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



