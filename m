Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:34429 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753920AbaHLRnP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2014 13:43:15 -0400
Received: by mail-qg0-f51.google.com with SMTP id a108so10001039qge.10
        for <linux-nfs@vger.kernel.org>; Tue, 12 Aug 2014 10:43:15 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 12 Aug 2014 13:43:13 -0400
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com
Subject: Re: [PATCH 0/5] locks: move most locks_release_private calls
 outside of i_lock
Message-ID: <20140812134313.1273dc63@tlielax.poochiereds.net>
In-Reply-To: <1407854893-2698-1-git-send-email-jlayton@primarydata.com>
References: <1407854893-2698-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 12 Aug 2014 10:48:08 -0400
Jeff Layton <jlayton@primarydata.com> wrote:

> In the days of yore, the file locking code was primarily protected by
> the BKL. That changed in commit 72f98e72551fa (locks: turn lock_flocks
> into a spinlock), at which point the code was changed to be protected
> by a conventional spinlock (mostly due to a push to finally eliminate
> the BKL). Since then, the code has been changed to use the i_lock
> instead of a global spinlock, but it's still under a spinlock.
> 
> With that change, several functions now no longer can block when they
> originally could. This is a particular problem with the
> fl_release_private operation. In NFSv4, that operation is used to kick
> off a RELEASE_LOCKOWNER or FREE_STATEID call, and that requires being
> able to do an allocation.
> 
> This was reported by Josh Stone here:
> 
>     https://bugzilla.redhat.com/show_bug.cgi?id=1089092
> 
> My initial stab at fixing this involved moving this to a workqueue, but
> Trond pointed out the above change was technically a regression with the
> way the spinlocking in the file locking code works, and suggested an
> alternate approach to fixing it.
> 
> This set focuses on moving most of the locks_release_private calls
> outside of the inode->i_lock. There are still a few that are done
> under the i_lock in the lease handling code. Cleaning up the use of
> the i_lock in the lease code is a larger project which we'll have to
> tackle at some point, but there are some other cleanups that will
> need to happen first.
> 
> Absent any objections, I'll plan to merge these for 3.18.
> 

Erm...make that v3.17...

As Trond points out, the fact that we end up doing sleeping allocations
under spinlock can allow an unprivileged user to crash a NFSv4 client.
So I may see about merging these sooner rather than later after they've
had a little soak time in linux-next.

-- 
Jeff Layton <jlayton@primarydata.com>
