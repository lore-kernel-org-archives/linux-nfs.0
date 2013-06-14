Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f174.google.com ([209.85.128.174]:57371 "EHLO
	mail-ve0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461Ab3FNMJN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jun 2013 08:09:13 -0400
Received: by mail-ve0-f174.google.com with SMTP id oz10so396153veb.33
        for <linux-nfs@vger.kernel.org>; Fri, 14 Jun 2013 05:09:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130612164637.GA6868@fieldses.org>
References: <CAEfL3KnfRWof4-6UAWTwXcH7XWSQuUR5ry_pg4qdyhBB6dt+5g@mail.gmail.com>
	<20130611195140.GA29634@fieldses.org>
	<51B7DE9C.6080703@talpey.com>
	<20130612153936.GB32569@fieldses.org>
	<CAEfL3KkdjB7bzvnfiDh024kHjCH0e64iH6GK6y+A+bpH3kUgJg@mail.gmail.com>
	<20130612164637.GA6868@fieldses.org>
Date: Fri, 14 Jun 2013 17:39:12 +0530
Message-ID: <CAEfL3Km7knMAW1Jx_jHZ0OYBMBpUkvbzk2riBE2C=NA9OMvUQw@mail.gmail.com>
Subject: Re: why does nfsd write not use splice
From: Sandeep Joshi <sanjos100@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 12, 2013 at 10:16 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Wed, Jun 12, 2013 at 09:51:09PM +0530, Sandeep Joshi wrote:
> > Splice can be implemented independent of RDMA.  It is supposed to
> > transfer
> > pages between two file descriptors.  I found some postings on lkml from
> > 2006 where Linus says it is quite possible to splice from a socket to a
> > file.
> >
> > See the paragraph:
> > " For filesystems, splice support tends to be really easy (both read and
> > write). For other things, it depends a bit. But unlike sendfile(), it
> > really is quite possible to splice _from_ a socket too, not just _to_ a
> > socket. But no, that case hasn't been written yet."
> >  http://yarchive.net/comp/linux/splice.html
> >
> > Larry McVoy's 1997 proposal for adding splice support to the  kernel can
> > be
> > read at
> > ftp.tux.org/pub/sites/ftp.bitmover.com/pub/*splice*.*ps*.gz<http://ftp.tux.org/pub/sites/ftp.bitmover.com/pub/splice.ps.gz>
> >
> > Perhaps I should have opened this thread on lkml to determine if splice
> > from socket to file is still feasible..
>
> Right, the thing is, nfsd reads the rpc request from the socket into its
> own buffers before it parses it.  If you want to move the data directly
> out of the network buffers into the page cache, then you have to know at
> what point the write data starts in the request--which I believe will
> mean doing the xdr parsing (and gss decryption if necessary) as the
> request comes in off the wire.
>
> That sounds like a lot of work and even if you have someone willing to
> do the work they'd also need to justify that it's worth it.
>
> RDMA may have some protocol support that simplifies this, I don't know.
>
> --b.

Hi Bruce,

> nfsd reads the rpc request from the socket into its own buffers before it parses it.

I am not intimate with the gss code but do you think the
svc_rqst->rq_pages[] can be spliced ?

-Sandeep
