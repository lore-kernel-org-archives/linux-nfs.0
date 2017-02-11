Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35126 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753379AbdBKMum (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Feb 2017 07:50:42 -0500
Received: by mail-qt0-f195.google.com with SMTP id s58so7478699qtc.2
        for <linux-nfs@vger.kernel.org>; Sat, 11 Feb 2017 04:50:42 -0800 (PST)
Message-ID: <1486817439.4233.31.camel@poochiereds.net>
Subject: Re: How NLM support posix threads?
From: Jeff Layton <jlayton@poochiereds.net>
To: Pankaj Singh <psingh.ait@gmail.com>,
        Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Sat, 11 Feb 2017 07:50:39 -0500
In-Reply-To: <CAPrqf938zLB73tShOZyeQDacDR5J9VaHhF4_-t7eEjecWocyUQ@mail.gmail.com>
References: <CAPrqf9378wbKmv9EaiuFzYLwvCxziXtkk-ZY-jsJxSOgSNm+QA@mail.gmail.com>
         <1486739454.19587.1.camel@primarydata.com>
         <CAPrqf938zLB73tShOZyeQDacDR5J9VaHhF4_-t7eEjecWocyUQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2017-02-11 at 11:49 +0530, Pankaj Singh wrote:
> > During "fl_grant" callback wrong "block" will be compared hence
> > this will result in lock failure even if lock is actually granted.
> 
> "nlm_compare_locks" will compare the locks on the bases of pid, owner,
> start offset, end offset and type. In case of posix threads as pid is
> same, also all other parameters can be same for locks of different
> files.
> 
> Now the scenario is, if there are two posix thread with pid p1 and
> they try to take the lock on different files (say l1 and l2) then
> different blocks will be created (say b1 and b2). In this case
> underline filesystem may send "FILE_LOCK_DEFERRED" for both the locks
> and these blocks will be added to deferred block list.
> 
> So during "fl_grant" callback lock are compared with the blocks of
> block list. Now lets say callback is called for l1 and the comparison
> will succeed with b1 (this is as expected) and B_GOT_CALLBACK flag
> will be set. But as b1 is still in block list, now when callback for
> l2 arrives then also comparison with b1 can succeed instead of b2
> because b1 is prior to b2 in the list. Hence B_GOT_CALLBACK flag will
> not be set for b2 and when NFS client will retry for lock then lock
> will be denied.
> 
> Below is the snipt fl_grant code where comparison happens.
> list_for_each_entry(block, &nlm_blocked, b_list) {
> if (nlm_compare_locks(&block->b_call->a_args.lock.fl, fl))
> 
> 

POSIX locks don't work the way you expect between threads, even on local
filesystems. The original spec for POSIX locking was written before
threads were really a "thing", so different threads within the same PID
can't have conflicting POSIX locks.

OFD locks [1] will work between threads, and the NFS client tries to
emulate flock() with NLM locks as well. The latter two are not well-
tested with NLM though, so there may be bugs there.

What might be best is to post a testcase for this, so we can see exactly
what you're trying to do, what you expect to happen, and what's really
happening.

Also, please post what kernel you're using as that may be relevant.

[1]: https://lwn.net/Articles/586904/


> On Fri, Feb 10, 2017 at 8:40 PM, Trond Myklebust
> <trondmy@primarydata.com> wrote:
> > On Fri, 2017-02-10 at 14:51 +0530, Pankaj Singh wrote:
> > > Hi,
> > > 
> > > I am getting a strange problem where locks are denied by NFSv3 server
> > > even though no locks on same file where taken.
> > > 
> > > While looking at the code it seems like NLM compares a lock by using
> > > "pid" and other options like form - to file offset, type of lock etc.
> > > But we are interested in "pid" because other comparison can be same
> > > for different file_locks.
> > > 
> > >  As we know posix threads use tgid as pid for all its thread hence
> > > NFSv3 server will can get lock request from different posix thread
> > > but
> > > with same pid. Hence NLM  will treat the locking request as they are
> > > coming from same process. This may result in following problems
> > 
> > Threads that share the same process id belong, by definition, to the
> > same process.
> > 
> > > 1. Different threads of same process can get lock on same file.
> > 
> > That is precisely how POSIX locks are expected to work in threaded
> > environments.
> > http://pubs.opengroup.org/onlinepubs/9699919799/functions/fcntl.html
> > "An exclusive lock shall prevent any other process from setting a
> > shared lock or an exclusive lock on any portion of the protected area."
> > 
> > 
> > > 2. During "fl_grant" callback wrong "block" will be compared hence
> > > this will result in lock failure even if lock is actually granted.
> > 
> > How so?
> > 
> > > Is this a limitation of NLM?
> > > 
> > 
> > 
> > --
> > Trond Myklebust
> > Linux NFS client maintainer, PrimaryData
> > trond.myklebust@primarydata.com
> 
> 
> 

-- 
Jeff Layton <jlayton@poochiereds.net>
