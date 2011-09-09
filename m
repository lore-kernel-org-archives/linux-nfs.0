Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15460 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759098Ab1IIWcR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Sep 2011 18:32:17 -0400
Subject: Re: shouldn't rpc_pipe_upcall message structs be
 __attribute__((packed)) ?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Date: Fri, 09 Sep 2011 18:32:01 -0400
In-Reply-To: <20110909220312.GA22084@merit.edu>
References: <20110909143605.57d54899@tlielax.poochiereds.net>
	 <20110909195615.GA21276@merit.edu>
	 <20110909171654.3ae6b513@tlielax.poochiereds.net>
	 <20110909220312.GA22084@merit.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1315607521.17611.106.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-09-09 at 18:03 -0400, Jim Rees wrote: 
> Jeff Layton wrote:
> 
>   On Fri, 9 Sep 2011 15:56:15 -0400
>   Jim Rees <rees@umich.edu> wrote:
>   
>   > Jeff Layton wrote:
>   > 
>   >   The blocklayout upcall is even more scary as the width of the status
>   >   field is not explicit:
>   >   
>   >   struct bl_dev_msg {
>   >           int status;
>   >           uint32_t major, minor;
>   >   };
>   > 
>   > I'll take the blame for that one.  I will queue up a fix.
>   > 
>   > Making the blocklayout upcall struct packed might still be possible since
>   > it's not officially released until 3.1, but I'm terrified of making changes
>   > at this point in the release cycle that aren't actual bug fixes.
>   
>   Thanks, though I guess I also should take some of the blame for not
>   reviewing and noticing this earlier...
>   
>   I'd personally call this a bug, and one that's particularly important
>   to fix sooner rather than later. Changing this will mean ABI breakage
>   any way you look at it. I think it would be better to go through that
>   pain now before anyone is really relying on that code.
> 
> I'll go with whatever Trond thinks is best (not to shirk the responsibility,
> but he's better able to assess the risks than I).  Should I send a patch?
> It needs to be coordinated with nfs-utils, but that hasn't been released yet
> either.

Since the type is an 'int' rather than a 'long', I don't think we're
actually breaking any ABIs. I can't think of any currently supported
Linux platforms where 'int' is anything other than a 32-bit integer.
That said, it is good to be specific whenever nailing down an ABI.

> Would packing this struct actually change the layout on either x86 or
> x86_64?

Possibly, but we don't pack the other upcall/downcall arguments. See, for instance, the RPCSEC_GSS contexts.

> While we're looking at this...do we also need to worry about endianness
>   here? Is it possible we'd ever end up running BE upcall code on a LE
>   kernel (or vice versa) in some sort of horrid compat mode? If so, it
>   might be worthwhile to consider making both those fields __be32 or
>   something and fixing the code to handle that properly as well.
> 
> If we're going to go to that much trouble, I think I would ditch the binary
> and go with text.  The upcall for block layout is not in a performance
> critical path.

Urgh... If we're mixing endian modes, won't system calls be the first
things to break?
In any case, the current NFS client upcalls suppose that the endianness
stays the same between kernel and userland.

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

