Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:51161 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214AbbKXQEb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 11:04:31 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v1 8/8] svcrdma: Remove svc_rdma_fastreg_mr::access_flags field
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20151124160323.GA16427@infradead.org>
Date: Tue, 24 Nov 2015 11:04:04 -0500
Cc: Tom Talpey <tom@talpey.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <5AC80703-8CA1-4CB3-9F96-642C45F650A3@oracle.com>
References: <20151123221738.13040.26277.stgit@klimt.1015granger.net> <20151123222118.13040.24258.stgit@klimt.1015granger.net> <5653B4CA.5050806@talpey.com> <92B143FC-0F2C-48E4-9042-189883D76403@oracle.com> <20151124063903.GA12300@infradead.org> <7B9388F8-3A88-4F61-AB87-A1E6DB9902FE@oracle.com> <20151124160323.GA16427@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 24, 2015, at 11:03 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> On Tue, Nov 24, 2015 at 09:08:21AM -0500, Chuck Lever wrote:
>> Why don???t you fold my change into yours?
> 
> It's already included.  Well, sort of - I have removed used of the
> field, but forgot to remove the definition.  I will update it.

Excellent, that works for me.

--
Chuck Lever




