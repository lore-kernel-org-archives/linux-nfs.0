Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41851 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757423Ab3BGSfm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2013 13:35:42 -0500
Date: Thu, 7 Feb 2013 13:35:38 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 2/2] nfsd: keep a checksum of the first 256 bytes of
 request
Message-ID: <20130207133538.4dab321b@corrin.poochiereds.net>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91836525F@SACEXCMBX04-PRD.hq.netapp.com>
References: <1360248701-23963-1-git-send-email-jlayton@redhat.com>
	<1360248701-23963-3-git-send-email-jlayton@redhat.com>
	<DF2DA489-3D72-4DBF-8C65-1B7DA9866B63@oracle.com>
	<20130207160032.GF3222@fieldses.org>
	<4FA345DA4F4AE44899BD2B03EEEC2FA91836525F@SACEXCMBX04-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 7 Feb 2013 16:32:20 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> > Sent: Thursday, February 07, 2013 11:01 AM
> > To: Chuck Lever
> > Cc: Jeff Layton; linux-nfs@vger.kernel.org
> > Subject: Re: [PATCH v3 2/2] nfsd: keep a checksum of the first 256 bytes of
> > request
> > 
> > On Thu, Feb 07, 2013 at 10:51:02AM -0500, Chuck Lever wrote:
> > >
> > > On Feb 7, 2013, at 9:51 AM, Jeff Layton <jlayton@redhat.com> wrote:
> > >
> > > > Now that we're allowing more DRC entries, it becomes a lot easier to
> > > > hit problems with XID collisions. In order to mitigate those,
> > > > calculate the crc32 of up to the first 256 bytes of each request
> > > > coming in and store that in the cache entry, along with the total
> > > > length of the request.
> > >
> > > I'm happy to see a checksummed DRC finally become reality for the
> > > Linux NFS server.
> > >
> > > Have you measured the CPU utilization impact and CPU cache footprint
> > > of performing a CRC computation for every incoming RPC?
> > 
> > Note this is over the first 256 bytes of the request--which we're probably just
> > about to read for xdr decoding anyway.
> 
> - Would it make sense perhaps to generate the checksum as you are reading the data?

It would be nice, but that would require some significant
reengineering, AFAICT. I'm not sure this is worth doing all of that,
but maybe there's an easy way to do that that I'm not seeing.

> - Also, is 256 bytes sufficient? How far does that get you with your average WRITE compound?

Mostly that length comes from a bug we had opened a while back which was
entitled "Oracle has insisted of all the NAS vendors that for all the
dNFS IO, the first 200 bytes check-sum of every write to be validated
before the commit takes place." The bug is marked private or I'd post a
link to it here.

In any case, the title is poorly worded, but basically they were saying
we should checksum the first 200 bytes of write data as a guard against
xid collisions in the DRC. I rounded it up to 256 just because I like
powers of 2 and we needed some extra to cover the NFS header anyway.

We could always extend that, or even make it variable based on some
criteria.

> - Could the integrity checksum in RPCSEC_GSS/krbi be reused as a DRC checksum?
> 

Sadly, no. As Bruce pointed out, that has GSSAPI sequence numbers,
which change on a retransmit. Scraping the checksum out of the TCP/UDP
headers somehow is also problematic for similar reasons...

-- 
Jeff Layton <jlayton@redhat.com>
