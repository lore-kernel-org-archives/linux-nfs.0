Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:51831 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754297AbaGAOKj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2014 10:10:39 -0400
Received: by mail-qg0-f52.google.com with SMTP id f51so3356623qge.39
        for <linux-nfs@vger.kernel.org>; Tue, 01 Jul 2014 07:10:38 -0700 (PDT)
Date: Tue, 1 Jul 2014 10:10:34 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 000/117] nfsd: eliminate the client_mutex
Message-ID: <20140701101034.520b04bb@tlielax.poochiereds.net>
In-Reply-To: <20140630163647.5227ac55@tlielax.poochiereds.net>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
	<20140630125142.GA32089@infradead.org>
	<20140630085934.2bf86ba0@tlielax.poochiereds.net>
	<20140630193237.GA11935@fieldses.org>
	<20140630162014.20e63e1a@tlielax.poochiereds.net>
	<CAHQdGtQtHaKx6mEXzO7XndZPo19joccuPa0_z0T_79TiG1434w@mail.gmail.com>
	<20140630163647.5227ac55@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 30 Jun 2014 16:36:47 -0400
Jeff Layton <jeff.layton@primarydata.com> wrote:

> On Mon, 30 Jun 2014 16:31:24 -0400
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> > On Mon, Jun 30, 2014 at 4:20 PM, Jeff Layton
> > <jeff.layton@primarydata.com> wrote:
> > > On Mon, 30 Jun 2014 15:32:37 -0400
> > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > >
> > >> On Mon, Jun 30, 2014 at 08:59:34AM -0400, Jeff Layton wrote:
> > >> > On Mon, 30 Jun 2014 05:51:42 -0700
> > >> > Christoph Hellwig <hch@infradead.org> wrote:
> > >> >
> > >> > > I'm pretty happy with what's the first 25 patches in this version
> > >> > > with all the review comments addressed, so as far as I'm concerned
> > >> > > these are ready for for-next.  Does anyone else plan to do a review
> > >> > > as well?
> > >> > >
> > >> >
> > >> > Thanks very much for the review so far.
> > >> >
> > >> > > I'll try to get to the locking changes as well soon, but I've got some
> > >> > > work keeping me fairly busy at the moment.  I guess it wasn't easily
> > >> > > feasible to move the various stateid refcounting to before the major
> > >> > > locking changes?
> > >> > >
> > >> >
> > >> > Not really. If I had done the set from scratch I would have probably
> > >> > done that instead, but Trond's original had those changes interleaved.
> > >> > Separating them would be a lot of work that I'd prefer to avoid.
> > >> >
> > >> > > Btw, do you have any benchrmarks showing the improvements of the new
> > >> > > locking scheme?
> > >> >
> > >> > No, I'm hoping to get those numbers soon from our QA folks. Most of the
> > >> > testing I've done has been for correctness and stability. I'm pretty
> > >> > happy with things at that end now, but I don't have any numbers that
> > >> > show whether and how much this helps scalability.
> > >>
> > >> The open-create problem at least shouldn't be hard to confirm.
> > >>
> > >> It's also the only problem I've actually seen a complaint about--I do
> > >> wish it were possible to do just the minimum required to fix that before
> > >> doing all the rest.
> > >>
> > >> --b.
> > >
> > > So I wrote a small program to fork off children and have them create a
> > > bunch of files. With 128 children creating 100 files each, and running
> > > the program under "time".
> > >
> > > ...with your for-3.17 branch:
> > >
> > > [jlayton@tlielax lockperf]$ time ./opentest -n 128 -l 100 /mnt/rawhide/opentest
> > >
> > > real    0m10.037s
> > > user    0m0.065s
> > > sys     0m0.340s
> > > [jlayton@tlielax lockperf]$ time ./opentest -n 128 -l 100 /mnt/rawhide/opentest
> > >
> > > real    0m10.378s
> > > user    0m0.058s
> > > sys     0m0.356s
> > > [jlayton@tlielax lockperf]$ time ./opentest -n 128 -l 100 /mnt/rawhide/opentest
> > >
> > > real    0m8.576s
> > > user    0m0.063s
> > > sys     0m0.352s
> > >
> > > ...with the entire pile of patches:
> > >
> > > [jlayton@tlielax lockperf]$ time ./opentest -n 128 -l 100 /mnt/rawhide/opentest
> > >
> > > real    0m7.150s
> > > user    0m0.053s
> > > sys     0m0.361s
> > > [jlayton@tlielax lockperf]$ time ./opentest -n 128 -l 100 /mnt/rawhide/opentest
> > >
> > > real    0m8.251s
> > > user    0m0.053s
> > > sys     0m0.369s
> > > [jlayton@tlielax lockperf]$ time ./opentest -n 128 -l 100 /mnt/rawhide/opentest
> > >
> > > real    0m8.661s
> > > user    0m0.066s
> > > sys     0m0.358s
> > >
> > > ...so it does seem to help, but there's a lot of variation in the
> > > results. I'll see if I can come up with a better benchmark for this
> > > and find a way to run this that doesn't involve virtualization.
> > >
> > > Alternately, does anyone have a stock benchmark they can suggest that
> > > might be better than my simple test program?
> > >
> > 
> > Hi Jeff,
> > 
> > If the processes are all running under the same credential, then the
> > client will serialise them automatically due to them all sharing the
> > same open owner.
> > 
> > To really make this test fly, you probably want to do something like
> > allocating a bunch of gids, assign them as auxiliary groups to the
> > parent process, then do a 'setfsgid()' to a random member of that set
> > of gids after each fork.
> > 
> > That should give you a maze of twisty little open owners to play with...
> > 
> 
> Ahh, good point. Yes, those were all done with the same creds. I'll see
> if I can spin up such a test tomorrow, and I'll see if I can also build
> a couple of bare-metal machines to test this with.
> 
> It's hard to trust KVM guests for performance testing...
> 

Quite right. I changed the program to be run as root and had each child
process do an setfsuid/setfsgid to a different UID/GID combo:

[jlayton@tlielax lockperf]$ time sudo  ./opentest -n 128 -l 100 /mnt/rawhide/opentest

real	0m3.448s
user	0m0.078s
sys	0m0.377s
[jlayton@tlielax lockperf]$ time sudo  ./opentest -n 128 -l 100 /mnt/rawhide/opentest

real	0m3.344s
user	0m0.053s
sys	0m0.374s
[jlayton@tlielax lockperf]$ time sudo  ./opentest -n 128 -l 100 /mnt/rawhide/opentest

real	0m3.550s
user	0m0.049s
sys	0m0.394s


...so the speedup seems to be quite dramatic, actually -- 3x faster or
so with the patched kernel.

The underlying filesystem is ext4 here, and the config is a rawhide
debug kernel config. For my next trick, I'll build some non-debug
kernels and replicate the test with them. Stay tuned...

-- 
Jeff Layton <jlayton@poochiereds.net>
