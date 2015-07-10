Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:33553 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457AbbGJWvO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 18:51:14 -0400
Received: by ykeo3 with SMTP id o3so154230561yke.0
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2015 15:51:14 -0700 (PDT)
Date: Fri, 10 Jul 2015 18:51:10 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: William Dauchy <wdauchy@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jean Spector <jean@primarydata.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        stable@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>
Subject: Re: [PATCH] nfs: take extra reference to fl->fl_file when running a
 LOCKU operation
Message-ID: <20150710185110.42bbe417@tlielax.poochiereds.net>
In-Reply-To: <CAJ75kXbMu_DuKvU=3vwdDstAAkcbmP4dY+TNgqypO_fyNpDcQA@mail.gmail.com>
References: <1435687950-22037-1-git-send-email-jeff.layton@primarydata.com>
	<20150701093547.116dd788@tlielax.poochiereds.net>
	<CAJ75kXYQ1+_1hRun-kUq=VH2Y3wM+2SEH0zd5-j7xsq9x+RSLA@mail.gmail.com>
	<20150702060827.66fc27f1@tlielax.poochiereds.net>
	<20150710110255.66fc6452@tlielax.poochiereds.net>
	<CAJ75kXb6FRN-DY+wtvUEi53pc=tqLjA12S1X5egc4eR5pBN_MA@mail.gmail.com>
	<20150710120714.53893586@tlielax.poochiereds.net>
	<CAJ75kXbMu_DuKvU=3vwdDstAAkcbmP4dY+TNgqypO_fyNpDcQA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 11 Jul 2015 00:35:27 +0200
William Dauchy <wdauchy@gmail.com> wrote:

> On Fri, Jul 10, 2015 at 6:07 PM, Jeff Layton
> <jeff.layton@primarydata.com> wrote:
> > Oh? Do you have some reason to suspect the setlk patch to be
> > problematic? If not, then I'd rather not revert that one (at least not
> > from mainline) since I don't think it's likely to be a problem and it
> > does fix a real bug. It's your call on what you do in stable of course.
> 
> Yes, I also had some instabilities with the setlk patch only applied.
> Same trace as mentioned in the other thread.
> 

That, I have no explanation for...

We clearly hold a reference to the filp already when setting a lock.

Hmm...unless there was maybe some reclaim involved? I wouldn't think
that we'd try to reclaim locks for a filp that was being torn down, but
I'd have to go over that code in detail to be sure. Can you give any
insight into what you were doing when it was having problems? Did the
server reboot while you were testing?

In any case, we can probably get rid of the extra filp reference in
that code too if/when the RFC series is merged. We definitely hold a
reference to the inode already, so we shouldn't need to take the extra
filp reference once that's merged.

Not sure whether that patchset will be stable material though since it
is a more invasive fix.

-- 
Jeff Layton <jeff.layton@primarydata.com>
