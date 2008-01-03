From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 38/38] svc: Add svc_xprt_names service to replace
	svc_sock_names
Date: Thu, 3 Jan 2008 16:14:05 -0500
Message-ID: <20080103211405.GG15354@fieldses.org>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int> <20071211233318.15718.11614.stgit@dell3.ogc.int> <20071215000328.GP23121@fieldses.org> <1198259507.14237.31.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:40397 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752036AbYACVOH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jan 2008 16:14:07 -0500
In-Reply-To: <1198259507.14237.31.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 21, 2007 at 11:51:47AM -0600, Tom Tucker wrote:
> 
> On Fri, 2007-12-14 at 19:03 -0500, J. Bruce Fields wrote:
> > On Tue, Dec 11, 2007 at 05:33:18PM -0600, Tom Tucker wrote:
> > > 
> > > Create a transport independent version of the svc_sock_names function.
> > > 
> > > The toclose capability of the svc_sock_names service can be implemented
> > > using the svc_xprt_find and svc_xprt_close services.
> > 
> > Should we delete the toclose checks from svc_sock_names(), then, under
> > the assumption it's always called with toclose non-NULL now?
> > 
> > And why can't we just completely replace svc_sock_names() at this point?
> > 
> 
> IMO we could, but there is currently a difference in behavior between
> svc_sock_names and svc_find_xprt/close. svc_find_xprt doesn't care what
> the IP address is, it only compares transport name, address family and
> port. 
> 
> Presently in NFS, we only ever listen on zero, but you can destroy an
> endpoint on a particular interface (IP address). Can anyone shed some
> light on why this is? 

Dunno.  Neil?

--b.
