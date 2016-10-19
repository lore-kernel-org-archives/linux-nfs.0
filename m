Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40896 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933023AbcJST0D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Oct 2016 15:26:03 -0400
Date: Wed, 19 Oct 2016 15:26:02 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: nfsd: managing pages under network I/O
Message-ID: <20161019192602.GE23282@fieldses.org>
References: <BD4A3DBB-71B5-4C30-8976-43F4DD58CBBE@oracle.com>
 <20161019172611.GA22783@fieldses.org>
 <CFE1B548-5AC0-451E-BC9D-253395443355@oracle.com>
 <20161019191608.GD23282@fieldses.org>
 <4B1F71E8-8EA3-49E3-A303-93D9E6508A45@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4B1F71E8-8EA3-49E3-A303-93D9E6508A45@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 19, 2016 at 03:21:02PM -0400, Chuck Lever wrote:
> > On Oct 19, 2016, at 3:16 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > I thought "moving pages around" here is basically just this, from
> > isvc_rdma_sendto.c:send_reply():
> > 
> > 	pages = rqstp->rq_next_page - rqstp->rq_respages;
> >        for (page_no = 0; page_no < pages; page_no++) {
> >                ctxt->pages[page_no+1] = rqstp->rq_respages[page_no];
> > 		...
> >                rqstp->rq_respages[page_no] = NULL;
> > 		...
> > 	}
> > 
> > So we're just copying an array of page pointers from one place to
> > another, and zeroing out the source array.
> > 
> > For a short reply that could be 1 page or even none.  In the worst case
> > (a 1MB read result) that could be 256 8-byte pointers, so 2K.
> > 
> > Am I missing something?  Has that up-to-2K operation been a problem?
> 
> Not a problem, but not optimal either. Like I said, I can put together
> some helpers so that this code is not duplicated, and the call-sites
> would be a little easier to understand.

Sure, I've no objection if you find some cleanup that makes sense.

--b.
