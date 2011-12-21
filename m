Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40294 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751418Ab1LUV7u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Dec 2011 16:59:50 -0500
Date: Wed, 21 Dec 2011 16:59:22 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, bfields@fieldses.org,
        steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 4/5] nfsd: add a header describing upcall to nfsdcld
Message-ID: <20111221165922.589101aa@tlielax.poochiereds.net>
In-Reply-To: <20111221164810.78d600a9@tlielax.poochiereds.net>
References: <1324499696-10318-1-git-send-email-jlayton@redhat.com>
	<1324499696-10318-5-git-send-email-jlayton@redhat.com>
	<46975244-4C42-4DC9-832B-E3597B8013FD@oracle.com>
	<20111221163312.3405c1f3@tlielax.poochiereds.net>
	<121533D1-9C5C-45EA-AF8F-90AA4167B066@oracle.com>
	<20111221164810.78d600a9@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 21 Dec 2011 16:48:10 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> On Wed, 21 Dec 2011 16:37:30 -0500
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> > 
> > On Dec 21, 2011, at 4:33 PM, Jeff Layton wrote:
> > 
> > > On Wed, 21 Dec 2011 15:45:01 -0500
> > > Chuck Lever <chuck.lever@oracle.com> wrote:
> > > 
> > >> 
> > >> On Dec 21, 2011, at 3:34 PM, Jeff Layton wrote:
> > >> 
> > >>> The daemon takes a versioned binary struct. Hopefully this should allow
> > >>> us to revise the struct later if it becomes necessary.
> > >> 
> > >> This breaks the pattern of using text-based up- and downcalls in NFSD.  I assume this is binary because nfs_client_id4 is a string of opaque bytes?
> > >> 
> > > 
> > > That's the main reason. We could, of course encode that string in hex or
> > > something, and decode it on the other end. No one has presented a
> > > strong argument for doing it that way as of yet though.
> > > 
> > > If anyone feels strongly about that, then it would be helpful to have
> > > them pipe up now and state why they do...
> > 
> > <pipe>Because binary data structures are difficult to work with over time, which is why other NFSD user space interfaces are text-based.</pipe>
> > 
> > ;-)
> > 
> 
> *sigh* that was the sort of comments I was hoping to get out of the RFC
> postings. But ok...
> 
> I'll see about respinning the whole thing with either a text-based or
> XDR-based upcall/downcall format. That'll take a while, but I'll see if
> I can get it in shape in time for 3.3.
> 

...and while we're discussing it. Does anyone have thoughts on which
would be better? I'd probably prefer a text-based format. That's more
flexible but is also going to be more verbose. I think we're still well
under a page with these requests even in text however so I don't really
see that as a problem.

-- 
Jeff Layton <jlayton@redhat.com>
