Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54096 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753083AbbGYAkm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Jul 2015 20:40:42 -0400
Date: Sat, 25 Jul 2015 10:40:33 +1000
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: export table lookup: was [PATCH 10/10 v7] nfsd: Allows user
 un-mounting filesystem where nfsd exports base on
Message-ID: <20150725104033.38bf2f56@noble>
In-Reply-To: <20150724194817.GA24619@fieldses.org>
References: <55A11010.6050005@gmail.com>
	<55A111A8.2040701@gmail.com>
	<20150713133934.6a4ef77d@noble>
	<20150715210756.GE21669@fieldses.org>
	<20150716094046.445c038b@noble>
	<20150716205148.GC10673@fieldses.org>
	<20150722075824.3e7498ce@noble>
	<20150722150840.GH22718@fieldses.org>
	<20150724094657.0ca793b4@noble>
	<20150724194817.GA24619@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 24 Jul 2015 15:48:17 -0400 "J. Bruce Fields"
<bfields@fieldses.org> wrote:

> On Fri, Jul 24, 2015 at 09:46:57AM +1000, NeilBrown wrote:

> > Does that seem like a reasonable approach from your understanding of the problem?
> 
> So something like that could give us a way to prevent asking mountd
> about mounts that it can't see.
> 
> Except when things change: it's possible a mount that would pass this
> test at the time we create the request is no longer by the time we get
> mountd's reply.
> 
> You can tell people not to do that.  It still bugs me to have the
> possibility of a unanswereable request.  

I can see three general ways to cope with the fact that things could
change between creating a request and receiving the reply:
 - lock to prevent the change
 - refcounts to provide a stable reference to the thing of interest
 - detect change and retry.

These correspond roughly to spinlock, kref, and seqlock.

Trying to prevent changes in the filesystem over an upcall-and-reply is
out of the question.

A refcount could be implemented as a file descriptor. i.e. when nfsd
finds a mountpoint at the end of a 'lookup', it creates a
file descriptor for the target object and passes that to mountd.  mountd
does what it does and sends the reply back with the same file
descriptor.
I think that is needlessly complex.

detect-change-and-retry is, I think, the best.  The cache already has a
retry mechanism.  It can often detect a change implicitly if it gets
told about some filesystem object that it doesn't really care about.
The only weakness is that it can't currently detect if its question can
no longer be answered...

I agree that an unanswerable request seems ugly.  But sometimes the
best way to handle races is to let ugly things happen temporarily.

I should probably double-check that the cache will retry the upcall in
a reasonable time frame - I only have a vague recollection of how that
works...

NeilBrown

