Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9368 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751652Ab1LUNVl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Dec 2011 08:21:41 -0500
Date: Wed, 21 Dec 2011 08:21:16 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 3/7] nfsdcld: add autoconf goop for sqlite
Message-ID: <20111221082116.49e8215e@tlielax.poochiereds.net>
In-Reply-To: <20111220211838.GA24085@fieldses.org>
References: <1323974641-16515-1-git-send-email-jlayton@redhat.com>
	<1323974641-16515-4-git-send-email-jlayton@redhat.com>
	<20111220141749.583ce3d0@tlielax.poochiereds.net>
	<20111220211838.GA24085@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 20 Dec 2011 16:18:38 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Dec 20, 2011 at 02:17:49PM -0500, Jeff Layton wrote:
> > On Thu, 15 Dec 2011 13:43:57 -0500
> > Jeff Layton <jlayton@redhat.com> wrote:
> > 
> > > Mostly cribbed from Chuck Lever's new-statd rewrite a few years ago...
> > > 
> > 
> > Sending this to Bruce and Steve, but cc'ing the list in case other
> > people have thoughts...
> > 
> > I have a couple of questions about configure/build behavior when the
> > dependencies aren't present on the build system. The patch below
> > autodisables the building of nfsdcld when sqlite isn't there or isn't
> > functional, etc.
> > 
> > This is probably fine initially, but eventually I'd like to see the
> > old state tracking code go away. At that point, this daemon will be
> > required for NFSv4 serving.
> > 
> > Some questions:
> > 
> > 1) does anyone have a problem with deprecating the old state tracking
> > code? I'd prefer we not maintain it in perpetuity, but maybe there's an
> > argument for keeping it around?
> 
> Just the usual: the kernel community depends for some of its testing on
> people being willing to upgrade to the latest kernel.  So we try to
> ensure they can just drop in a new kernel without breaking a random
> subsystem that (as non-NFS specialists) they don't ordinarily have to
> think about....
> 

There's the rub. The legacy scheme is completely transparent for most
users. There's no daemon involved, so they don't need to set anything
up. That's not the case with the new scheme.

If we do want to eventually deprecate the old code, what I think we'd
do is add printk's that say we're deprecating the old code in release
3.x, and to ensure that nfsdcld is running. We'd want to do that for at
least 2 releases before removing anything, but could do so for longer
too.

> > 2) assuming we do want to eventually deprecate the old code. When
> > should we plan to do this. Assuming that this goes into 3.3 and we add
> > sufficient printk warnings when the old tracker is used, the earliest
> > we could remove it is 3.5. Is that too aggressive?
> 
> That sounds a little aggressive.  It may depend on how much trouble we
> find it is to keep it up to date.
> 
> Then again I guess it depends how obnoxiously we fail in the case the
> new daemon isn't running.
> 

Ok, it sounds like you're leaning toward keeping the old code around
for now and not forcing anyone onto the new. The only downside I can
see is the maintenance hassle (which is fairly low for now), and the
fact that it adds a new dimension to the testing matrix. If we can live
with that, then I won't worry about deprecating anything at this point.

-- 
Jeff Layton <jlayton@redhat.com>
