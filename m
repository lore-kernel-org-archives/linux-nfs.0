Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50183 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752403Ab1LVNHb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Dec 2011 08:07:31 -0500
Date: Thu, 22 Dec 2011 08:07:06 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: bfields@fieldses.org, steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 4/5] nfsd: add a header describing upcall to nfsdcld
Message-ID: <20111222080706.7a064430@tlielax.poochiereds.net>
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
> 

Now that I've started looking at actually implementing this, I'm
leaning toward keeping this as a packed binary struct. The upcalls to
which you refer mostly use the cache_* interfaces in the kernel, and
the actual upcall "pipes" are in /proc. That code is already set up to
use primarily text based interfaces so it makes sense there.

I looked at using that here and determined that the cache_* interface
was not well suited to this task. Those are geared toward interfaces
(like exportfs or mountd) where the information is primarily stored and
manipulated in userspace and the kernel upcalls to fetch that info and
populate its cache.

In this case, the info is mostly coming from kernel space originally
and I believe that rpc_pipefs was better suited for this task. The
upcalls that use rpc_pipefs almost universally use a binary struct to
pass data between userspace and the kernel.

Certainly this could use text or XDR, but I don't see that as a clear
benefit here. It's going to add a lot of extra overhead and complexity
to both the kernel and userspace code and we'll still have similar
concerns with extending the interface later.

The union that the code currently uses for passing call-specific args
is 1k currently. If we're concerned about that expandablity then we can
simply pad that out to a larger size.

-- 
Jeff Layton <jlayton@redhat.com>
