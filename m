Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:55559 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754356AbaGAUNU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2014 16:13:20 -0400
Received: by mail-qc0-f181.google.com with SMTP id x13so8832553qcv.40
        for <linux-nfs@vger.kernel.org>; Tue, 01 Jul 2014 13:13:19 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 1 Jul 2014 16:13:17 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 000/117] nfsd: eliminate the client_mutex
Message-ID: <20140701161317.0761839e@tlielax.poochiereds.net>
In-Reply-To: <20140701200135.GE14728@fieldses.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
	<20140630125142.GA32089@infradead.org>
	<20140630085934.2bf86ba0@tlielax.poochiereds.net>
	<20140630193237.GA11935@fieldses.org>
	<20140630162014.20e63e1a@tlielax.poochiereds.net>
	<CAHQdGtQtHaKx6mEXzO7XndZPo19joccuPa0_z0T_79TiG1434w@mail.gmail.com>
	<20140630163647.5227ac55@tlielax.poochiereds.net>
	<20140701101034.520b04bb@tlielax.poochiereds.net>
	<CAHQdGtQZP8RGqWS0pw-X97D_3GE1tqxaeVMSXgLa+VtaSLae2w@mail.gmail.com>
	<20140701144631.4bf0e9b5@tlielax.poochiereds.net>
	<20140701200135.GE14728@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 1 Jul 2014 16:01:35 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Jul 01, 2014 at 02:46:31PM -0400, Jeff Layton wrote:
> > Ok, I haven't tested that yet, but I did put together a f20 machine on
> > bare metal to act as a server. Here are some results from a test that
> > forks 128 child processes and has each one create and close 1024 files.
> > Client is 3.14.8-200.fc20.x86_64 and using NFSv4.1:
> > 
> > With a stock Fedora kernel on the server running 3.14.8-200.fc20.x86_64:
> > 
> > $ time sudo ./opentest -n 128 -l 1024 /mnt/palma
> > 
> > real	59m5.022s
> > user	0m1.401s
> > sys	0m17.561s
> > 
> > 
> > ...with the patched kernel 3.16.0-rc2.jlayton.1+ (basically Bruce's
> > for-3.17 branch with the rest of my patches piled on):
> > 
> > $ time sudo ./opentest -n 128 -l 1024 /mnt/palma
> > 
> > real	4m19.060s
> > user	0m1.259s
> > sys	0m13.059s
> > 
> > ...so around a factor of 13x speedup on parallel creates. Again, this
> > is not a terribly scientific benchmark, but it does suggest that this
> > patchset helps immensely.
> 
> Neat-o.
> 
> It might also be interesting to compare with NFSv3?
> 
> I wonder what a first good test of the smp scalability would be.
> 
> --b.

Yeah, it is neato. And just to be sure that it wasn't some other random
change between 3.14 and 3.16, I popped off all of my patches, rebuilt
nfsd.ko and reran the test with everything else the same:

$ time sudo ./opentest -n 128 -l 1024 /mnt/palma

real	58m50.564s
user	0m1.513s
sys	0m18.963s

...so it really does appear that these changes make the difference.

-- 
Jeff Layton <jlayton@primarydata.com>
