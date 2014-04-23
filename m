Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19441 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756082AbaDWTUx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Apr 2014 15:20:53 -0400
Date: Wed, 23 Apr 2014 15:00:23 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] nfs4: treat lock owners as opaque values
Message-ID: <20140423150023.6b0956cb@tlielax.poochiereds.net>
In-Reply-To: <1A139D9F-E986-4854-8C15-AB1332880E29@primarydata.com>
References: <1398277500-31575-1-git-send-email-jlayton@redhat.com>
	<1398277500-31575-2-git-send-email-jlayton@redhat.com>
	<1A139D9F-E986-4854-8C15-AB1332880E29@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 23 Apr 2014 14:48:08 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> 
> On Apr 23, 2014, at 14:24, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > Do the following set of ops with a file on a NFSv4 mount:
> > 
> >    exec 3>>$1
> >    flock -x 3
> >    exec 3>&-
> > 
> > You'll see the LOCK request go across the wire, but no LOCKU when the
> > file is closed. This leads to
> > 
> > What happens is that the fd is passed across a fork, and the final close
> > is done in a different process than the opener. That makes
> > __nfs4_find_lock_state miss finding the correct lock state because it
> > uses the fl_pid as a search key. A new one is created, and the locking
> > code treats it as a delegation stateid (because NFS_LOCK_INITIALIZED
> > isn't set).
> > 
> > The root cause of this breakage seems to be commit 77041ed9b49a9e
> > (NFSv4: Ensure the lockowners are labelled using the fl_owner and/or
> > fl_pid).
> > 
> > That changed it so that flock lockowners are allocated based on the
> > fl_pid. I think this is incorrect. flock locks should be "owned" by the
> > struct file, and that is already accounted for in the fl_owner field of
> > the lock request when the vfs layer passes it down.
> 
> NACKed for now.
> 
> I'll grant you that there are several nice potential cleanups here, but as far as I can tell, flock_make_lock() never sets fl_owner, and neither does anything else in sys_flock().
> 

Ahh right...nfs_flock is what sets that currently. So this patch *does*
work, but I think you're right that we ought to have the generic flock
codepath universally set fl_owner instead.

I'll see if I can make that a bit more consistent for v3.16 and then we
can revisit this one.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
