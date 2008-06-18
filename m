From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [RFC] new client gssd upcall
Date: Wed, 18 Jun 2008 07:51:54 -0400
Message-ID: <20080618075154.441a6d75@barsoom.rdu.redhat.com>
References: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu>
	<20080616102859.66fa6a34@tleilax.poochiereds.net>
	<20080617213622.GA5849@fieldses.org>
	<1213739969.7288.90.camel@localhost>
	<20080617220918.GE5849@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, aglo@citi.umich.edu,
	kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56356 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754772AbYFRLwN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Jun 2008 07:52:13 -0400
In-Reply-To: <20080617220918.GE5849@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 17 Jun 2008 18:09:18 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Jun 17, 2008 at 05:59:29PM -0400, Trond Myklebust wrote:
> > On Tue, 2008-06-17 at 17:36 -0400, J. Bruce Fields wrote:
> > > On Mon, Jun 16, 2008 at 10:28:59AM -0400, Jeff Layton wrote:
> > > > Has any thought been given to moving all of the rpc_pipefs upcalls to use
> > > > the keyctl API that David Howells did? It seems like that would be better
> > > > suited to this sort of application than rpc_pipefs...
> > > 
> > > I haven't looked at it.  I've just assumed that since Trond and Kevin
> > > have both looked at both API's, then there must be some good reason
> > > we're not using it....
> > 
> > Kevin has spent quite some time working on the keyring support, but as
> > far as I understand the amount of time he can continue to spend working
> > for CITI has recently been heavily reduced...
> 
> Hm, but I thought that you'd both decided that the gssd upcalls would
> end up coexisting with the upcalls in any case?
> 
> If there's a chance we might end up replacing the gssd upcalls entirely,
> then--while I don't want to stretch out this one task
> indefinitely--still it might be worth my time to go take a look at the
> keyctl API's Jeff mentions.
> 

If you're interested, there are several examples of upcalls that use
this API in CIFS. I used it for the SPNEGO/Kerberos stuff that I did
there several months ago. It's pretty easy to use and can handle a
fairly large payload if needed.

When it does the upcall, it runs a particular program, so there's no
need for a running daemon. That might be considered a good thing here
since it may be one less thing that a user has to remember to have
running...

-- 
Jeff Layton <jlayton@redhat.com>
