From: Steve Rago <sar@nec-labs.com>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
	workloads
Date: Wed, 23 Dec 2009 23:30:14 -0500
Message-ID: <1261629014.13028.160.camel@serenity>
References: <1261015420.1947.54.camel@serenity>
	 <1261037877.27920.36.camel@laptop> <20091219122033.GA11360@localhost>
	 <1261232747.1947.194.camel@serenity>
	 <20091222122557.GA604@atrey.karlin.mff.cuni.cz>
	 <1261498815.13028.63.camel@serenity>  <20091223183912.GE3159@quack.suse.cz>
	 <1261599385.13028.142.camel@serenity>  <1261604952.18047.7.camel@localhost>
	 <1261610013.13028.151.camel@serenity> <1261611898.18047.37.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755527AbZLXEa3@vger.kernel.org>
In-Reply-To: <1261611898.18047.37.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2009-12-24 at 00:44 +0100, Trond Myklebust wrote:

> > #2 is the difficult one.  If you wait for memory pressure, you could
> > have waited too long, because depending on the latency of the commit,
> > you could run into low-memory situations.  Then mayhem ensues, the
> > oom-killer gets cranky (if you haven't disabled it), and stuff starts
> > failing and/or hanging.  So you need to be careful about setting the
> > threshold for generating a commit so that the client doesn't run out of
> > memory before the server can respond.
> 
> Right, but this is why we have limits on the total number of dirty pages
> that can be kept in memory. The NFS unstable writes don't significantly
> change that model, they just add an extra step: once all the dirty data
> has been transmitted to the server, your COMMIT defines a
> synchronisation point after which you know that the data you just sent
> is all on disk. Given a reasonable NFS server implementation, it will
> already have started the write out of that data, and so hopefully the
> COMMIT operation itself will run reasonably quickly.

Right.  The trick is to do this with the best performance possible.

> 
> Any userland application with basic data integrity requirements will
> have the same expectations. It will write out the data and then fsync()
> at regular intervals. I've never heard of any expectations from
> filesystem and VM designers that applications should be required to
> fine-tune the length of those intervals in order to achieve decent
> performance.

Agreed, except that the more you call fsync(), the more you are stalling
the writing, so application designers must use fsync() judiciously.
Otherwise they'd just use synchronous writes.  (Apologies if I sound
like Captain Obvious.)

Thanks,

Steve

> 
> Cheers
>   Trond
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
