Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21667 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754779Ab2LLQbp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Dec 2012 11:31:45 -0500
Date: Wed, 12 Dec 2012 11:31:40 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Fred Isaman <faisaman4@gmail.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org, eguan@redhat.com
Subject: Re: non-aligned DIO reads on NFS are corrupting memory in 3.7.0
Message-ID: <20121212113140.145fc424@tlielax.poochiereds.net>
In-Reply-To: <CADnza44_ZTHuuFHbQds9TBcSAdHD-FBoSJLwym7ETcC-HeFjZw@mail.gmail.com>
References: <20121212094654.5ce53d89@tlielax.poochiereds.net>
	<CADnza44_ZTHuuFHbQds9TBcSAdHD-FBoSJLwym7ETcC-HeFjZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 12 Dec 2012 11:20:11 -0500
Fred Isaman <faisaman4@gmail.com> wrote:

> On Wed, Dec 12, 2012 at 9:46 AM, Jeff Layton <jlayton@redhat.com> wrote:
> > One of our QA folks found that the attached testcase would segfault
> > when run on a recent rhel6 kernel that has a backport of the pnfs dio
> > code. I get the same segfault when I run it on a 3.7.0 kernel as well.
> >
> > I think the problem is that because the buffer we're reading into is on
> > the stack, the kernel is scribbling over the rest of the page after the
> > read and corrupting it.
> >
> > The problem, I think is this block in nfs_direct_read_completion():
> >
> > -----------------------[snip]-----------------------
> >                 if (test_bit(NFS_IOHDR_EOF, &hdr->flags)) {
> >                         if (bytes > hdr->good_bytes)
> >                                 zero_user(page, 0, PAGE_SIZE);
> >                         else if (hdr->good_bytes - bytes < PAGE_SIZE)
> >                                 zero_user_segment(page,
> >                                         hdr->good_bytes & ~PAGE_MASK,
> >                                         PAGE_SIZE);
> >                 }
> > -----------------------[snip]-----------------------
> >
> > If I comment that out, then the test passes and it doesn't scribble
> > over memory. I'm not clear on what that block is trying to accomplish.
> > If we get a short read in the DIO codepath, I don't think we ought to
> > be zeroing out the rest of the page. We should just return the number
> > of bytes read and be done with it.
> >
> 
> I would say the problem is not zeroing memory, but that the code isn't
> taking into account the offsets into the page.
> 

Erm maybe...

I don't get it though. Why would you ever want to zero out the rest of
the buffer on a DIO read() request? You're certainly under no obligation
to do so. If you didn't get all of the data requested, you're going to
return a number that's less than "count", and you should be fine to
just ignore the rest of the buffer.

> 
> > I'm also suspicious of the "if (!PageCompound(page))" check in that
> > function as well. It doesn't seem like we ought to be marking pages
> > dirty in the DIO codepaths, should we?
> >
> 
> I'm not sure if we should, but code to do so has been around forever.
> The exception for PageCompound is from commit 566dd6064e89b "NFS: Make
> directIO aware of compound pages", almost 7 years ago.
> 
> Fred
>

Yeah. Maybe it's concern with someone doing DIO reads into a mmapped
buffer? Dunno...

-- 
Jeff Layton <jlayton@redhat.com>
