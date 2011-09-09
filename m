Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20979 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752582Ab1IIVQ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Sep 2011 17:16:59 -0400
Date: Fri, 9 Sep 2011 17:16:54 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: shouldn't rpc_pipe_upcall message structs be
 __attribute__((packed)) ?
Message-ID: <20110909171654.3ae6b513@tlielax.poochiereds.net>
In-Reply-To: <20110909195615.GA21276@merit.edu>
References: <20110909143605.57d54899@tlielax.poochiereds.net>
	<20110909195615.GA21276@merit.edu>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

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

While we're looking at this...do we also need to worry about endianness
here? Is it possible we'd ever end up running BE upcall code on a LE
kernel (or vice versa) in some sort of horrid compat mode? If so, it
might be worthwhile to consider making both those fields __be32 or
something and fixing the code to handle that properly as well.

-- 
Jeff Layton <jlayton@redhat.com>
