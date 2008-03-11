From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH] SVCRDMA: Add check for XPT_CLOSE in svc_rdma_send
Date: Tue, 11 Mar 2008 14:23:46 -0500
Message-ID: <1205263426.4795.12.camel@trinity.ogc.int>
References: <1205257467.4795.3.camel@trinity.ogc.int>
	 <20080311183215.GA14679@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:60678 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751252AbYCKTNV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Mar 2008 15:13:21 -0400
In-Reply-To: <20080311183215.GA14679@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-03-11 at 14:32 -0400, J. Bruce Fields wrote:
> On Tue, Mar 11, 2008 at 12:44:27PM -0500, Tom Tucker wrote:
> > SVCRDMA: Add check for XPT_CLOSE in svc_rdma_send
> >     
> > The svcrdma transport can crash if a send is waiting for an
> > empty SQ slot and the connection is closed due to an asynchronous error.
> > The crash is caused when svc_rdma_send attempts to send on a deleted
> > QP.
> >     
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > ---
> > 
> > This is not a critical fix for 2.6.25, but part of a general clean up of the error paths.
> 
> OK, thanks; I've applied this, and passed along the other two to Linus.

Awesome, thanks.

> 
> --b.

