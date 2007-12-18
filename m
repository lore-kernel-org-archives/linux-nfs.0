From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 01/38] svc: Add an svc transport class
Date: Tue, 18 Dec 2007 13:30:38 -0600
Message-ID: <1198006238.13463.79.camel@trinity.ogc.int>
References: <20071213184506.GA29496@fieldses.org>
	 <C38BA039.233C0%tom@opengridcomputing.com>
	 <20071217174535.GA13515@fieldses.org>
	 <1197937584.13463.44.camel@trinity.ogc.int>
	 <20071218145419.GC14783@fieldses.org>
	 <1197990256.13463.54.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:50061 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751620AbXLRTZS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Dec 2007 14:25:18 -0500
In-Reply-To: <1197990256.13463.54.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2007-12-18 at 09:04 -0600, Tom Tucker wrote:
> On Tue, 2007-12-18 at 09:54 -0500, J. Bruce Fields wrote:
> > On Mon, Dec 17, 2007 at 06:26:24PM -0600, Tom Tucker wrote:
> > > I've coded all of the changes that you suggested and built a new
> > > patchset. Besides the tests I outlined in my "test matrix" are there any
> > > other tests you would like to see performed?
> > 
> > krb5p testing might still be interesting.
> > 
> 
> I'll add it to my matrix. It will take some time to set up though since
> I don't have a KDC or anything set up. Are we under any time
> constraints?
> 
> > > 
> > > I could not reproduce the BUG_ON from Bull. I'm wondering if it's a PPC
> > > issue :-\ 
> > 
> > Hm, too bad, I'd like to understand that one.
> > 

FYI, I have now reproduced this bug on an AMD64 box with the
CITI_NFS4_ALL-1 tree. 

I am regression testing it on the new build have been running it about
2hrs without failure.

> 
> Yeah, and I'm having a hard time believing it's PPC related. I think I'm
> missing something, I'll keep looking.
> 
> > > 
> > > After the testing, I'll publish the revised patchset.
> > > 
> > 
> > OK, thanks.--b.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

