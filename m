Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50318 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755518Ab1LVSHd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Dec 2011 13:07:33 -0500
Date: Thu, 22 Dec 2011 13:07:30 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jim Rees <rees@umich.edu>
Cc: Jeff Layton <jlayton@redhat.com>, Chuck Lever <chuck.lever@oracle.com>,
        steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 4/5] nfsd: add a header describing upcall to nfsdcld
Message-ID: <20111222180730.GD6597@fieldses.org>
References: <1324499696-10318-1-git-send-email-jlayton@redhat.com>
 <1324499696-10318-5-git-send-email-jlayton@redhat.com>
 <46975244-4C42-4DC9-832B-E3597B8013FD@oracle.com>
 <20111221163312.3405c1f3@tlielax.poochiereds.net>
 <121533D1-9C5C-45EA-AF8F-90AA4167B066@oracle.com>
 <20111222080706.7a064430@tlielax.poochiereds.net>
 <20111222152051.GA2500@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111222152051.GA2500@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 22, 2011 at 10:20:51AM -0500, Jim Rees wrote:
> Jeff Layton wrote:
> 
>   Now that I've started looking at actually implementing this, I'm
>   leaning toward keeping this as a packed binary struct. The upcalls to
>   which you refer mostly use the cache_* interfaces in the kernel, and
>   the actual upcall "pipes" are in /proc. That code is already set up to
>   use primarily text based interfaces so it makes sense there.
>   
>   I looked at using that here and determined that the cache_* interface
>   was not well suited to this task. Those are geared toward interfaces
>   (like exportfs or mountd) where the information is primarily stored and
>   manipulated in userspace and the kernel upcalls to fetch that info and
>   populate its cache.
>   
>   In this case, the info is mostly coming from kernel space originally
>   and I believe that rpc_pipefs was better suited for this task. The
>   upcalls that use rpc_pipefs almost universally use a binary struct to
>   pass data between userspace and the kernel.
> 
> Having recently added a new rpc_pipe upcall for idmapd, my only suggestion
> is that you think about compatibility issues if the message format changes.
> Ideally you want any combination of new/old * kernel/user to work.  But I
> suspect you've already thought about this.

Yes, I think the 8-bit version and command numbers give us what we'd
need.  We should make sure the daemon returns a well-defined error in
the case it doesn't know about a new command or version number.  And
then any backwards compatibility problem can be solved with sufficient
application of switch statements.  Hopefully unnecessary, but should be
safe.

So the current format encoding looks OK to me.  Unless someone has a
real slam-dunk of an argument I'd rather stick with it for now.

--b.

> I see no harm in using binary for an interface that's only intended for a
> particular user daemon (assuming you solve the compatibility problem).  Text
> is useful for things in /proc that someone might want to manipulate using
> their own tool.  For something like idmapd I don't think a text interface is
> necessary.  No one is going to write their own idmapd, and if they do, the
> binary upcall interface will be the least of their worries.  The same may be
> true of nfsdcld.
