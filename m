From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 38/38] svc: Add svc_xprt_names service to replace
	svc_sock_names
Date: Fri, 4 Jan 2008 11:47:22 +1100
Message-ID: <18301.33306.486417.193770@notabene.brown>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int>
	<20071211233318.15718.11614.stgit@dell3.ogc.int>
	<20071215000328.GP23121@fieldses.org>
	<1198259507.14237.31.camel@trinity.ogc.int>
	<20080103211405.GG15354@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46712 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752774AbYADAra (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jan 2008 19:47:30 -0500
In-Reply-To: message from J. Bruce Fields on Thursday January 3
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday January 3, bfields@fieldses.org wrote:
> On Fri, Dec 21, 2007 at 11:51:47AM -0600, Tom Tucker wrote:
> > 
> > On Fri, 2007-12-14 at 19:03 -0500, J. Bruce Fields wrote:
> > > On Tue, Dec 11, 2007 at 05:33:18PM -0600, Tom Tucker wrote:
> > > > 
> > > > Create a transport independent version of the svc_sock_names function.
> > > > 
> > > > The toclose capability of the svc_sock_names service can be implemented
> > > > using the svc_xprt_find and svc_xprt_close services.
> > > 
> > > Should we delete the toclose checks from svc_sock_names(), then, under
> > > the assumption it's always called with toclose non-NULL now?
> > > 
> > > And why can't we just completely replace svc_sock_names() at this point?
> > > 
> > 
> > IMO we could, but there is currently a difference in behavior between
> > svc_sock_names and svc_find_xprt/close. svc_find_xprt doesn't care what
> > the IP address is, it only compares transport name, address family and
> > port. 
> > 
> > Presently in NFS, we only ever listen on zero, but you can destroy an
> > endpoint on a particular interface (IP address). Can anyone shed some
> > light on why this is? 
> 
> Dunno.  Neil?

The "-H" option to "rpc.nfsd" allow you to bind nfsd to a specific
interface.
I don't think any user-space tools current allow you to unbind a
specific interface, but I wouldn't want to lose that functionality.

Why are we changing this.  Clear the toclose functionality of the
svc_sock_names service can *NOT* be impletemented using svc_xprt_find
and svc_xprt_close as _find_ doesn't check the port - so just leave
things the way they are??? I haven't really been following this update
much so maybe there is something I'm missing....

NeilBrown
