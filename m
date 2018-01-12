Return-Path: <smayhew@redhat.com>
Date: Fri, 12 Jan 2018 12:39:28 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
	bcodding redhat <bcodding@redhat.com>,
	"fsorenso@redhat.com" <fsorenso@redhat.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"dwysocha@redhat.com" <dwysocha@redhat.com>
Subject: Re: [PATCH v2] nfs/pnfs: fix nfs_direct_req ref leak when i/o falls
 back to the mds
Message-ID: <20180112173928.wjefygafbw5fe6w4@tonberry.usersys.redhat.com>
References: <20171213182220.lrfbvkaj65fg6abk@tonberry.usersys.redhat.com>
 <20171215211232.18942-1-smayhew@redhat.com>
 <20180111131038.vi25s2rvmjgqr3l6@tonberry.usersys.redhat.com>
 <1515676811.3463.0.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1515676811.3463.0.camel@primarydata.com>
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 11 Jan 2018, Trond Myklebust wrote:

> On Thu, 2018-01-11 at 08:10 -0500, Scott Mayhew wrote:
> > Trond, Anna,
> > 
> > Any concerns with this patch?
> > 
> > We left this run on multiple machines through the holidays... all
> > doing
> > direct I/O to a Netapp filer while doing storage failovers on an
> > hourly
> > basis on the filer.  No more issues with processes getting stuck in
> > inode_dio_wait.
> 
> I'm fine with this version. Should it be a stable fix? If so, do we
> have a "Fixes:" commit for it?

Yeah it should probably be a stable fix.  The hdr->release() call was
added in commit 1ca018d28d ("pNFS: Fix a memory leak when attempted pnfs
fails")... but I can reproduce this on earlier kernels than that (I
tested 4.0) so it looks like this goes way back...

-Scott
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
