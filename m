From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] bug in read_buf
Date: Thu, 22 Apr 2010 09:08:04 +1000
Message-ID: <20100422090804.4b0fbd22@notabene.brown>
References: <19405.3732.562014.510508@notabene.brown>
	<20100420165152.GD28826@fieldses.org>
	<g2k89c397151004201224wb35ae389g961523bbef23f452@mail.gmail.com>
	<20100420193944.GB31901@fieldses.org>
	<20100421223527.GB23480@fieldses.org>
	<20100421223605.GC23480@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "William A. (Andy) Adamson" <androsadamson@gmail.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35945 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754025Ab0DUXIM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Apr 2010 19:08:12 -0400
In-Reply-To: <20100421223605.GC23480@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 21 Apr 2010 18:36:05 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:


> > Hm, I guess even when argp->end is wrong, argp->p is always set to
> > something sane; so on the next READ_BUF(), when you hit the
> > 
> > 	nbytes <= (u32)((char *)argp->end - (char *)argp->p
> > 
> > case, you do
> > 
> > 	p = argp->p;
> > 	argp->p += XDR_QUADLEN(nbytes);
> > 
> > and p is something reasonable.  "end" stays wrong, but that won't be a
> > problem until you run past the end of the *next* page, which it would
> > take a very unusual compound to do.

Yes, it would not be an easy bug to trigger ... it takes away some of the
thrill of finding a bug when you discover that it only affects a corner case
that never ever happens :-(

> 
> (Nevertheless: applied, for 2.6.34 and stable.)

Thanks.

NeilBrown
