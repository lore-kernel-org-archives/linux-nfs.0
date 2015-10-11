Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:49073 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751563AbbJKNIX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 Oct 2015 09:08:23 -0400
Date: Sun, 11 Oct 2015 15:08:22 +0200
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Stable Tree Mailing List <stable@vger.kernel.org>
Subject: Re: [PATCH] nfsd/blocklayout: accept any minlength
Message-ID: <20151011130821.GC3726@lst.de>
References: <1444395806-32111-1-git-send-email-hch@lst.de> <20151009152803.GC6825@fieldses.org> <20151009170400.GA7482@lst.de> <20151009174556.GA8188@fieldses.org> <CAHQdGtQN15nChCy8mzrDBdaU+RTTCvqaSbH1D=e56c2B_+5KiA@mail.gmail.com> <20151009200438.GB8188@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151009200438.GB8188@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 09, 2015 at 04:04:38PM -0400, J. Bruce Fields wrote:
> I had some ideas that layouts were something a server could decline just
> on random whim.  Rereading that section.... OK, looks like I was
> confused, TRYLATER is the closest we come to random whim.
> 
> So the following condition on the alignments of the offset also looks
> wrong.  Christoph, should it be rounding the offset down instead of
> rejecting in that case?

RFC5663 is very explicit about the extents being aligned, but doesn't
say anything about LAYOUTGET requests.  It's a bit of a gray area, but
I think not handing out a layout is still the best thing to do as a client
has to be really confused to ask for an unaligned layout and expect to get
an aligned extent back.  I just need to check for the best possible error
value.

> And other layoutunavailable cases might need review too.

Will do.
