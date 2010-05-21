From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] sunrpc: fix leak on error on socket xprt setup
Date: Fri, 21 May 2010 11:12:19 -0400
Message-ID: <20100521151219.GG6938@fieldses.org>
References: <20100521002508.GA30928@fieldses.org> <1274447779.3692.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56301 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757451Ab0EUPMU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 May 2010 11:12:20 -0400
In-Reply-To: <1274447779.3692.8.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 21, 2010 at 09:16:19AM -0400, Trond Myklebust wrote:
> On Thu, 2010-05-20 at 20:25 -0400, J. Bruce Fields wrote: 
> > From: J. Bruce Fields <bfields@citi.umich.edu>
> > 
> > Also collect exit code together while we're at it.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> > Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> >  net/sunrpc/xprtsock.c |   29 ++++++++++++++++++-----------
> >  1 files changed, 18 insertions(+), 11 deletions(-)
> > 
> > I think I sent this before, but it must have fallen through the cracks.
> 
> The patch doesn't really ring a bell, but it looks correct. On the other
> hand, this doesn't look like a bug we'd ever hit in practice,

... and even if we do, the consequences aren't much.

> so I'll
> probably delay merging it until I've got a few more critical bugfixes
> queued up.

I'd've probably left it to the next merge window.

> Unless, of course, you'd prefer to merge it yourself?

No preference; if you're in no hurry I'd just add it to my for-2.6.36
branch with your ack.

--b.
