Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:43636 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753189AbbKXUCN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 15:02:13 -0500
Date: Tue, 24 Nov 2015 12:02:12 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 3/8] svcrdma: Add svc_rdma_get_context() API that is
 allowed to fail
Message-ID: <20151124200212.GA10208@infradead.org>
References: <20151123221738.13040.26277.stgit@klimt.1015granger.net>
 <20151123222038.13040.61285.stgit@klimt.1015granger.net>
 <20151124065522.GC29141@infradead.org>
 <7717B6B1-4A27-4D8A-8BCC-528CEC6DB54D@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <7717B6B1-4A27-4D8A-8BCC-528CEC6DB54D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 24, 2015 at 09:24:51AM -0500, Chuck Lever wrote:
> There is only one (new) call site that needs it. I can simplify
> this patch as Sagi suggested before, but it seems silly to
> introduce the extra clutter of adding a gfp_t argument
> everywhere.

We a) generally try to pass the gfp_t around if we expect calling
contexts to change, and b the changes to the 6 callers are probably
still smaller than this patch :)

> > And if we have any way to avoid the __GFP_NOFAIL
> > I'd really appreciate if we could give that a try.
> 
> I???m not introducing the flag here.
> 
> Changing all the svc_rdma_get_context() call sites to handle
> allocation failure (when it is already highly unlikely) is
> a lot of needless work, IMO, and not related to supporting
> bi-directional RPC.

Ok.
