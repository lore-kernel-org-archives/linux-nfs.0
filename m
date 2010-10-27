Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35664 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753056Ab0J0Rks (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Oct 2010 13:40:48 -0400
Date: Wed, 27 Oct 2010 13:40:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@infradead.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: nfsd changes for 2.6.37
Message-ID: <20101027174016.GA18974@fieldses.org>
References: <20101026164549.GD19445@fieldses.org>
 <20101027145538.GC6328@fieldses.org>
 <20101027145929.GA5788@infradead.org>
 <201010271723.59734.arnd@arndb.de>
 <AANLkTinTm-LwjfBfoFUyp5Dj8S2hexnHGQGpZiOWqyMY@mail.gmail.com>
 <20101027164606.GF6328@fieldses.org>
 <AANLkTinTXoGiFap-vfu0P_SXb5xS+gMsHOwQtN3Hra3r@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <AANLkTinTXoGiFap-vfu0P_SXb5xS+gMsHOwQtN3Hra3r@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Oct 27, 2010 at 10:32:20AM -0700, Linus Torvalds wrote:
> On Wed, Oct 27, 2010 at 9:46 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Wed, Oct 27, 2010 at 09:12:06AM -0700, Linus Torvalds wrote:
> >>
> >> Something like the attached (UNTESTED!) perhaps?
> >
> > Makes sense to me.  Testing....
> 
> So I found a buglet in the patch: the
> 
>   NOTE! It is very important that the FASYNC flag always
>   match the state "is the filp on a fasync list".
> 
> comment should be moved to be associated with "fasync_insert_entry()"
> rather than "fasync_add_entry()", since it's the insert-entry thing
> that does the actual FASYNC flag handling.
> 
> But that incorrect comment placement shouldn't affect testing, obviously ;)
> 
> Btw, who is going to collect these things assuming it passes testing?
> Arnd? You? I'll happily sign off on the fasync patch (with the comment
> movement) assuming it tests out ok, but there's all the other patches
> too that have been passed around. I really do want to get this into
> the merge window, because it would be a big shame if we couldn't
> effectively get rid of the BKL now just because of these kinds of
> smallish final details, so I'm just checking who wants to step up to
> the plate to collect it all together and make sure I have it?

Doesn't matter to me.  What I've currently got (Arnd's patches with some
minor fixes from me, and your patch, all in a poorly changelogged
jumble) is in

	git://linux-nfs.org/~bfields/linux-topics.git TMP-BKL-TESTING

You wouldn't want to merge that as is, but it does seem to work.

--b.
