Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:55264 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbaF3UUR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 16:20:17 -0400
Received: by mail-qa0-f51.google.com with SMTP id j7so6975437qaq.10
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 13:20:16 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 30 Jun 2014 16:20:14 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 000/117] nfsd: eliminate the client_mutex
Message-ID: <20140630162014.20e63e1a@tlielax.poochiereds.net>
In-Reply-To: <20140630193237.GA11935@fieldses.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
	<20140630125142.GA32089@infradead.org>
	<20140630085934.2bf86ba0@tlielax.poochiereds.net>
	<20140630193237.GA11935@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 30 Jun 2014 15:32:37 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jun 30, 2014 at 08:59:34AM -0400, Jeff Layton wrote:
> > On Mon, 30 Jun 2014 05:51:42 -0700
> > Christoph Hellwig <hch@infradead.org> wrote:
> > 
> > > I'm pretty happy with what's the first 25 patches in this version
> > > with all the review comments addressed, so as far as I'm concerned
> > > these are ready for for-next.  Does anyone else plan to do a review
> > > as well?
> > > 
> > 
> > Thanks very much for the review so far.
> > 
> > > I'll try to get to the locking changes as well soon, but I've got some
> > > work keeping me fairly busy at the moment.  I guess it wasn't easily
> > > feasible to move the various stateid refcounting to before the major
> > > locking changes?
> > > 
> > 
> > Not really. If I had done the set from scratch I would have probably
> > done that instead, but Trond's original had those changes interleaved.
> > Separating them would be a lot of work that I'd prefer to avoid.
> > 
> > > Btw, do you have any benchrmarks showing the improvements of the new
> > > locking scheme?
> > 
> > No, I'm hoping to get those numbers soon from our QA folks. Most of the
> > testing I've done has been for correctness and stability. I'm pretty
> > happy with things at that end now, but I don't have any numbers that
> > show whether and how much this helps scalability.
> 
> The open-create problem at least shouldn't be hard to confirm.
> 
> It's also the only problem I've actually seen a complaint about--I do
> wish it were possible to do just the minimum required to fix that before
> doing all the rest.
> 
> --b.

So I wrote a small program to fork off children and have them create a
bunch of files. With 128 children creating 100 files each, and running
the program under "time". 

...with your for-3.17 branch:

[jlayton@tlielax lockperf]$ time ./opentest -n 128 -l 100 /mnt/rawhide/opentest

real	0m10.037s
user	0m0.065s
sys	0m0.340s
[jlayton@tlielax lockperf]$ time ./opentest -n 128 -l 100 /mnt/rawhide/opentest

real	0m10.378s
user	0m0.058s
sys	0m0.356s
[jlayton@tlielax lockperf]$ time ./opentest -n 128 -l 100 /mnt/rawhide/opentest

real	0m8.576s
user	0m0.063s
sys	0m0.352s

...with the entire pile of patches:

[jlayton@tlielax lockperf]$ time ./opentest -n 128 -l 100 /mnt/rawhide/opentest

real	0m7.150s
user	0m0.053s
sys	0m0.361s
[jlayton@tlielax lockperf]$ time ./opentest -n 128 -l 100 /mnt/rawhide/opentest

real	0m8.251s
user	0m0.053s
sys	0m0.369s
[jlayton@tlielax lockperf]$ time ./opentest -n 128 -l 100 /mnt/rawhide/opentest

real	0m8.661s
user	0m0.066s
sys	0m0.358s

...so it does seem to help, but there's a lot of variation in the
results. I'll see if I can come up with a better benchmark for this
and find a way to run this that doesn't involve virtualization.

Alternately, does anyone have a stock benchmark they can suggest that
might be better than my simple test program?

-- 
Jeff Layton <jlayton@primarydata.com>
