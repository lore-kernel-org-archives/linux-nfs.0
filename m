Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f45.google.com ([209.85.216.45]:52698 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932151AbaGASqf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2014 14:46:35 -0400
Received: by mail-qa0-f45.google.com with SMTP id v10so8038296qac.32
        for <linux-nfs@vger.kernel.org>; Tue, 01 Jul 2014 11:46:34 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 1 Jul 2014 14:46:31 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 000/117] nfsd: eliminate the client_mutex
Message-ID: <20140701144631.4bf0e9b5@tlielax.poochiereds.net>
In-Reply-To: <CAHQdGtQZP8RGqWS0pw-X97D_3GE1tqxaeVMSXgLa+VtaSLae2w@mail.gmail.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
	<20140630125142.GA32089@infradead.org>
	<20140630085934.2bf86ba0@tlielax.poochiereds.net>
	<20140630193237.GA11935@fieldses.org>
	<20140630162014.20e63e1a@tlielax.poochiereds.net>
	<CAHQdGtQtHaKx6mEXzO7XndZPo19joccuPa0_z0T_79TiG1434w@mail.gmail.com>
	<20140630163647.5227ac55@tlielax.poochiereds.net>
	<20140701101034.520b04bb@tlielax.poochiereds.net>
	<CAHQdGtQZP8RGqWS0pw-X97D_3GE1tqxaeVMSXgLa+VtaSLae2w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 1 Jul 2014 10:21:40 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Tue, Jul 1, 2014 at 10:10 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
> >
> > Quite right. I changed the program to be run as root and had each child
> > process do an setfsuid/setfsgid to a different UID/GID combo:
> >
> > [jlayton@tlielax lockperf]$ time sudo  ./opentest -n 128 -l 100 /mnt/rawhide/opentest
> >
> > real    0m3.448s
> > user    0m0.078s
> > sys     0m0.377s
> > [jlayton@tlielax lockperf]$ time sudo  ./opentest -n 128 -l 100 /mnt/rawhide/opentest
> >
> > real    0m3.344s
> > user    0m0.053s
> > sys     0m0.374s
> > [jlayton@tlielax lockperf]$ time sudo  ./opentest -n 128 -l 100 /mnt/rawhide/opentest
> >
> > real    0m3.550s
> > user    0m0.049s
> > sys     0m0.394s
> >
> >
> > ...so the speedup seems to be quite dramatic, actually -- 3x faster or
> > so with the patched kernel.
> >
> > The underlying filesystem is ext4 here, and the config is a rawhide
> > debug kernel config. For my next trick, I'll build some non-debug
> > kernels and replicate the test with them. Stay tuned...
> 
> Just for grins, we should probably also try with the 3 client side
> OPEN parallelisation patches in my 'devel' branch. I'd expect them to
> give a slight performance improvement with your original test (i.e.
> the one that doesn't play the UID/GID games)
> 


Ok, I haven't tested that yet, but I did put together a f20 machine on
bare metal to act as a server. Here are some results from a test that
forks 128 child processes and has each one create and close 1024 files.
Client is 3.14.8-200.fc20.x86_64 and using NFSv4.1:

With a stock Fedora kernel on the server running 3.14.8-200.fc20.x86_64:

$ time sudo ./opentest -n 128 -l 1024 /mnt/palma

real	59m5.022s
user	0m1.401s
sys	0m17.561s


...with the patched kernel 3.16.0-rc2.jlayton.1+ (basically Bruce's
for-3.17 branch with the rest of my patches piled on):

$ time sudo ./opentest -n 128 -l 1024 /mnt/palma

real	4m19.060s
user	0m1.259s
sys	0m13.059s

...so around a factor of 13x speedup on parallel creates. Again, this
is not a terribly scientific benchmark, but it does suggest that this
patchset helps immensely.

-- 
Jeff Layton <jlayton@primarydata.com>
