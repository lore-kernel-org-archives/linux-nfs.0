Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:44432 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753887AbaIQBnI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Sep 2014 21:43:08 -0400
Received: by mail-ig0-f180.google.com with SMTP id hn15so446114igb.1
        for <linux-nfs@vger.kernel.org>; Tue, 16 Sep 2014 18:43:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140813140831.22f3e9c7@notabene.brown>
References: <20140813140831.22f3e9c7@notabene.brown>
Date: Tue, 16 Sep 2014 21:43:07 -0400
Message-ID: <CAHQdGtTrWhX=iE9y1nWH13M=kt1dbu=_dwdNVSQGBh1BeZ9aTA@mail.gmail.com>
Subject: Re: [PATCH] NFS: state manager thread must stay running.
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.de>
Cc: NFS <linux-nfs@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 13, 2014 at 12:08 AM, NeilBrown <neilb@suse.de> wrote:
>
>
> If the server restarts at an awkward time it is possible for write
> requests to block waiting for the state manager to run.
> If the state manager isn't already running a new thread will
> need to be started which requires a GFP_KERNEL allocation
> (for do_fork).
>
> If memory is short, that GFP_KERNEL allocation could block on the
> writes going out via NFS, resulting in a deadlock.
>
> The easiest solution is to keep the manager thread running
> always.

I'm still trying to figure out what to do about this patch. There are
2 concerns:

1) If we're so low on memory that we can't even start a state manager
thread, then how do we guarantee that the recovery can be completed?
We rely on that state manager thread being able to allocate memory to
perform the lease, session, open and lock recoveries.

2) Does allocating 1 thread per server really scale? Consider that
each thread is going to be completely idle almost all the time.
Wouldn't it be better to just preallocate only 1 thread, and then
allocating others dynamically if we really do hit a situation where 2
or more servers are rebooting at the same time?

Cheers
  Trond

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
