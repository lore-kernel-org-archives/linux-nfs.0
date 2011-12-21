Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35772 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751473Ab1LUVsh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Dec 2011 16:48:37 -0500
Date: Wed, 21 Dec 2011 16:48:10 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: bfields@fieldses.org, steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 4/5] nfsd: add a header describing upcall to nfsdcld
Message-ID: <20111221164810.78d600a9@tlielax.poochiereds.net>
In-Reply-To: <121533D1-9C5C-45EA-AF8F-90AA4167B066@oracle.com>
References: <1324499696-10318-1-git-send-email-jlayton@redhat.com>
	<1324499696-10318-5-git-send-email-jlayton@redhat.com>
	<46975244-4C42-4DC9-832B-E3597B8013FD@oracle.com>
	<20111221163312.3405c1f3@tlielax.poochiereds.net>
	<121533D1-9C5C-45EA-AF8F-90AA4167B066@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 21 Dec 2011 16:37:30 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Dec 21, 2011, at 4:33 PM, Jeff Layton wrote:
> 
> > On Wed, 21 Dec 2011 15:45:01 -0500
> > Chuck Lever <chuck.lever@oracle.com> wrote:
> > 
> >> 
> >> On Dec 21, 2011, at 3:34 PM, Jeff Layton wrote:
> >> 
> >>> The daemon takes a versioned binary struct. Hopefully this should allow
> >>> us to revise the struct later if it becomes necessary.
> >> 
> >> This breaks the pattern of using text-based up- and downcalls in NFSD.  I assume this is binary because nfs_client_id4 is a string of opaque bytes?
> >> 
> > 
> > That's the main reason. We could, of course encode that string in hex or
> > something, and decode it on the other end. No one has presented a
> > strong argument for doing it that way as of yet though.
> > 
> > If anyone feels strongly about that, then it would be helpful to have
> > them pipe up now and state why they do...
> 
> <pipe>Because binary data structures are difficult to work with over time, which is why other NFSD user space interfaces are text-based.</pipe>
> 
> ;-)
> 

*sigh* that was the sort of comments I was hoping to get out of the RFC
postings. But ok...

I'll see about respinning the whole thing with either a text-based or
XDR-based upcall/downcall format. That'll take a while, but I'll see if
I can get it in shape in time for 3.3.

-- 
Jeff Layton <jlayton@redhat.com>
