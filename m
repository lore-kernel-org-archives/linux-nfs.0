Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:36354 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933101AbbGJPC7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 11:02:59 -0400
Received: by ykey15 with SMTP id y15so68739098yke.3
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2015 08:02:58 -0700 (PDT)
Date: Fri, 10 Jul 2015 11:02:55 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: William Dauchy <wdauchy@gmail.com>
Cc: trond.myklebust@primarydata.com, jean@primarydata.com,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        stable@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>
Subject: Re: [PATCH] nfs: take extra reference to fl->fl_file when running a
 LOCKU operation
Message-ID: <20150710110255.66fc6452@tlielax.poochiereds.net>
In-Reply-To: <20150702060827.66fc27f1@tlielax.poochiereds.net>
References: <1435687950-22037-1-git-send-email-jeff.layton@primarydata.com>
	<20150701093547.116dd788@tlielax.poochiereds.net>
	<CAJ75kXYQ1+_1hRun-kUq=VH2Y3wM+2SEH0zd5-j7xsq9x+RSLA@mail.gmail.com>
	<20150702060827.66fc27f1@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2 Jul 2015 06:08:27 -0400
Jeff Layton <jeff.layton@primarydata.com> wrote:

> On Thu, 2 Jul 2015 10:58:59 +0200
> William Dauchy <wdauchy@gmail.com> wrote:
> 
> > On Wed, Jul 1, 2015 at 3:37 PM Jeff Layton <jeff.layton@primarydata.com> wrote:
> > >
> > > > The problem is almost exactly the same as the one fixed by feaff8e5b2cf.
> > >
> > > Oops, I forgot to Cc stable on this one...
> > > Trond, can you add that?
> > 
> > Is the commit mentionned also targeted for stable?
> > commit feaff8e5b2cfc3eae02cf65db7a400b0b9ffc596
> > nfs: take extra reference to fl->fl_file when running a setlk
> > 
> > Regards,
> 
> Oh! It wasn't marked as such but probably should be. I'll resend it to
> stable list a little later.
> 
> Thanks,

So, William has done some testing and hit some problems with this
patch. I suspect that it's because we can end up running an unlock
after the filp->f_count has already gone to zero and are in __fput, so
we take an extra reference and end up with a use-after-free.

I think it'd be best to revert this patch from all kernels for now
(mainline and stable). I don't think the one that changes the setlk
codepath is susceptible to this, but it's probably fine to hold off on
applying both until I can sort out a better way to fix this one.

Thanks!
-- 
Jeff Layton <jeff.layton@primarydata.com>
