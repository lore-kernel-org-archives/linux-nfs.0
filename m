Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:55241 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759179Ab1IIWDO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Sep 2011 18:03:14 -0400
Date: Fri, 9 Sep 2011 18:03:12 -0400
From: Jim Rees <rees@umich.edu>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: shouldn't rpc_pipe_upcall message structs be
 __attribute__((packed)) ?
Message-ID: <20110909220312.GA22084@merit.edu>
References: <20110909143605.57d54899@tlielax.poochiereds.net>
 <20110909195615.GA21276@merit.edu>
 <20110909171654.3ae6b513@tlielax.poochiereds.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110909171654.3ae6b513@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jeff Layton wrote:

  On Fri, 9 Sep 2011 15:56:15 -0400
  Jim Rees <rees@umich.edu> wrote:
  
  > Jeff Layton wrote:
  > 
  >   The blocklayout upcall is even more scary as the width of the status
  >   field is not explicit:
  >   
  >   struct bl_dev_msg {
  >           int status;
  >           uint32_t major, minor;
  >   };
  > 
  > I'll take the blame for that one.  I will queue up a fix.
  > 
  > Making the blocklayout upcall struct packed might still be possible since
  > it's not officially released until 3.1, but I'm terrified of making changes
  > at this point in the release cycle that aren't actual bug fixes.
  
  Thanks, though I guess I also should take some of the blame for not
  reviewing and noticing this earlier...
  
  I'd personally call this a bug, and one that's particularly important
  to fix sooner rather than later. Changing this will mean ABI breakage
  any way you look at it. I think it would be better to go through that
  pain now before anyone is really relying on that code.

I'll go with whatever Trond thinks is best (not to shirk the responsibility,
but he's better able to assess the risks than I).  Should I send a patch?
It needs to be coordinated with nfs-utils, but that hasn't been released yet
either.

Would packing this struct actually change the layout on either x86 or
x86_64?

  While we're looking at this...do we also need to worry about endianness
  here? Is it possible we'd ever end up running BE upcall code on a LE
  kernel (or vice versa) in some sort of horrid compat mode? If so, it
  might be worthwhile to consider making both those fields __be32 or
  something and fixing the code to handle that properly as well.

If we're going to go to that much trouble, I think I would ditch the binary
and go with text.  The upcall for block layout is not in a performance
critical path.
