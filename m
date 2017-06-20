Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40708 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751763AbdFTT2O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Jun 2017 15:28:14 -0400
Date: Tue, 20 Jun 2017 15:28:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 19/19] sunrpc: Disable splice for krb5i
Message-ID: <20170620192808.GC13008@fieldses.org>
References: <20170616151535.14210.34926.stgit@klimt.1015granger.net>
 <20170616152254.14210.48071.stgit@klimt.1015granger.net>
 <20170617150705.GA27917@infradead.org>
 <A573E1EB-48DB-4E4A-B710-34914B0CF016@oracle.com>
 <20170618073438.GA15358@infradead.org>
 <20170620192449.GB13008@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170620192449.GB13008@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 20, 2017 at 03:24:49PM -0400, J. Bruce Fields wrote:
> On Sun, Jun 18, 2017 at 12:34:38AM -0700, Christoph Hellwig wrote:
> > On Sat, Jun 17, 2017 at 01:23:24PM -0400, Chuck Lever wrote:
> > > 
> > > > On Jun 17, 2017, at 11:07 AM, Christoph Hellwig <hch@infradead.org> wrote:
> > > > 
> > > > On Fri, Jun 16, 2017 at 11:22:54AM -0400, Chuck Lever wrote:
> > > >> Running a multi-threaded 8KB fio test (70/30 mix), three or four out
> > > >> of twelve of the jobs fail when using krb5i. The failure is an EIO
> > > >> on a read.
> > > > 
> > > > Just curious: what is the backing fs that you tested with?  I'd be
> > > > curious if you see this on XFS for example.
> > > 
> > > I was able to reproduce this with a tmpfs share and
> > > with an XFS share on NVMe LUNs.
> > 
> > Interesting.  XFS actually locks out all writes while doing a buffered
> > read, so we end up with two different read instance for the hash vs
> > the data, which does indeed sound dangerous.
> 
> In the bad case Chuck was seeing, we were going through
> splice_direct_to_actor(), is that a buffered read for the purposes of
> the above statement?

But, even if xfs is holding a lock across that splice operation, nfsd is
still left holding references to the pages, and they'll be checksumed
and transmitted some time later, so I don't see how xfs has much control
over the problem.

--b.
