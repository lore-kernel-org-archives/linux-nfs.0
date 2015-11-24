Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:52094 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbbKXGjG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 01:39:06 -0500
Date: Mon, 23 Nov 2015 22:39:03 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Tom Talpey <tom@talpey.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 8/8] svcrdma: Remove svc_rdma_fastreg_mr::access_flags
 field
Message-ID: <20151124063903.GA12300@infradead.org>
References: <20151123221738.13040.26277.stgit@klimt.1015granger.net>
 <20151123222118.13040.24258.stgit@klimt.1015granger.net>
 <5653B4CA.5050806@talpey.com>
 <92B143FC-0F2C-48E4-9042-189883D76403@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <92B143FC-0F2C-48E4-9042-189883D76403@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 23, 2015 at 07:53:04PM -0500, Chuck Lever wrote:
> > Wait, the REMOTE_WRITE is there to support iWARP, but it isn't
> > needed for IB or RoCE. Shouldn't this be updated to peek at those
> > new attributes to decide, instead of remaining unconditional?
> 
> That???s coming in another patch from Christoph.

Can you drop this patch so that we have less conflicts with that one,
assuming this series goes in through the NFS tree, and the memory
registration changes go in through the RDMA tree?
