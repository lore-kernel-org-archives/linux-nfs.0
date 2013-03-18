Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:30178 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752760Ab3CRRKG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Mar 2013 13:10:06 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@tonian.com>
CC: "Mora, Jorge" <Jorge.Mora@netapp.com>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfs: do not reset to mds if wb_offset != wb_pgbase
Date: Mon, 18 Mar 2013 17:09:27 +0000
Message-ID: <1363626566.4351.47.camel@leira.trondhjem.org>
References: <1363617532-24172-1-git-send-email-bhalevy@tonian.com>
	  <1363622128.4351.15.camel@leira.trondhjem.org> <51473F46.10401@tonian.com>
	 <1363624756.4351.30.camel@leira.trondhjem.org>
	 <514744BD.6000205@tonian.com>
In-Reply-To: <514744BD.6000205@tonian.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-03-18 at 18:45 +0200, Benny Halevy wrote:
> On 2013-03-18 18:39, Myklebust, Trond wrote:
> > On Mon, 2013-03-18 at 18:22 +0200, Benny Halevy wrote:
> >> On 2013-03-18 17:55, Myklebust, Trond wrote:
> >>> On Mon, 2013-03-18 at 16:38 +0200, Benny Halevy wrote:
> >>>> We're seeing roughly 20% of the I/Os going to the MDS
> >>>> when installing a VM over KVM in "none" caching mode (O_DIRECT).
> >>>> Instrumenting the client reveled that this is caused by buffer
> >>>> alignment vs. file offset alignment.
> >>>> Besides being a performance problem, when the MDS caches data
> >>>> this is also manifested as data corruption when data is written
> >>>> first via the MDS, then via the DS, eventually the stale data is
> >>>> read back from the MDS.
> >>>
> >>> That's why we should return the layout.
> >>
> >> We are not in this case.
> > 
> > Doh! I was thinking it was a case where we need to fence...
> > 
> > Actually, it shouldn't be needed: we will always do a _stable_ write of
> > the data before we try to read it back in from the server, so MDS
> > caching shouldn't be a problem.
> > 
> 
> Writing stable to the MDS does not solve all cases.
> The corruption we've seen happens like this:
> 
> write(A) to MDS
> write(B) to DS
> read(A) from MDS - since the MDS is caching the last data written to it.

That looks like a server bug to me. If I write the data to stable
storage in both the A and B case above, then I expect READs the MDS and
the DS to return the same data.
That's particularly true in the case of O_DIRECT reads and writes; the
server can't make assumptions as to whether or not the next client to
read the data will use the DS or the MDS.

Note that I'm happy to accept that our client may not be meeting the
requirements of "write to stable storage" here if, say, we're failing to
issue a LAYOUTCOMMIT after the WRITE(B). If that's the case, then we
need to fix that.
My beef is rather with the notion that _if_ the client meets the stable
storage criterion, then the MDS can somehow still lie to us.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
