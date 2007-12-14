From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 34/38] svc: Add transport hdr size for defer/revisit
Date: Fri, 14 Dec 2007 18:37:17 -0500
Message-ID: <20071214233717.GM23121@fieldses.org>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int> <20071211233309.15718.84852.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37650 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756162AbXLNXhV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Dec 2007 18:37:21 -0500
In-Reply-To: <20071211233309.15718.84852.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 11, 2007 at 05:33:09PM -0600, Tom Tucker wrote:
> 
> Some transports have a header in front of the RPC header. The current
> defer/revisit processing considers only the iov_len and arg_len to 
> determine how much to back up when saving the original request
> to revisit. Add a field to the rqstp structure to save the size
> of the transport header so svc_defer can correctly compute
> the start of a request. 

I know I asked before, and can't remember what happened: has this been
tested with krb5p?  (I know nobody cares much whether krb5p/rdma works,
I just want to make sure krb5p/rdma doesn't oops, and that
krb5p/{tcp,udp} are unchanged.)

I'll try it eventually if you don't....

--b.
