Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:18804 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279AbbKXOIw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 09:08:52 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v1 8/8] svcrdma: Remove svc_rdma_fastreg_mr::access_flags field
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20151124063903.GA12300@infradead.org>
Date: Tue, 24 Nov 2015 09:08:21 -0500
Cc: Tom Talpey <tom@talpey.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <7B9388F8-3A88-4F61-AB87-A1E6DB9902FE@oracle.com>
References: <20151123221738.13040.26277.stgit@klimt.1015granger.net> <20151123222118.13040.24258.stgit@klimt.1015granger.net> <5653B4CA.5050806@talpey.com> <92B143FC-0F2C-48E4-9042-189883D76403@oracle.com> <20151124063903.GA12300@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 24, 2015, at 1:39 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> On Mon, Nov 23, 2015 at 07:53:04PM -0500, Chuck Lever wrote:
>>> Wait, the REMOTE_WRITE is there to support iWARP, but it isn't
>>> needed for IB or RoCE. Shouldn't this be updated to peek at those
>>> new attributes to decide, instead of remaining unconditional?
>> 
>> That???s coming in another patch from Christoph.
> 
> Can you drop this patch so that we have less conflicts with that one,
> assuming this series goes in through the NFS tree, and the memory
> registration changes go in through the RDMA tree?

Why don’t you fold my change into yours?


--
Chuck Lever




