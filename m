Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50828 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbbEEQEQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 May 2015 12:04:16 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v1 00/16] NFS/RDMA patches proposed for 4.1
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150505154411.GA16729@infradead.org>
Date: Tue, 5 May 2015 12:04:00 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Message-Id: <5E1B32EA-9803-49AA-856D-BF0E1A5DFFF4@oracle.com>
References: <20150313211124.22471.14517.stgit@manet.1015granger.net> <20150505154411.GA16729@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 5, 2015, at 11:44 AM, Christoph Hellwig <hch@infradead.org> wrote:

> On Fri, Mar 13, 2015 at 05:21:17PM -0400, Chuck Lever wrote:
>> This is a series of client-side patches for NFS/RDMA. In preparation
>> for increasing the transport credit limit and maximum rsize/wsize,
>> I've re-factored the memory registration logic into separate files,
>> invoked via a method API.
> 
> Just curious if you ever though of moving this into the generic
> rdma layer?

Not really. The new files are really just shims that adapt the RPC/RDMA
transport to memory registration verbs. There’s only a few hundred lines
per registration mode, and it’s all fairly specific to RPC/RDMA.

> I've been working on a rdma based storage driver recently, and the
> various different memory registration methods are a complete pain in the
> ass, and impossible to test in and ULD without havin access to all kinds
> of different hardware.

Agree that the test matrix grows exponentially in complexity and
expense as more MR modes are introduced. We have strategies for
managing this when there’s a community involved, but when there’s
just one developer it’s a challenge.

> And from I see we litterly dont use them much different from the generic
> dma mapping API helpers (at a very high level) so it seems it should
> be easy to move a slightly expanded version of your API to the core
> code.

IMO FRWR is the only registration mode that has legs for the long term,
and is specifically designed for storage.

If you are not working on a legacy piece of code that has to support
older HCAs, why not stay with FRWR?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



