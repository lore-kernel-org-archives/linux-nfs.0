From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.6.30-rc deadline scheduler performance regression for iozone
	over NFS
Date: Fri, 22 May 2009 19:45:08 -0400
Message-ID: <20090522234508.GC9076@fieldses.org>
References: <20090512204433.7eb69075.akpm@linux-foundation.org> <x49y6t1rqw0.fsf@segfault.boston.devel.redhat.com> <x49k54ku7i2.fsf@segfault.boston.devel.redhat.com> <1242258338.5407.244.camel@heimdal.trondhjem.org> <x49octv7qr8.fsf@segfault.boston.devel.redhat.com> <1242311620.6560.14.camel@heimdal.trondhjem.org> <x49ws8j686r.fsf@segfault.boston.devel.redhat.com> <1242587454.17796.2.camel@heimdal.trondhjem.org> <1242587524.17796.3.camel@heimdal.trondhjem.org> <x49tz3ia45h.fsf@segfault.boston.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
To: Jeff Moyer <jmoyer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <x49tz3ia45h.fsf@segfault.boston.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 18, 2009 at 10:15:22AM -0400, Jeff Moyer wrote:
> Trond Myklebust <trond.myklebust@fys.uio.no> writes:
> 
> > On Sun, 2009-05-17 at 15:11 -0400, Trond Myklebust wrote:
> >> On Thu, 2009-05-14 at 11:00 -0400, Jeff Moyer wrote:
> >> > Sorry for the previous, stupid question.  I applied the patch in
> >> > addition the last one and here are the results:
> >> > 
> >> > 70327
> >> > 71561
> >> > 68760
> >> > 69199
> >> > 65324
> >> > 
> >> > A packet capture for this run is available here:
> >> >   http://people.redhat.com/jmoyer/trond2.pcap.bz2
> >> > 
> >> > Any more ideas?  ;)
> >> 
> >> Yep. I've got 2 more patches for you. With both of them applied, I'm
> >> seeing decent performance on my own test rig. The first patch is
> >> appended. I'll send the second in another email (to avoid attachments).
> >
> > Here is number 2. It is incremental to all the others...
> 
> With all 4 patches applied, these are the numbers for 5 runs:
> 
> 103168
> 101212
> 103346
> 100842
> 103172
> 
> It's looking much better, but we're still off by a few percent.  Thanks
> for the quick turnaround on this, Trond!  If you submit these patches,
> feel free to add:

I'd like to take a look and run some tests of my own when I get back
from vacation next week.

Then assuming no problems I'm inclined to queue them up for 2.6.31, and,
in the meantime, revert the autotuning patch temporarily for
2.6.30--under the assumption that autotuning is still the right thing to
do, but that this is too significant a regression to ignore, and Trond's
work is too involved to submit for 2.6.30 this late in the process.

--b.

> 
> Tested-by: Jeff Moyer <jmoyer@redhat.com>
> 
> Cheers,
> Jeff
