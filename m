Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1918 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754548Ab0LHAaE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Dec 2010 19:30:04 -0500
Subject: Re: oops in nfs_flush_incompatible (and possible fix?)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20101207165354.32c863f2@tlielax.poochiereds.net>
References: <20101206145743.4464c79d@tlielax.poochiereds.net>
	 <1291758082.3049.42.camel@heimdal.trondhjem.org>
	 <20101207165354.32c863f2@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Dec 2010 19:30:00 -0500
Message-ID: <1291768200.3049.51.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-12-07 at 16:53 -0500, Jeff Layton wrote:
> On Tue, 07 Dec 2010 16:41:22 -0500
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > I've been racking my brain for days now trying to remember why we clear
> > the request in these cases. I think it was only about ensuring that we
> > could throw the page out of the cache using invalidate_inode_pages()
> > (and there is a comment about that in early 2.4.x kernels).
> > 
> > As far as I can see, there no longer appear to be any side effects to
> > deferring releasing the page or open_contexts but I'm still a bit
> > nervous about doing so.
> > Can we therefore please give it a good week of pounding upon before I
> > pass it on to Linus?
> > 
> > Cheers
> >   Trond
> > 
> 
> Sounds good. I have the reporter of this problem testing a 2.6.18-based
> kernel with this patch now to see whether it fixes it. We might as well
> hold off until we have results from that. Their test takes several days
> to run though so it may be a little while before we know whether this
> helps. I'll reply once I hear from them.

Looks like I was right to be sceptical. My setup hangs hard on the
Connectathon test5 (read and write) when this patch is applied.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

