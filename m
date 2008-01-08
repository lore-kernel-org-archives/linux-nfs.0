From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 37/38] knfsd: Support adding transports by writing
	portlist file
Date: Tue, 08 Jan 2008 11:45:39 -0600
Message-ID: <1199814339.4887.16.camel@trinity.ogc.int>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int>
	 <20071211233316.15718.85089.stgit@dell3.ogc.int>
	 <20071214235109.GO23121@fieldses.org>
	 <1198259550.14237.33.camel@trinity.ogc.int>
	 <20080103211313.GF15354@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:57480 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757270AbYAHRjF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2008 12:39:05 -0500
In-Reply-To: <20080103211313.GF15354@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2008-01-03 at 16:13 -0500, J. Bruce Fields wrote:
> On Fri, Dec 21, 2007 at 11:52:30AM -0600, Tom Tucker wrote:

[...snip...]

> > > > +						     AF_UNSPEC, port);
> > > > +				if (xprt) {
> > > > +					svc_close_xprt(xprt);
> > > > +					err = 0;
> > > 
> > > Hm, also: I'd have thought that svc_find_xprt should be incrementing the
> > > reference count on the returned xprt, if we're expecting the caller to
> > > do anything with it other than check it against NULL.
> 
> ... there's still a race here, isn't there?
> 

I think it's a good idea to have the svc_find_xprt service take a
reference. I'll code this up....

> --b.

