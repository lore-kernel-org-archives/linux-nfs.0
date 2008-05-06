From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH  2/17] svcrdma: Fix race with dto_tasklet in
	svc_rdma_send
Date: Tue, 6 May 2008 17:18:51 -0400
Message-ID: <20080506211851.GM13484@fieldses.org>
References: <20080505220636.GG12814@fieldses.org> <C4452BEA.4959F%tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43768 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932717AbYEFVSw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 17:18:52 -0400
In-Reply-To: <C4452BEA.4959F%tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 05, 2008 at 09:26:02PM -0500, Tom Tucker wrote:
> 
> 
> 
> On 5/5/08 5:06 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Fri, May 02, 2008 at 11:28:34AM -0500, Tom Tucker wrote:
> >> The svc_rdma_send function will attempt to reap SQ WR to make room for
> >> a new request if it finds the SQ full. This function races with the
> >> dto_tasklet that also reaps SQ WR. To avoid calling the function
> >> unnecessarily use test_and_clear_bit with the RDMAXPRT_SQ_PENDING
> >> flag to serialize access to the sq_cq_reap function.
> > 
> > OK.  I won't pretend to understand much of this, but--would it be worth
> > pulling out the added code here into a helper function, since it now
> > exists in two different places?  (Especially if correctness depends on
> > the same thing happening in both the places this bit can be cleared.)
> 
> Yes. Good suggestions.
> 
> BTW, this code is here because the SQ is undersized for big data. Since a
> single NFS_READ/WRITE can result in an attempt to fetch a large amount of
> data from the client (2M) and depending on certain HW resources this can
> result in a lot of WR being posted to the SQ.

WR is write request, SQ is send queue?  (In which case this happens on
nfs read operations?)  I'm behind....

> That said, there is a change coming in the 2.6.27 time frame that supports
> what is called Fast NSMR register. This allows the transport to effectively
> DMA map the entire transfer size (32k -- 2M) all as a single SGE. This will
> take a lot of pressure off the SQ and effectively make this code
> unnecessary.

OK!

Ideally we'd have patches for 2.6.27 in linux-next for a little while
first, so we should try to have that ready in a month or so, when the
-rc's start looking final.

--b.
