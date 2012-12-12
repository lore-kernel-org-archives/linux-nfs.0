Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f46.google.com ([209.85.215.46]:48170 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753820Ab2LLQUM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2012 11:20:12 -0500
Received: by mail-la0-f46.google.com with SMTP id p5so800418lag.19
        for <linux-nfs@vger.kernel.org>; Wed, 12 Dec 2012 08:20:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121212094654.5ce53d89@tlielax.poochiereds.net>
References: <20121212094654.5ce53d89@tlielax.poochiereds.net>
Date: Wed, 12 Dec 2012 11:20:11 -0500
Message-ID: <CADnza44_ZTHuuFHbQds9TBcSAdHD-FBoSJLwym7ETcC-HeFjZw@mail.gmail.com>
Subject: Re: non-aligned DIO reads on NFS are corrupting memory in 3.7.0
From: Fred Isaman <faisaman4@gmail.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org, eguan@redhat.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 12, 2012 at 9:46 AM, Jeff Layton <jlayton@redhat.com> wrote:
> One of our QA folks found that the attached testcase would segfault
> when run on a recent rhel6 kernel that has a backport of the pnfs dio
> code. I get the same segfault when I run it on a 3.7.0 kernel as well.
>
> I think the problem is that because the buffer we're reading into is on
> the stack, the kernel is scribbling over the rest of the page after the
> read and corrupting it.
>
> The problem, I think is this block in nfs_direct_read_completion():
>
> -----------------------[snip]-----------------------
>                 if (test_bit(NFS_IOHDR_EOF, &hdr->flags)) {
>                         if (bytes > hdr->good_bytes)
>                                 zero_user(page, 0, PAGE_SIZE);
>                         else if (hdr->good_bytes - bytes < PAGE_SIZE)
>                                 zero_user_segment(page,
>                                         hdr->good_bytes & ~PAGE_MASK,
>                                         PAGE_SIZE);
>                 }
> -----------------------[snip]-----------------------
>
> If I comment that out, then the test passes and it doesn't scribble
> over memory. I'm not clear on what that block is trying to accomplish.
> If we get a short read in the DIO codepath, I don't think we ought to
> be zeroing out the rest of the page. We should just return the number
> of bytes read and be done with it.
>

I would say the problem is not zeroing memory, but that the code isn't
taking into account the offsets into the page.


> I'm also suspicious of the "if (!PageCompound(page))" check in that
> function as well. It doesn't seem like we ought to be marking pages
> dirty in the DIO codepaths, should we?
>
> --
> Jeff Layton <jlayton@redhat.com>

I'm not sure if we should, but code to do so has been around forever.
The exception for PageCompound is from commit 566dd6064e89b "NFS: Make
directIO aware of compound pages", almost 7 years ago.

Fred
