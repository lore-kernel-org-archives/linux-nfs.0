Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:26935 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751300AbbDOWu3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Apr 2015 18:50:29 -0400
Date: Thu, 16 Apr 2015 08:50:02 +1000
From: Dave Chinner <david@fromorbit.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Marc Eshel <eshel@us.ibm.com>, xfs@oss.sgi.com,
        Christoph Hellwig <hch@infradead.org>, linux-nfs-owner@vger.kernel.org
Subject: Re: [PATCH v3 3/3] NFSD: Add support for encoding multiple segments
Message-ID: <20150415225002.GV13731@dastard>
References: <CAHQdGtS_VuBOzRZjsiYdjZS8qMj2Sw65BYdFmWWf-LJhQL6yOg@mail.gmail.com>
 <5515A9C8.6090400@Netapp.com>
 <CAHQdGtRaUYxU2JAAWErH7FT=Gy5JLzAKi-RtqqBSkNFZrhaB9Q@mail.gmail.com>
 <5515C1BF.8000907@Netapp.com>
 <20150327205414.GD27889@fieldses.org>
 <5515C3BE.3040807@Netapp.com>
 <20150327210839.GE27889@fieldses.org>
 <552EBCB2.1040609@Netapp.com>
 <20150415195614.GA31407@fieldses.org>
 <20150415200016.GB31407@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150415200016.GB31407@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 15, 2015 at 04:00:16PM -0400, J. Bruce Fields wrote:
> On Wed, Apr 15, 2015 at 03:56:14PM -0400, J. Bruce Fields wrote:
> > On Wed, Apr 15, 2015 at 03:32:02PM -0400, Anna Schumaker wrote:
> > > I just ran some more tests comparing the directio case across
> > > different filesystem types.  These tests used three 1G files:  100%
> > > data, 100% hole, and mixed file with alternating 4k data and hole
> > > segments.  The mixed case seems to be consistently slower compared to
> > > NFS v4.1, and I'm at a loss for anything I could do to make it faster.
> > > Here are my numbers:
> > 
> > Have you tried the implementation we discussed that always returns a
> > single segment covering the whole requested range, by treating holes as
> > data if necessary when they don't cover the whole range?
> > 
> > (Also: I assume it's the same as before, but: when you post test
> > results, could you repost if necessary:
> > 
> > 	- what the actual test is
> > 	- what the hardware/software setup is on client and server
> > 
> > so that we have reproduceable results for posterity's sake.)
> > 
> > Interesting that "Mixed" is a little slower even before READ_PLUS.
> > 
> > And I guess we should really report this to ext4 people, looks like they
> > may have a bug.
> 
> FWIW, this is what I was using to test SEEK_HOLE/SEEK_DATA and map out
> holes on files on my local disk.  Might be worth checking whether the
> ext4 slowdowns are reproduceable just with something like this, to rule
> out protocol problems.

Wheel reinvention. :)

$ rm -f /mnt/scratch/bar
$ for i in `seq 20 -2 0`; do
> sudo xfs_io -f -c "pwrite $((i * 8192)) 4096" /mnt/scratch/bar
> done
.....
$ sync
$ sudo xfs_io -c "seek -ar 0" /mnt/scratch/bar
Whence  Result
DATA    0
HOLE    4096
DATA    16384
HOLE    20480
DATA    32768
HOLE    36864
DATA    49152
HOLE    53248
DATA    65536
HOLE    69632
DATA    81920
HOLE    86016
DATA    98304
HOLE    102400
DATA    114688
HOLE    118784
DATA    131072
HOLE    135168
DATA    147456
HOLE    151552
DATA    163840
HOLE    167936
$

-Dave.
-- 
Dave Chinner
david@fromorbit.com
