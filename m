Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:43602 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1161820AbeBNSWL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Feb 2018 13:22:11 -0500
Date: Wed, 14 Feb 2018 13:22:10 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Question about the removal of __nfs_revalidate_inode() from
 do_setlk()
Message-ID: <20180214182210.6k25ni7snxxywxi3@tonberry.usersys.redhat.com>
References: <20180214140125.kkpoz4cgouuk5lvx@tonberry.usersys.redhat.com>
 <1518620465.2999.11.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1518620465.2999.11.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 14 Feb 2018, Trond Myklebust wrote:

> On Wed, 2018-02-14 at 09:01 -0500, Scott Mayhew wrote:
> > Hi Trond,
> > 
> > Commit ca0daa2 ("NFS: Cache aggressively when file is open for
> > writing")
> > removed the inode revalidation from do_setlk().  Why was that
> > necessary?
> > If just that part of the commit is added back in, the client still
> > seems
> > to be able to cope with out-of-order write replies.
> 
> It can cope with out of order replies, but not with changes by a second
> client, which is highly likely when you are using file locking. In that
> case, we still need to invalidate the data cache.

Couldn't do_setlk incorporate a check similar to nfs_file_has_writers
and do the revalidation if there are no writers, otherwise do the
invalidation if there are writers?

> 
> > Currently the client invalidates the data cache whenever it takes a
> > lock
> > and that causes performance problems for some workloads... if a 
> 
> Exactly which workloads?

I'll need to get specifics on the actual workload, all that was attached
to the bugzilla was a script to illustrate the behavior, basically
flock/read/unlock in a loop (and looking at the support case attached
to the bug I don't really see any specifics either).

> 
> > client
> > wants to re-read portions of a file, and no other client has
> > modified 
> > that file, then why should the reads go out on the wire just because
> > locking is being used?
> 
> The point of the patch is to no longer track whether or not another
> client has changed the file while the file is open. That tracking was
> producing way too many false positives for no gain, and causing heavy
> slowdowns for performance optimised workloads due to spurious cache
> invalidations. Workloads that use locking are generally _not_
> considered to be optimised for performance.
> 
> IOW: The patch is restoring the behaviour of the locking code to the
> historically preferred one as described in the NFS FAQ.
> See http://nfs.sourceforge.net/#faq_a8

Doesn't that need to be reconciled with section 10.3.2 in RFCs 5661 &
7530?  Maybe those need to be amended?

-Scott
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
