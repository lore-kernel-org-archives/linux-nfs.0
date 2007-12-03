From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 34/38] svc: Add /proc/sys/sunrpc/transport files
Date: Mon, 03 Dec 2007 13:10:58 -0600
Message-ID: <1196709058.5811.21.camel@trinity.ogc.int>
References: <20071129223917.14563.77633.stgit@dell3.ogc.int>
	 <20071129224105.14563.48684.stgit@dell3.ogc.int>
	 <C3F9B0D5-6CBD-4BBC-B00E-DCA16DD78EBF@oracle.com>
	 <20071203165853.GE16422@fieldses.org>
	 <1C15F1D5-88CC-4FD1-A7B9-508694A1A009@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>,
	Greg Banks <gnb@sgi.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:56485 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752599AbXLCT3M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2007 14:29:12 -0500
In-Reply-To: <1C15F1D5-88CC-4FD1-A7B9-508694A1A009@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2007-12-03 at 13:30 -0500, Chuck Lever wrote:
> On Dec 3, 2007, at 11:58 AM, J. Bruce Fields wrote:
> > On Mon, Dec 03, 2007 at 11:44:15AM -0500, Chuck Lever wrote:
> >> One last one, then I will crawl back into my hole.
> >
> > By the way, based on who I recall making a lot of comments, I'm  
> > planning
> > on just adding:
> >
> > 	Acked-by: Neil Brown <neilb@suse.de>
> > 	Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
> > 	Reviewed-by: Greg Banks <gnb@sgi.com>
> >
> > to all of the server transport-switch and rdma patches.  Does that  
> > sound
> > right?
> 
> OK for the transport switch.  I'm not qualified to review the bulk of  
> the RDMA work, so I would prefer that you don't add Reviewed-by "me"  
> for those patches.  My eyes glazed over a few lines after the GPL  
> boilerplate.
> 
> > And I'm assuming there are no objections to submitting this come the
> > next merge window.
> 
> 
> Refactoring the server-side write space logic has exposed some  
> problems that really shouldn't be allowed to stand.  I think we  
> should resolve the issues in the TCP write space callback before  
> merging.  Realistically those problems are non-architectural and  
> should be fixable before the window opens.
> 

Could you be more specific on what these problems are?

> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com

