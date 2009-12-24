From: Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
	workloads
Date: Thu, 24 Dec 2009 09:49:40 -0500
Message-ID: <1261666180.13028.175.camel@serenity>
References: <1261015420.1947.54.camel@serenity>
	 <1261037877.27920.36.camel@laptop> <20091219122033.GA11360@localhost>
	 <1261232747.1947.194.camel@serenity> <20091222015907.GA6223@localhost>
	 <1261500113.13028.78.camel@serenity>  <20091224012101.GA8486@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>, Jan Kara <jack@suse.cz>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.nec-labs.com ([138.15.200.209]:41906 "EHLO
	mail.nec-labs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831AbZLXOtn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Dec 2009 09:49:43 -0500
In-Reply-To: <20091224012101.GA8486@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2009-12-24 at 09:21 +0800, Wu Fengguang wrote:

> > Commits and writes on the same inode need to be serialized for
> > consistency (write can change the data and metadata; commit [fsync]
> > needs to provide guarantees that the written data are stable). The
> > performance problem arises because NFS writes are fast (they generally
> > just deposit data into the server's page cache), but commits can take a
> 
> Right. 
> 
> > long time, especially if there is a lot of cached data to flush to
> > stable storage.
> 
> "a lot of cached data to flush" is not likely with pdflush, since it
> roughly send one COMMIT per 4MB WRITEs. So in average each COMMIT
> syncs 4MB at the server side.

Maybe on paper, but empirically I see anywhere from one commit per 8MB
to one commit per 64 MB.

> 
> Your patch adds another pre-pdlush async write logic, which greatly
> reduced the number of COMMITs by pdflush. Can this be the major factor
> of the performance gain?

My patch removes pdflush from the picture almost entirely.  See my
comments below.

> 
> Jan has been proposing to change the pdflush logic from
> 
>         loop over dirty files {
>                 writeback 4MB
>                 write_inode
>         }
> to
>         loop over dirty files {
>                 writeback all its dirty pages
>                 write_inode
>         }
> 
> This should also be able to reduce the COMMIT numbers. I wonder if
> this (more general) approach can achieve the same performance gain.

The pdflush mechanism is fine for random writes and small sequential
writes, because it promotes concurrency -- instead of the application
blocking while it tries to write and commit its data, the application
can go on doing other more useful things, and the data gets flushed in
the background.  There is also a benefit if the application makes
another modification to a page that is already dirty, because then
multiple modifications are coalesced into a single write.

However, the pdflush mechanism is wrong for large sequential writes
(like a backup stream, for example).  First, there is no concurrency to
exploit -- the application is only going to dirty more pages, so
removing the need for it to block writing the pages out only adds to the
problem of memory pressure.  Second, the application is not going to go
back and modify a page it has already written, so leaving it in the
cache for someone else to write provides no additional benefit.

Note that this assumes the application actually cares about the
consistency of its data and will call fsync() when it is done.  If the
application doesn't call fsync(), then it doesn't matter when the pages
are written to backing store, because the interface makes no guarantees
in this case.

Thanks,

Steve



