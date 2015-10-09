Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:33500 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757213AbbJIRyX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Oct 2015 13:54:23 -0400
Received: by obbbh8 with SMTP id bh8so68171525obb.0
        for <linux-nfs@vger.kernel.org>; Fri, 09 Oct 2015 10:54:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151009174556.GA8188@fieldses.org>
References: <1444395806-32111-1-git-send-email-hch@lst.de>
	<20151009152803.GC6825@fieldses.org>
	<20151009170400.GA7482@lst.de>
	<20151009174556.GA8188@fieldses.org>
Date: Fri, 9 Oct 2015 13:54:22 -0400
Message-ID: <CAHQdGtQN15nChCy8mzrDBdaU+RTTCvqaSbH1D=e56c2B_+5KiA@mail.gmail.com>
Subject: Re: [PATCH] nfsd/blocklayout: accept any minlength
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Stable Tree Mailing List <stable@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 9, 2015 at 1:45 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Fri, Oct 09, 2015 at 07:04:00PM +0200, Christoph Hellwig wrote:
> > On Fri, Oct 09, 2015 at 11:28:03AM -0400, J. Bruce Fields wrote:
> > > OK, planning to apply for 4.3 just on the assumption that you know what
> > > you're doing, but: I don't get it--it looks like the worst that can
> > > happen here is we just reuturn LAYOUTUNAVAILABLE to LAYOUTGET.
> > > Shouldn't the client then just fall back on normal NFS IO?  Why the
> > > hang?
> >
> > I've just retested with Trond's latest tree and can't reproduce the
> > hang anymore.  It used to fence the client due to a lack of response,
> > but that might have been a different client bug that has now been fixed.
>
> OK, makes sense.
>
> This still looks like a harmless enough change, but is it still stable
> and 4.3 material?
>
> If it affected a released client then it's probably worth it even if
> it's really a client bug.  If it's just something you saw once against
> an -rc1, I'd rather leave it for 4.4.

It's not a client bug.

The server is supposed to comply with the requirements in table 13 of
https://tools.ietf.org/html/rfc5661#section-18.43.3
Note that it should also be returning NFS4ERR_BADLAYOUT (or
NFS4ERR_LAYOUTTRYLATER if loga_minlength == 0) instead of
layoutunavailable if the loga_minlength request cannot be met.

Cheers
  Trond
