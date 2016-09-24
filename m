Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40148 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753315AbcIXPCN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 24 Sep 2016 11:02:13 -0400
Date: Sat, 24 Sep 2016 11:02:11 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 2/5] nfsd: have nfsd4_lock use blocking locks for
 v4.1+ locks
Message-ID: <20160924150211.GA19783@fieldses.org>
References: <1474057707-31286-1-git-send-email-jlayton@redhat.com>
 <1474057707-31286-3-git-send-email-jlayton@redhat.com>
 <20160923211901.GB9998@fieldses.org>
 <1474677824.29585.11.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1474677824.29585.11.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 23, 2016 at 08:43:44PM -0400, Jeff Layton wrote:
> On Fri, 2016-09-23 at 17:19 -0400, J. Bruce Fields wrote:
> > On Fri, Sep 16, 2016 at 04:28:24PM -0400, Jeff Layton wrote:
> > > 
> > > Create a new per-lockowner+per-inode structure that contains a
> > > file_lock. Have nfsd4_lock add this structure to the lockowner's list
> > > prior to setting the lock. Then call the vfs and request a blocking lock
> > > (by setting FL_SLEEP). If we get anything besides FILE_LOCK_DEFERRED
> > 
> > That doesn't sound right.  FILE_LOCK_DEFERRED is a special case for
> > asynchronous locking--it means "I don't know whether there's a conflict
> > or not, it may take a while to check", not "there's a conflict".
> > 
> > (Ugh.  I apologize for the asynchronous locking code.)
> > 
> > --b.
> > 
> 
> The local file locking code definitely uses this return code to mean
> "This lock is blocked, and I'll call your lm_notify when it's
> unblocked", which is exactly what we rely on here.
> 
> There is a place that uses it in the way you mention though, and that is
> when DLM and svc lockd are interacting via dlm_posix_lock(). lockd can't
> be in play here since this is all NFSv4, so I think the code does handle
> this correctly.

Got it, my apologies!  I'll read some more....

The patches look fine as far as I can tell.

> That said...maybe should probably think about some way to disambiguate
> those two states in the return code. It is horribly confusing.

Yes.

Honestly maybe the asynchronous dlm case just shouldn't be there.  I
remember thinking multithreading lockd would accomplish the same.  But
maybe we already have that in the nfsv4 case, in which case who cares.
(Well, except maybe the locking effectively serializes locking anyway, I
haven't looked.)

--b.
