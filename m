Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:51764 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754839AbcJMGgd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Oct 2016 02:36:33 -0400
Date: Wed, 12 Oct 2016 23:35:35 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: nfsd: managing pages under network I/O
Message-ID: <20161013063535.GA7149@infradead.org>
References: <BD4A3DBB-71B5-4C30-8976-43F4DD58CBBE@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BD4A3DBB-71B5-4C30-8976-43F4DD58CBBE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 12, 2016 at 01:42:26PM -0400, Chuck Lever wrote:
> I'm studying the way that the ->recvfrom and ->sendto calls work
> for RPC-over-RDMA.
> 
> The ->sendto path moves pages out of the svc_rqst before posting
> I/O (RDMA Write and Send). Once the work is posted, ->sendto
> returns, and looks like svc_rqst is released at that point. The
> subsequent completion of the Send then releases those moved pages.
> 
> I'm wondering if the transport can be simplified: instead of
> moving pages around, ->sendto could just wait until the Write and
> Send activity is complete, then return. The upper layer then
> releases everything.

I'd prefer not block for no reason at all.

> Another option would be for ->sendto to return a value that means
> the transport will release the svc_rqst and pages.

Or just let the transport always release it.  We only have two
different implementations of the relevant ops anyway.
