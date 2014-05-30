Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44747 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751975AbaE3AoZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 May 2014 20:44:25 -0400
Date: Thu, 29 May 2014 20:44:23 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Live lock in silly-rename.
Message-ID: <20140530004423.GA13746@fieldses.org>
References: <20140529164521.02324559@notabene.brown>
 <CAHQdGtTtU9_zBcfzRb_wmEf7XaX9rNg-_Q85ZLX9BYax14D2Gg@mail.gmail.com>
 <20140530075135.753fb7ed@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140530075135.753fb7ed@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 30, 2014 at 07:51:35AM +1000, NeilBrown wrote:
> On Thu, 29 May 2014 12:38:19 -0400 Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
> 
> > Apologies Neil. Resending due to gmail defaulting to html formatting
> > which gets rejected by vger.kernel.org...
> > 
> > On Thu, May 29, 2014 at 2:45 AM, NeilBrown <neilb@suse.de> wrote:
> > >
> > > The program below (provided by a customer) demonstrates a livelock that can
> > > trigger in NFS.
> > >
> > > "/mnt" should be an NFSv4 mount from a server which will hand out READ
> > > delegations (e.g. the Linux NFS server) and should contain a subdirectory
> > > "/mnt/data".
> > >
> > > The program forks off some worker threads which poll a particular file in
> > > that directory until it disappears.  Then each worker will exit.
> > > The main program waits a few seconds and then unlinks the file.
> > >
> > > The number of threads can be set with the first arg (4 is good). The number of
> > > seconds with the second.  Both have useful defaults.
> > >
> > > The unlink should happen promptly and then all the workers should  exit.  But
> > > they don't.
> > >
> > > What happens is that between when the "unlink" returns the delegation that it
> > > will inevitably have due to all those "open"s, and when it performs the
> > > required silly-rename (because some thread will have the file open), some
> > > other thread opens the file and gets a delegation.
> > > So the NFSv4 RENAME returns NFS4ERR_DELAY while it tries to reclaim the
> > > delegation.  15 seconds later the rename will be retried, but there will still
> > > (or again) be an active delegation.  So the pattern repeats indefinitely.
> > > All this time the i_mutex on the directory and file are held so "ls" on the
> > > directory will also hang.
> > 
> > Why would the server hand out another delegation just moments after it
> > recalled the last one? That sounds like a nasty server bug.
> 
> Exactly how long should it wait?
> Bruce: do you have any thoughts on whether the server should hold off giving
> out new delegations after trying to recall one (e.g. due to a lease-break
> caused by rename)??
> I don't suppose the RFC addresses this?

Yes, it's a known server bug.

As a first attempt I was thinking of just sticking a timestamp in struct
inode to record the time of the most recent conflicting access and deny
delegations if the timestamp is too recent, for some definition of too
recent.

--b.

> 
> > 
> > You can invent variants of this problem with a second client trying to
> > open() the file while the first one is trying to unlink(), where the
> > i_mutex hack will not suffice to prevent client 2 from getting the
> > delegation back.
> 
> True.  So we do need support from the server.
> 
> Thanks,
> NeilBrown
> 


