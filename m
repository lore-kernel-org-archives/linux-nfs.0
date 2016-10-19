Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40778 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941332AbcJSR0N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Oct 2016 13:26:13 -0400
Date: Wed, 19 Oct 2016 13:26:11 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: nfsd: managing pages under network I/O
Message-ID: <20161019172611.GA22783@fieldses.org>
References: <BD4A3DBB-71B5-4C30-8976-43F4DD58CBBE@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BD4A3DBB-71B5-4C30-8976-43F4DD58CBBE@oracle.com>
From: bfields@fieldses.org (J. Bruce Fields)
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

I don't understand what problem you're trying to fix.  Is "moving pages
around" really especially complicated or expensive?

--b.

> 
> Another option would be for ->sendto to return a value that means
> the transport will release the svc_rqst and pages.
> 
> Or, the svc_rqst could be reference counted.
> 
> Anyone have thoughts about this?
> 
> --
> Chuck Lever
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
