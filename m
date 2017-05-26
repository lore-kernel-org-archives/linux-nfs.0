Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:36062 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933272AbdEZTjl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 May 2017 15:39:41 -0400
Received: by mail-qt0-f178.google.com with SMTP id f55so16302493qta.3
        for <linux-nfs@vger.kernel.org>; Fri, 26 May 2017 12:39:41 -0700 (PDT)
Message-ID: <1495827577.14036.3.camel@redhat.com>
Subject: Re: [PATC_H] locks: Set fl_nspid at file_lock allocation
From: Jeff Layton <jlayton@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, bfields@fieldses.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 26 May 2017 15:39:37 -0400
In-Reply-To: <C98A1A8E-F8CF-48B2-87B7-0006621626AD@redhat.com>
References: <896e8ca302614f71f3030015ebf3befe2b40d3c4.1495122972.git.bcodding@redhat.com>
         <1495126525.3956.10.camel@poochiereds.net>
         <1069ECDA-D96D-495E-BB7B-128A926AD3DF@redhat.com>
         <1495140075.3956.13.camel@poochiereds.net>
         <6ED42F9C-F290-451C-89A9-4A7C3FFDEFA6@redhat.com>
         <F45B59D5-DEB8-48ED-A127-780F96D92FDA@redhat.com>
         <1495817366.4299.3.camel@redhat.com>
         <C98A1A8E-F8CF-48B2-87B7-0006621626AD@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-05-26 at 13:53 -0400, Benjamin Coddington wrote:
> On 26 May 2017, at 12:49, Jeff Layton wrote:
> 
> > On Fri, 2017-05-26 at 11:22 -0400, Benjamin Coddington wrote:
> > > On 19 May 2017, at 8:35, Benjamin Coddington wrote:
> > > So, the client considers remote pids to be bogus, which makes a lot 
> > > of sense
> > > to me.
> > > 
> > 
> > Yeah, not much it can do with a pid, really...
> > 
> > > Additionally, after testing, today's kernel returns lockd's pid on a 
> > > local
> > > F_GETLCK for a remotely-held NFS lock.  So, I think our understanding 
> > > of the
> > > situation needs to be reversed.  Lock manager's locks are locally 
> > > reporting
> > > the local lock pid, but sometimes a remote lock needs to override the 
> > > local
> > > pid to set fl_pid.
> > > 
> > 
> > Fair enough. Now that I look...v4 locks set by knfsd just pick up the
> > pid of whatever the nfsd thread it happens to be running in. From
> > nfsd4_lock:
> > 
> >     file_lock->fl_pid = current->tgid;
> > 
> > So, it sounds like it really is totally meaningless then. In that case
> > I'll reverse my earlier opinion, and say that if it's easier to just
> > set it to whatever lockd's pid is, then that'd be fine with me.
> > 
> > OTOH, pid_t is an int, and I don't think negative pids are valid (are
> > they?)
> > 
> > Maybe we should set it to -1 for a remote lock (like we do for OFD
> > locks). Or, could consider declaring a new value (-2?) to represent a
> > remote lock?
> 
> OK, for my own clarity I'd like to nail down the desired behavior for 
> all
> four cases:
> 
> 1) F_GETLK on a remote file with a remote lock.
> 
>      I think the filesystem should determine the l_pid to return here.  
> NFS
> is returning 0 for v3.  Other filesystems are doing different things.  
> This
> is easy to do from locks.c by setting a flag on the lock in the 
> ops->lock
> path for F_GETLK.
> 
> 2) F_GETLK on a local file with a remote lock.
> 
>      I think this should be the l_pid of the lock manager.  That seems 
> to be
> the case now for NFS.
> 
> 3) F_GETLK on a remote file with a local lock, and..
> 4) F_GETLK on a local file with a local lock.
> 
>      Should set l_pid of the local locking process
> 
> This is still an unreliable mess, but I don't see any way around it 
> until we
> have something like l_sysid.
> 
> 

ACK...I'm onboard now. That all sounds pretty reasonable.

But...most important would be to add some comments that lay out this
rationale at the right point in the code sothat  we don't forget this
conversation in a year or two. I'd suggest a comment over the file_lock
for sure, to explain why we have fl_pid and fl_nspid and how we intend
for them to be used.

Would also be interesting to add some tests for this to xfstests too, as
I know that gets run frequently...

I'm also not opposed to the idea of l_sysid. It'd mean adding in a new
API of some sort, but it could be done. However, l_sysid on solaris is a
single int. I think that's probably insufficient in this day and age.

Maybe you would want to allow the pass in a pointer to a buffer, and
have the kernel populate it with a string? We could have a per-fs string
formatter (with a standard one for local filesystems).

-- 
Jeff Layton <jlayton@redhat.com>
