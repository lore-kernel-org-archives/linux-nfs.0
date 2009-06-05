Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:35174 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752153AbZFEVWD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2009 17:22:03 -0400
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page
 flushing
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, Krishna Kumar <krikku@gmail.com>,
        Greg Banks <gnb@fmeh.org>, Brian R Cowan <brcowan@us.ibm.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-nfs-owner@vger.kernel.org, Peter Staubach <staubach@redhat.com>
In-Reply-To: <20090605195434.GI14043@fieldses.org>
References: <1241126587.15476.62.camel@heimdal.trondhjem.org>
	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>
	 <1243615595.7155.48.camel@heimdal.trondhjem.org>
	 <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com>
	 <1243618500.7155.56.camel@heimdal.trondhjem.org>
	 <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com>
	 <20090530075756.GA27885@infradead.org> <20090601223008.GF5950@fieldses.org>
	 <20090605145450.GA11988@infradead.org>
	 <1244218328.5410.38.camel@heimdal.trondhjem.org>
	 <20090605195434.GI14043@fieldses.org>
Content-Type: text/plain
Date: Fri, 05 Jun 2009 17:21:50 -0400
Message-Id: <1244236910.5275.5.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2009-06-05 at 15:54 -0400, J. Bruce Fields wrote:
> On Fri, Jun 05, 2009 at 12:12:08PM -0400, Trond Myklebust wrote:
> > On Fri, 2009-06-05 at 10:54 -0400, Christoph Hellwig wrote:
> > > On Mon, Jun 01, 2009 at 06:30:08PM -0400, J. Bruce Fields wrote:
> > > > > NFSD stops calling ->fsync without a file struct.
> > > > > 
> > > > > I think the open file cache will help us with that, if we can extend
> > > > > it to also cache open file structs for directories.
> > > > 
> > > > Krishna Kumar--do you think that'd be a reasonable thing to do?
> > > 
> > > Btw, do you have at least the basic open files cache queue for 2.6.31?
> > > 
> > 
> > Now that _will_ badly screw up the write gathering heuristic...
> 
> How?
> 

The heuristic looks at inode->i_writecount in order to figure out how
many nfsd threads are currently trying to write to the file. The
reference to i_writecount is held by the struct file.
The problam is that if you start sharing struct file among several nfsd
threads by means of a cache, then the i_writecount will not change, and
so the heuristic fails.

While we won't miss it much in NFSv3 and v4, it may change the
performance of the few systems out there that still believe NFSv2 is the
best thing since sliced bread...

  Trond

