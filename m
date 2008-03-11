From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] SVCRDMA: Add check for XPT_CLOSE in svc_rdma_send
Date: Tue, 11 Mar 2008 14:32:15 -0400
Message-ID: <20080311183215.GA14679@fieldses.org>
References: <1205257467.4795.3.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60221 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755929AbYCKScR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Mar 2008 14:32:17 -0400
In-Reply-To: <1205257467.4795.3.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 11, 2008 at 12:44:27PM -0500, Tom Tucker wrote:
> SVCRDMA: Add check for XPT_CLOSE in svc_rdma_send
>     
> The svcrdma transport can crash if a send is waiting for an
> empty SQ slot and the connection is closed due to an asynchronous error.
> The crash is caused when svc_rdma_send attempts to send on a deleted
> QP.
>     
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
> This is not a critical fix for 2.6.25, but part of a general clean up of the error paths.

OK, thanks; I've applied this, and passed along the other two to Linus.

--b.
