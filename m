Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50479 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758501Ab2I1PKv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Sep 2012 11:10:51 -0400
Date: Fri, 28 Sep 2012 11:10:43 -0400
To: Alexander Graf <agraf@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        LKML List <linux-kernel@vger.kernel.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        linux-nfs@vger.kernel.org, Jan Kara <jack@suse.cz>,
        skinsbursky@parallels.com, bfields@redhat.com
Subject: Re: [REGRESSION] nfsd crashing with 3.6.0-rc7 on PowerPC
Message-ID: <20120928151043.GA19102@fieldses.org>
References: <3BDA9E62-7031-42D6-8CA9-5327B61700F5@suse.de>
 <CA+55aFyXwB1QcXE4Z_FAGnXROSgvP2x2+wjnX9OWPa4Dfaaf0A@mail.gmail.com>
 <DC545CD9-8745-47DD-B13B-3385C0EB5B27@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <DC545CD9-8745-47DD-B13B-3385C0EB5B27@suse.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 28, 2012 at 04:19:55AM +0200, Alexander Graf wrote:
> 
> On 28.09.2012, at 04:04, Linus Torvalds wrote:
> 
> > On Thu, Sep 27, 2012 at 6:55 PM, Alexander Graf <agraf@suse.de> wrote:
> >> 
> >> Below are OOPS excerpts from different rc's I tried. All of them crashed - all the way up to current Linus' master branch. I haven't cross-checked, but I don't remember any such behavior from pre-3.6 releases.
> > 
> > Since you seem to be able to reproduce it easily (and apparently
> > reliably), any chance you could just bisect it?
> > 
> > Since I assume v3.5 is fine, and apparently -rc1 is already busted, a simple
> > 
> >   git bisect start
> >   git bisect good v3.5
> >   git bisect bad v3.6-rc1
> > 
> > will get you started on your adventure..
> 
> Heh, will give it a try :). The thing really does look quite bisectable.
> 
> 
> It might take a few hours though - the machine isn't exactly fast by today's standards and it's getting late here. But I'll keep you updated.

I doubt it's anything special about that workload, but just for kicks I
tried a "git clone -ls" (cloning my linux tree to another directory on
the same nfs filesystem), with server on 3.6.0-rc7, and didn't see
anything interesting (just an xfs lockdep warning that looks like this
one jlayton already reported:
http://oss.sgi.com/archives/xfs/2012-09/msg00088.html
)

Any (even partial) bisection results would certainly be useful, thanks.

--b.
