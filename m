Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44908 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752266AbbJIUEj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Oct 2015 16:04:39 -0400
Date: Fri, 9 Oct 2015 16:04:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Stable Tree Mailing List <stable@vger.kernel.org>
Subject: Re: [PATCH] nfsd/blocklayout: accept any minlength
Message-ID: <20151009200438.GB8188@fieldses.org>
References: <1444395806-32111-1-git-send-email-hch@lst.de>
 <20151009152803.GC6825@fieldses.org>
 <20151009170400.GA7482@lst.de>
 <20151009174556.GA8188@fieldses.org>
 <CAHQdGtQN15nChCy8mzrDBdaU+RTTCvqaSbH1D=e56c2B_+5KiA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtQN15nChCy8mzrDBdaU+RTTCvqaSbH1D=e56c2B_+5KiA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 09, 2015 at 01:54:22PM -0400, Trond Myklebust wrote:
> On Fri, Oct 9, 2015 at 1:45 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Fri, Oct 09, 2015 at 07:04:00PM +0200, Christoph Hellwig wrote:
> > > On Fri, Oct 09, 2015 at 11:28:03AM -0400, J. Bruce Fields wrote:
> > > > OK, planning to apply for 4.3 just on the assumption that you know what
> > > > you're doing, but: I don't get it--it looks like the worst that can
> > > > happen here is we just reuturn LAYOUTUNAVAILABLE to LAYOUTGET.
> > > > Shouldn't the client then just fall back on normal NFS IO?  Why the
> > > > hang?
> > >
> > > I've just retested with Trond's latest tree and can't reproduce the
> > > hang anymore.  It used to fence the client due to a lack of response,
> > > but that might have been a different client bug that has now been fixed.
> >
> > OK, makes sense.
> >
> > This still looks like a harmless enough change, but is it still stable
> > and 4.3 material?
> >
> > If it affected a released client then it's probably worth it even if
> > it's really a client bug.  If it's just something you saw once against
> > an -rc1, I'd rather leave it for 4.4.
> 
> It's not a client bug.
> 
> The server is supposed to comply with the requirements in table 13 of
> https://tools.ietf.org/html/rfc5661#section-18.43.3
> Note that it should also be returning NFS4ERR_BADLAYOUT (or
> NFS4ERR_LAYOUTTRYLATER if loga_minlength == 0) instead of
> layoutunavailable if the loga_minlength request cannot be met.

I had some ideas that layouts were something a server could decline just
on random whim.  Rereading that section.... OK, looks like I was
confused, TRYLATER is the closest we come to random whim.

So the following condition on the alignments of the offset also looks
wrong.  Christoph, should it be rounding the offset down instead of
rejecting in that case?

And other layoutunavailable cases might need review too.

--b.
