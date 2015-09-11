Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:35861 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553AbbIKOig (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Sep 2015 10:38:36 -0400
Received: by ykdt18 with SMTP id t18so72743223ykd.3
        for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2015 07:38:34 -0700 (PDT)
Date: Fri, 11 Sep 2015 10:38:30 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v4 03/16] fs: allow __fput_sync to be used by
 non-kthreads and in modules
Message-ID: <20150911103830.4f4e5901@tlielax.poochiereds.net>
In-Reply-To: <20150911140049.GN22011@ZenIV.linux.org.uk>
References: <1441968882-7851-1-git-send-email-jeff.layton@primarydata.com>
	<1441968882-7851-4-git-send-email-jeff.layton@primarydata.com>
	<20150911140049.GN22011@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 11 Sep 2015 15:00:49 +0100
Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Fri, Sep 11, 2015 at 06:54:29AM -0400, Jeff Layton wrote:
> > We want nfsd to keep a cache of open files, but that would potentially
> > block userland callers from obtaining leases on them. To fix this,
> > we'll be adding a new notifier chain to the lease code that will call
> > back into nfsd on any attempt to set a FL_LEASE. nfsd can then close
> > any open files for that inode in advance of that.
> > 
> > The problem however is that since that notifier will run in normal
> > process context, the final __fput will be delayed a'la task_work and we
> > are still unable to set a lease. What we need to do is to put the struct
> > file synchronously so that the __fput runs before returning from the
> > notifier call.
> > 
> > The comments over __fput_sync and the BUG_ON in there mandate that it
> > should only be used in kthread context, but I see no reason why that
> > should be so. As long as the caller avoids holding locks that may be
> > problematic, it should be OK to use it from normal process context as
> > well.
> > 
> > Remove the __ prefix and the BUG_ON from that function and update the
> > comments over it. Also export it so that it can be used from nfsd code,
> > and move the export of fput just below the function definition.
> 
> I really don't like that.
> 	a) how deep in kernel stack will that thing run?
> 	b) what locking environment is expected in your case?
> 
> And opening it for use by any random driver that just feels like e.g.
> using it to go parse its config over there in /lib/we/are/special/wank.conf
> with 5Kb worth of kernel stack already eaten is a really bad idea.


Not too deep in our case, and with no real locking held aside from a
SRCU lock. Basically we're going to have a SRCU notifier chain that
will run from vfs_setlease. That will call back into the nfsd code when
it's running which will scan the hash for open files for the inode,
unhash and release them (synchronously). If they're being held open in
the cache but are otherwise idle, that's enough to allow a lease to be
acquired.

That said, I'm not thrilled with it either. There are some
alternatives:

1) we could just call task_work_run after the fput, but that seems
scary if (e.g.) some random interrupt walks in and queues up some
task_work.

2) we could add a "delayed_fput(file)", that adds it to the
delayed_fput_list, even when being run from normal process context.
Then we could just flush_delayed_fput() afterward. More context
switching, but that should be relatively safe I'd think.

-- 
Jeff Layton <jlayton@poochiereds.net>
