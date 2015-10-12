Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46494 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751861AbbJLUSR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Oct 2015 16:18:17 -0400
Date: Mon, 12 Oct 2015 16:18:15 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Stable Tree Mailing List <stable@vger.kernel.org>
Subject: Re: [PATCH] nfsd/blocklayout: accept any minlength
Message-ID: <20151012201815.GK28755@fieldses.org>
References: <1444395806-32111-1-git-send-email-hch@lst.de>
 <20151009152803.GC6825@fieldses.org>
 <20151009170400.GA7482@lst.de>
 <20151009174556.GA8188@fieldses.org>
 <CAHQdGtQN15nChCy8mzrDBdaU+RTTCvqaSbH1D=e56c2B_+5KiA@mail.gmail.com>
 <20151009200438.GB8188@fieldses.org>
 <20151011130821.GC3726@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151011130821.GC3726@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 11, 2015 at 03:08:22PM +0200, Christoph Hellwig wrote:
> On Fri, Oct 09, 2015 at 04:04:38PM -0400, J. Bruce Fields wrote:
> > I had some ideas that layouts were something a server could decline just
> > on random whim.  Rereading that section.... OK, looks like I was
> > confused, TRYLATER is the closest we come to random whim.
> > 
> > So the following condition on the alignments of the offset also looks
> > wrong.  Christoph, should it be rounding the offset down instead of
> > rejecting in that case?
> 
> RFC5663 is very explicit about the extents being aligned, but doesn't
> say anything about LAYOUTGET requests.  It's a bit of a gray area, but
> I think not handing out a layout is still the best thing to do as a client
> has to be really confused to ask for an unaligned layout and expect to get
> an aligned extent back.

http://tools.ietf.org/html/rfc5661#section-18.43.3 always allows a
server to round down the offset, is there any downside to doing that?

> I just need to check for the best possible error value.

INVAL or BADLAYOUT, I guess.  But just rounding down seems harmless and
compatible with the letter of the spec.

Though without any reason or a client to request an unaligned offset I
guess it's a bit academic.

--b.

> 
> > And other layoutunavailable cases might need review too.
> 
> Will do.
