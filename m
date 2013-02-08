Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5115 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760020Ab3BHPl2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Feb 2013 10:41:28 -0500
Date: Fri, 8 Feb 2013 10:41:18 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 2/2] nfsd: keep a checksum of the first 256 bytes of
 request
Message-ID: <20130208104118.032b1c10@tlielax.poochiereds.net>
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

Maybe, but I'm not sure it's worth the engineering effort. On my highly
unscientific test rig, the time to calculate the checksum is ~800ns
using the IP checksum routine. If we can run the checksum while we read
the data off the socket, then we might shave some of that off, but that
"feels" like small potatoes to me.

OTOH, I don't have a good way to measure what the effect of this is on
the CPU cache. Any ideas of how to measure whether that's significant?

> - Also, is 256 bytes sufficient? How far does that get you with your average WRITE compound?

I also had a look at this, and it looks like the data portion of a
WRITE compound from the Linux client starts at ~80 bytes from the
beginning of the NFS part of the frame. So with a 256 byte checksum
length, we're checksumming over about 176 bytes of write data from a
typical NFSv4.0 WRITE request.

It might not hurt to extend that out to 384 bytes or so? We have to
figure that some clients also set the tag field, so having a bit of
fudge factor for that might be reasonable.

Making it variable doesn't seem like it would buy us too much since
most calls are much smaller than 256 bytes to begin with.

-- 
Jeff Layton <jlayton@redhat.com>
